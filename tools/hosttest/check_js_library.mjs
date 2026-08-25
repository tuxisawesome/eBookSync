/*
 * Check calc/src/library.c parses exactly what web/js/library.js builds.
 *
 * The browser and the calculator agree on this layout only by construction, so
 * build an index here, hand it to the real C parser, and compare every field
 * and every expanded title bitmap.
 *
 *   node tools/hosttest/check_js_library.mjs
 */

import { execFileSync } from 'node:child_process';
import { mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

import { buildIndex, FLAG_READ } from '../../web/js/library.js';
import { writeAppvar } from '../../web/js/tifile.js';

const HERE = dirname(fileURLToPath(import.meta.url));

/* Stand-in for the canvas renderer: deterministic, and shaped like real title
 * bitmaps (2bpp, 16 rows, mostly background with some ink). */
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

const books = [
  {
    title: '第一本书',
    strips: [
      { title: '001 - 标题很长的一集漫画故事名字会被截断掉的', slot: 0, chunkCount: 25,
        size: 401920, read: true, readAt: 1756000001, pos: 1234, layer: 1 },
      { title: '002 - 第二集', slot: 1, chunkCount: 25, size: 402000,
        read: true, readAt: 1756000500, pos: 0, layer: 0 },
      { title: '003 - 第三集', slot: 2, chunkCount: 24, size: 390100,
        read: false, readAt: 0, pos: 0, layer: 0 },
    ],
  },
  {
    title: 'Another Book 另一本',
    strips: [
      { title: '01 - Episode One', slot: 10, chunkCount: 9, size: 140000,
        read: false, readAt: 0, pos: 99, layer: 0 },
    ],
  },
  { title: '短', strips: [] },
];

const index = buildIndex(books, { render: fakeRender });
const dir = mkdtempSync(join(tmpdir(), 'ebooksync-'));
writeFileSync(join(dir, 'CSLIB.8xv'), writeAppvar('CSLIB', index));

const output = execFileSync(join(HERE, 'lib_probe'), [dir], { encoding: 'utf8' });

const rows = { book: [], strip: [] };
let header = {};
for (const line of output.trim().split('\n')) {
  const parts = line.split(' ');
  if (parts[0] === 'books') header = { books: +parts[1], strips: +parts[3] };
  else if (rows[parts[0]]) {
    const row = {};
    for (let i = 2; i < parts.length - 1; i += 2) row[parts[i]] = parts[i + 1];
    rows[parts[0]].push(row);
  }
}

const checksum = (packed) => {
  let sum = 0n;
  for (const byte of packed) sum = (sum * 31n + BigInt(byte)) % (2n ** 64n);
  return sum.toString();
};

const failures = [];
const check = (label, actual, expected) => {
  if (String(actual) !== String(expected)) failures.push(`${label}: C ${actual} != JS ${expected}`);
};

const flat = books.flatMap((b) => b.strips);
check('book count', header.books, books.length);
check('strip count', header.strips, flat.length);

let first = 0;
books.forEach((book, i) => {
  const probe = rows.book[i] || {};
  const title = fakeRender(book.title, 300);
  check(`book ${i} first`, probe.first, first);
  check(`book ${i} count`, probe.count, book.strips.length);
  check(`book ${i} read`, probe.read, book.strips.filter((s) => s.read).length);
  check(`book ${i} title`, probe.title, `${title.width}x${title.height}`);
  check(`book ${i} sum`, probe.sum, checksum(title.packed));
  first += book.strips.length;
});

flat.forEach((strip, i) => {
  const probe = rows.strip[i] || {};
  const title = fakeRender(strip.title, 272);
  check(`strip ${i} slot`, probe.slot, strip.slot);
  check(`strip ${i} chunks`, probe.chunks, strip.chunkCount);
  check(`strip ${i} bytes`, probe.bytes, strip.size);
  check(`strip ${i} flags`, probe.flags, strip.read ? FLAG_READ : 0);
  check(`strip ${i} readat`, probe.readat, strip.readAt);
  check(`strip ${i} pos`, probe.pos, strip.pos);
  check(`strip ${i} layer`, probe.layer, strip.layer);
  check(`strip ${i} title`, probe.title, `${title.width}x${title.height}`);
  check(`strip ${i} sum`, probe.sum, checksum(title.packed));
});

const total = 2 + books.length * 5 + flat.length * 9;
for (const failure of failures) console.log('  FAIL ' + failure);
console.log(`index is ${index.length} bytes`);
console.log(`${total - failures.length}/${total} js library checks pass`);
process.exit(failures.length ? 1 : 0);
