/*
 * ebooksync.json: the order of things, what has been read, what is selected,
 * and when we last synced.
 *
 * It lives in the root of the library directory so the state travels with the
 * comics. The calculator is authoritative for read flags and scroll positions
 * -- that is where reading happens -- and this file is authoritative for
 * everything else, including the order books and strips appear in.
 *
 * Order is stored here rather than inferred from filenames because the point of
 * the library editor is to let you arrange a library that does not happen to
 * sort the way you want it read. The order flows straight through to the
 * calculator: CSLIB lists books and strips in array order, and the reader draws
 * them in the order it finds them.
 */

import { readJson, writeJson, titleFromFilename } from './fs.js';
import { DEFAULT_PRESET, LAYER_PRESETS } from './convert.js';

export const META_FILENAME = 'ebooksync.json';
export const VERSION = 4;

/*
 * What eBookSync called the same file.
 *
 * A library folder is the user's own directory of comics, so the rename happens
 * on their disk: load() reads the old name when the new one is not there and
 * carries the library id across, and the next save writes the new one. The old
 * file is left alone rather than deleted -- it costs a few kilobytes, and an
 * eBookSync that turns out to be a mistake should be able to be walked back.
 */
export const LEGACY_META_FILENAME = 'ebooksync.json';

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

/*
 * A library's identity, generated once and kept in its metadata file.
 *
 * The calculator stores it alongside the comics and compares it on every
 * connection, so plugging into a calculator holding a different library is
 * noticed rather than quietly mixed together.
 */
function newLibraryId() {
  const bytes = new Uint8Array(16);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
}

export function libraryIdBytes(meta) {
  const out = new Uint8Array(16);
  const hex = String(meta.libraryId || '');
  for (let i = 0; i < 16; i++) out[i] = parseInt(hex.substr(i * 2, 2), 16) || 0;
  return out;
}

/** The hex form of an id read back out of an index. */
export function libraryIdHex(bytes) {
  if (!bytes || bytes.length < 16) return null;
  const hex = Array.from(bytes.subarray(0, 16), (b) => b.toString(16).padStart(2, '0')).join('');
  return /^0{32}$/.test(hex) ? null : hex;
}

/**
 * Give a library an identity it does not yet have.
 *
 * Adopting the calculator's is right rather than merely convenient: a folder
 * with no identity has never successfully claimed a calculator, so taking the
 * identity of the one it is plugged into is exactly what the first sync would
 * have done. Minting a fresh one instead would declare a calculator full of
 * this library's own comics to be somebody else's.
 */
export function adoptLibraryId(meta, fromCalculator) {
  if (meta.libraryId) return meta.libraryId;
  meta.libraryId = fromCalculator || newLibraryId();
  return meta.libraryId;
}

export function defaultMeta() {
  return {
    version: VERSION,
    libraryId: newLibraryId(),
    lastSync: null,
    settings: { ...DEFAULT_SETTINGS },
    books: {},
  };
}

export async function load(root) {
  let raw = await readJson(root, META_FILENAME);
  if (!raw || typeof raw !== 'object') raw = await readJson(root, LEGACY_META_FILENAME);
  if (!raw || typeof raw !== 'object') return defaultMeta();

  const meta = defaultMeta();

  /*
   * Keep the identity a library already has. A file without one is left with
   * none rather than given a fresh one: that is the state left behind by the
   * versions that dropped it on save, and inventing an identity there is what
   * makes a calculator holding this library's own comics look like somebody
   * else's. connect() adopts the calculator's instead. See adoptLibraryId().
   */
  meta.libraryId = (typeof raw.libraryId === 'string' && raw.libraryId.length === 32)
    ? raw.libraryId
    : null;
  meta.lastSync = typeof raw.lastSync === 'string' ? raw.lastSync : null;
  meta.settings = { ...DEFAULT_SETTINGS, ...(raw.settings || {}) };
  if (!(meta.settings.detail in LAYER_PRESETS)) meta.settings.detail = DEFAULT_PRESET;
  meta.settings.keepRead = Math.max(0, Number(meta.settings.keepRead) || 0);
  meta.settings.maxDeviceBytes = Number(meta.settings.maxDeviceBytes) || DEFAULT_DEVICE_BUDGET;
  meta.books = raw.books && typeof raw.books === 'object' ? raw.books : {};

  /* Version 1 had no order fields. Anything without one picks its order up in
   * reconcile() from the natural sort the scan already did, which is exactly
   * the order a version 1 library was displayed in.
   *
   * Version 4 is the eBookSync-to-eBookSync rename and changes nothing in here -- the
   * library id is what matters and it is carried across above, so a library
   * that has already been synced is still recognised as the same one. */
  return meta;
}

