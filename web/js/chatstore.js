/*
 * What the sync computer keeps of the chat.
 *
 * The relay holds the real history; this is the middle ground between it and
 * the calculator, and it exists for one reason. The calculator's outbox is
 * cleared once its messages are stored *here*, not once they reach the relay --
 * so if the network is down when you sync, the messages are still safely off
 * the calculator and go up whenever the relay is next reachable.
 *
 * IndexedDB rather than localStorage because that is where the folder handle
 * and the conversion cache already live, and because a chat history outgrows
 * localStorage's few megabytes eventually.
 *
 * The relay's address and token are deliberately NOT in eos.json. That file
 * sits next to the comics and travels with the library folder; a bearer token
 * in it would be handed to anyone the folder is shared with.
 */

import { makeStore } from './idb.js';

const withStore = makeStore('eos-chat', 'chat');

/* Enough history for the page to be useful offline without becoming a second
 * database. The relay is the archive; this is a working copy. */
const MESSAGE_LIMIT = 5000;

async function read(key, fallback) {
  try {
    const value = await withStore('readonly', (store) => store.get(key));
    return value === undefined ? fallback : value;
  } catch {
    return fallback;
  }
}

async function write(key, value) {
  await withStore('readwrite', (store) => store.put(value, key));
}

/* ---------------------------------------------------------------- settings */

const DEFAULT_SETTINGS = {
  url: '',
  token: null,
  username: '',
  userId: null,
  displayName: '',
};

export async function settings() {
  return { ...DEFAULT_SETTINGS, ...(await read('settings', {})) };
}

export async function saveSettings(patch) {
  const merged = { ...(await settings()), ...patch };
  await write('settings', merged);
  return merged;
}

export async function signOut() {
  await saveSettings({ token: null, userId: null, username: '', displayName: '' });
}

/* ------------------------------------------------------------------- state */

export async function cursor() {
  return Number(await read('cursor', 0)) || 0;
}

export async function conversations() {
  return await read('conversations', []);
}

export async function roster() {
  return await read('roster', []);
}

export async function messages() {
  return await read('messages', []);
}

export async function setDirectory({ conversations: list, roster: people }) {
  if (list) await write('conversations', list);
  if (people) await write('roster', people);
}

/**
 * Merge in messages from the relay, keeping the list sorted and bounded.
 *
 * Keyed by id, so a message that arrives twice -- which happens whenever a
 * cursor is replayed -- lands once.
 */
export async function absorb(incoming, newCursor = null) {
  if (!incoming.length && newCursor === null) return await messages();

  const byId = new Map((await messages()).map((message) => [message.id, message]));
  for (const message of incoming) byId.set(message.id, message);

  const sorted = [...byId.values()].sort((a, b) => a.id - b.id);
  const kept = sorted.slice(-MESSAGE_LIMIT);

  await write('messages', kept);
  if (newCursor !== null) await write('cursor', Number(newCursor) || 0);
  return kept;
}

/* ------------------------------------------------------------------ outbox */

/*
 * Messages that exist here and not yet on the relay.
 *
 * Two sources: typed on this page while it was offline, and taken off the
 * calculator. Both are keyed by the clientId the relay de-duplicates on, so
 * uploading the same one twice is free and losing track of one is the only
 * failure worth worrying about.
 */
export async function pending() {
  return await read('pending', []);
}

export async function queue(items) {
  if (!items.length) return await pending();

  const byClientId = new Map((await pending()).map((item) => [item.clientId, item]));
  for (const item of items) byClientId.set(item.clientId, item);

  const merged = [...byClientId.values()];
  await write('pending', merged);
  return merged;
}

export async function clearPending(clientIds) {
  const gone = new Set(clientIds);
  const left = (await pending()).filter((item) => !gone.has(item.clientId));
  await write('pending', left);
  return left;
}

/* What the calculator was last told, so a sync can tell what has changed. */
export async function calculatorState() {
  return await read('calculator', { conversations: [], syncedAt: null });
}

export async function setCalculatorState(value) {
  await write('calculator', value);
}
