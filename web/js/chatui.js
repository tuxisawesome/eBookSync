/*
 * The chat panel on the sync page.
 *
 * The same conversations the PWA shows, from the same relay -- this exists
 * because the sync computer is where you already are when you plug the
 * calculator in, and because messages typed here have to reach the calculator
 * on the next sync just like everyone else's.
 *
 * It polls, for the same reason the PWA does: PythonAnywhere has no WebSockets.
 * Slower than the PWA, because a page you are using to sort comics does not
 * need three-second latency and a background tab should not be chattering.
 */

import { Relay, Unauthorised, pageClientId } from './chat.js';
import * as store from './chatstore.js';

const POLL_VISIBLE = 8000;
const POLL_HIDDEN = 60000;

/*
 * How often to re-read the conversation list and the roster.
 *
 * Messages change constantly; who exists and who has a calculator does not.
 * Fetching the whole directory on every poll made a background tab a steady
 * load on the relay for information that had not changed, so it now happens on
 * sign-in and every couple of minutes after that.
 */
const DIRECTORY_EVERY = 120000;

const el = (id) => document.getElementById(id);

const ui = {
  tabLibrary: el('tab-library'),
  tabChat: el('tab-chat'),
  libraryView: el('library-view'),
  chatView: el('chat-view'),
  title: el('chat-title'),
  link: el('chat-link'),
  error: el('chat-error'),
  form: el('relay-form'),
  url: el('relay-url'),
  user: el('relay-user'),
  pass: el('relay-pass'),
  signIn: el('relay-signin'),
  signOut: el('relay-signout'),
  body: el('chat-body'),
  conversations: el('chat-conversations'),
  messages: el('chat-messages'),
  composer: el('chat-composer'),
  draft: el('chat-draft'),
};

const state = {
  relay: null,
  settings: null,
  conversations: [],
  roster: [],
  messages: [],
  current: null,
  timer: null,
  failures: 0,
  directoryAt: 0,
};

/* What main.js needs: the relay to upload through, and who we are. */
export function relay() {
  return state.relay;
}

export function account() {
  return state.settings && state.settings.userId
    ? { id: state.settings.userId, username: state.settings.username }
    : null;
}

/* ---------------------------------------------------------------- chrome */

function setLink(text, kind = '') {
  ui.link.textContent = text;
  ui.link.className = `chip ${kind}`;
}

function setError(message) {
  ui.error.hidden = !message;
  ui.error.textContent = message || '';
}

function showSignedIn(signedIn) {
  ui.signIn.hidden = signedIn;
  ui.signOut.hidden = !signedIn;
  ui.body.hidden = !signedIn;
  ui.url.disabled = signedIn;
  ui.user.disabled = signedIn;
  ui.pass.disabled = signedIn;
  ui.pass.value = '';
}

export function showTab(which) {
  const chat = which === 'chat';
  ui.libraryView.hidden = chat;
  ui.chatView.hidden = !chat;
  ui.tabLibrary.setAttribute('aria-selected', String(!chat));
  ui.tabChat.setAttribute('aria-selected', String(chat));
  if (chat) poll();
}

/* -------------------------------------------------------------- rendering */

