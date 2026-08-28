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

import { execFileSync, spawn } from 'node:child_process';
import { existsSync, mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  Calculator, LIBRARY, PROTOCOL_VERSION, STATUS, UPDATE_TARGET, ProtocolError,
} from '../../web/js/link.js';
import * as update from '../../web/js/update.js';
import { writeAppvar } from '../../web/js/tifile.js';
import { chunkName } from '../../web/js/convert.js';
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

function startProbe(libraryDir, extra = []) {
  const args = (libraryDir ? ['--lib', libraryDir] : []).concat(extra);
  const child = spawn(join(HERE, 'usb_probe'), args, {
    stdio: ['pipe', 'pipe', 'pipe'],
  });
  let stderr = '';
  child.stderr.on('data', (data) => { stderr += data; });
  return { child, getStderr: () => stderr };
}

async function session(libraryDir, body, extra = []) {
  const { child, getStderr } = startProbe(libraryDir, extra);
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

  check('hello: protocol version', result.hello.version, PROTOCOL_VERSION);
  check('hello: reports a build number', result.hello.build > 0, true);
  check('hello: compatible with this page', result.hello.compatible, true);
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
  const directory = mkdtempSync(join(tmpdir(), 'eos-usb-'));
  const index = lib.buildIndex([{
    title: '第一本书',
    strips: [
      { title: '001', slot: 3, chunkCount: 25, size: 401927,
        read: true, readAt: 1756000001, pos: 1234, layer: 1 },
      { title: '002', slot: 4, chunkCount: 9, size: 140000,
        read: false, readAt: 0, pos: 0, layer: 0 },
    ],
  }], { render: fakeRender });

  writeFileSync(join(directory, `${lib.NAME}.8xv`), writeAppvar(lib.NAME, index));

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
  check('the link survives it', result.stillAlive, PROTOCOL_VERSION);
  check('unknown-command session: link used correctly', status, 0);
}

/*
 * --- a defragment in the middle of a sync ---------------------------------
 *
 * The OS defragments the archive when it runs out of room. It asks the user
 * first, so it takes as long as it takes, and it moves every archived variable,
 * which invalidates every pointer the reader is holding. Left unhandled the
 * computer times out and abandons a strip half-written; handled badly, the
 * reader carries on reading from where the index used to be.
 */
{
  const chunk = Uint8Array.from({ length: 4096 }, (_, i) => i & 0xff);
  let busy = 0;

  const { result, status } = await session(null, async (calculator) => {
    calculator.onBusy = () => { busy++; };

    /* The forced collect fires on this chunk's archive. */
    await calculator.putChunk(9, 0, chunk);

    /* The link must still work afterwards, with everything re-fetched. */
    return {
      hello: (await calculator.hello()).version,
      list: (await calculator.list()).length,
      index: (await calculator.getIndex()).length,
    };
  }, ['--gc']);

  check('a chunk written across a defragment is accepted', result.hello,
        PROTOCOL_VERSION);
  check('the computer was told to keep waiting', busy >= 1, true);
  check('the link still works afterwards', result.list >= 0, true);
  check('cached pointers were refetched, not reused', result.index, 0);
  check('defragment session: link used correctly', status, 0);
}


/* --- the device block belongs to the calculator ---------------------------- */
/*
 * The password lives in the last 64 bytes of the index header, so that deleting
 * it to get past the prompt also destroys the table of contents. That only
 * works if the block outlives everything the computer does to the index -- and
 * the computer replaces the whole variable on every push, sending zeros there
 * because it has no idea the block exists.
 *
 * Getting this wrong unlocks the calculator silently, which is exactly the kind
 * of bug nobody notices until it matters.
 */
function libraryWith(titles, libraryId) {
  return lib.buildIndex([{
    title: 'book',
    strips: titles.map((title, i) => ({
      title, slot: i, chunkCount: 1, size: 1000,
      read: false, readAt: 0, pos: 0, layer: 0,
    })),
  }], { render: fakeRender, libraryId });
}

function deviceBlockOf(bytes) {
  return Array.from(bytes.slice(lib.DEVICE_OFFSET, lib.DEVICE_OFFSET + lib.DEVICE_SIZE));
}

