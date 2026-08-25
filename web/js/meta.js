/*
 * ebooksync.json: what has been read, what is selected, and when we last synced.
 *
 * It lives in the root of the library directory so the state travels with the
 * comics. The calculator is authoritative for read flags and scroll positions
 * -- that is where reading happens -- and this file is authoritative for
 * everything else.
 */

import { readJson, writeJson, titleFromFilename } from './fs.js';
import { DEFAULT_PRESET, LAYER_PRESETS } from './convert.js';

export const META_FILENAME = 'ebooksync.json';
export const VERSION = 1;

/* 3 MB of archive, minus room for the OS's own housekeeping and the index. */
export const DEFAULT_DEVICE_BUDGET = 2_900_000;

export const DEFAULT_SETTINGS = {
  detail: DEFAULT_PRESET,
  colors: 16,
  dither: false,
  selection: 'manual',
  autoDelete: true,
  keepRead: 2,
  maxDeviceBytes: DEFAULT_DEVICE_BUDGET,
};

export function defaultMeta() {
  return { version: VERSION, lastSync: null, settings: { ...DEFAULT_SETTINGS }, books: {} };
}

export async function load(root) {
  const raw = await readJson(root, META_FILENAME);
  if (!raw || typeof raw !== 'object') return defaultMeta();

  const meta = defaultMeta();
  meta.lastSync = typeof raw.lastSync === 'string' ? raw.lastSync : null;
  meta.settings = { ...DEFAULT_SETTINGS, ...(raw.settings || {}) };
  if (!(meta.settings.detail in LAYER_PRESETS)) meta.settings.detail = DEFAULT_PRESET;
  meta.settings.keepRead = Math.max(0, Number(meta.settings.keepRead) || 0);
  meta.settings.maxDeviceBytes = Number(meta.settings.maxDeviceBytes) || DEFAULT_DEVICE_BUDGET;
  meta.books = raw.books && typeof raw.books === 'object' ? raw.books : {};
  return meta;
}

export async function save(root, meta) {
  await writeJson(root, META_FILENAME, meta);
}

/**
 * Fold a fresh directory scan into the metadata.
 *
 * New strips get a slot; strips whose file has vanished are dropped, along with
 * books that end up empty. Slots are stable identities -- they name the appvars
 * on the calculator -- so an existing one is never reassigned.
 */
export function reconcile(meta, books) {
  const used = new Set();
  for (const book of Object.values(meta.books)) {
    for (const strip of Object.values(book.strips || {})) {
      if (Number.isInteger(strip.id)) used.add(strip.id);
    }
  }

  const nextSlot = () => {
    for (let slot = 0; slot < 256; slot++) {
      if (!used.has(slot)) {
        used.add(slot);
        return slot;
      }
    }
    throw new Error('all 256 strip slots are in use; remove some strips from the library');
  };

  const merged = {};
  for (const book of books) {
    const previous = meta.books[book.name] || {};
    const strips = {};

    for (const strip of book.strips) {
      const before = (previous.strips || {})[strip.name] || {};
      strips[strip.name] = {
        id: Number.isInteger(before.id) ? before.id : nextSlot(),
        selected: before.selected === true,
        read: before.read === true,
        readAt: before.readAt || null,
        pos: before.pos || 0,
        layer: before.layer || 0,
        srcHash: before.srcHash || null,
        srcSize: strip.size,
        onCalc: before.onCalc === true,
        chunkCount: before.chunkCount || 0,
        deviceBytes: before.deviceBytes || 0,
      };
    }

    if (Object.keys(strips).length) merged[book.name] = { strips };
  }

  meta.books = merged;
  return meta;
}

/** Every strip as a flat list in reading order, with its book and filename. */
export function flatten(meta, books) {
  const out = [];
  for (const book of books) {
    const entry = meta.books[book.name];
    if (!entry) continue;
    for (const strip of book.strips) {
      const state = entry.strips[strip.name];
      if (!state) continue;
      out.push({
        book: book.name,
        file: strip.name,
        title: titleFromFilename(strip.name),
        handle: strip.handle,
        state,
      });
    }
  }
  return out;
}

/**
 * Fold the calculator's own state back in.
 *
 * The calculator wins on `read`, `readAt`, `pos` and `layer`: those changed
 * because somebody read the comic. Everything else stays as the computer has
 * it. `onCalc` is rebuilt from what the calculator actually reports rather than
 * what we believe, so an interrupted sync self-corrects.
 */
export function mergeFromCalculator(meta, resident) {
  const bySlot = new Map(resident.map((strip) => [strip.slot, strip]));

  for (const book of Object.values(meta.books)) {
    for (const state of Object.values(book.strips)) {
      const live = bySlot.get(state.id);
      if (!live) {
        state.onCalc = false;
        continue;
      }
      state.onCalc = true;
      state.chunkCount = live.chunkCount;
      state.deviceBytes = live.bytes;
      state.pos = live.pos;
      state.layer = live.layer;
      if (live.read && !state.read) {
        state.read = true;
        state.readAt = live.readAt
          ? new Date(live.readAt * 1000).toISOString()
          : new Date().toISOString();
      } else if (live.read) {
        state.read = true;
      }
    }
  }
  return meta;
}

/** Read strips, most recently read first; ties fall back to library order. */
export function readOrder(strips) {
  return strips
    .filter((strip) => strip.state.read)
    .sort((a, b) => {
      const at = Date.parse(a.state.readAt || 0) || 0;
      const bt = Date.parse(b.state.readAt || 0) || 0;
      return bt - at;
    });
}
