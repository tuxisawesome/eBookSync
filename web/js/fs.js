/*
 * Getting at the comics on disk.
 *
 * The user grants access to one directory; books are the folders inside it.
 * Inside a book, a strip is either one image or a folder of images, which are
 * read in natural order and stitched into one strip on the way to the
 * calculator -- a chapter that arrives as many slices stays as it arrived.
 * Nothing here ever writes a converted strip into the library folder. The handle is kept in IndexedDB so
 * reconnecting later is one click rather than a fresh directory picker.
 *
 * Chromium only -- the File System Access API does not exist in Firefox or
 * Safari, which is the same constraint WebUSB imposes anyway.
 */

import { makeStore } from './idb.js';

const HANDLE_KEY = 'library-root';

/*
 * What counts as a comic image: anything createImageBitmap() decodes in
 * Chromium. A GIF contributes its first frame. Matches IMAGE_SUFFIXES in
 * tools/csx/image.py.
 */
const IMAGE_PATTERN = /\.(jpe?g|png|webp|gif|bmp|avif)$/i;

/* Natural order, so "10" sorts after "9", digits come before letters, case is
 * ignored, and Chinese names sort sensibly. It is also the order the images of
 * a folder strip are stitched in. */
const collator = new Intl.Collator(undefined, { numeric: true, sensitivity: 'base' });

export function compareNames(a, b) {
  return collator.compare(a, b);
}

export function isSupported() {
  return typeof window !== 'undefined' && 'showDirectoryPicker' in window;
}

const withStore = makeStore('ebooksync', 'handles', { legacy: 'eos' });

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
  const handle = await window.showDirectoryPicker({ id: 'ebooksync', mode: 'readwrite' });
  await rememberDirectory(handle);
  return handle;
}

/** The display title: the filename without its extension. A folder strip's
 *  name is its title as it stands. */
export function titleFromFilename(name) {
  return name.replace(IMAGE_PATTERN, '');
}

function hex(buffer) {
  return Array.from(new Uint8Array(buffer), (b) => b.toString(16).padStart(2, '0')).join('');
}

export async function hashFile(file) {
  return hex(await crypto.subtle.digest('SHA-256', await file.arrayBuffer()));
}

/**
 * The images a scanned strip is made of, as Files, in reading order: one for
 * an image, every image in natural order for a folder.
 */
export async function stripFiles(strip) {
  if (strip.kind !== 'folder') return [await strip.handle.getFile()];
  return Promise.all(strip.parts.map((part) => part.handle.getFile()));
}

/**
 * What a strip's conversion is cached against.
 *
 * An image is its contents. A folder is its images' names and contents, in
 * order -- so adding an image, removing one, renaming one into a different
 * place or replacing one all make it a different strip, and none of them can
 * be served an old conversion.
 */
export async function hashStrip(strip, files = null) {
  files = files || await stripFiles(strip);
  if (strip.kind !== 'folder') return hashFile(files[0]);

  const lines = [];
  for (const [index, file] of files.entries()) {
    lines.push(`${strip.parts[index].name}\t${await hashFile(file)}`);
  }
  return hex(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(lines.join('\n'))));
}

/**
 * Walk the library.
 *
 * Returns `[{ name, strips }]` in reading order. A strip is
 * `{ kind: 'file', name, handle, size, stamp }` for an image, or
 * `{ kind: 'folder', name, handle, parts: [{ name, handle, size }], size,
 * stamp }` for a folder of images -- the folder's images in the order they are
 * read. A folder with no images in it is not a strip, and folders inside it are
 * not looked into.
 *
 * Files are not read here -- only their metadata -- so scanning a large library
 * stays cheap; hashing happens lazily when a strip is converted. `stamp`
 * changes whenever the strip's files do, which is what tells reconcile() a
 * remembered hash no longer describes them.
 */
