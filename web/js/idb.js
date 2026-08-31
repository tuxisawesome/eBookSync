/*
 * The key-value stores the page keeps in IndexedDB, and the one-time move off
 * whatever name they were last under.
 *
 * Both stores -- the library folder handle and the converted-container cache --
 * are a plain map opened exactly the same way, so the mechanics live here once
 * rather than twice.
 *
 * The rename is the reason this file exists at all. A database name is part of
 * a store's identity, so renaming one silently abandons everything in it: the
 * directory handle is what lets the page reopen your library without asking,
 * and the container cache is tens of seconds of ZX0 work per strip. Starting
 * Starting with both gone would look exactly like a bug, so the first use of a
 * store adopts whatever the old database held and then drops it.
 */

function open(name, storeName) {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(name, 1);
    request.onupgradeneeded = () => {
      if (!request.result.objectStoreNames.contains(storeName)) {
        request.result.createObjectStore(storeName);
      }
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

function run(db, storeName, mode, action) {
  return new Promise((resolve, reject) => {
    const tx = db.transaction(storeName, mode);
    const request = action(tx.objectStore(storeName));
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

/* Every key and value in a store, or an empty list if it is not there. */
function readAll(db, storeName) {
  return new Promise((resolve, reject) => {
    if (!db.objectStoreNames.contains(storeName)) {
      resolve([]);
      return;
    }
    const entries = [];
    const request = db.transaction(storeName, 'readonly').objectStore(storeName).openCursor();
    request.onsuccess = () => {
      const cursor = request.result;
      if (!cursor) {
        resolve(entries);
        return;
      }
      entries.push([cursor.key, cursor.value]);
      cursor.continue();
    };
    request.onerror = () => reject(request.error);
  });
}

function drop(name) {
  return new Promise((resolve) => {
    const request = indexedDB.deleteDatabase(name);
    /* A blocked delete means another tab still has it open. Not worth waiting
     * for -- the data has already been copied, and the next run will retry. */
    request.onsuccess = request.onerror = request.onblocked = () => resolve();
  });
}

/**
 * A key-value store, adopting `legacy`'s contents the first time it is used.
 *
 * Returns `withStore(mode, action)` with the same shape both callers already
 * had: `action` is handed the object store and returns an IDBRequest.
 */
export function makeStore(name, storeName, { legacy = null } = {}) {
  let adopted = null;

  async function adopt() {
    if (!legacy) return;

    /*
     * Ask first. indexedDB.open() creates the database it is asked for, so
     * probing for the old one by opening it would resurrect it on every run
     * after the migration -- and then delete it again, forever.
     */
    try {
      if (!indexedDB.databases) return;
      const present = await indexedDB.databases();
      if (!present.some((entry) => entry.name === legacy)) return;
    } catch {
      return;
    }

    const from = await open(legacy, storeName);
    let entries;
    try {
      entries = await readAll(from, storeName);
    } finally {
      from.close();
    }

    if (entries.length) {
      const to = await open(name, storeName);
      try {
        for (const [key, value] of entries) {
          /* Never overwrite: anything already here is newer than what the old
           * database is holding. */
          if ((await run(to, storeName, 'readonly', (store) => store.get(key))) === undefined) {
            await run(to, storeName, 'readwrite', (store) => store.put(value, key));
          }
        }
      } finally {
        to.close();
      }
    }

    await drop(legacy);
  }

  return async function withStore(mode, action) {
    /* Once per page load, and every caller waits on the same attempt. A failed
     * migration must not take the store down with it: losing a cache is a
     * slower sync, not a broken one. */
    if (!adopted) adopted = adopt().catch(() => {});
    await adopted;

    const db = await open(name, storeName);
    try {
      return await run(db, storeName, mode, action);
    } finally {
      db.close();
    }
  };
}
