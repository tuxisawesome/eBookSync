/*
 * web/js/chat.js against the real Flask relay.
 *
 * Both ends are tested on their own -- server/tests/test_api.py and the units
 * above -- but agreeing separately is not the same as agreeing with each other.
 * This starts the actual server, drives it with the actual browser client, and
 * checks the JSON shapes line up: a renamed field would pass both other suites
 * and break the page.
 *
 * It also covers the round trip that matters most and spans three components:
 * something typed on a calculator reaching the relay through the sync page's
 * batch upload, keyed so that sending it twice is free.
 *
 *   node tools/hosttest/check_relay.mjs
 */

import { spawn, spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { Relay, Unauthorised, calculatorClientId } from '../../web/js/chat.js';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = join(HERE, '..', '..');
const PORT = 5177;
const ORIGIN = `http://127.0.0.1:${PORT}`;

let failures = 0;
let checks = 0;

function check(label, actual, expected) {
  checks++;
  const a = JSON.stringify(actual);
  const b = JSON.stringify(expected);
  if (a !== b) {
    failures++;
    console.log(`  FAIL ${label}: got ${a}, want ${b}`);
  }
}

const python = process.env.PYTHON || 'python3';

/* Flask is optional here the way node is optional elsewhere: say so and skip,
 * rather than failing a run on a machine that has not installed it. */
const hasFlask = spawnSync(python, ['-c', 'import flask'], { stdio: 'ignore' }).status === 0;
if (!hasFlask) {
  console.log('  SKIP relay: python has no flask installed');
  console.log('0/0 relay checks pass');
  process.exit(0);
}

const directory = mkdtempSync(join(tmpdir(), 'eos-relay-'));

const server = spawn(python, ['-m', 'flask', '--app', 'server.app', 'run', '--port', String(PORT)], {
  cwd: ROOT,
  stdio: ['ignore', 'pipe', 'pipe'],
  env: {
    ...process.env,
    EOS_DB_PATH: join(directory, 'eos.db'),
    EOS_SECRET_KEY: 'check-relay',
    EOS_ALLOWED_ORIGINS: 'https://example.github.io',
  },
});

function stop() {
  server.kill('SIGTERM');
  rmSync(directory, { recursive: true, force: true });
}

process.on('exit', stop);

async function waitForServer() {
  for (let attempt = 0; attempt < 100; attempt++) {
    try {
      const response = await fetch(`${ORIGIN}/admin/login`);
      if (response.ok) return;
    } catch { /* not up yet */ }
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
  throw new Error('the relay did not start');
}

/* Form posts, because the admin panel is a browser form and not the API. */
async function form(path, fields, cookie = '') {
  const body = new URLSearchParams();
  for (const [key, value] of Object.entries(fields)) {
    if (Array.isArray(value)) value.forEach((v) => body.append(key, v));
    else body.append(key, value);
  }

  const response = await fetch(`${ORIGIN}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded', Cookie: cookie },
    body,
    redirect: 'manual',
  });
  const setCookie = response.headers.getSetCookie?.()[0];
  return { status: response.status, cookie: setCookie ? setCookie.split(';')[0] : cookie };
}

try {
  await waitForServer();

  /* --- set the relay up the way a person would --- */
  await form('/admin/bootstrap', { username: 'walter', password: 'bootstrap-pass' });
  let { cookie } = await form('/admin/login', { username: 'walter', password: 'bootstrap-pass' });
  await form('/admin/users/new', { username: 'sam', password: 'sam-pass-1' }, cookie);
  await form('/admin/direct', { a: '1', b: '2' }, cookie);
  await form('/admin/groups/new', { name: 'Study group', members: ['1', '2'] }, cookie);

  /* --- the browser client signs in --- */
  const { relay, user } = await Relay.signIn(ORIGIN, 'walter', 'bootstrap-pass');
  check('signing in returns the account', user.username, 'walter');
  check('and an id the client can key messages on', typeof user.id, 'number');

  const directory1 = await relay.me();
  check('the client is given both conversations', directory1.conversations.length, 2);
  check('a direct conversation is named after the other person',
        directory1.conversations.find((c) => c.kind === 'direct').name, 'sam');
  check('the roster lists everyone', directory1.roster.map((r) => r.username).sort(),
        ['sam', 'walter']);
  check('and nobody has a calculator yet',
        directory1.roster.every((r) => r.hasCalculator === false), true);

  const group = directory1.conversations.find((c) => c.kind === 'group');

  /* --- a message from the page --- */
  await relay.send(group.id, 'from the sync page', 'page-1-aaa');
  const first = await relay.messagesSince(0);
  check('the message comes back', first.messages.map((m) => m.body), ['from the sync page']);
  check('with a cursor to continue from', first.cursor, first.messages[0].id);
  check('and asking again returns nothing',
        (await relay.messagesSince(first.cursor)).messages, []);

  /* --- a calculator's outbox, uploaded by the page --- */
  /*
   * The exact path chatsync.drain takes: messages keyed with the sequence
   * numbers the calculator minted, uploaded in one batch, and marked as having
   * come from a calculator so the roster can say so.
   */
  const { relay: samRelay, user: sam } = await Relay.signIn(ORIGIN, 'sam', 'sam-pass-1');
  const queued = [
    { conversationId: group.id, body: 'typed on the calculator',
      clientId: calculatorClientId(sam.id, 90001), sentAt: 1_700_000_000 },
    { conversationId: group.id, body: 'and another',
      clientId: calculatorClientId(sam.id, 90002), sentAt: 1_700_000_060 },
  ];

  const uploaded = await samRelay.sendBatch(queued);
  check('both were stored', uploaded.created, 2);

  /* The case the keys exist for: a sync that died before the acknowledgement. */
  const again = await samRelay.sendBatch(queued);
  check('replaying the batch stores nothing new', again.created, 0);

  const second = await relay.messagesSince(first.cursor);
  check('the page sees both, once each',
        second.messages.map((m) => m.body), ['typed on the calculator', 'and another']);
  check('attributed to the right person',
        second.messages.every((m) => m.username === 'sam'), true);

  const directory2 = await relay.me();
  const samEntry = directory2.roster.find((r) => r.username === 'sam');
  check('the roster now says sam reads on a calculator', samEntry.hasCalculator, true);
  check('and when it last synced', typeof samEntry.lastCalcSync, 'number');


  /* --- fetch has to be called the way a browser demands ------------------- */
  /*
   * This shipped broken and the suite was green, because node's fetch does not
   * check its receiver and a browser's does: calling it as `this.fetcher(...)`
   * makes the receiver the Relay object, and Chrome answers "Failed to execute
   * 'fetch' on 'Window': Illegal invocation".
   *
   * So the check is not "does a request work" -- it did, here -- but "is fetch
   * ever called as a method of something that is not the window". A stand-in
   * that enforces what the browser enforces is the only way to see it from
   * node.
   */
  {
    const seen = [];

    function browserLikeFetch(url, init) {
      /* `this` is undefined for a plain call in a module, and the window for a
       * bound one. Anything else is what Chrome rejects. */
      if (this !== undefined && this !== globalThis) {
        throw new TypeError(
          "Failed to execute 'fetch' on 'Window': Illegal invocation");
      }
      seen.push(url);
      return fetch(url, init);
    }

    const strict = new Relay(ORIGIN, relay.token, { fetcher: browserLikeFetch });
    let called = null;
    try {
      await strict.me();
    } catch (error) {
      called = error.message;
    }

    check('an injected fetch is never called as a method', called, null);
    check('and it really was used', seen.length > 0, true);

    /* The default path too: the real fetch, taken off the global and stored on
     * the instance, is the exact shape that broke. */
    const plain = new Relay(ORIGIN, relay.token);
    check('the default fetcher is bound, not bare',
          plain.fetcher !== globalThis.fetch, true);

    let defaulted = null;
    try {
      await plain.me();
    } catch (error) {
      defaulted = error.message;
    }
    check('and the default path works', defaulted, null);
  }

  /* --- what the client must refuse to paper over --- */
  let unauthorised = false;
  try {
    await new Relay(ORIGIN, 'not-a-real-token').me();
  } catch (error) {
    unauthorised = error instanceof Unauthorised;
  }
  check('a dead token raises Unauthorised, not a generic failure', unauthorised, true);

  let refused = null;
  try {
    await new Relay(ORIGIN, samRelay.token).send(999, 'nowhere', 'page-1-bbb');
  } catch (error) {
    refused = error.message;
  }
  check('a conversation you are not in is refused', refused, 'no such conversation');

  let unreachable = null;
  try {
    await new Relay('http://127.0.0.1:1').me();
  } catch (error) {
    unreachable = error.message;
  }
  check('an unreachable relay explains the likely causes',
        /https/.test(unreachable) && /EOS_ALLOWED_ORIGINS/.test(unreachable), true);

  /*
   * ...but only a real network failure gets that advice. A bug in this file
   * also arrives as a TypeError, and telling someone to check their address and
   * their CORS settings sends them to look at the server for a fault that is
   * here. That is exactly what happened with the receiver bug above.
   */
  {
    const throwing = (message) => new Relay(ORIGIN, null, {
      fetcher: () => { throw new TypeError(message); },
    });

    let misblamed = null;
    try {
      await throwing("Failed to execute 'fetch' on 'Window': Illegal invocation").me();
    } catch (error) {
      misblamed = error;
    }
    check('a client bug is not reported as an address problem',
          /EOS_ALLOWED_ORIGINS/.test(misblamed.message), false);
    check('and reaches the caller unchanged',
          misblamed.message, "Failed to execute 'fetch' on 'Window': Illegal invocation");

    let genuine = null;
    try {
      await throwing('Failed to fetch').me();
    } catch (error) {
      genuine = error;
    }
    check('while a real network failure still gets the advice',
          /EOS_ALLOWED_ORIGINS/.test(genuine.message), true);
  }

} catch (error) {
  failures++;
  console.log(`  FAIL relay: ${error.stack || error.message}`);
} finally {
  stop();
}

console.log(`${checks - failures}/${checks} relay checks pass`);
process.exit(failures ? 1 : 0);