export async function scanLibrary(root) {
  const books = [];

  for await (const entry of root.values()) {
    if (entry.kind !== 'directory') continue;

    const strips = [];
    for await (const child of entry.values()) {
      if (child.kind === 'file') {
        if (!IMAGE_PATTERN.test(child.name)) continue;
        const file = await child.getFile();
        strips.push({
          kind: 'file',
          name: child.name,
          handle: child,
          size: file.size,
          stamp: `${file.size}:${file.lastModified}`,
        });
      } else {
        const strip = await scanFolderStrip(child);
        if (strip) strips.push(strip);
      }
    }

    strips.sort((a, b) => collator.compare(a.name, b.name));
    books.push({ name: entry.name, strips });
  }

  books.sort((a, b) => collator.compare(a.name, b.name));
  return books;
}

/** A folder inside a book, as a strip of its images; null if it has none. */
async function scanFolderStrip(directory) {
  const parts = [];
  for await (const entry of directory.values()) {
    if (entry.kind !== 'file' || !IMAGE_PATTERN.test(entry.name)) continue;
    const file = await entry.getFile();
    parts.push({ name: entry.name, handle: entry, size: file.size,
                 lastModified: file.lastModified });
  }
  if (!parts.length) return null;

  parts.sort((a, b) => collator.compare(a.name, b.name));
  return {
    kind: 'folder',
    name: directory.name,
    handle: directory,
    parts,
    size: parts.reduce((sum, part) => sum + part.size, 0),
    stamp: parts.map((part) => `${part.name}:${part.size}:${part.lastModified}`).join('|'),
  };
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

/*
 * One file at the root of the library folder, beside ebooksync.json.
 *
 * scanLibrary() only looks inside directories, so a file put here cannot be
 * mistaken for a book or a strip -- which is what makes the root the right
 * place for the wallpaper.
 */
export async function readFile(root, name) {
  try {
    return await (await root.getFileHandle(name)).getFile();
  } catch {
    return null;
  }
}

export async function writeFile(root, name, blob) {
  const handle = await root.getFileHandle(name, { create: true });
  const stream = await handle.createWritable();
  try {
    await stream.write(blob);
  } finally {
    await stream.close();
  }
}

export async function removeFile(root, name) {
  try {
    await root.removeEntry(name);
    return true;
  } catch {
    return false;
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

async function entryExists(directory, name) {
  return await fileExists(directory, name) || await directoryExists(directory, name);
}

/** "001.jpg" -> "001 (2).jpg", or "第1话" -> "第1话 (2)", until nothing collides. */
export async function uniqueName(directory, name, { folder = false } = {}) {
  if (!await entryExists(directory, name)) return name;

  const extension = folder ? '' : extensionOf(name);
  const stem = name.slice(0, name.length - extension.length);
  for (let n = 2; n < 1000; n++) {
    const candidate = `${stem} (${n})${extension}`;
    if (!await entryExists(directory, candidate)) return candidate;
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

/** Delete a strip: an image, or a folder strip and every image in it. */
export async function deleteStrip(root, bookName, fileName) {
  const book = await root.getDirectoryHandle(bookName);
  await book.removeEntry(fileName, { recursive: true });
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

/*
 * Move everything in one folder into another, folders and all, then leave the
 * source empty for the caller to remove.
 *
 * There is no directory rename or move in the File System Access API -- move()
 * is only implemented for files -- so a folder moves by being rebuilt around
 * its files. Moving a file is cheap, so this costs about what a real rename
 * would; if it is interrupted the source keeps whatever has not moved yet, and
 * re-scanning shows both.
 */
async function moveDirectoryContents(source, target) {
  const entries = [];
  for await (const entry of source.values()) entries.push(entry);

  for (const entry of entries) {
    if (entry.kind === 'file') {
      await moveFile(entry, source, target, entry.name);
    } else {
      const inner = await target.getDirectoryHandle(entry.name, { create: true });
      await moveDirectoryContents(entry, inner);
      await source.removeEntry(entry.name, { recursive: true });
    }
  }
}

async function isFolder(directory, name) {
  return directoryExists(directory, name);
}

/**
 * Rename a strip. An image keeps its extension whatever was typed; a folder
 * strip is a folder, and gets none.
 */
export async function renameStrip(root, bookName, oldFile, newFile) {
  const book = await root.getDirectoryHandle(bookName);
  const folder = await isFolder(book, oldFile);

  const clean = folder ? validateName(newFile)
    : validateName(newFile, { extension: extensionOf(oldFile) });
  if (clean === oldFile) return clean;
  if (await entryExists(book, clean)) throw new Error(`"${clean}" already exists in this book.`);

  if (folder) {
    const source = await book.getDirectoryHandle(oldFile);
    await moveDirectoryContents(source, await book.getDirectoryHandle(clean, { create: true }));
    await book.removeEntry(oldFile, { recursive: true });
  } else {
    await moveFile(await book.getFileHandle(oldFile), book, book, clean);
  }
  return clean;
}

/**
 * Rename a book by moving its contents into a new folder.
 *
 * Its folder strips go with it, images and all. This used to move only the
 * files at the top of the book and then delete the old folder recursively,
 * which was harmless while every strip was a file and would now throw a
 * book's folder strips away.
 */
export async function renameBook(root, oldName, newName) {
  const clean = validateName(newName);
  if (clean === oldName) return clean;
  if (await directoryExists(root, clean)) throw new Error(`"${clean}" already exists.`);

  const source = await root.getDirectoryHandle(oldName);
  const target = await root.getDirectoryHandle(clean, { create: true });
  await moveDirectoryContents(source, target);

  await root.removeEntry(oldName, { recursive: true });
  return clean;
}

export async function moveStripToBook(root, fromBook, toBook, fileName) {
  if (fromBook === toBook) return fileName;

  const source = await root.getDirectoryHandle(fromBook);
  const target = await root.getDirectoryHandle(toBook);

  if (await isFolder(source, fileName)) {
    const name = await uniqueName(target, fileName, { folder: true });
    const from = await source.getDirectoryHandle(fileName);
    await moveDirectoryContents(from, await target.getDirectoryHandle(name, { create: true }));
    await source.removeEntry(fileName, { recursive: true });
    return name;
  }

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

/**
 * Copy a folder of images into a book as one strip.
 *
 * The folder is named after the dropped one, uniquified against whatever is
 * already in the book, and the images keep their names -- their names are
 * their order. Returns the folder's name.
 */
export async function importFolderStrip(root, bookName, folderName, files,
                                        onProgress = () => {}) {
  const book = await root.getDirectoryHandle(bookName, { create: true });
  const name = await uniqueName(book, validateName(folderName), { folder: true });
  const folder = await book.getDirectoryHandle(name, { create: true });
  for (const [index, file] of [...files].entries()) {
    if (!IMAGE_PATTERN.test(file.name)) continue;
    onProgress({ name: file.name, index, total: files.length });
    const handle = await folder.getFileHandle(file.name, { create: true });
    const stream = await handle.createWritable();
    try {
      await stream.write(file);
    } finally {
      await stream.close();
    }
  }
  return name;
}

export function isImageName(name) {
  return IMAGE_PATTERN.test(name);
}

/**
 * Pull files out of a drop, including whole folders.
 *
 * Returns `{ loose, folders }`. `folders` maps each dropped folder's name to
 * `{ files, subfolders }`: the images directly inside it, and each folder
 * inside that mapped to its own images. What they become depends on where
 * they land -- see importDrop() in main.js -- but a folder of images is always
 * one strip, since that is how a chapter of slices arrives.
 */
async function imagesIn(directory) {
  const files = [];
  for await (const entry of directory.values()) {
    if (entry.kind !== 'file' || !IMAGE_PATTERN.test(entry.name)) continue;
    files.push(await entry.getFile());
  }
  return files.sort((a, b) => collator.compare(a.name, b.name));
}

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
        const files = await imagesIn(handle);
        const subfolders = new Map();
        for await (const entry of handle.values()) {
          if (entry.kind !== 'directory') continue;
          const inner = await imagesIn(entry);
          if (inner.length) subfolders.set(entry.name, inner);
        }
        if (files.length || subfolders.size) folders.set(handle.name, { files, subfolders });
      }
    }
    return { loose, folders };
  }

  for (const file of dataTransfer.files || []) {
    if (IMAGE_PATTERN.test(file.name)) loose.push(file);
  }
  return { loose, folders };
}
