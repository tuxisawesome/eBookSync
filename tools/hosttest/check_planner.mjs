/*
 * Check the sync planner decides the right things.
 *
 * The planner is what deletes comics off the calculator, so its rules are worth
 * pinning down: keep the N most recently read, never push past the budget,
 * reclaim slots the library no longer knows about, and respect manual versus
 * automatic selection.
 *
 *   node tools/hosttest/check_planner.mjs
 */

import { execute, plan } from '../../web/js/sync.js';
import {
  defaultMeta, mergeFromCalculator, reconcile, slotAllocator,
} from '../../web/js/meta.js';
import { MAX_INDEX_BYTES, MAX_RESIDENT } from '../../web/js/library.js';

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

/* A library of two books; sizes are set so the budget maths is easy to read. */
function library() {
  return [
    {
      name: 'Book A',
      strips: [1, 2, 3, 4].map((n) => ({
        name: `00${n}.jpg`, handle: null, size: 1_000_000, lastModified: 0,
      })),
    },
    {
      name: 'Book B',
      strips: [1, 2].map((n) => ({
        name: `0${n}.jpg`, handle: null, size: 1_000_000, lastModified: 0,
      })),
    },
  ];
}

function setup(mutate = () => {}) {
  const books = library();
  const meta = reconcile(defaultMeta(), books);
  /* A known size per strip so the budget is predictable. */
  for (const book of Object.values(meta.books)) {
    for (const strip of Object.values(book.strips)) strip.deviceBytes = 100_000;
  }
  mutate(meta, books);
  return { meta, books };
}

/* A strip only has a slot while it is on the calculator, so a test that puts
 * one there gives it one first -- the way execute() would have. */
function slotOf(meta, book, file) {
  const strip = meta.books[book].strips[file];
  if (!Number.isInteger(strip.id)) strip.id = slotAllocator(meta)();
  return strip.id;
}

/* --- manual selection only sends what is ticked ------------------------- */
{
  const { meta, books } = setup((m) => {
    m.books['Book A'].strips['001.jpg'].selected = true;
    m.books['Book B'].strips['02.jpg'].selected = true;
  });
  const result = plan(meta, books, []);
  check('manual: pushes', result.pushes.map((s) => s.file).sort(), ['001.jpg', '02.jpg']);
  check('manual: no deletes', result.deletes.length, 0);
}

/* --- auto selection sends unread strips regardless of ticks -------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.selection = 'auto';
    m.books['Book A'].strips['001.jpg'].read = true;
  });
  const result = plan(meta, books, []);
  check('auto: skips the read one', result.pushes.some((s) => s.file === '001.jpg'), false);
  check('auto: pushes the rest', result.pushes.length, 5);
}

/* --- already resident strips are not sent again -------------------------- */
{
  const { meta, books } = setup((m) => {
    m.books['Book A'].strips['001.jpg'].selected = true;
    m.books['Book A'].strips['002.jpg'].selected = true;
  });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 25, bytes: 100_000,
    read: false, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);
  const result = plan(meta, books, resident);
  check('resident: only the missing one', result.pushes.map((s) => s.file), ['002.jpg']);
}

/* --- auto-delete keeps the N most recently read -------------------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.keepRead = 2;
    const a = m.books['Book A'].strips;
    a['001.jpg'].read = true; a['001.jpg'].readAt = '2026-08-01T00:00:00Z';
    a['002.jpg'].read = true; a['002.jpg'].readAt = '2026-08-03T00:00:00Z';
    a['003.jpg'].read = true; a['003.jpg'].readAt = '2026-08-02T00:00:00Z';
    a['004.jpg'].read = true; a['004.jpg'].readAt = '2026-08-04T00:00:00Z';
  });
  const resident = ['001.jpg', '002.jpg', '003.jpg', '004.jpg'].map((file) => ({
    slot: slotOf(meta, 'Book A', file), chunkCount: 25, bytes: 100_000,
    read: true, readAt: 0, pos: 0, layer: 0,
  }));
  mergeFromCalculator(meta, resident);
  const result = plan(meta, books, resident);
  /* The two oldest reads go; 004 (newest) and 002 (next newest) stay. */
  check('keepRead: deletes the oldest two',
        result.deletes.map((s) => s.file).sort(), ['001.jpg', '003.jpg']);
}

/* --- auto-delete off deletes nothing ------------------------------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.autoDelete = false;
    m.books['Book A'].strips['001.jpg'].read = true;
  });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 25, bytes: 100_000,
    read: true, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);
  const result = plan(meta, books, resident);
  check('autoDelete off: nothing deleted', result.deletes.length, 0);
}

/* --- the budget trims the tail of the selection --------------------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.maxDeviceBytes = 250_000;      /* room for two 100 KB strips */
    for (const strip of Object.values(m.books['Book A'].strips)) strip.selected = true;
  });
  const result = plan(meta, books, []);
  check('budget: pushes what fits', result.pushes.length, 2);
  check('budget: reports the rest', result.skipped.length, 2);
  check('budget: projection stays inside', result.projectedBytes <= 250_000, true);
}

