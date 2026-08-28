/*
 * Getting at the comics on disk.
 *
 * The user grants access to one directory; books are the folders inside it and
 * strips are the JPEGs inside those. The handle is kept in IndexedDB so
 * reconnecting later is one click rather than a fresh directory picker.
 *
 * Chromium only -- the File System Access API does not exist in Firefox or
 * Safari, which is the same constraint WebUSB imposes anyway.
 */

import { makeStore } from './idb.js';

const HANDLE_KEY = 'library-root';

const IMAGE_PATTERN = /\.(jpe?g)$/i;

/* Natural order, so "10" sorts after "9", and Chinese names sort sensibly. */
const collator = new Intl.Collator(undefined, { numeric: true, sensitivity: 'base' });

export function isSupported() {
  return typeof window !== 'undefined' && 'showDirectoryPicker' in window;
}

const withStore = makeStore('eos', 'handles', { legacy: 'ebooksync' });

export async function rememberDirectory(handle) {
  await withStore('readwrite', (store) => store.put(handle, HANDLE_KEY));
}

export async function forgetDirectory() {
  await withStore('readwrite', (store) => store.delete(HANDLE_KEY));
}

/**
 * The directory from last time, if the browser still has permission.
 *
 * Returns null when nothing was stored or when permission has lapsed --
 * `prompt` decides whether to ask the user to re-grant it, which browsers only
 * allow from a user gesture.
 */
export async function restoreDirectory({ prompt = false } = {}) {
  let handle;
  try {
    handle = await withStore('readonly', (store) => store.get(HANDLE_KEY));
  } catch {
    return null;
  }
  if (!handle) return null;

  const options = { mode: 'readwrite' };
  if (await handle.queryPermission(options) === 'granted') return handle;
  if (!prompt) return null;
  return await handle.requestPermission(options) === 'granted' ? handle : null;
}

export async function pickDirectory() {
  const handle = await window.showDirectoryPicker({ id: 'eos', mode: 'readwrite' });
  await rememberDirectory(handle);
  return handle;
}

/** The display title: the filename without its extension. */
export function titleFromFilename(name) {
  return name.replace(IMAGE_PATTERN, '');
}