{
  const libraryId = new Uint8Array(16).fill(0xa5);

  /* Stand in for a password the calculator has set. */
  const device = new Uint8Array(lib.DEVICE_SIZE);
  for (let i = 0; i < device.length; i++) device[i] = (i * 7 + 1) & 0xff;

  const seed = () => {
    const directory = mkdtempSync(join(tmpdir(), 'eos-device-'));
    const index = libraryWith(['001', '002'], libraryId);
    index.set(device, lib.DEVICE_OFFSET);
    writeFileSync(join(directory, `${lib.NAME}.8xv`), writeAppvar(lib.NAME, index));

    /* The chunks the index points at, so a reset has something to delete. */
    for (const slot of [0, 1]) {
      const name = chunkName(slot, 0);
      writeFileSync(join(directory, `${name}.8xv`), writeAppvar(name, new Uint8Array(64)));
    }
    return directory;
  };

  /* --- INDEX_PUT must splice the block back in --- */
  {
    const directory = seed();
    const replacement = libraryWith(['001', '002', '003'], libraryId);
    check('the page sends zeros in the device block',
          deviceBlockOf(replacement).every((b) => b === 0), true);

    const { result, status } = await session(directory, async (calculator) => {
      const before = await calculator.getIndex();
      await calculator.putIndex(replacement);
      return { before, after: await calculator.getIndex() };
    }, ['--save', directory]);

    check('INDEX_GET zeroes the device block',
          deviceBlockOf(result.before).every((b) => b === 0), true);
    check('INDEX_GET returns the rest of the header intact',
          Array.from(result.before.slice(0, lib.DEVICE_OFFSET)),
          Array.from(libraryWith(['001', '002'], libraryId).slice(0, lib.DEVICE_OFFSET)));
    check('INDEX_GET zeroes it after a push too',
          deviceBlockOf(result.after).every((b) => b === 0), true);
    check('INDEX_GET reports the pushed index', result.after.length, replacement.length);

    const stored = readFileSync(join(directory, `${lib.NAME}.bin`));
    check('INDEX_PUT carried the device block across',
          deviceBlockOf(stored), Array.from(device));
    check('INDEX_PUT stored the computer\'s index otherwise',
          Array.from(stored.slice(0, lib.DEVICE_OFFSET)),
          Array.from(replacement.slice(0, lib.DEVICE_OFFSET)));
    check('device block session: link used correctly', status, 0);
  }

  /* --- erasing the library must not erase the password with it --- */
  {
    const directory = seed();
    const { result, status } = await session(directory, async (calculator) => ({
      before: (await calculator.hello(libraryId)).library,
      removed: await calculator.resetLibrary(),
      after: await calculator.getIndex(),
      /* A calculator that has been erased is empty to anyone, not "somebody
       * else's" -- the id is zeroed, and an all-zero id means no identity. */
      library: (await calculator.hello(new Uint8Array(16))).library,
    }), ['--save', directory]);

    check('reset: the library was recognised first', result.before, LIBRARY.SAME);
    check('reset: strips were removed', result.removed, 2);
    check('reset: the index survives, emptied', result.after.length, lib.HEADER_SIZE);
    check('reset: it reads as empty to any computer', result.library, LIBRARY.EMPTY);

    const stored = readFileSync(join(directory, `${lib.NAME}.bin`));
    check('reset: the index was emptied, not deleted', stored.length, lib.HEADER_SIZE);
    check('reset: the device block survived', deviceBlockOf(stored), Array.from(device));
    check('reset session: link used correctly', status, 0);
  }
}


/* --- pushing a new build ---------------------------------------------------- */
/*
 * A CE program runs in place inside its own variable, so it cannot overwrite
 * itself. eOS gets round that with two programs that install each other: the
 * reader installs EOSUP as it arrives, and EOSUP installs the reader later.
 *
 * What this can check is the half that goes over the wire -- that the chunks
 * land, that the CRC is verified before anything is replaced, and that an
 * updater update really does replace prgmEOSUP during the session. What it
 * cannot check is prgmEOSUP running on hardware, which is the other half.
 */