/* --- slots the library no longer knows about are reclaimed ---------------- */
{
  const { meta, books } = setup();
  const resident = [{ slot: 200, chunkCount: 4, bytes: 60_000, read: false, readAt: 0, pos: 0, layer: 0 }];
  mergeFromCalculator(meta, resident);
  const result = plan(meta, books, resident);
  check('orphans: found', result.orphans.map((o) => o.slot), [200]);
}

/* --- a read strip that is deleted stops being selected -------------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.keepRead = 0;
    m.books['Book A'].strips['001.jpg'].read = true;
    m.books['Book A'].strips['001.jpg'].selected = true;
  });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 25, bytes: 100_000,
    read: true, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);
  const result = plan(meta, books, resident);
  check('cleanup: the read strip is deleted', result.deletes.map((s) => s.file), ['001.jpg']);
  /* It is also a push candidate, because deleting frees the slot -- but that
   * would make it bounce straight back, so execute() clears `selected`. This
   * check pins the behaviour the planner is relied upon for. */
  check('cleanup: re-push is planned only once',
        result.pushes.filter((s) => s.file === '001.jpg').length <= 1, true);
}

/* --- free space on the device caps the budget ----------------------------- */
{
  const { meta, books } = setup((m) => {
    for (const strip of Object.values(m.books['Book A'].strips)) strip.selected = true;
  });
  const result = plan(meta, books, [], { freeArchive: 150_000 });
  check('freeArchive: caps the pushes', result.pushes.length, 1);
}

/* --- connecting ticks whatever is already on the calculator ------------- */
{
  const { meta, books } = setup();
  const slot = slotOf(meta, 'Book A', '001.jpg');
  const resident = [{
    slot, chunkCount: 25, bytes: 100_000, read: false, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);

  check('resident strips arrive ticked',
        meta.books['Book A'].strips['001.jpg'].selected, true);

  /* Ticked and resident: nothing to do. */
  const before = plan(meta, books, resident);
  check('a ticked resident strip is left alone',
        [before.pushes.length, before.deletes.length], [0, 0]);

  /* Unticking it is how you ask for it to go. */
  meta.books['Book A'].strips['001.jpg'].selected = false;
  const after = plan(meta, books, resident);
  check('unticking a resident strip removes it',
        after.deletes.map((s) => s.file), ['001.jpg']);
  check('and it is not re-sent in the same breath', after.pushes.length, 0);
}

/* --- a strip being removed is not also queued to be sent ----------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.keepRead = 0;
    m.books['Book A'].strips['001.jpg'].read = true;
    m.books['Book A'].strips['001.jpg'].selected = true;
  });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 25, bytes: 100_000,
    read: true, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);

  const result = plan(meta, books, resident);
  check('cleanup deletes it', result.deletes.map((s) => s.file), ['001.jpg']);
  check('and does not immediately re-send it',
        result.pushes.filter((s) => s.file === '001.jpg').length, 0);
}

/* --- automatic selection ignores the ticks ------------------------------ */
{
  const { meta, books } = setup((m) => { m.settings.selection = 'auto'; });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 25, bytes: 100_000,
    read: false, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);
  meta.books['Book A'].strips['001.jpg'].selected = false;

  const result = plan(meta, books, resident);
  check('auto mode does not remove unticked strips', result.deletes.length, 0);
}

/* --- a strip holds no slot until it is sent ------------------------------ */
{
  const { meta, books } = setup((m) => {
    m.books['Book A'].strips['001.jpg'].selected = true;
  });
  check('a fresh library assigns no slots',
        Object.values(meta.books['Book A'].strips).map((s) => s.id), [null, null, null, null]);

  /* A LIST can never report a slot of null, but if one did it must not make
   * every slotless strip look resident. */
  const result = plan(meta, books, [{ slot: null, chunkCount: 1, bytes: 1 }]);
  check('a slotless strip is never resident', result.pushes.map((s) => s.file), ['001.jpg']);
  check('and is never deleted', result.deletes.length, 0);
}