/**
 * What actually goes into eos.json.
 *
 * Defined here, beside load(), and not at the call site -- the two have to
 * agree on the field list, and when they did not the effect was quietly
 * terrible: `libraryId` was read on load and dropped on save, so every page
 * load minted a fresh identity and every reconnect reported the calculator as
 * holding somebody else's library.
 *
 * The JSON round trip is what removes any live file handle that found its way
 * in; those cannot be stored and must not be.
 */
export function serialisable(meta) {
  return JSON.parse(JSON.stringify({
    version: VERSION,
    libraryId: meta.libraryId,
    lastSync: meta.lastSync,
    settings: meta.settings,
    books: meta.books,
  }));
}

export async function save(root, meta) {
  await writeJson(root, META_FILENAME, serialisable(meta));
}

/* ------------------------------------------------------------------ ordering */

const hasOrder = (entry) => Number.isFinite(entry && entry.order);

function nextOrder(entries) {
  let max = -1;
  for (const entry of entries) {
    if (hasOrder(entry) && entry.order > max) max = entry.order;
  }
  return max + 1;
}

/** Renumber a sorted list to 0..n-1, so orders stay dense and comparable. */
function renumber(entries) {
  entries.forEach((entry, index) => { entry.order = index; });
}

/** Book names in display order. */
export function bookNames(meta) {
  return Object.keys(meta.books).sort((a, b) => {
    const left = meta.books[a].order;
    const right = meta.books[b].order;
    if (left !== right) return left - right;
    return a.localeCompare(b);
  });
}

/** Filenames of one book in display order. */
export function stripNames(meta, bookName) {
  const book = meta.books[bookName];
  if (!book) return [];
  return Object.keys(book.strips).sort((a, b) => {
    const left = book.strips[a].order;
    const right = book.strips[b].order;
    if (left !== right) return left - right;
    return a.localeCompare(b);
  });
}

/**
 * Fold a fresh directory scan into the metadata.
 *
 * New strips get a slot and land at the end of their book rather than wherever
 * their filename happens to sort -- dropping episode 15 into a library should
 * put it after 14, not somewhere in the middle. Strips whose file has vanished
 * are dropped, along with books that end up empty of both files and metadata.
 * Slots are stable identities -- they name the appvars on the calculator -- so
 * an existing one is never reassigned.
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
  const previousBooks = Object.values(meta.books);
  let bookOrder = nextOrder(previousBooks);

  for (const book of books) {
    const previous = meta.books[book.name] || {};
    const strips = {};
    let stripOrder = nextOrder(Object.values(previous.strips || {}));

    for (const strip of book.strips) {
      const before = (previous.strips || {})[strip.name] || {};
      strips[strip.name] = {
        id: Number.isInteger(before.id) ? before.id : nextSlot(),
        order: hasOrder(before) ? before.order : stripOrder++,
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

    /* An empty book is kept: you can create one in the editor and fill it
     * later, and deleting it is an explicit action. */
    merged[book.name] = {
      order: hasOrder(previous) ? previous.order : bookOrder++,
      strips,
    };
  }

  meta.books = merged;
  normalise(meta);
  return meta;
}

/** Squeeze every order back to 0..n-1. Cheap, and keeps the file tidy. */
export function normalise(meta) {
  renumber(bookNames(meta).map((name) => meta.books[name]));
  for (const name of Object.keys(meta.books)) {
    renumber(stripNames(meta, name).map((file) => meta.books[name].strips[file]));
  }
  return meta;
}