function fakeImage(bytes) {
  const body = new Uint8Array(bytes);
  for (let i = 0; i < body.length; i++) body[i] = (i * 31 + 7) & 0xff;
  return { body, chunks: update.chunksOf(body), crc: update.crc32(body) };
}

function describe(image, build) {
  return { build, bytes: image.body.length, chunks: image.chunks.length, crc: image.crc };
}

{
  /* Two chunks and a bit, so the "every chunk but the last is full" rule is
   * actually exercised rather than assumed. */
  const reader = fakeImage(34567);

  check('an image splits into full chunks and a remainder',
        reader.chunks.map((c) => c.length), [16384, 16384, 1799]);

  /* --- a reader update is armed, not installed --- */
  {
    const directory = mkdtempSync(join(tmpdir(), 'eos-update-'));
    const { result, status } = await session(directory, async (calculator) => {
      const before = await calculator.hello();
      await calculator.updateBegin(UPDATE_TARGET.READER, describe(reader, 41));
      for (let i = 0; i < reader.chunks.length; i++) {
        await calculator.updateChunk(UPDATE_TARGET.READER, i, reader.chunks[i]);
      }
      await calculator.updateEnd(UPDATE_TARGET.READER);
      return { before, after: await calculator.hello() };
    }, ['--save', directory]);

    check('nothing is armed to start with', result.before.updateArmed, false);
    check('no updater to start with', result.before.hasUpdater, false);
    check('the reader update is armed', result.after.updateArmed, true);
    check('the reader was not replaced', existsSync(join(directory, 'EOS.bin')), false);

    const manifest = readFileSync(join(directory, 'EOSUPD.bin'));
    check('a manifest was written', manifest.length, 20);
    check('the manifest names the build', manifest[6] | (manifest[7] << 8), 41);
    check('the manifest names the target', manifest[5], UPDATE_TARGET.READER);

    const stored = Buffer.concat(reader.chunks.map((_, i) =>
      readFileSync(join(directory, `EOSU0${i}.bin`))));
    check('every chunk landed, in order', Array.from(stored), Array.from(reader.body));
    check('update session: link used correctly', status, 0);
  }

  /* --- an updater update is installed there and then --- */
  {
    const directory = mkdtempSync(join(tmpdir(), 'eos-update-'));
    const updater = fakeImage(7000);

    const { result } = await session(directory, async (calculator) => {
      await calculator.updateBegin(UPDATE_TARGET.UPDATER, describe(updater, 41));
      await calculator.updateChunk(UPDATE_TARGET.UPDATER, 0, updater.chunks[0]);
      await calculator.updateEnd(UPDATE_TARGET.UPDATER);
      return { hello: await calculator.hello() };
    }, ['--save', directory]);

    check('the updater is reported present afterwards', result.hello.hasUpdater, true);
    check('nothing was armed for it', result.hello.updateArmed, false);
    check('prgmEOSUP was written', Array.from(readFileSync(join(directory, 'EOSUP.bin'))),
          Array.from(updater.body));
    check('the chunks were cleared up', existsSync(join(directory, 'EOSU00.bin')), false);
  }

  /* --- a damaged image is refused, and takes nothing with it --- */
  {
    const directory = mkdtempSync(join(tmpdir(), 'eos-update-'));
    const { result } = await session(directory, async (calculator) => {
      /* Announce the real checksum, then send a chunk with a bit flipped. */
      await calculator.updateBegin(UPDATE_TARGET.READER, describe(reader, 42));
      for (let i = 0; i < reader.chunks.length; i++) {
        const chunk = Uint8Array.from(reader.chunks[i]);
        if (i === 1) chunk[0] ^= 0x01;
        await calculator.updateChunk(UPDATE_TARGET.READER, i, chunk);
      }

      let status = null;
      try {
        await calculator.updateEnd(UPDATE_TARGET.READER);
      } catch (error) {
        status = error instanceof ProtocolError ? error.status : String(error);
      }
      return { status, hello: await calculator.hello() };
    }, ['--save', directory]);

    check('a bad checksum is reported', result.status, 6);
    check('and says so in words', STATUS[result.status], 'payload ended early');
    check('nothing was armed', result.hello.updateArmed, false);
    check('the damaged chunks were discarded',
          existsSync(join(directory, 'EOSU00.bin')), false);
    check('no manifest was left behind', existsSync(join(directory, 'EOSUPD.bin')), false);
  }

  /* --- chunks outside a begun update are refused --- */
  {
    const { result } = await session(null, async (calculator) => {
      let status = null;
      try {
        await calculator.updateChunk(UPDATE_TARGET.READER, 0, new Uint8Array(16));
      } catch (error) {
        status = error instanceof ProtocolError ? error.status : String(error);
      }
      return { status };
    });

    check('a chunk with no UPDATE_BEGIN is refused', result.status, 7);
    check('and says so in words', STATUS[result.status],
          'the calculator cannot do that right now');
  }
}