/* --- the calculator can only hold so many strips ------------------------- */
/*
 * Even with titles that cost nothing, each strip is a 17-byte row in an index
 * the calculator takes at most 16 KB of -- which is tighter than the 1092 its
 * LIST reply has room for. Whichever binds, the rest stay on the computer.
 */
{
  const count = MAX_RESIDENT + 5;
  const books = [{
    name: 'Huge',
    strips: Array.from({ length: count }, (_, i) => ({
      name: `${i}.jpg`, handle: null, size: 1000, lastModified: 0,
    })),
  }];
  const meta = reconcile(defaultMeta(), books);
  meta.settings.maxDeviceBytes = 1e12;
  for (const strip of Object.values(meta.books.Huge.strips)) {
    strip.selected = true;
    strip.deviceBytes = 10;
  }

  const fits = Math.min(MAX_RESIDENT, Math.floor((MAX_INDEX_BYTES - 92 - 6) / 17));
  const result = plan(meta, books, [], { titleBytes: () => 0 });
  check('capacity: sends what the calculator can hold', result.pushes.length, fits);
  check('capacity: the rest are reported as full', result.full.length, count - fits);
  check('capacity: and not as over budget', result.skipped.length, 0);
}

/* --- the calculator's index has a size limit ----------------------------- */
{
  const { meta, books } = setup((m) => {
    for (const strip of Object.values(m.books['Book A'].strips)) strip.selected = true;
  });
  /* Titles so large that the header, one book and two strips are all that fit. */
  const big = Math.floor((MAX_INDEX_BYTES - 92 - 6 - 2 * 17) / 3);
  const result = plan(meta, books, [], { titleBytes: () => big });
  check('index cap: sends what fits', result.pushes.map((s) => s.file), ['001.jpg', '002.jpg']);
  check('index cap: the rest are full', result.full.map((s) => s.file), ['003.jpg', '004.jpg']);
}

/* --- what is already there counts against the calculator's room ---------- */
{
  const { meta, books } = setup((m) => {
    for (const strip of Object.values(m.books['Book A'].strips)) strip.selected = true;
  });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 1, bytes: 10,
    read: false, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);
  const big = Math.floor((MAX_INDEX_BYTES - 92 - 6 - 2 * 17) / 3);
  const result = plan(meta, books, resident, { titleBytes: () => big });
  check('index cap: resident strips use room too', result.pushes.map((s) => s.file), ['002.jpg']);
}

/* --- slots come back when strips come off -------------------------------- */
{
  const { meta } = setup();
  const first = slotOf(meta, 'Book A', '001.jpg');
  const second = slotOf(meta, 'Book A', '002.jpg');
  check('slots are handed out lowest first', [first, second], [0, 1]);

  /* The calculator reports only 002 and an orphan in slot 0... */
  const resident = [
    { slot: second, chunkCount: 1, bytes: 10, read: false, readAt: 0, pos: 0, layer: 0 },
  ];
  mergeFromCalculator(meta, resident);
  check('a strip that is not there gives its slot back',
        meta.books['Book A'].strips['001.jpg'].id, null);
  check('one that is there keeps it', meta.books['Book A'].strips['002.jpg'].id, second);

  const next = slotAllocator(meta, [...resident, { slot: 2 }]);
  check('the allocator reuses a freed slot', next(), 0);
  check('and skips anything held or reported', next(), 3);
}


/* ========================================================================== */
/* Carrying a plan out, against a calculator that is only a Map.              */
/* ========================================================================== */

/* Enough of Calculator for execute(): stores chunk counts per slot and keeps a
 * log of what it was asked, so the order of things can be checked. */
class FakeCalculator {
  constructor() {
    this.slots = new Map();
    this.log = [];
    this.index = null;
  }

  async putChunk(slot, chunk) {
    this.log.push(`put ${slot}`);
    this.slots.set(slot, Math.max(this.slots.get(slot) || 0, chunk + 1));
  }

  async verifyStrip() { return { ok: true }; }

  async deleteStrip(slot) {
    this.log.push(`delete ${slot}`);
    if (!this.slots.delete(slot)) throw new Error('not found');
  }

  async putIndex(bytes) { this.index = bytes; }

  /* What LIST would say: everything the index lists. */
  list(meta) {
    const out = [];
    for (const book of Object.values(meta.books)) {
      for (const strip of Object.values(book.strips)) {
        if (strip.onCalc) {
          out.push({ slot: strip.id, chunkCount: 1, bytes: 10, read: strip.read,
                     readAt: 0, pos: 0, layer: 0 });
        }
      }
    }
    return out;
  }
}

const pool = {
  convert: async () => ({ chunks: [new Uint8Array(10)], totalBytes: 10 }),
};

/* A title the size of the widest the index allows and no more compressible
 * than noise, so an index can be made to overflow with a handful of strips. */
function noisyRender(text, maxWidth) {
  const stride = (maxWidth + 3) >> 2;
  const packed = new Uint8Array(stride * 16);
  let seed = 7;
  for (const ch of text) seed = (seed * 31 + ch.codePointAt(0)) >>> 0;
  for (let i = 0; i < packed.length; i++) {
    seed = (seed * 1_103_515_245 + 12_345) >>> 0;
    packed[i] = seed >>> 24;
  }
  return { width: maxWidth, height: 16, packed };
}

