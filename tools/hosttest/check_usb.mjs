/*
 * Run the real sync protocol, both ends, over a pipe.
 *
 * web/js/link.js talks to a stand-in serial port whose bytes are piped to
 * tools/hosttest/usb_probe, which runs calc/src/usb.c for real -- the same
 * loop, command handlers and appvar writes that run on the calculator. Replies
 * come back the same way.
 *
 * It cannot check the thing that actually broke sync for a week, which was the
 * USB layer underneath: descriptors, control requests, endpoints, interrupts.
 * That is exactly why the transport moved to a CDC serial port and srldrvce,
 * which is the one device-mode path on this platform known to work. What is
 * left above it is a byte stream, and this checks that end to end.
 *
 *   node tools/hosttest/check_usb.mjs
 */

import { spawn } from 'node:child_process';
import { mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { Calculator } from '../../web/js/link.js';
import * as lib from '../../web/js/library.js';

const HERE = dirname(fileURLToPath(import.meta.url));
const PACKET_SIZE = 64;

let failures = 0;
let checks = 0;

/* "os calls N" from the probe's stderr: how many times the reader called into
 * the operating system while the link was up. */
function osCalls(stderr) {
  const match = /os calls (\d+)/.exec(stderr || '');
  return match ? Number(match[1]) : -1;
}

function check(label, actual, expected) {
  checks++;
  const a = JSON.stringify(actual);
  const b = JSON.stringify(expected);
  if (a !== b) {
    failures++;
    console.log(`  FAIL ${label}: got ${a}, want ${b}`);
  }
}

/*
 * A stand-in for a Web Serial port, wired to the probe's stdin and stdout.
 * A byte stream in, a byte stream out -- there is nothing else to model.
 */
function makePort(child) {
  return {
    async open() {},
    async close() { child.stdin.end(); },
    getInfo() { return { usbVendorId: 0x16c0, usbProductId: 0x05e1 }; },

    readable: new ReadableStream({
      start(controller) {
        child.stdout.on('data', (data) => controller.enqueue(new Uint8Array(data)));
        child.stdout.on('end', () => {
          try { controller.close(); } catch { /* already closed */ }
        });
      },
    }),

    writable: new WritableStream({
      write(chunk) { child.stdin.write(Buffer.from(chunk)); },
    }),
  };
}

function fakeRender(text, maxWidth) {
  const width = Math.min(maxWidth, Math.max(1, text.length * 13));
  const stride = (width + 3) >> 2;
  return { width, height: 16, packed: new Uint8Array(stride * 16).fill(0x1b) };
}

function startProbe(libraryDir) {
  const args = libraryDir ? ['--lib', libraryDir] : [];
  const child = spawn(join(HERE, 'usb_probe'), args, {
    stdio: ['pipe', 'pipe', 'pipe'],
  });
  let stderr = '';
  child.stderr.on('data', (data) => { stderr += data; });
  return { child, getStderr: () => stderr };
}

async function session(libraryDir, body) {
  const { child, getStderr } = startProbe(libraryDir);
  const calculator = new Calculator(makePort(child));
  await calculator.open();

  let result;
  try {
    result = await body(calculator);
  } finally {
    child.stdin.end();
  }

  const status = await new Promise((resolve) => child.on('close', resolve));
  return { result, status, stderr: getStderr() };
}

/* --- an empty calculator answers the opening exchange --------------------- */
{
  const { result, status, stderr } = await session(null, async (calculator) => ({
    hello: await calculator.hello(),
    list: await calculator.list(),
    index: await calculator.getIndex(),
    space: await calculator.freeSpace(),
  }));

  check('hello: protocol version', result.hello.version, 1);
  check('hello: chunk size', result.hello.chunkSize, 16384);
  check('hello: reports free archive', result.hello.freeArchive > 0, true);
  check('list: empty calculator', result.list, []);
  check('index: empty calculator', result.index.length, 0);
  check('space: reports free archive', result.space > 0, true);
  check('the probe used the link correctly', status, 0);
  if (status !== 0) console.log('    probe said:', stderr.trim());

  /*
   * The read-only commands must not call the operating system at all. A binary
   * search over ti_ArchiveHasRoom inside HELLO -- two dozen calls, each walking
   * the VAT and flash -- froze the calculator outright, with or without a cable
   * attached, and nothing else here could have caught it.
   */
  check('hello/list/index/space make no OS calls', osCalls(stderr), 0);
}

/* --- a library round-trips through LIST ----------------------------------- */
{
  const directory = mkdtempSync(join(tmpdir(), 'ebooksync-usb-'));
  const index = lib.buildIndex([{
    title: '第一本书',
    strips: [
      { title: '001', slot: 3, chunkCount: 25, size: 401927,
        read: true, readAt: 1756000001, pos: 1234, layer: 1 },
      { title: '002', slot: 4, chunkCount: 9, size: 140000,
        read: false, readAt: 0, pos: 0, layer: 0 },
    ],
  }], { render: fakeRender });

  const { writeAppvar } = await import('../../web/js/tifile.js');
  writeFileSync(join(directory, 'CSLIB.8xv'), writeAppvar('CSLIB', index));

  const { result, status } = await session(directory, async (calculator) => ({
    list: await calculator.list(),
    index: await calculator.getIndex(),
  }));

  check('list: two strips', result.list.length, 2);
  check('list: first record', result.list[0],
        { slot: 3, chunkCount: 25, bytes: 401927, read: true,
          readAt: 1756000001, pos: 1234, layer: 1 });
  check('list: second record', result.list[1],
        { slot: 4, chunkCount: 9, bytes: 140000, read: false,
          readAt: 0, pos: 0, layer: 0 });
  check('index: comes back byte for byte',
        Array.from(result.index), Array.from(index));
  check('library session: link used correctly', status, 0);
}

/*
 * --- chunks survive the trip ----------------------------------------------
 *
 * Sizes spanning the staging buffer boundaries the reader reads through, and a
 * full 16 KB chunk.
 */
{
  const sizes = [1, 63, 64, 65, 511, 512, 513, 1024, 4096, 16384];
  const chunks = sizes.map((size) =>
    Uint8Array.from({ length: size }, (_, i) => (i * 37 + size) & 0xff));

  const { result, status } = await session(null, async (calculator) => {
    for (const [i, chunk] of chunks.entries()) await calculator.putChunk(7, i, chunk);
    return { count: chunks.length };
  });

  check('every chunk was accepted', result.count, sizes.length);
  check('chunk session: link used correctly', status, 0);
}

/* --- delete and bye ------------------------------------------------------- */
{
  const { result, status } = await session(null, async (calculator) => ({
    removed: await calculator.deleteStrip(200),
    bye: await calculator.bye().then(() => 'ok'),
  }));

  check('deleting a strip that is not there is not an error', result.removed, 0);
  check('bye is acknowledged', result.bye, 'ok');
  check('delete session: link used correctly', status, 0);
}

/* --- an unknown command is refused, not fatal ----------------------------- */
{
  const { result, status } = await session(null, async (calculator) => {
    let refused = null;
    try {
      await calculator.request(0x7f);
    } catch (error) {
      refused = error.status;
    }
    /* And the link still works afterwards. */
    return { refused, stillAlive: (await calculator.hello()).version };
  });

  check('unknown command is refused', result.refused, 1);
  check('the link survives it', result.stillAlive, 1);
  check('unknown-command session: link used correctly', status, 0);
}

console.log(`${checks - failures}/${checks} usb protocol checks pass`);
process.exit(failures ? 1 : 0);