/*
 * `toIndex` means "put it where the row currently at toIndex is", counting in
 * the list as it looks *before* the move. That is what a drag lands on -- you
 * drop onto a row you can see -- so dropping on the row below something moves
 * it down by one. Pulling the item out first would shift every index after it
 * and make a downward drag land one short.
 */
function moveWithin(names, from, toIndex) {
  const [item] = names.splice(from, 1);
  const target = from < toIndex ? toIndex - 1 : toIndex;
  names.splice(Math.max(0, Math.min(target, names.length)), 0, item);
  return names;
}

/** Move a book to a new position in the book list. */
export function reorderBook(meta, name, toIndex) {
  const names = bookNames(meta);
  const from = names.indexOf(name);
  if (from < 0) return meta;

  renumber(moveWithin(names, from, toIndex).map((each) => meta.books[each]));
  return meta;
}

/** Move a strip to a new position within its book. */
export function reorderStrip(meta, bookName, file, toIndex) {
  const book = meta.books[bookName];
  if (!book || !book.strips[file]) return meta;

  const files = stripNames(meta, bookName);
  renumber(moveWithin(files, files.indexOf(file), toIndex).map((each) => book.strips[each]));
  return meta;
}

/* ------------------------------------------------- structural edits */

/**
 * Rekey a book after its folder was renamed on disk.
 *
 * The slot ids, read state and order ride along, so renaming a book does not
 * cost you a re-sync of its contents -- only the titles on the calculator
 * change.
 */
export function renameBookKey(meta, oldName, newName) {
  if (oldName === newName || !meta.books[oldName]) return meta;
  if (meta.books[newName]) throw new Error(`a book called "${newName}" already exists`);

  meta.books[newName] = meta.books[oldName];
  delete meta.books[oldName];
  return meta;
}

/** Rekey a strip after its file was renamed on disk. */
export function renameStripKey(meta, bookName, oldFile, newFile) {
  const book = meta.books[bookName];
  if (!book || oldFile === newFile || !book.strips[oldFile]) return meta;
  if (book.strips[newFile]) throw new Error(`"${newFile}" already exists in this book`);

  book.strips[newFile] = book.strips[oldFile];
  delete book.strips[oldFile];
  return meta;
}

/** Move a strip's metadata to another book, appending it at the end. */
export function moveStripKey(meta, fromBook, toBook, file) {
  const source = meta.books[fromBook];
  const target = meta.books[toBook];
  if (!source || !target || !source.strips[file]) return meta;
  if (target.strips[file]) throw new Error(`"${file}" already exists in "${toBook}"`);

  const state = source.strips[file];
  delete source.strips[file];
  state.order = nextOrder(Object.values(target.strips));
  target.strips[file] = state;
  return meta;
}

export function addBookKey(meta, name) {
  if (meta.books[name]) throw new Error(`a book called "${name}" already exists`);
  meta.books[name] = { order: nextOrder(Object.values(meta.books)), strips: {} };
  return meta;
}

export function removeBookKey(meta, name) {
  delete meta.books[name];
  return normalise(meta);
}

export function removeStripKey(meta, bookName, file) {
  const book = meta.books[bookName];
  if (book) delete book.strips[file];
  return normalise(meta);
}

/* ------------------------------------------------------------------- views */

/**
 * Every strip as a flat list in display order, with its book and filename.
 *
 * Driven by the stored order rather than the directory scan; the scan only
 * supplies the file handles. This is the order that reaches the calculator.
 */
export function flatten(meta, books) {
  const handles = new Map();
  for (const book of books) {
    for (const strip of book.strips) handles.set(`${book.name}/${strip.name}`, strip.handle);
  }

  const out = [];
  for (const bookName of bookNames(meta)) {
    for (const file of stripNames(meta, bookName)) {
      out.push({
        book: bookName,
        file,
        title: titleFromFilename(file),
        handle: handles.get(`${bookName}/${file}`) || null,
        state: meta.books[bookName].strips[file],
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
      /*
       * Anything on the calculator shows as ticked. Unticking it is then how
       * you ask for it to be removed on the next sync -- the tick means "I want
       * this on the calculator", not "send this now".
       */
      state.selected = true;
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
