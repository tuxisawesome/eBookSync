/*
 * Run the real sync protocol, both ends, over a pipe.
 *
 * web/js/usb.js talks to a fake USBDevice that frames its transfers into 64-byte
 * packets and pipes them to tools/hosttest/usb_probe, which runs calc/src/usb.c
 * for real -- the same scheduling loop, command handlers and appvar writes that
 * run on the calculator. Replies come back the same way.
 *
 * This exists because two bugs got all the way to hardware:
 *
 *   - the reader waited for the next request with a *blocking* transfer, so the
 *     calculator stopped scanning its keypad the moment it was plugged in and
 *     could only be recovered with the reset button;
 *   - the computer sent a request header and its payload in one transfer, so
 *     both landed in one USB packet while the reader read them separately --
 *     everything past the header was silently dropped by the endpoint.
 *
 * The wire model counts that second failure and the probe exits non-zero on it,
 * so neither can come back unnoticed.
 *
 *   node tools/hosttest/check_usb.mjs
 */

import { spawn } from 'node:child_process';
import { mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { Calculator } from '../../web/js/usb.js';
import * as lib from '../../web/js/library.js';

const HERE = dirname(fileURLToPath(import.meta.url));
const PACKET_SIZE = 64;

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

/*
 * A USBDevice whose transfers become framed packets on the probe's stdin, and
 * whose reads come from its stdout. Splitting into packets here is the whole
 * point: it is what makes an over-long transfer visible to the model.
 */
class PipeDevice {
  constructor(child) {
    this.child = child;
    this.buffered = [];
    this.waiting = null;
    this.closed = false;

    child.stdout.on('data', (data) => {
      this.buffered.push(...data);
      this.#pump();
    });
    child.stdout.on('end', () => {
      this.closed = true;
      this.#pump();
    });
  }

  #pump() {
    while (this.waiting) {
      if (this.buffered.length < 2) break;
      const length = this.buffered[0] | (this.buffered[1] << 8);
      if (this.buffered.length < 2 + length) break;
      this.buffered.splice(0, 2);
      const packet = this.buffered.splice(0, length);
      const resolve = this.waiting;
      this.waiting = null;
      resolve(Uint8Array.from(packet));
    }
    if (this.waiting && this.closed) {
      const resolve = this.waiting;
      this.waiting = null;
      resolve(null);
    }
  }

  #nextPacket() {
    return new Promise((resolve) => {
      this.waiting = resolve;
      this.#pump();
    });
  }

  async open() {}
  async close() { this.child.stdin.end(); }
  async selectConfiguration() {}
  async claimInterface() {}
  async releaseInterface() {}

  get configuration() { return {}; }

  async transferOut(endpoint, data) {
    const bytes = data instanceof Uint8Array ? data : new Uint8Array(data);
    let sent = 0;
    do {
      const packet = bytes.subarray(sent, sent + PACKET_SIZE);
      const frame = Buffer.alloc(2 + packet.length);
      frame.writeUInt16LE(packet.length, 0);
      Buffer.from(packet).copy(frame, 2);
      this.child.stdin.write(frame);
      sent += PACKET_SIZE;
    } while (sent < bytes.length);
    return { status: 'ok', bytesWritten: bytes.length };
  }

  async transferIn(endpoint, length) {
    const packet = await this.#nextPacket();
    if (!packet) return { status: 'stall', data: new DataView(new ArrayBuffer(0)) };
    if (packet.length > length) {
      failures++;
      console.log(`  FAIL babble: ${packet.length} byte packet into a ${length} byte read`);
    }
    return { status: 'ok', data: new DataView(packet.buffer, packet.byteOffset, packet.length) };
  }
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
  const calculator = new Calculator(new PipeDevice(child));

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
  check('no endpoint overflows', status, 0);
  if (status !== 0) console.log('    probe said:', stderr.trim());
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
  check('library session: no endpoint overflows', status, 0);
}

/*
 * --- chunks survive the trip ----------------------------------------------
 *
 * Sizes chosen to catch the packet edges: one byte, exactly one packet, exactly
 * one staging buffer, a size that lands on a packet boundary with no short
 * packet to end it, and a full 16 KB chunk.
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
  check('chunk session: no endpoint overflows', status, 0);
}

/* --- delete and bye ------------------------------------------------------- */
{
  const { result, status } = await session(null, async (calculator) => ({
    removed: await calculator.deleteStrip(200),
    bye: await calculator.bye().then(() => 'ok'),
  }));

  check('deleting a strip that is not there is not an error', result.removed, 0);
  check('bye is acknowledged', result.bye, 'ok');
  check('delete session: no endpoint overflows', status, 0);
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
  check('unknown-command session: no endpoint overflows', status, 0);
}

console.log(`${checks - failures}/${checks} usb protocol checks pass`);
process.exit(failures ? 1 : 0);