/* --- the computer sets the clock ------------------------------------------- */
{
  const { result, status } = await session(null, async (calculator) => {
    await calculator.setClock(1_800_000_000);
    return { ok: true };
  });
  check('CLOCK_SET is accepted', result.ok, true);
  check('clock session: link used correctly', status, 0);
}


/* --- the real staged build, end to end ------------------------------------- */
/*
 * Everything above uses a made-up image, which proves the protocol but not the
 * pipeline. This pushes what tools/stage_update.sh actually staged, through the
 * real .8xp parser, and checks the bytes that land are the program's -- so a
 * wrapper misread, an off-by-two in the length fields or a chunking mistake is
 * caught here rather than by a calculator that will not start.
 */
{
  const staged = join(HERE, '..', '..', 'web', 'eos', 'EOSUP.8xp');
  if (!existsSync(staged)) {
    console.log('  SKIP real build: run tools/stage_update.sh first');
  } else {
    const { readVariable } = await import('../../web/js/tifile.js');
    const variable = readVariable(readFileSync(staged));
    const image = {
      body: variable.body,
      chunks: update.chunksOf(variable.body),
      crc: update.crc32(variable.body),
    };

    check('the staged file is prgmEOSUP', variable.name, 'EOSUP');

    const directory = mkdtempSync(join(tmpdir(), 'eos-real-'));
    await session(directory, async (calculator) => {
      await calculator.updateBegin(UPDATE_TARGET.UPDATER, describe(image, 99));
      for (let i = 0; i < image.chunks.length; i++) {
        await calculator.updateChunk(UPDATE_TARGET.UPDATER, i, image.chunks[i]);
      }
      await calculator.updateEnd(UPDATE_TARGET.UPDATER);
      return {};
    }, ['--save', directory]);

    const installed = readFileSync(join(directory, 'EOSUP.bin'));
    check('the real program installs byte for byte',
          Buffer.compare(installed, Buffer.from(image.body)), 0);
    check('and it is the size the manifest claims', installed.length, variable.body.length);
  }
}