/* A small, compressible title. */
function plainRender(text, maxWidth) {
  const width = Math.min(maxWidth, 8);
  return { width, height: 16, packed: new Uint8Array(((width + 3) >> 2) * 16) };
}

function syncLibrary(count) {
  const books = [{
    name: 'Book',
    strips: Array.from({ length: count }, (_, i) => ({
      name: `${String(i).padStart(3, '0')}.jpg`, size: 1000, lastModified: 0,
      handle: { getFile: async () => new Blob(['x']) },
    })),
  }];
  const meta = reconcile(defaultMeta(), books);
  meta.settings.maxDeviceBytes = 1e12;
  for (const strip of Object.values(meta.books.Book.strips)) {
    strip.srcHash = 'fixed';
    strip.deviceBytes = 10;
  }
  return { meta, books };
}

const ids = (meta) => Object.fromEntries(
  Object.entries(meta.books.Book.strips).map(([name, strip]) => [name, strip.id]));

/* --- slots are taken as strips are sent, and given back as they go -------- */
{
  const { meta, books } = syncLibrary(4);
  const calc = new FakeCalculator();
  const strips = meta.books.Book.strips;
  strips['000.jpg'].selected = true;
  strips['001.jpg'].selected = true;
  strips['002.jpg'].selected = true;

  let result = await execute(calc, meta, books, plan(meta, books, []),
                             { pool, render: plainRender });
  check('execute: nothing failed', result.failures.length, 0);
  check('execute: sent strips got slots in order',
        ids(meta), { '000.jpg': 0, '001.jpg': 1, '002.jpg': 2, '003.jpg': null });
  check('execute: the calculator holds them', [...calc.slots.keys()], [0, 1, 2]);
  check('execute: each slot is cleared before it is written',
        calc.log.slice(0, 2), ['delete 0', 'put 0']);

  /* Take the first off and ask for the last: it gets the freed slot. */
  const resident = calc.list(meta);
  mergeFromCalculator(meta, resident);
  strips['000.jpg'].selected = false;
  strips['003.jpg'].selected = true;
  result = await execute(calc, meta, books, plan(meta, books, resident),
                         { pool, render: plainRender });
  check('execute: a removed strip gives its slot back', strips['000.jpg'].id, null);
  check('execute: and the next strip sent takes it', strips['003.jpg'].id, 0);
  check('execute: the calculator agrees', [...calc.slots.keys()].sort(), [0, 1, 2]);
}

/* --- an orphan's slot is not handed out while it is still occupied -------- */
{
  const { meta, books } = syncLibrary(2);
  const calc = new FakeCalculator();
  calc.slots.set(0, 1);                  /* something the library never sent */
  meta.books.Book.strips['000.jpg'].selected = true;

  const resident = [{ slot: 0, chunkCount: 1, bytes: 10, read: false, readAt: 0, pos: 0, layer: 0 }];
  mergeFromCalculator(meta, resident);
  const current = plan(meta, books, resident);
  check('orphan: found', current.orphans.map((o) => o.slot), [0]);

  await execute(calc, meta, books, current, { pool, render: plainRender });
  check('orphan: removed, and its slot reused afterwards',
        meta.books.Book.strips['000.jpg'].id, 0);
  check('orphan: the log shows the order', calc.log.slice(0, 3),
        ['delete 0', 'delete 0', 'put 0']);
}

/* --- an index that comes out too big is trimmed, not sent ----------------- */
{
  const { meta, books } = syncLibrary(30);
  const calc = new FakeCalculator();
  for (const strip of Object.values(meta.books.Book.strips)) strip.selected = true;

  /* Plan as if titles were free, so it sends all thirty; then build the index
   * with titles that are anything but. */
  const current = plan(meta, books, [], { titleBytes: () => 0 });
  check('overflow: the plan sends everything', current.pushes.length, 30);

  const result = await execute(calc, meta, books, current, { pool, render: noisyRender });
  check('overflow: the index sent fits', calc.index.length <= MAX_INDEX_BYTES, true);

  const kept = Object.values(meta.books.Book.strips).filter((s) => s.onCalc);
  check('overflow: some were sent', kept.length > 0, true);
  check('overflow: the rest were taken back off and reported',
        result.failures.length, 30 - kept.length);
  check('overflow: the calculator holds only what the index lists',
        calc.slots.size, kept.length);
  check('overflow: and those taken back hold no slot',
        Object.values(meta.books.Book.strips).filter((s) => !s.onCalc).every((s) => s.id === null),
        true);
}


console.log(`${checks - failures}/${checks} planner checks pass`);
process.exit(failures ? 1 : 0);
