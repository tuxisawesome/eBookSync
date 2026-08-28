/*
 * The two web front ends: the sync page and the relay's chat client.
 *
 * Neither has a DOM in the harness, so this checks the things that can be
 * checked without one -- and they are exactly the things that went wrong.
 *
 * The bug this exists for: `hidden` is `display: none` in the *user agent*
 * stylesheet, which loses to any author rule that sets `display` on the same
 * element. `main { display: grid }` therefore left the chat panel showing
 * underneath the library, and `body.chat #app { display: flex }` left the
 * relay's sign-in form stacked above the messages. Both looked like layout
 * bugs and were the same one-line omission.
 *
 *   node tools/hosttest/check_page.mjs
 */

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = join(HERE, '..', '..');

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

const read = (...parts) => readFileSync(join(ROOT, ...parts), 'utf8');

/* Strip comments so a rule discussed in prose is not read as a rule. */
function withoutComments(css) {
  return css.replace(/\/\*[\s\S]*?\*\//g, '');
}

/** Does the stylesheet make `hidden` win? */
function guardsHidden(css) {
  const rules = withoutComments(css);
  const match = /\[hidden\]\s*\{([^}]*)\}/.exec(rules);
  if (!match) return false;
  return /display\s*:\s*none\s*!important/.test(match[1]);
}

/**
 * Selectors that set `display` on something the page toggles with `hidden`.
 *
 * Each of these needs the guard above to be present. Listing them is the point:
 * it says *why* the guard is not optional, rather than asserting that a line of
 * CSS exists somewhere.
 */
function displayRulesFor(css, names) {
  const rules = withoutComments(css);
  const found = [];

  /* Index 0 of a match is the whole match, so the groups start at 1. */
  for (const [, selector, block] of rules.matchAll(/([^{}]+)\{([^}]*)\}/g)) {
    if (!/(^|[^-])display\s*:/.test(block)) continue;
    const text = selector.trim();
    for (const name of names) {
      if (text.includes(`#${name}`) || text === name || text.split(/[\s,>]+/).includes(name)) {
        found.push(`${text} sets display, and ${name} is toggled with hidden`);
        break;
      }
    }
  }
  return found;
}

/* --- the sync page -------------------------------------------------------- */
{
  const html = read('web', 'index.html');
  const css = read('web', 'css', 'app.css');
  const main = read('web', 'js', 'main.js');
  const chatui = read('web', 'js', 'chatui.js');

  check('the sync page makes hidden win', guardsHidden(css), true);

  /* The chat panel and the library are separate tabs, so exactly one shows. */
  check('the library view is a distinct element', /id="library-view"/.test(html), true);
  check('the chat view starts hidden', /id="chat-view"[^>]*\shidden/.test(html), true);

  const hazards = displayRulesFor(css, ['library-view', 'chat-view', 'chat-body', 'main']);
  check('and there is a reason the guard is needed', hazards.length > 0, true);

  /* Every element the JS reaches for has to exist, or a whole panel silently
   * does nothing. */
  const ids = [...html.matchAll(/id="([^"]+)"/g)].map((m) => m[1]);
  const missing = [];
  for (const source of [main, chatui]) {
    for (const use of source.matchAll(/\bel\('([^']+)'\)/g)) {
      if (!ids.includes(use[1])) missing.push(use[1]);
    }
  }
  check('every element the page script reaches for exists', missing, []);
}

/* --- the relay's chat client ---------------------------------------------- */
{
  const html = read('server', 'templates', 'app.html');
  const css = read('server', 'static', 'app.css');
  const app = read('server', 'static', 'app.js');

  check('the relay page makes hidden win', guardsHidden(css), true);
  check('the sign-in form starts hidden', /id="signin"[^>]*\shidden/.test(html), true);
  check('and so does the app shell', /id="app"[^>]*\shidden/.test(html), true);

  const hazards = displayRulesFor(css, ['app', 'signin', 'back', 'conversations', 'thread']);
  check('and there is a reason the guard is needed here too', hazards.length > 0, true);

  const ids = [...html.matchAll(/id="([^"]+)"/g)].map((m) => m[1]);
  const missing = [...app.matchAll(/\bel\('([^']+)'\)/g)]
    .map((m) => m[1]).filter((id) => !ids.includes(id));
  check('every element the client reaches for exists', missing, []);
}

/* --- and the guard actually does something -------------------------------- */
/*
 * A stylesheet that never sets display on a toggled element would pass the
 * checks above whether or not the guard were there. This proves the opposite:
 * remove the guard from a copy and the hazards are still present, which is the
 * state that shipped.
 */
{
  const css = read('web', 'css', 'app.css');
  const stripped = css.replace(/\[hidden\]\s*\{[^}]*\}/, '');
  check('removing the guard leaves hidden losing to a display rule',
        guardsHidden(stripped), false);
  check('while the display rule it loses to is still there',
        displayRulesFor(stripped, ['main']).length > 0, true);
}

console.log(`${checks - failures}/${checks} page checks pass`);
process.exit(failures ? 1 : 0);