export async function hashFile(file) {
  const digest = await crypto.subtle.digest('SHA-256', await file.arrayBuffer());
  return Array.from(new Uint8Array(digest), (b) => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Walk the library.
 *
 * Returns `[{ name, strips: [{ name, handle, size, lastModified }] }]` in
 * reading order. Files are not read here -- only their metadata -- so scanning
 * a large library stays cheap; hashing happens lazily when a strip is
 * converted.
 */
export async function scanLibrary(root) {
  const books = [];

  for await (const entry of root.values()) {
    if (entry.kind !== 'directory') continue;

    const strips = [];
    for await (const child of entry.values()) {
      if (child.kind !== 'file' || !IMAGE_PATTERN.test(child.name)) continue;
      const file = await child.getFile();
      strips.push({
        name: child.name,
        handle: child,
        size: file.size,
        lastModified: file.lastModified,
      });
    }

    strips.sort((a, b) => collator.compare(a.name, b.name));
    books.push({ name: entry.name, strips });
  }

  books.sort((a, b) => collator.compare(a.name, b.name));
  return books;
}

export async function readJson(root, name) {
  try {
    const handle = await root.getFileHandle(name);
    const text = await (await handle.getFile()).text();
    return JSON.parse(text);
  } catch {
    return null;
  }
}

export async function writeJson(root, name, value) {
  const handle = await root.getFileHandle(name, { create: true });
  const stream = await handle.createWritable();
  try {
    await stream.write(`${JSON.stringify(value, null, 2)}\n`);
  } finally {
    await stream.close();
  }
}

/* ------------------------------------------------------------ library edits */

/*
 * Names that would confuse the filesystem or escape the library directory.
 * Windows also refuses a handful of reserved device names, and browsers reject
 * trailing dots, so this is stricter than strictly necessary rather than let a
 * rename fail halfway through moving a book's files.
 */
const RESERVED = /^(con|prn|aux|nul|com[1-9]|lpt[1-9])$/i;
const CONTROL_CHARS = /[\u0000-\u001f\u007f]/;

export function validateName(name, { extension = null } = {}) {
  const trimmed = String(name).trim();

  if (!trimmed) throw new Error('The name cannot be empty.');
  if (trimmed.length > 100) throw new Error('That name is too long.');
  if (/[\\/:*?"<>|]/.test(trimmed)) throw new Error('A name cannot contain \\ / : * ? " < > or |');
  if (CONTROL_CHARS.test(trimmed)) throw new Error('That name contains control characters.');
  if (trimmed === '.' || trimmed === '..') throw new Error('That name is not allowed.');
  if (trimmed.endsWith('.')) throw new Error('A name cannot end with a dot.');
  if (RESERVED.test(trimmed.replace(/\..*$/, ''))) {
    throw new Error(`"${trimmed}" is a reserved name on Windows.`);
  }
  if (extension && !trimmed.toLowerCase().endsWith(extension.toLowerCase())) {
    return trimmed + extension;
  }
  return trimmed;
}

/** Keep the extension when a strip is renamed, whatever the user typed. */
export function extensionOf(filename) {
  const match = /\.[^.]+$/.exec(filename);
  return match ? match[0] : '.jpg';
}

async function directoryExists(root, name) {
  try {
    await root.getDirectoryHandle(name);
    return true;
  } catch {
    return false;
  }
}

async function fileExists(directory, name) {
  try {
    await directory.getFileHandle(name);
    return true;
  } catch {
    return false;
  }
}

/** "001.jpg" -> "001 (2).jpg" until nothing collides. */
export async function uniqueName(directory, name) {
  if (!await fileExists(directory, name)) return name;

  const extension = extensionOf(name);
  const stem = name.slice(0, name.length - extension.length);
  for (let n = 2; n < 1000; n++) {
    const candidate = `${stem} (${n})${extension}`;
    if (!await fileExists(directory, candidate)) return candidate;
  }
  throw new Error(`Too many files named like "${name}".`);
}

export async function createBook(root, name) {
  const clean = validateName(name);
  if (await directoryExists(root, clean)) throw new Error(`"${clean}" already exists.`);
  await root.getDirectoryHandle(clean, { create: true });
  return clean;
}

export async function deleteBook(root, name) {
  await root.removeEntry(name, { recursive: true });
}

export async function deleteStrip(root, bookName, fileName) {
  const book = await root.getDirectoryHandle(bookName);
  await book.removeEntry(fileName);
}

/*
 * Move a file, preferring the filesystem's own move.
 *
 * FileSystemFileHandle.move() relinks the file without touching its contents,
 * which matters when a strip is a couple of megabytes. Where it is missing we
 * copy the bytes and delete the original -- correct, just slower. The order
 * matters: the original only goes once the copy is safely closed.
 */
async function moveFile(fileHandle, sourceDirectory, targetDirectory, newName) {
  if (typeof fileHandle.move === 'function') {
    try {
      if (sourceDirectory === targetDirectory) await fileHandle.move(newName);
      else await fileHandle.move(targetDirectory, newName);
      return;
    } catch (error) {
      /* A refused permission will refuse the fallback too; anything else is
       * likely "not implemented here", so do it the long way. */
      if (error.name === 'NotAllowedError') throw error;
    }
  }

  const file = await fileHandle.getFile();
  const destination = await targetDirectory.getFileHandle(newName, { create: true });
  const stream = await destination.createWritable();
  try {
    await stream.write(file);
  } finally {
    await stream.close();
  }
  await sourceDirectory.removeEntry(fileHandle.name);
}

export async function renameStrip(root, bookName, oldFile, newFile) {
  const clean = validateName(newFile, { extension: extensionOf(oldFile) });
  if (clean === oldFile) return clean;

  const book = await root.getDirectoryHandle(bookName);
  if (await fileExists(book, clean)) throw new Error(`"${clean}" already exists in this book.`);

  await moveFile(await book.getFileHandle(oldFile), book, book, clean);
  return clean;
}

/**
 * Rename a book by moving its contents into a new folder.
 *
 * There is no directory rename in the File System Access API -- move() is only
 * implemented for files -- so this creates the new folder, moves every file
 * across, and removes the old one. Moving files is cheap, so this costs about
 * as much as a real rename would; if it is interrupted the old folder survives
 * with whatever has not moved yet, and re-scanning shows both.
 */
export async function renameBook(root, oldName, newName) {
  const clean = validateName(newName);
  if (clean === oldName) return clean;
  if (await directoryExists(root, clean)) throw new Error(`"${clean}" already exists.`);

  const source = await root.getDirectoryHandle(oldName);
  const target = await root.getDirectoryHandle(clean, { create: true });

  const files = [];
  for await (const entry of source.values()) {
    if (entry.kind === 'file') files.push(entry);
  }
  for (const entry of files) await moveFile(entry, source, target, entry.name);

  await root.removeEntry(oldName, { recursive: true });
  return clean;
}

export async function moveStripToBook(root, fromBook, toBook, fileName) {
  if (fromBook === toBook) return fileName;

  const source = await root.getDirectoryHandle(fromBook);
  const target = await root.getDirectoryHandle(toBook);
  const name = await uniqueName(target, fileName);

  await moveFile(await source.getFileHandle(fileName), source, target, name);
  return name;
}

/**
 * Copy dropped files into a book.
 *
 * Files come from outside the library, so they are copied rather than moved --
 * dragging a comic in should not empty the folder you dragged it from. Returns
 * the names actually written, which may have been uniquified.
 */
export async function importFiles(root, bookName, files, onProgress = () => {}) {
  const book = await root.getDirectoryHandle(bookName, { create: true });
  const written = [];

  for (const [index, file] of [...files].entries()) {
    if (!IMAGE_PATTERN.test(file.name)) continue;
    onProgress({ name: file.name, index, total: files.length });

    const name = await uniqueName(book, file.name);
    const handle = await book.getFileHandle(name, { create: true });
    const stream = await handle.createWritable();
    try {
      await stream.write(file);
    } finally {
      await stream.close();
    }
    written.push(name);
  }
  return written;
}

export function isImageName(name) {
  return IMAGE_PATTERN.test(name);
}

/**
 * Pull files out of a drop, including whole folders.
 *
 * A dropped folder becomes a book of its own; loose files land in whichever
 * book they were dropped on. Returns `{ loose, folders }`, where `folders` maps
 * a folder name to the images inside it.
 */
export async function readDrop(dataTransfer) {
  const loose = [];
  const folders = new Map();

  const items = [...(dataTransfer.items || [])].filter((item) => item.kind === 'file');

  /* getAsFileSystemHandle is the only way to see inside a dropped folder; where
   * it is missing we still get the loose files from dataTransfer.files. */
  if (items.length && typeof items[0].getAsFileSystemHandle === 'function') {
    const handles = await Promise.all(items.map((item) => item.getAsFileSystemHandle()));
    for (const handle of handles) {
      if (!handle) continue;
      if (handle.kind === 'file') {
        const file = await handle.getFile();
        if (IMAGE_PATTERN.test(file.name)) loose.push(file);
      } else {
        const files = [];
        for await (const entry of handle.values()) {
          if (entry.kind !== 'file' || !IMAGE_PATTERN.test(entry.name)) continue;
          files.push(await entry.getFile());
        }
        files.sort((a, b) => collator.compare(a.name, b.name));
        if (files.length) folders.set(handle.name, files);
      }
    }
    return { loose, folders };
  }

  for (const file of dataTransfer.files || []) {
    if (IMAGE_PATTERN.test(file.name)) loose.push(file);
  }
  return { loose, folders };
}