/* --- the chat half of a sync, end to end ----------------------------------- */
/*
 * web/js/chatsync.js driving the real calc/src/chat.c over the pipe. What this
 * covers that check_chat.mjs does not is the order the exchange happens in --
 * take, acknowledge, push the table, push the messages -- and the fact that a
 * calculator holding a different library still does all of it.
 */
{
  const chatsync = await import('../../web/js/chatsync.js');
  const wire = await import('../../web/js/chatwire.js');

  /* A stand-in for chatstore.js: same shape, no IndexedDB. */
  function fakeStore(conversations, messages) {
    const state = { pending: [], calculator: null };
    return {
      conversations: async () => conversations,
      messages: async () => messages,
      queue: async (items) => { state.pending.push(...items); return state.pending; },
      pending: async () => state.pending,
      clearPending: async () => { state.pending = []; return []; },
      setCalculatorState: async (value) => { state.calculator = value; },
      calculatorState: async () => state.calculator,
      taken: () => state.pending,
    };
  }

  const conversations = [{ id: 3, name: 'Study group' }, { id: 9, name: 'sam' }];
  const relayMessages = [
    { id: 10, conversationId: 3, body: 'are you there', sentAt: 1700000000,
      userId: 2, username: 'sam', displayName: 'Sam' },
    { id: 11, conversationId: 3, body: 'yes', sentAt: 1700000060,
      userId: 1, username: 'walter', displayName: 'Walter' },
    { id: 12, conversationId: 9, body: 'just us', sentAt: 1700000120,
      userId: 2, username: 'sam', displayName: 'Sam' },
    /* Not in any conversation the calculator is given: must not be sent. */
    { id: 13, conversationId: 55, body: 'elsewhere', sentAt: 1700000180,
      userId: 2, username: 'sam', displayName: 'Sam' },
  ];

  /* --- a first sync fills an empty calculator --- */
  {
    const directory = mkdtempSync(join(tmpdir(), 'eos-chatsync-'));
    const store = fakeStore(conversations, relayMessages);

    const { result, status } = await session(directory, async (calculator) => {
      const before = await calculator.chatState();
      const summary = await chatsync.exchange(calculator, store, { userId: 1 });
      return { before, summary, after: await calculator.chatState() };
    }, ['--save', directory]);

    check('an empty calculator knows no conversations', result.before.conversations, []);
    check('and has nothing queued', result.before.outboxCount, 0);
    check('the exchange sent the messages it should', result.summary.sent, 3);
    check('and took nothing', result.summary.taken, 0);
    check('the calculator now knows both conversations',
          result.after.conversations.map((c) => c.id), [3, 9]);
    check('and has read up to the newest in each',
          result.after.conversations.map((c) => c.lastServerId), [11, 12]);

    const stored = wire.parseMessages(new Uint8Array(readFileSync(join(directory, 'EOSC00.bin'))));
    check('the first conversation holds both its messages',
          stored.map((m) => m.body), ['are you there', 'yes']);
    check('with the right one marked as ours', stored.map((m) => m.mine), [false, true]);
    check('and the sender names came across', stored.map((m) => m.sender), ['Sam', 'Walter']);
    check('a conversation the calculator does not have was not sent',
          existsSync(join(directory, 'EOSC02.bin')), false);
    check('chat session: link used correctly', status, 0);
  }

  /* --- a second sync sends only what is new --- */
  {
    const directory = mkdtempSync(join(tmpdir(), 'eos-chatsync-'));
    const store = fakeStore(conversations, relayMessages);

    /* Two sessions against one calculator: the appvars the first leaves behind
     * are what the second one starts from. */
    await session(directory, async (calculator) => {
      await chatsync.exchange(calculator, store, { userId: 1 });
      return {};
    }, ['--save', directory]);

    /* --save writes raw .bin; feed them back as the calculator's contents. */
    for (const name of ['EOSCHT', 'EOSC00', 'EOSC01']) {
      const path = join(directory, `${name}.bin`);
      if (existsSync(path)) {
        writeFileSync(join(directory, `${name}.8xv`),
                      writeAppvar(name, new Uint8Array(readFileSync(path))));
      }
    }

    const later = relayMessages.concat([{
      id: 20, conversationId: 3, body: 'still here', sentAt: 1700001000,
      userId: 2, username: 'sam', displayName: 'Sam',
    }]);
    const store2 = fakeStore(conversations, later);

    const { result } = await session(directory, async (calculator) => {
      const summary = await chatsync.exchange(calculator, store2, { userId: 1 });
      return { summary, after: await calculator.chatState() };
    }, ['--save', directory]);

    check('the second sync sends only the new message', result.summary.sent, 1);
    check('and the read position moved on',
          result.after.conversations.find((c) => c.id === 3).lastServerId, 20);

    const stored = wire.parseMessages(new Uint8Array(readFileSync(join(directory, 'EOSC00.bin'))));
    check('the conversation now holds three, in order',
          stored.map((m) => m.serverId), [10, 11, 20]);
  }

  /* --- what is typed on the calculator comes back --- */
  {
    const directory = mkdtempSync(join(tmpdir(), 'eos-chatsync-'));
    const store = fakeStore(conversations, relayMessages);

    /* Seed a table and an outbox by driving chat.c directly, which is what the
     * reader's compose screen does. */
    const seed = execFileSync(join(HERE, 'chat_probe'), [
      directory,
      'table', (() => {
        const path = join(directory, 'table.bin');
        writeFileSync(path, wire.packTable(conversations));
        return path;
      })(),
      'send', '3', 'typed on the calculator',
      'send', '9', 'and another',
      'save',
    ], { encoding: 'utf8' });
    check('the seed queued two', (seed.match(/^send 1$/gm) || []).length, 2);

    for (const name of ['EOSCHT', 'EOSOUT']) {
      writeFileSync(join(directory, `${name}.8xv`),
                    writeAppvar(name, new Uint8Array(readFileSync(join(directory, `${name}.bin`)))));
    }

    const { result } = await session(directory, async (calculator) => {
      const before = await calculator.chatState();
      const summary = await chatsync.exchange(calculator, store, { userId: 7 });
      return { before, summary, after: await calculator.chatState() };
    }, ['--save', directory]);

    check('the calculator reported its queue', result.before.outboxCount, 2);
    check('the exchange took both', result.summary.taken, 2);
    check('and the queue is empty afterwards', result.after.outboxCount, 0);

    const taken = store.taken();
    check('with the right bodies', taken.map((m) => m.body),
          ['typed on the calculator', 'and another']);
    check('and the right conversations', taken.map((m) => m.conversationId), [3, 9]);
    check('each keyed for the relay to de-duplicate on',
          taken.every((m) => /^calc-7-\d+$/.test(m.clientId)), true);
    check('with keys that differ', taken[0].clientId !== taken[1].clientId, true);
  }

  /* --- chat runs even when the library does not --- */
  /*
   * The whole point of the split. A calculator carrying somebody else's comics
   * must not be synced with this library, but its chat is this account's and
   * has nothing to do with which comics are on it.
   */
  {
    const directory = mkdtempSync(join(tmpdir(), 'eos-chatsync-'));
    const index = lib.buildIndex([{
      title: 'someone else', strips: [{ title: '001', slot: 0, chunkCount: 1, size: 100,
        read: false, readAt: 0, pos: 0, layer: 0 }],
    }], { render: fakeRender, libraryId: new Uint8Array(16).fill(0x5a) });
    writeFileSync(join(directory, `${lib.NAME}.8xv`), writeAppvar(lib.NAME, index));

    const store = fakeStore(conversations, relayMessages);
    const { result } = await session(directory, async (calculator) => {
      const hello = await calculator.hello(new Uint8Array(16).fill(0x11));
      const summary = await chatsync.exchange(calculator, store, { userId: 1 });
      return { library: hello.library, summary };
    }, ['--save', directory]);

    check('the library is recognised as somebody else\'s', result.library, LIBRARY.DIFFERENT);
    check('and the chat exchange ran anyway', result.summary.sent, 3);
    check('landing on the calculator',
          existsSync(join(directory, 'EOSC00.bin')), true);
  }
}


