/*
 * Deciding what to send, and sending it.
 *
 * Planning is deliberately separate from execution: the page shows the plan
 * first -- what will be pushed, what will be deleted -- because a sync deletes
 * comics off the calculator and that should never be a surprise.
 */

import * as cache from './cache.js';
import * as library from './library.js';
import { flatten, readOrder } from './meta.js';
import { hashFile } from './fs.js';

/** Runs conversions in workers, one per core up to a sensible ceiling. */
export class ConversionPool {
  constructor(size = Math.min(4, navigator.hardwareConcurrency || 2)) {
    this.size = Math.max(1, size);
    this.workers = [];
    this.idle = [];
    this.queue = [];
    this.pending = new Map();
    this.nextId = 1;
  }

  #spawn() {
    const worker = new Worker(new URL('./worker/convert.js', import.meta.url), { type: 'module' });
    worker.onmessage = (event) => {
      const { id, result, error, progress } = event.data;
      const job = this.pending.get(id);
      if (!job) return;

      if (progress) {
        if (job.onProgress) job.onProgress(progress);
        return;
      }
      this.pending.delete(id);
      this.idle.push(worker);
      if (error) job.reject(new Error(error));
      else job.resolve(result);
      this.#drain();
    };
    this.workers.push(worker);
    return worker;
  }

  #drain() {
    while (this.queue.length && (this.idle.length || this.workers.length < this.size)) {
      const worker = this.idle.pop() || this.#spawn();
      const job = this.queue.shift();
      this.pending.set(job.id, job);
      worker.postMessage({ id: job.id, blob: job.blob, settings: job.settings });
    }
  }

  convert(blob, settings, onProgress) {
    return new Promise((resolve, reject) => {
      this.queue.push({ id: this.nextId++, blob, settings, onProgress, resolve, reject });
      this.#drain();
    });
  }

  terminate() {
    for (const worker of this.workers) worker.terminate();
    this.workers = [];
    this.idle = [];
    this.queue = [];
    this.pending.clear();
  }
}

/**
 * Work out what this sync would do.
 *
 * `resident` is what the calculator reported. Nothing here touches the
 * calculator or the disk -- it is pure enough to show as a preview.
 *
 * `indexStale` says the order or titles have changed since the calculator was
 * last written, which is a reason to sync even when no bytes need moving.
 * The caller works it out, because doing so needs a canvas to render titles.
 */
export function plan(meta, books, resident, { freeArchive = null, indexStale = false } = {}) {
  const strips = flatten(meta, books);
  const bySlot = new Map(resident.map((strip) => [strip.slot, strip]));
  const { autoDelete, keepRead, selection, maxDeviceBytes } = meta.settings;

  /* Read strips are dropped oldest-read first, keeping the most recent few so
   * you can still flip back to what you just finished. */
  const keep = new Set();
  if (autoDelete) {
    for (const strip of readOrder(strips).slice(0, keepRead)) keep.add(strip.state.id);
  }

  const deletes = [];
  if (autoDelete) {
    for (const strip of strips) {
      if (strip.state.read && bySlot.has(strip.state.id) && !keep.has(strip.state.id)) {
        deletes.push(strip);
      }
    }
  }

  /* Slots on the calculator the library no longer knows about: leftovers from a
   * removed file or an interrupted sync. They are always safe to reclaim. */
  const known = new Set(strips.map((strip) => strip.state.id));
  const orphans = resident.filter((strip) => !known.has(strip.slot));

  const wanted = selection === 'auto'
    ? strips.filter((strip) => !strip.state.read)
    : strips.filter((strip) => strip.state.selected);

  const deleting = new Set(deletes.map((strip) => strip.state.id));
  const candidates = wanted.filter(
    (strip) => !bySlot.has(strip.state.id) || deleting.has(strip.state.id),
  );

  /* Budget against what will actually be free once the deletes have happened. */
  let residentBytes = resident
    .filter((strip) => !deleting.has(strip.slot)
      && !orphans.some((orphan) => orphan.slot === strip.slot))
    .reduce((sum, strip) => sum + strip.bytes, 0);

  const budget = freeArchive === null
    ? maxDeviceBytes
    : Math.min(maxDeviceBytes, residentBytes + freeArchive);

  const pushes = [];
  const skipped = [];
  for (const strip of candidates) {
    /* Before conversion the size is a guess from the last time this strip was
     * converted, or from the source file. It is refined once it is converted. */
    const estimate = strip.state.deviceBytes || estimateBytes(strip, meta.settings);
    if (residentBytes + estimate > budget) {
      skipped.push({ strip, estimate });
      continue;
    }
    residentBytes += estimate;
    pushes.push(strip);
  }

  return {
    strips, deletes, orphans, pushes, skipped, indexStale,
    projectedBytes: residentBytes,
    budget,
    empty: !pushes.length && !deletes.length && !orphans.length && !indexStale,
  };
}

