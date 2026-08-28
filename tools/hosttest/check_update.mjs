/*
 * The self-update, both halves.
 *
 * The wire half is in check_usb.mjs -- chunks arriving, checksums verified,
 * nothing armed when they fail. This is the other half: what prgmEOSUP does
 * when the user runs it, driven through tools/hosttest/update_probe against the
 * real calc/src/update.c.
 *
 * It matters more than the line count suggests. The wire half failing costs a
 * retry; this half failing replaces prgmEOS with something that does not run,
 * on a calculator whose only way back is a cable and TI Connect.
 *
 *   node tools/hosttest/check_update.mjs
 */

import { execFileSync } from 'node:child_process';
import { existsSync, mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { writeAppvar } from '../../web/js/tifile.js';
import { readVariable } from '../../web/js/tifile.js';
import * as update from '../../web/js/update.js';

const HERE = dirname(fileURLToPath(import.meta.url));

let failures = 0;
let checks = 0;

function check(label, actual, expected) {
  checks++;
  const a = JSON.stringify(actual);
  const b = JSON.stringify(expected);
  if (a !== b) {
    failures++;
    console.log(`  FAIL ${label}: got ${a}, want ${b}`);
  }
}

/* The manifest calc/src/update.c writes. Built here independently, so the two
 * are compared rather than one being read back through the other. */
function manifestBytes({ target, build, bytes, chunks, crc }) {
  const out = new Uint8Array(20);
  const view = new DataView(out.buffer);
  for (let i = 0; i < 4; i++) out[i] = 'EUP1'.charCodeAt(i);
  out[4] = 1;
  out[5] = target;
  view.setUint16(6, build, true);
  view.setUint32(8, bytes, true);
  view.setUint16(12, chunks, true);
  view.setUint32(14, crc, true);
  return out;
}

function chunkName(index) {
  return `EOSU${index.toString(16).toUpperCase().padStart(2, '0')}`;
}

/**
 * Lay out a calculator holding a pending update, run the updater, and report.
 *
 * `damage` corrupts a byte of the image after the manifest was written, which
 * is what a flash fault or an interrupted sync looks like from here.
 */
function runUpdater(body, { build = 7, target = 0, damage = false, omitChunk = -1 } = {}) {
  const directory = mkdtempSync(join(tmpdir(), 'eos-updater-in-'));
  const out = mkdtempSync(join(tmpdir(), 'eos-updater-out-'));

  const chunks = update.chunksOf(body);
  const manifest = manifestBytes({
    target, build, bytes: body.length, chunks: chunks.length, crc: update.crc32(body),
  });
  writeFileSync(join(directory, 'EOSUPD.8xv'), writeAppvar('EOSUPD', manifest));

  chunks.forEach((chunk, i) => {
    if (i === omitChunk) return;
    const stored = Uint8Array.from(chunk);
    if (damage && i === 0) stored[0] ^= 0xff;
    writeFileSync(join(directory, `${chunkName(i)}.8xv`), writeAppvar(chunkName(i), stored));
  });

  let status = 0;
  let stdout = '';
  try {
    stdout = execFileSync(join(HERE, 'update_probe'), [directory, out], { encoding: 'utf8' });
  } catch (error) {
    status = error.status;
    stdout = error.stdout || '';
  }

  return {
    status,
    said: stdout.trim().split('\n').pop(),
    installed: existsSync(join(out, 'EOS.bin')) ? readFileSync(join(out, 'EOS.bin')) : null,
    manifestLeft: existsSync(join(out, 'EOSUPD.bin')),
    chunksLeft: chunks.some((_, i) => existsSync(join(out, `${chunkName(i)}.bin`))),
  };
}

function sample(bytes) {
  const body = new Uint8Array(bytes);
  for (let i = 0; i < body.length; i++) body[i] = (i * 31 + 7) & 0xff;
  return body;
}

/* --- the ordinary case ----------------------------------------------------- */
{
  const body = sample(34567);
  const result = runUpdater(body);

  check('a good update installs', result.said, 'installed');
  check('the reader is exactly the image', Buffer.compare(result.installed, Buffer.from(body)), 0);
  check('spanning three chunks', update.chunksOf(body).length, 3);
  check('the manifest is cleared up', result.manifestLeft, false);
  check('the chunks are cleared up', result.chunksLeft, false);
  check('it reports success', result.status, 0);
}

/* --- a single flipped bit must not reach prgmEOS --------------------------- */
{
  const result = runUpdater(sample(20000), { damage: true });

  check('a damaged image is refused', result.said, 'damaged');
  check('and nothing is installed', result.installed, null);
  check('and it is thrown away rather than left to be retried', result.manifestLeft, false);
  check('including its chunks', result.chunksLeft, false);
  check('it reports failure', result.status, 1);
}

/* --- a sync that died partway leaves a hole -------------------------------- */
{
  const result = runUpdater(sample(34567), { omitChunk: 1 });

  check('a missing chunk is caught', result.said, 'damaged');
  check('and nothing is installed', result.installed, null);
}

/* --- an updater update is not this program's business ---------------------- */
{
  const result = runUpdater(sample(7000), { target: 1 });

  check('an updater update is left alone', result.said, 'not for the reader');
  check('nothing is installed', result.installed, null);
  check('and the manifest is left where the reader will find it', result.manifestLeft, true);
}

/* --- the real staged build ------------------------------------------------- */
{
  const staged = join(HERE, '..', '..', 'web', 'eos', 'EOS.8xp');
  if (!existsSync(staged)) {
    console.log('  SKIP real build: run tools/stage_update.sh first');
  } else {
    const variable = readVariable(readFileSync(staged));
    const result = runUpdater(variable.body, { build: 99 });

    check('the real reader installs', result.said, 'installed');
    check('byte for byte', Buffer.compare(result.installed, Buffer.from(variable.body)), 0);
  }
}

console.log(`${checks - failures}/${checks} updater checks pass`);
process.exit(failures ? 1 : 0);
