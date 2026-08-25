/*
 * Check the library editor's bookkeeping, and that the order you arrange in the
 * browser is the order the calculator ends up showing.
 *
 * The second half is the one that matters: it builds a CSLIB from reordered
 * metadata and runs it through calc/src/library.c, the real parser, so a claim
 * like "reordering is preserved onto the calculator" is checked end to end
 * rather than asserted.
 *
 *   node tools/hosttest/check_library_edit.mjs
 */

import { execFileSync } from 'node:child_process';
import { mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  addBookKey, bookNames, defaultMeta, flatten, mergeFromCalculator, moveStripKey,
  reconcile, removeStripKey, renameBookKey, renameStripKey, reorderBook, reorderStrip,
  stripNames,
} from '../../web/js/meta.js';
import { buildIndexFor } from '../../web/js/sync.js';
import { writeAppvar } from '../../web/js/tifile.js';

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

/* A scan result, as fs.scanLibrary would return it: naturally sorted. */
function scan(spec) {
  return Object.entries(spec).map(([name, files]) => ({
    name,
    strips: files.map((file) => ({ name: file, handle: null, size: 1_000_000, lastModified: 0 })),
  }));
}

const LIBRARY = {
  'Book A': ['001.jpg', '002.jpg', '003.jpg'],
  'Book B': ['01.jpg', '02.jpg'],
  '第三本书': ['第一话.jpg'],
};

function setup() {
  const books = scan(LIBRARY);
  return { meta: reconcile(defaultMeta(), books), books };
}

/* --- a fresh scan orders everything the way it sorted ------------------- */
{
  const { meta } = setup();
  check('initial book order', bookNames(meta), ['Book A', 'Book B', '第三本书']);
  check('initial strip order', stripNames(meta, 'Book A'), ['001.jpg', '002.jpg', '003.jpg']);
  check('orders are dense', bookNames(meta).map((n) => meta.books[n].order), [0, 1, 2]);
}

/* --- reordering books and strips ---------------------------------------- */
{
  const { meta } = setup();
  reorderBook(meta, '第三本书', 0);
  check('book moved to the front', bookNames(meta), ['第三本书', 'Book A', 'Book B']);

  reorderBook(meta, '第三本书', 3);
  check('book moved to the end', bookNames(meta), ['Book A', 'Book B', '第三本书']);

  reorderStrip(meta, 'Book A', '003.jpg', 0);
  check('strip moved to the front', stripNames(meta, 'Book A'), ['003.jpg', '001.jpg', '002.jpg']);

  reorderStrip(meta, 'Book A', '003.jpg', 2);
  check('strip moved to the middle', stripNames(meta, 'Book A'), ['001.jpg', '003.jpg', '002.jpg']);

  /* Out-of-range targets clamp rather than corrupting the list. */
  reorderStrip(meta, 'Book A', '001.jpg', 99);
  check('clamped to the end', stripNames(meta, 'Book A'), ['003.jpg', '002.jpg', '001.jpg']);
  reorderStrip(meta, 'Book A', '001.jpg', -5);
  check('clamped to the start', stripNames(meta, 'Book A'), ['001.jpg', '003.jpg', '002.jpg']);
}

/* --- a rescan keeps the arranged order and appends new files ------------- */
{
  const { meta } = setup();
  reorderStrip(meta, 'Book A', '003.jpg', 0);
  reorderBook(meta, 'Book B', 0);
  const slot = meta.books['Book A'].strips['003.jpg'].id;
  meta.books['Book A'].strips['003.jpg'].read = true;

  /* 004 appears on disk, and the scan hands it back in natural order. */
  const rescanned = scan({ ...LIBRARY, 'Book A': ['001.jpg', '002.jpg', '003.jpg', '004.jpg'] });
  reconcile(meta, rescanned);

  check('rescan keeps the book order', bookNames(meta), ['Book B', 'Book A', '第三本书']);
  check('rescan keeps the strip order and appends',
        stripNames(meta, 'Book A'), ['003.jpg', '001.jpg', '002.jpg', '004.jpg']);
  check('rescan keeps the slot', meta.books['Book A'].strips['003.jpg'].id, slot);
  check('rescan keeps read state', meta.books['Book A'].strips['003.jpg'].read, true);
  check('the new strip got its own slot',
        meta.books['Book A'].strips['004.jpg'].id !== slot, true);
}

