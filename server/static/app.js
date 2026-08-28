/*
 * The eOS chat client.
 *
 * Polls. PythonAnywhere has no WebSockets, so there is nothing to upgrade to --
 * every three seconds while the tab is visible, every thirty when it is not.
 * Do not "fix" this by reaching for a socket without checking the host first.
 *
 * The token lives in localStorage, which is what makes the second and every
 * later open go straight to the conversation list. A 401 clears it and shows
 * the sign-in form again, so a revoked account fails closed.
 */

const TOKEN_KEY = 'eos.token';
const LAST_CONVERSATION = 'eos.conversation';

const POLL_VISIBLE = 3000;
const POLL_HIDDEN = 30000;

const el = (id) => document.getElementById(id);

const ui = {
  signin: el('signin'),
  signinForm: el('signin-form'),
  signinError: el('signin-error'),
  username: el('username'),
  password: el('password'),
  app: el('app'),
  title: el('title'),
  link: el('link'),
  back: el('back'),
  signout: el('signout'),
  conversations: el('conversations'),
  messages: el('messages'),
  composer: el('composer'),
  draft: el('draft'),
};

const state = {
  token: null,
  me: null,
  conversations: [],
  roster: [],
  /* Every message we have been given, keyed by id, and the cursor that says
   * what to ask for next. One cursor for everything -- the relay's ids are a
   * single sequence, which is what lets a calculator track one number. */
  messages: new Map(),
  cursor: 0,
  current: null,
  timer: null,
  failures: 0,
};

/* ------------------------------------------------------------------ storage */

function readToken() {
  try {
    return localStorage.getItem(TOKEN_KEY);
  } catch {
    return null;
  }
}

function writeToken(token) {
  try {
    if (token) localStorage.setItem(TOKEN_KEY, token);
    else localStorage.removeItem(TOKEN_KEY);
  } catch { /* private windows and blocked site data: the app still works */ }
}

function remember(key, value) {
  try {
    if (value === null) localStorage.removeItem(key);
    else localStorage.setItem(key, String(value));
  } catch { /* ignore */ }
}

function recall(key) {
  try {
    return localStorage.getItem(key);
  } catch {
    return null;
  }
}

/* ----------------------------------------------------------------- the wire */

class Unauthorised extends Error {}

async function call(path, { method = 'GET', body = null } = {}) {
  const headers = {};
  if (state.token) headers.Authorization = `Bearer ${state.token}`;
  if (body) headers['Content-Type'] = 'application/json';

  const response = await fetch(path, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  if (response.status === 401) throw new Unauthorised('signed out');
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.error || `request failed (${response.status})`);
  return data;
}

/* ------------------------------------------------------------------ helpers */

function when(seconds) {
  const date = new Date(seconds * 1000);
  const today = new Date();
  const sameDay = date.toDateString() === today.toDateString();
  return sameDay
    ? date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    : date.toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
}

/* A message id we can mint that nobody else will. Also what makes handing the
 * same message over twice free -- see /api/messages/batch. */