/* --- a calculator connected without a library folder ---------------------- */
/*
 * Connecting for the chat or an update alone is ordinary: neither is about
 * comics. The page sends an all-zero library id when no folder is chosen, and
 * the calculator has to read that as "no identity" rather than as somebody
 * else's library -- a random id would have looked like the latter.
 */
{
  const directory = mkdtempSync(join(tmpdir(), 'eos-nolib-'));
  const index = lib.buildIndex([{
    title: 'mine', strips: [{ title: '001', slot: 0, chunkCount: 1, size: 100,
      read: false, readAt: 0, pos: 0, layer: 0 }],
  }], { render: fakeRender, libraryId: new Uint8Array(16).fill(0x77) });
  writeFileSync(join(directory, `${lib.NAME}.8xv`), writeAppvar(lib.NAME, index));

  const { result } = await session(directory, async (calculator) => ({
    zero: (await calculator.hello(new Uint8Array(16))).library,
    same: (await calculator.hello(new Uint8Array(16).fill(0x77))).library,
    other: (await calculator.hello(new Uint8Array(16).fill(0x22))).library,
  }));

  check('no library id is unknown, not somebody else\'s', result.zero, LIBRARY.UNKNOWN);
  check('the right one still matches', result.same, LIBRARY.SAME);
  check('and a genuinely different one is still noticed', result.other, LIBRARY.DIFFERENT);
}

console.log(`${checks - failures}/${checks} usb protocol checks pass`);
process.exit(failures ? 1 : 0);