/* --- renaming keeps identity, so a rename is not a re-sync --------------- */
{
  const { meta } = setup();
  const slot = meta.books['Book A'].strips['002.jpg'].id;
  meta.books['Book A'].strips['002.jpg'].read = true;
  meta.books['Book A'].strips['002.jpg'].onCalc = true;

  renameStripKey(meta, 'Book A', '002.jpg', '002 - 新标题.jpg');
  check('strip rename keeps order',
        stripNames(meta, 'Book A'), ['001.jpg', '002 - 新标题.jpg', '003.jpg']);
  check('strip rename keeps the slot',
        meta.books['Book A'].strips['002 - 新标题.jpg'].id, slot);
  check('strip rename keeps read/onCalc',
        [meta.books['Book A'].strips['002 - 新标题.jpg'].read,
         meta.books['Book A'].strips['002 - 新标题.jpg'].onCalc], [true, true]);

  renameBookKey(meta, 'Book A', '第一本书');
  check('book rename keeps position', bookNames(meta), ['第一本书', 'Book B', '第三本书']);
  check('book rename keeps its strips', stripNames(meta, '第一本书').length, 3);

  let threw = false;
  try { renameBookKey(meta, 'Book B', '第三本书'); } catch { threw = true; }
  check('renaming onto an existing book is refused', threw, true);
}

/* --- moving a strip between books --------------------------------------- */
{
  const { meta } = setup();
  const slot = meta.books['Book A'].strips['002.jpg'].id;
  moveStripKey(meta, 'Book A', 'Book B', '002.jpg');

  check('moved out of the source', stripNames(meta, 'Book A'), ['001.jpg', '003.jpg']);
  check('appended to the target', stripNames(meta, 'Book B'), ['01.jpg', '02.jpg', '002.jpg']);
  check('move keeps the slot', meta.books['Book B'].strips['002.jpg'].id, slot);
}

/* --- deleting ------------------------------------------------------------ */
{
  const { meta } = setup();
  removeStripKey(meta, 'Book A', '002.jpg');
  check('strip removed', stripNames(meta, 'Book A'), ['001.jpg', '003.jpg']);
  check('orders re-densified', stripNames(meta, 'Book A').map((f) => meta.books['Book A'].strips[f].order), [0, 1]);

  addBookKey(meta, 'New Book');
  check('new book lands at the end', bookNames(meta).at(-1), 'New Book');
  check('new book is empty', stripNames(meta, 'New Book'), []);
}

/* --- flatten follows the arranged order, not the scan -------------------- */
{
  const { meta, books } = setup();
  reorderBook(meta, 'Book B', 0);
  reorderStrip(meta, 'Book A', '003.jpg', 0);

  check('flatten follows the stored order',
        flatten(meta, books).map((s) => `${s.book}/${s.file}`),
        ['Book B/01.jpg', 'Book B/02.jpg',
         'Book A/003.jpg', 'Book A/001.jpg', 'Book A/002.jpg',
         '第三本书/第一话.jpg']);
}

/* --- and the order reaches the calculator -------------------------------- */

function fakeRender(text, maxWidth) {
  const width = Math.min(maxWidth, Math.max(1, text.length * 13));
  const height = 16;
  const stride = (width + 3) >> 2;
  const packed = new Uint8Array(stride * height);
  let hash = 7;
  for (const ch of text) hash = (hash * 31 + ch.codePointAt(0)) >>> 0;
  for (let y = 2; y < height - 2; y++) {
    for (let x = 0; x < width; x++) {
      const level = ((hash + x * 7 + y * 13) % 5) & 3;
      if (level) packed[y * stride + (x >> 2)] |= level << (6 - 2 * (x & 3));
    }
  }
  return { width, height, packed };
}