function clientId() {
  return `w-${state.me.id}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

function conversationById(id) {
  return state.conversations.find((c) => c.id === Number(id)) || null;
}

/* ---------------------------------------------------------------- rendering */

function renderConversations() {
  ui.conversations.replaceChildren();

  if (!state.conversations.length) {
    const empty = document.createElement('p');
    empty.className = 'hint';
    empty.textContent = 'No conversations yet. An administrator opens these.';
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

    /* For a direct conversation, say whether the other person reads on a
     * calculator and when it last synced -- that is the difference between "has
     * not replied" and "has not plugged in since Tuesday". */
    const other = conversation.kind === 'direct'
      ? conversation.members.find((m) => m.id !== state.me.id)
      : null;
    const entry = other && state.roster.find((r) => r.id === other.id);
    if (entry && entry.hasCalculator) {
      const chip = document.createElement('span');
      chip.className = 'chip calc';
      chip.textContent = entry.lastCalcSync
        ? `calc · ${when(entry.lastCalcSync)}` : 'calc';
      chip.title = 'Reads on a calculator; messages arrive when it next syncs.';
      row.append(chip);
    }

    const unread = countUnread(conversation.id);
    if (unread) {
      const badge = document.createElement('span');
      badge.className = 'chip unread';
      badge.textContent = String(unread);
      row.append(badge);
    }

    row.addEventListener('click', () => select(conversation.id));
    ui.conversations.append(row);
  }
}

const seen = new Map();

function countUnread(conversationId) {
  const mark = Number(recall(`eos.seen.${conversationId}`) || 0);
  let count = 0;
  for (const message of state.messages.values()) {
    if (message.conversationId === conversationId && message.id > mark
        && message.userId !== state.me.id) {
      count++;
    }
  }
  return count;
}

function renderThread() {
  ui.messages.replaceChildren();
  const conversation = conversationById(state.current);
  ui.title.textContent = conversation ? conversation.name : 'eOS';

  if (!conversation) {
    ui.draft.disabled = true;
    ui.composer.querySelector('button').disabled = true;
    return;
  }

  ui.draft.disabled = false;
  ui.composer.querySelector('button').disabled = false;

  const mine = [...state.messages.values()]
    .filter((m) => m.conversationId === conversation.id)
    .sort((a, b) => a.id - b.id || a.sentAt - b.sentAt);

  let lastAuthor = null;
  for (const message of mine) {
    const row = document.createElement('div');
    row.className = 'message';
    row.classList.toggle('mine', message.userId === state.me.id);
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
    time.textContent = message.id < 0 ? 'sending…' : when(message.sentAt);
    row.append(time);

    ui.messages.append(row);
  }

  ui.messages.scrollTop = ui.messages.scrollHeight;

  const highest = mine.reduce((top, m) => Math.max(top, m.id), 0);
  if (highest > 0) remember(`eos.seen.${conversation.id}`, highest);
}

function setLink(text, kind = '') {
  ui.link.textContent = text;
  ui.link.className = `chip ${kind}`;
}

/* ------------------------------------------------------------------ actions */

function select(id) {
  state.current = Number(id);
  remember(LAST_CONVERSATION, state.current);
  document.body.classList.add('viewing');
  ui.back.hidden = false;
  renderConversations();
  renderThread();
}

async function refresh() {
  const data = await call(`/api/messages?since=${state.cursor}`);
  for (const message of data.messages) {
    /* Drop the optimistic copy: the relay's version has the real id and time,
     * and the clientId is what ties the two together. */
    for (const [key, held] of state.messages) {
      if (held.id < 0 && held.clientId === message.clientId) state.messages.delete(key);
    }
    state.messages.set(message.id, message);
  }
  if (data.messages.length) {
    state.cursor = data.cursor;
    renderConversations();
    renderThread();
  }
  return data.messages.length;
}

async function loadEverything() {
  const data = await call('/api/me');
  state.me = data.user;
  state.conversations = data.conversations;
  state.roster = data.roster;

  /* Ask for everything from the beginning on a cold start. There is no local
   * store here -- the relay keeps the history, and this is a viewer onto it. */
  state.cursor = 0;
  state.messages.clear();
  while (await refresh() >= 200) { /* keep going while pages are full */ }

  const remembered = Number(recall(LAST_CONVERSATION) || 0);
  const wanted = conversationById(remembered) ? remembered
    : (state.conversations[0] && state.conversations[0].id);

  renderConversations();
  if (wanted) select(wanted);
  else renderThread();
}

async function send(text) {
  const conversation = conversationById(state.current);
  if (!conversation || !text.trim()) return;

  /* Shown immediately with a negative id, so the thread does not sit still for
   * a round trip. refresh() replaces it by clientId. */
  const pending = {
    id: -Date.now(),
    conversationId: conversation.id,
    body: text,
    sentAt: Math.floor(Date.now() / 1000),
    clientId: clientId(),
    userId: state.me.id,
    username: state.me.username,
    displayName: state.me.displayName,
  };
  state.messages.set(pending.id, pending);
  renderThread();

  try {
    await call('/api/messages', {
      method: 'POST',
      body: {
        conversationId: conversation.id,
        body: text,
        clientId: pending.clientId,
      },
    });
    await refresh();
  } catch (error) {
    if (error instanceof Unauthorised) throw error;
    state.messages.delete(pending.id);
    renderThread();
    setLink('not sent', 'error');
  }
}

/* ------------------------------------------------------------------ polling */

function schedule() {
  clearTimeout(state.timer);
  const base = document.visibilityState === 'visible' ? POLL_VISIBLE : POLL_HIDDEN;

  /* Back off when the relay is unreachable, so a phone in a tunnel is not
   * hammering a dead connection every three seconds. */
  const delay = Math.min(base * (1 + state.failures), 60000);
  state.timer = setTimeout(poll, delay);
}

async function poll() {
  try {
    await refresh();
    state.failures = 0;
    setLink('live', 'ok');
  } catch (error) {
    if (error instanceof Unauthorised) {
      signOut();
      return;
    }
    state.failures++;
    setLink('offline', 'error');
  }
  schedule();
}

/* ------------------------------------------------------------------- signin */

function showSignIn(message) {
  ui.app.hidden = true;
  ui.signin.hidden = false;
  ui.signinError.hidden = !message;
  ui.signinError.textContent = message || '';
  ui.username.focus();
}

async function start() {
  state.token = readToken();
  if (!state.token) {
    showSignIn(null);
    return;
  }

  try {
    await loadEverything();
    ui.signin.hidden = true;
    ui.app.hidden = false;
    setLink('live', 'ok');
    schedule();
  } catch (error) {
    if (error instanceof Unauthorised) {
      writeToken(null);
      state.token = null;
      showSignIn('That sign-in has expired.');
    } else {
      showSignIn(error.message);
    }
  }
}

function signOut() {
  clearTimeout(state.timer);
  call('/api/logout', { method: 'POST' }).catch(() => {});
  writeToken(null);
  state.token = null;
  state.messages.clear();
  showSignIn(null);
}

ui.signinForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  ui.signinError.hidden = true;

  try {
    const data = await call('/api/login', {
      method: 'POST',
      body: { username: ui.username.value, password: ui.password.value },
    });
    state.token = data.token;
    writeToken(data.token);
    ui.password.value = '';
    await start();
  } catch (error) {
    ui.signinError.hidden = false;
    ui.signinError.textContent = error instanceof Unauthorised
      ? 'Wrong username or password.' : error.message;
  }
});

ui.composer.addEventListener('submit', async (event) => {
  event.preventDefault();
  const text = ui.draft.value;
  ui.draft.value = '';
  try {
    await send(text);
  } catch (error) {
    if (error instanceof Unauthorised) signOut();
  }
});

ui.signout.addEventListener('click', signOut);
ui.back.addEventListener('click', () => {
  document.body.classList.remove('viewing');
  ui.back.hidden = true;
});

document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'visible') {
    state.failures = 0;
    poll();
  } else {
    schedule();
  }
});

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js').catch(() => {
    /* No worker means no offline shell, which is a smaller app, not a broken
     * one. Not worth telling anybody about. */
  });
}

start();
