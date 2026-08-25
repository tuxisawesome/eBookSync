/*
 * Caching converted strips in IndexedDB.
 *
 * Converting a long strip takes tens of seconds, almost all of it the ZX0
 * parse. Nothing about that depends on the calculator, so the result is kept
 * against the source file's hash and the settings that produced it: re-syncing
 * an unchanged library does no work at all, and changing a setting invalidates
 * exactly the strips it affects.
 */

const DB_NAME = 'ebooksync-cache';
const DB_STORE = 'containers';
const VERSION = 1;

function openDatabase() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, VERSION);
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

/** Everything about the settings that changes the bytes we produce. */
export function settingsKey(settings) {
  return [settings.detail, settings.colors, settings.dither ? 'd' : '', settings.despeckle ?? 32]
    .join(':');
}

export function cacheKey(srcHash, settings) {
  return `${srcHash}|${settingsKey(settings)}`;
}

export async function get(key) {
  try {
    return (await withStore('readonly', (store) => store.get(key))) || null;
  } catch {
    return null;
  }
}

export async function put(key, value) {
  try {
    await withStore('readwrite', (store) => store.put(value, key));
  } catch {
    /* A full or unavailable cache costs time, never correctness. */
  }
}

export async function clear() {
  await withStore('readwrite', (store) => store.clear());
}

/** Rough total size held, so the UI can offer to clear it. */
export async function size() {
  if (!navigator.storage || !navigator.storage.estimate) return null;
  const estimate = await navigator.storage.estimate();
  return estimate.usage || null;
}