const checksum = (packed) => {
  let sum = 0n;
  for (const byte of packed) sum = (sum * 31n + BigInt(byte)) % (2n ** 64n);
  return sum.toString();
};

function readBack(meta, books) {
  const index = buildIndexFor(meta, books, { render: fakeRender });
  const dir = mkdtempSync(join(tmpdir(), 'ebooksync-order-'));
  writeFileSync(join(dir, 'CSLIB.8xv'), writeAppvar('CSLIB', index));

  const output = execFileSync(join(HERE, 'lib_probe'), [dir], { encoding: 'utf8' });
  const rows = { book: [], strip: [] };
  for (const line of output.trim().split('\n')) {
    const parts = line.split(' ');
    if (!rows[parts[0]]) continue;
    const row = {};
    for (let i = 2; i < parts.length - 1; i += 2) row[parts[i]] = parts[i + 1];
    rows[parts[0]].push(row);
  }
  return rows;
}

{
  const { meta, books } = setup();
  /* Everything is resident, so all of it lands in the index. */
  for (const name of bookNames(meta)) {
    for (const file of stripNames(meta, name)) {
      Object.assign(meta.books[name].strips[file],
                    { onCalc: true, chunkCount: 9, deviceBytes: 140_000 });
    }
  }

  /* Arrange it into an order nothing would sort into by itself. */
  reorderBook(meta, '第三本书', 0);
  reorderBook(meta, 'Book A', 3);
  reorderStrip(meta, 'Book A', '003.jpg', 0);
  reorderStrip(meta, 'Book B', '02.jpg', 0);

  const expectedBooks = bookNames(meta);
  check('arranged book order', expectedBooks, ['第三本书', 'Book B', 'Book A']);

  const rows = readBack(meta, books);

  /* The C parser sees books in that order, with those titles. */
  check('calculator book count', rows.book.length, expectedBooks.length);
  expectedBooks.forEach((name, i) => {
    check(`calculator book ${i} title`, rows.book[i].sum,
          checksum(fakeRender(name, 300).packed));
  });

  /* And each book's strips, in the arranged order, contiguously. */
  const expectedStrips = expectedBooks.flatMap((name) => stripNames(meta, name));
  check('arranged strip order', expectedStrips,
        ['第一话.jpg', '02.jpg', '01.jpg', '003.jpg', '001.jpg', '002.jpg']);
  check('calculator strip count', rows.strip.length, expectedStrips.length);

  expectedStrips.forEach((file, i) => {
    const title = file.replace(/\.jpe?g$/i, '');
    check(`calculator strip ${i} title`, rows.strip[i].sum,
          checksum(fakeRender(title, 272).packed));
  });

  /* Book rows point at the right runs of the strip table. */
  let first = 0;
  expectedBooks.forEach((name, i) => {
    const count = stripNames(meta, name).length;
    check(`calculator book ${i} strip range`,
          [rows.book[i].first, rows.book[i].count], [String(first), String(count)]);
    first += count;
  });
}

/* --- a strip only in the library, not on the calculator, is left out ----- */
{
  const { meta, books } = setup();
  const names = bookNames(meta);
  meta.books[names[0]].strips['001.jpg'].onCalc = true;
  meta.books[names[0]].strips['001.jpg'].chunkCount = 9;

  const rows = readBack(meta, books);
  check('only resident strips are indexed', rows.strip.length, 1);
  check('only books with resident strips are indexed', rows.book.length, 1);
}

/* --- the calculator's read state survives a merge ------------------------ */
{
  const { meta } = setup();
  const slot = meta.books['Book A'].strips['001.jpg'].id;
  mergeFromCalculator(meta, [{
    slot, chunkCount: 9, bytes: 140_000, read: true, readAt: 1_756_000_000, pos: 512, layer: 1,
  }]);
  const strip = meta.books['Book A'].strips['001.jpg'];
  check('merge marks it read', [strip.read, strip.onCalc, strip.pos, strip.layer],
        [true, true, 512, 1]);
  check('merge dates it', typeof strip.readAt, 'string');
}

console.log(`${checks - failures}/${checks} library editing checks pass`);
process.exit(failures ? 1 : 0);