function when(seconds) {
  const date = new Date(seconds * 1000);
  const sameDay = date.toDateString() === new Date().toDateString();
  return sameDay
    ? date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    : date.toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function renderConversations() {
  ui.conversations.replaceChildren();

  if (!state.conversations.length) {
    const empty = document.createElement('p');
    empty.className = 'hint';
    empty.textContent = 'No conversations yet. They are opened in the relay\'s admin panel.';
    ui.conversations.append(empty);
    return;
  }

  for (const conversation of state.conversations) {
    const row = document.createElement('button');
    row.type = 'button';
    row.className = 'conversation-row';
    row.classList.toggle('current', conversation.id === state.current);

    const name = document.createElement('span');
    name.className = 'name';
    name.textContent = conversation.name;
    row.append(name);

    /* Whether the other person reads on a calculator, and when it last synced.
     * That is the difference between "has not replied" and "has not plugged in
     * since Tuesday", and it is the whole reason the relay tracks it. */
    const other = conversation.kind === 'direct'
      ? conversation.members.find((m) => m.id !== state.settings.userId)
      : null;
    const entry = other && state.roster.find((r) => r.id === other.id);
    if (entry && entry.hasCalculator) {
      const chip = document.createElement('span');
      chip.className = 'chip calc';
      chip.textContent = entry.lastCalcSync ? `calc · ${when(entry.lastCalcSync)}` : 'calc';
      chip.title = 'Reads on a calculator; messages arrive when it next syncs.';
      row.append(chip);
    }

    row.addEventListener('click', () => {
      state.current = conversation.id;
      renderConversations();
      renderThread();
    });
    ui.conversations.append(row);
  }
}

function renderThread() {
  ui.messages.replaceChildren();

  const conversation = state.conversations.find((c) => c.id === state.current);
  ui.title.textContent = conversation ? conversation.name : 'Chat';

  const enabled = Boolean(conversation);
  ui.draft.disabled = !enabled;
  ui.composer.querySelector('button').disabled = !enabled;
  if (!conversation) return;

  const mine = state.messages
    .filter((m) => m.conversationId === conversation.id)
    .sort((a, b) => a.id - b.id);

  let lastAuthor = null;
  for (const message of mine) {
    const row = document.createElement('div');
    row.className = 'message';
    row.classList.toggle('mine', message.userId === state.settings.userId);
    row.classList.toggle('pending', message.id < 0);

    if (message.userId !== lastAuthor) {
      const who = document.createElement('div');
      who.className = 'who';
      who.textContent = message.displayName || message.username || 'someone';
      row.append(who);
      lastAuthor = message.userId;
    }

    const text = document.createElement('div');
    text.className = 'text';
    text.textContent = message.body;
    row.append(text);

    const time = document.createElement('time');
    time.textContent = message.id < 0 ? 'waiting to send…' : when(message.sentAt);
    row.append(time);

    ui.messages.append(row);
  }

  ui.messages.scrollTop = ui.messages.scrollHeight;
}

/* ---------------------------------------------------------------- the wire */

async function absorbDirectory(data) {
  state.conversations = data.conversations;
  state.roster = data.roster;
  await store.setDirectory({ conversations: data.conversations, roster: data.roster });

  if (!state.current && state.conversations.length) {
    state.current = state.conversations[0].id;
  }
}

/** Fetch whatever is new. Returns how many messages arrived. */
export async function refresh() {
  if (!state.relay) return 0;

  const cursor = await store.cursor();
  const data = await state.relay.messagesSince(cursor);
  if (data.messages.length) {
    state.messages = await store.absorb(data.messages, data.cursor);
  }
  return data.messages.length;
}

async function poll() {
  clearTimeout(state.timer);
  if (!state.relay) return;

  try {
    const arrived = await refresh();

    /* The roster says who has a calculator and when it last synced. It changes
     * far more slowly than messages, so it is re-read on a timer rather than on
     * every poll -- and straight away while we still have no conversations,
     * since without them there is nothing to show at all. */
    const stale = Date.now() - state.directoryAt > DIRECTORY_EVERY;
    if (stale || !state.conversations.length || arrived) {
      await absorbDirectory(await state.relay.me());
      state.directoryAt = Date.now();
    }

    state.failures = 0;
    setLink(`signed in as ${state.settings.username}`, 'ok');
    setError(null);
    renderConversations();
    renderThread();
  } catch (error) {
    if (error instanceof Unauthorised) {
      await signOut('The relay signed this page out. Sign in again.');
      return;
    }
    state.failures++;
    setLink('offline', 'error');
  }

  const base = document.visibilityState === 'visible' ? POLL_VISIBLE : POLL_HIDDEN;
  state.timer = setTimeout(poll, Math.min(base * (1 + state.failures), 120000));
}

/* ------------------------------------------------------------------ actions */

async function send(text) {
  const conversation = state.conversations.find((c) => c.id === state.current);
  if (!conversation || !text.trim()) return;

  const item = {
    conversationId: conversation.id,
    body: text,
    clientId: pageClientId(state.settings.userId),
    sentAt: Math.floor(Date.now() / 1000),
    fromCalculator: false,
  };

  /*
   * Queued locally first, then sent. If the relay is unreachable the message is
   * not lost -- it goes up on the next drain, and the calculator can be given
   * it in the meantime. The relay de-duplicates on clientId, so the double
   * delivery that this risks costs nothing.
   */
  await store.queue([item]);

  state.messages = state.messages.concat([{
    id: -Date.now(),
    conversationId: item.conversationId,
    body: item.body,
    sentAt: item.sentAt,
    clientId: item.clientId,
    userId: state.settings.userId,
    username: state.settings.username,
    displayName: state.settings.displayName,
  }]);
  renderThread();

  try {
    const stored = await state.relay.send(item.conversationId, item.body, item.clientId);
    await store.clearPending([item.clientId]);

    /*
     * The reply carries the stored message, so the optimistic copy is replaced
     * here rather than by waiting for a follow-up read to bring it back.
     *
     * That read was where "sending…" got stuck: the message was on the relay,
     * but if the read after it failed or was slow there was nothing to resolve
     * the pending copy, and it sat there saying "sending" forever.
     *
     * The cursor is deliberately not advanced. Another person's message may
     * have taken an id below this one, and skipping past it would lose it.
     * The next poll re-reads from where it was and simply overwrites this.
     */
    state.messages = state.messages.filter((m) => m.clientId !== item.clientId);
    if (stored.message) state.messages = state.messages.concat([stored.message]);
    renderThread();
  } catch (error) {
    if (error instanceof Unauthorised) await signOut('Signed out. Sign in again.');
    else setLink('not sent — will retry', 'error');
  }
}

async function signOut(message = null) {
  clearTimeout(state.timer);
  state.relay = null;
  state.messages = [];
  state.conversations = [];
  await store.signOut();
  state.settings = await store.settings();

  showSignedIn(false);
  setLink('not signed in');
  setError(message);
  renderConversations();
  renderThread();
}

async function signIn(url, username, password) {
  setError(null);
  setLink('signing in…');

  const { relay: connection, user } = await Relay.signIn(url, username, password);
  state.relay = connection;
  state.settings = await store.saveSettings({
    url: connection.baseUrl,
    token: connection.token,
    username: user.username,
    userId: user.id,
    displayName: user.displayName,
  });

  showSignedIn(true);
  await poll();
}

/* -------------------------------------------------------------------- start */

export async function start() {
  state.settings = await store.settings();
  state.messages = await store.messages();
  state.conversations = await store.conversations();
  state.roster = await store.roster();
  if (state.conversations.length) state.current = state.conversations[0].id;

  ui.url.value = state.settings.url;
  ui.user.value = state.settings.username;

  renderConversations();
  renderThread();

  if (state.settings.url && state.settings.token) {
    state.relay = new Relay(state.settings.url, state.settings.token);
    showSignedIn(true);
    setLink(`signed in as ${state.settings.username}`, 'ok');
    poll();
  } else {
    showSignedIn(false);
    setLink('not signed in');
  }
}

ui.form.addEventListener('submit', async (event) => {
  event.preventDefault();
  try {
    await signIn(ui.url.value, ui.user.value, ui.pass.value);
  } catch (error) {
    setLink('not signed in', 'error');
    setError(error instanceof Unauthorised
      ? 'Wrong username or password.' : error.message);
  }
});

ui.signOut.addEventListener('click', () => signOut());

ui.composer.addEventListener('submit', async (event) => {
  event.preventDefault();
  const text = ui.draft.value;
  ui.draft.value = '';
  await send(text);
});

ui.tabLibrary.addEventListener('click', () => showTab('library'));
ui.tabChat.addEventListener('click', () => showTab('chat'));

document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'visible' && !ui.chatView.hidden) {
    state.failures = 0;
    poll();
  }
});
