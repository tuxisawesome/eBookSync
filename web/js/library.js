/*
 * Building the CSLIB index: what is on the calculator, and what it is called.
 *
 * Only content actually resident on the calculator goes in here -- the computer
 * stays the source of truth for the whole library. Mirrors tools/csx/library.py
 * and is parsed by calc/src/library.c; see docs/FORMAT.md.
 */

import { compress, decompress } from './zx0.js';
import { BOOK_WIDTH, STRIP_WIDTH, renderTitle } from './titles.js';

const MAGIC = 'CSLIB';
export const VERSION = 3;
export const NAME = 'CSLIB';

/*
 * The last 64 bytes of the header are the calculator's, not ours: its password
 * and its own settings. We write zeros there and it splices its own block back
 * in on INDEX_PUT, and zeros the block again on INDEX_GET -- which is what lets
 * indexIsStale() compare the two byte for byte.
 */
export const HEADER_SIZE = 92;
export const DEVICE_OFFSET = 28;
export const DEVICE_SIZE = 64;
export const LIBRARY_ID_SIZE = 16;
export const BOOK_SIZE = 6;
export const STRIP_SIZE = 17;

/*
 * The largest CSLIB the calculator will take.
 *
 * INDEX_PUT arrives in the same buffer as a chunk plus its arguments, and the
 * calculator refuses anything longer outright (usb.c). A calculator's worth of
 * strips has to fit in it -- which, unlike the library, is a real ceiling.
 */
export const MAX_INDEX_BYTES = 16384 + 8;

/*
 * The most strips the calculator can hold at once.
 *
 * LIST answers with a two-byte count and fifteen bytes a strip, all in one
 * 16 KB reply, and fails outright past this -- which would leave a calculator
 * nothing could sync with again.
 */
export const MAX_RESIDENT = Math.floor((16384 - 2) / 15);

/**
 * One title as it is stored in the index: a five-byte header and the
 * compressed bitmap.
 */
function titleEntry(text, maxWidth, render) {
  const { width, height, packed } = render(text, maxWidth);
  const payload = compress(packed);
  const entry = new Uint8Array(5 + payload.length);
  const view = new DataView(entry.buffer);
  view.setUint16(0, width, true);
  view.setUint8(2, height);
  view.setUint16(3, payload.length, true);
  entry.set(payload, 5);
  return entry;
}

/** How many bytes a title adds to the index. The planner uses it to see the
 *  index coming before it is too big to send. */
export function titleEntryBytes(text, maxWidth, render = renderTitle) {
  return titleEntry(text, maxWidth, render).length;
}

export const FLAG_READ = 0x01;

/* Set and cleared on the calculator, and carried back in every index sent so a
 * sync never drops it. A bookmarked strip is kept through clean-up. */
export const FLAG_BOOKMARK = 0x02;

/**
 * Serialise the index.
 *
 * `books` is `[{ title, strips: [{ title, slot, chunkCount, size, read,
 * bookmarked, readAt, pos, layer }] }]` in reading order.
 *
 * Titles are ZX0-compressed. Uncompressed they would push the index past the
 * 16 KB an appvar comfortably holds; compressed, a whole library's titles are a
 * couple of kilobytes and the reader expands only the row it is drawing.
 *
 * `render` is injectable so the index can be built where there is no canvas --
 * the host tests use a deterministic stand-in.
 */