/* Bytes per source byte, measured across the sample strip at each preset. Only
 * used before a strip has ever been converted; the real number replaces it as
 * soon as we have one. */
const ESTIMATE_RATIO = { fit: 0.07, 'fit+1.5x': 0.2, 'fit+2x': 0.28 };

export function estimateBytes(strip, settings) {
  const ratio = ESTIMATE_RATIO[settings.detail] ?? 0.2;
  return Math.round((strip.state.srcSize || 1_500_000) * ratio);
}

/**
 * Carry out a plan.
 *
 * Deletes come first so the space they free is available to the pushes, and
 * each chunk is acknowledged on its own, so an interrupted sync resumes by
 * re-listing and sending whatever is missing rather than starting over.
 */
export async function execute(calculator, meta, books, currentPlan, {
  pool,
  onStatus = () => {},
  onProgress = () => {},
  signal = null,
} = {}) {
  const aborted = () => signal && signal.aborted;

  for (const strip of currentPlan.deletes) {
    if (aborted()) return { aborted: true };
    onStatus(`Removing ${strip.title}`);
    await calculator.deleteStrip(strip.state.id);
    strip.state.onCalc = false;
    strip.state.selected = false;      /* so cleanup does not bounce it back */
    strip.state.chunkCount = 0;
    strip.state.deviceBytes = 0;
  }

  for (const orphan of currentPlan.orphans) {
    if (aborted()) return { aborted: true };
    onStatus(`Removing an unknown strip in slot ${orphan.slot}`);
    await calculator.deleteStrip(orphan.slot);
  }

  let index = 0;
  for (const strip of currentPlan.pushes) {
    if (aborted()) return { aborted: true };
    index++;

    onStatus(`Converting ${strip.title} (${index}/${currentPlan.pushes.length})`);
    const file = await strip.handle.getFile();
    if (!strip.state.srcHash) strip.state.srcHash = await hashFile(file);

    const key = cache.cacheKey(strip.state.srcHash, meta.settings);
    let container = await cache.get(key);
    if (!container) {
      container = await pool.convert(file, meta.settings, (progress) => {
        onProgress({ strip, phase: 'convert', ...progress });
      });
      await cache.put(key, container);
    }

    onStatus(`Sending ${strip.title} (${index}/${currentPlan.pushes.length})`);
    for (let chunk = 0; chunk < container.chunks.length; chunk++) {
      if (aborted()) return { aborted: true };
      await calculator.putChunk(strip.state.id, chunk, container.chunks[chunk]);
      onProgress({
        strip, phase: 'send', chunk: chunk + 1, chunks: container.chunks.length,
      });
    }

    strip.state.onCalc = true;
    strip.state.chunkCount = container.chunks.length;
    strip.state.deviceBytes = container.totalBytes;
  }

  onStatus('Updating the index');
  await calculator.putIndex(buildIndexFor(meta, books));
  meta.lastSync = new Date().toISOString();

  return { aborted: false };
}

/**
 * The CSLIB describing exactly what is resident now.
 *
 * Books and strips go in in the order stored in ebooksync.json, and the reader
 * draws them in the order it finds them -- that is the whole mechanism by which
 * the order you arrange here is the order you get on the calculator.
 *
 * `render` is injectable so this can be built where there is no canvas; the
 * host tests use a deterministic stand-in.
 */
export function buildIndexFor(meta, books, { render = undefined } = {}) {
  const strips = flatten(meta, books);
  const grouped = new Map();

  for (const strip of strips) {
    if (!strip.state.onCalc) continue;
    if (!grouped.has(strip.book)) grouped.set(strip.book, []);
    grouped.get(strip.book).push({
      title: strip.title,
      slot: strip.state.id,
      chunkCount: strip.state.chunkCount,
      size: strip.state.deviceBytes,
      read: strip.state.read,
      readAt: strip.state.readAt ? Math.floor(Date.parse(strip.state.readAt) / 1000) : 0,
      pos: strip.state.pos,
      layer: strip.state.layer,
    });
  }

  return library.buildIndex(
    [...grouped.entries()].map(([title, bookStrips]) => ({ title, strips: bookStrips })),
    render ? { render } : {},
  );
}
