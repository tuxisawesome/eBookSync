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

const DB_NAME = 'ebooksync';
const DB_STORE = 'handles';
const HANDLE_KEY = 'library-root';

const IMAGE_PATTERN = /\.(jpe?g)$/i;

/* Natural order, so "10" sorts after "9", and Chinese names sort sensibly. */
const collator = new Intl.Collator(undefined, { numeric: true, sensitivity: 'base' });

export function isSupported() {
  return typeof window !== 'undefined' && 'showDirectoryPicker' in window;
}

function openDatabase() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, 1);
    request.onupgradeneeded = () => {
      if (!request.result.objectStoreNames.contains(DB_STORE)) {
        request.result.createObjectStore(DB_STORE);
      }
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

async function withStore(mode, action) {
  const db = await openDatabase();
  try {
    return await new Promise((resolve, reject) => {
      const tx = db.transaction(DB_STORE, mode);
      const request = action(tx.objectStore(DB_STORE));
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  } finally {
    db.close();
  }
}

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

/** Strip the extension and any leading numbering, for display. */
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