export function buildIndex(books, { render = renderTitle, libraryId = null } = {}) {
  const strips = books.flatMap((book) => book.strips);
  if (books.length > 0xffff || strips.length > 0xffff) {
    throw new Error('too many books or strips for the index');
  }

  const titleBase = HEADER_SIZE + books.length * BOOK_SIZE + strips.length * STRIP_SIZE;
  const blob = [];
  let blobLength = 0;
  const offsets = new Map();

  /* Titles are deduplicated by text and width, so a repeated name is free. */
  const addTitle = (text, maxWidth) => {
    const key = `${maxWidth} ${text}`;
    if (offsets.has(key)) return offsets.get(key);

    const entry = titleEntry(text, maxWidth, render);
    const offset = titleBase + blobLength;
    offsets.set(key, offset);
    blob.push(entry);
    blobLength += entry.length;
    return offset;
  };

  const bookRows = new Uint8Array(books.length * BOOK_SIZE);
  const bookView = new DataView(bookRows.buffer);
  let first = 0;
  books.forEach((book, i) => {
    bookView.setUint16(i * BOOK_SIZE, addTitle(book.title, BOOK_WIDTH), true);
    bookView.setUint16(i * BOOK_SIZE + 2, first, true);
    bookView.setUint16(i * BOOK_SIZE + 4, book.strips.length, true);
    first += book.strips.length;
  });

  const stripRows = new Uint8Array(strips.length * STRIP_SIZE);
  const stripView = new DataView(stripRows.buffer);
  strips.forEach((strip, i) => {
    const at = i * STRIP_SIZE;
    const size = strip.size >>> 0;
    const pos = (strip.pos || 0) >>> 0;
    stripView.setUint16(at, strip.slot, true);
    stripView.setUint8(at + 2, strip.chunkCount);
    stripView.setUint16(at + 3, size & 0xffff, true);
    stripView.setUint8(at + 5, (size >>> 16) & 0xff);
    stripView.setUint8(at + 6, (strip.read ? FLAG_READ : 0)
      | (strip.bookmarked ? FLAG_BOOKMARK : 0));
    stripView.setUint32(at + 7, strip.readAt || 0, true);
    stripView.setUint16(at + 11, pos & 0xffff, true);
    stripView.setUint8(at + 13, (pos >>> 16) & 0xff);
    stripView.setUint8(at + 14, strip.layer || 0);
    stripView.setUint16(at + 15, addTitle(strip.title, STRIP_WIDTH), true);
  });

  const out = new Uint8Array(titleBase + blobLength);
  const view = new DataView(out.buffer);
  for (let i = 0; i < MAGIC.length; i++) view.setUint8(i, MAGIC.charCodeAt(i));
  view.setUint8(5, VERSION);
  view.setUint16(6, books.length, true);
  view.setUint16(8, strips.length, true);

  /* Which library folder these comics came from, so the calculator can tell
   * when it is handed somebody else's. */
  if (libraryId) out.set(libraryId.subarray(0, LIBRARY_ID_SIZE), 12);

  out.set(bookRows, HEADER_SIZE);
  out.set(stripRows, HEADER_SIZE + bookRows.length);

  let at = titleBase;
  for (const entry of blob) {
    out.set(entry, at);
    at += entry.length;
  }
  return out;
}

/** Read an index back -- used to merge the calculator's read state. */
export function parseIndex(data) {
  if (!data || data.length < HEADER_SIZE) return { books: [], strips: [] };

  const view = new DataView(data.buffer, data.byteOffset, data.byteLength);
  for (let i = 0; i < MAGIC.length; i++) {
    if (view.getUint8(i) !== MAGIC.charCodeAt(i)) throw new Error('not a CSLIB index');
  }
  const version = view.getUint8(5);
  if (version !== VERSION) throw new Error(`unsupported CSLIB version ${version}`);

  const bookCount = view.getUint16(6, true);
  const stripCount = view.getUint16(8, true);
  const stripBase = HEADER_SIZE + bookCount * BOOK_SIZE;

  const strips = [];
  for (let i = 0; i < stripCount; i++) {
    const at = stripBase + i * STRIP_SIZE;
    strips.push({
      slot: view.getUint16(at, true),
      chunkCount: view.getUint8(at + 2),
      size: view.getUint16(at + 3, true) | (view.getUint8(at + 5) << 16),
      read: (view.getUint8(at + 6) & FLAG_READ) !== 0,
      bookmarked: (view.getUint8(at + 6) & FLAG_BOOKMARK) !== 0,
      readAt: view.getUint32(at + 7, true),
      pos: view.getUint16(at + 11, true) | (view.getUint8(at + 13) << 16),
      layer: view.getUint8(at + 14),
    });
  }

  const books = [];
  for (let i = 0; i < bookCount; i++) {
    const at = HEADER_SIZE + i * BOOK_SIZE;
    const firstStrip = view.getUint16(at + 2, true);
    books.push({ strips: strips.slice(firstStrip, firstStrip + view.getUint16(at + 4, true)) });
  }
  return { books, strips, libraryId: data.slice(12, 12 + LIBRARY_ID_SIZE) };
}

/** Decode one title bitmap, for previewing what the calculator will show. */
export function readTitle(data, offset) {
  const view = new DataView(data.buffer, data.byteOffset, data.byteLength);
  const width = view.getUint16(offset, true);
  const height = view.getUint8(offset + 2);
  const length = view.getUint16(offset + 3, true);
  return { width, height, packed: decompress(data.subarray(offset + 5, offset + 5 + length)) };
}
