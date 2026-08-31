/*
 * Pushing a new build of eBookSync to the calculator.
 *
 * The builds are static files next to this page -- `web/comics/COMICS.8xp`,
 * `web/comics/CSUP.8xp` and `web/comics/build.json` -- so GitHub Pages serves them
 * same-origin with no server and no CORS. `tools/stage_update.sh` puts them
 * there.
 *
 * What goes over the link is the program body inside the .8xp, not the file
 * wrapper: the calculator creates the variable itself. See calc/src/update.h
 * for why there are two programs and which one installs which.
 */

import { UPDATE_CHUNK_SIZE, UPDATE_TARGET } from './link.js';
import { readVariable } from './tifile.js';

export const CATALOGUE = 'comics/build.json';

/**
 * CRC-32, the ordinary reflected one, matching calc/src/crc32.c.
 *
 * A corrupt comic is a smeared page; a corrupt program is a calculator that
 * will not start the reader. This is the one thing in the protocol worth
 * checksumming, and both ends have to agree on how.
 */
export function crc32(bytes) {
  let crc = 0xffffffff;
  for (let i = 0; i < bytes.length; i++) {
    crc ^= bytes[i];
    for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
  }
  return (crc ^ 0xffffffff) >>> 0;
}

export function chunksOf(body) {
  const chunks = [];
  for (let at = 0; at < body.length; at += UPDATE_CHUNK_SIZE) {
    chunks.push(body.subarray(at, Math.min(at + UPDATE_CHUNK_SIZE, body.length)));
  }
  return chunks;
}

function imageFrom(bytes, expectedName) {
  const variable = readVariable(bytes);
  if (variable.name !== expectedName) {
    throw new Error(`expected ${expectedName}.8xp, but the file holds ${variable.name}`);
  }
  const body = variable.body;
  return { name: variable.name, body, chunks: chunksOf(body), crc: crc32(body) };
}

/**
 * Load the staged builds, or null when there are none to load.
 *
 * `fetch` of a relative path fails from `file://`, so a page opened straight
 * off disk simply has no updates to offer rather than an error to report. That
 * is the honest answer: the builds are served, not read.
 */
export async function loadCatalogue(base = '') {
  let manifest;
  try {
    const response = await fetch(`${base}${CATALOGUE}`, { cache: 'no-cache' });
    if (!response.ok) return null;
    manifest = await response.json();
  } catch {
    return null;
  }

  if (!manifest || typeof manifest.build !== 'number') return null;

  const [reader, updater] = await Promise.all([
    fetch(`${base}comics/COMICS.8xp`, { cache: 'no-cache' }).then((r) => r.arrayBuffer()),
    fetch(`${base}comics/CSUP.8xp`, { cache: 'no-cache' }).then((r) => r.arrayBuffer()),
  ]);

  return {
    build: manifest.build,
    reader: imageFrom(new Uint8Array(reader), 'COMICS'),
    updater: imageFrom(new Uint8Array(updater), 'CSUP'),
  };
}

/**
 * What this calculator needs, given what HELLO said.
 *
 * The updater is pushed whenever the reader is, and whenever the calculator has
 * none. It is a seven-kilobyte program with no state of its own, so keeping it
 * in step by simply always sending it costs less than tracking its version
 * would -- and it means the only file that ever has to be installed by hand is
 * COMICS.8xp: a calculator with no updater is given one on its first sync.
 */
export function plan(hello, catalogue) {
  if (!catalogue || !hello) {
    return { reader: false, updater: false, armed: false, build: 0 };
  }

  /*
   * An armed update is done, not missing.
   *
   * A reader update is armed rather than installed, so HELLO goes on reporting
   * the build that is *running* until prgmCSUP has been run. Comparing only
   * those two numbers means the page offers to send a build it has already
   * sent, every time, for ever -- which reads as "still out of date by one" and
   * as though the update had not worked.
   *
   * What is armed still has to be the build we would send: one armed from an
   * earlier deploy is genuinely out of date and should be replaced.
   */
  const armed = Boolean(hello.updateArmed) && hello.armedBuild === catalogue.build;
  const behind = hello.build !== catalogue.build;

  return {
    build: catalogue.build,
    from: hello.build,
    armed,
    reader: behind && !armed,
    /* No point pushing the updater for an update that is already waiting. */
    updater: (behind && !armed) || !hello.hasUpdater,
  };
}

async function push(calculator, target, image, build, onProgress) {
  await calculator.updateBegin(target, {
    build,
    bytes: image.body.length,
    chunks: image.chunks.length,
    crc: image.crc,
  });

  for (let i = 0; i < image.chunks.length; i++) {
    await calculator.updateChunk(target, i, image.chunks[i]);
    onProgress(i + 1, image.chunks.length);
  }

  /* The calculator checksums what it stored before anything is installed or
   * armed. A mismatch throws, and nothing on the calculator has changed. */
  await calculator.updateEnd(target);
}

/**
 * Send everything `plan` asked for.
 *
 * The updater goes first and is installed by the reader as it arrives, so that
 * if the session dies between the two, what is left behind is a calculator with
 * a current updater and its old reader -- which still works, and can still be
 * updated next time. The other order would leave an armed reader update and an
 * updater too old to be trusted with it.
 */
export async function execute(calculator, catalogue, wanted, { onStatus = () => {} } = {}) {
  const done = { updater: false, reader: false };

  if (wanted.updater) {
    onStatus('Sending the updater…');
    await push(calculator, UPDATE_TARGET.UPDATER, catalogue.updater, wanted.build,
               (n, of) => onStatus(`Sending the updater… ${n}/${of}`));
    done.updater = true;
  }

  if (wanted.reader) {
    onStatus('Sending the reader…');
    await push(calculator, UPDATE_TARGET.READER, catalogue.reader, wanted.build,
               (n, of) => onStatus(`Sending the reader… ${n}/${of}`));
    done.reader = true;
  }

  return done;
}
