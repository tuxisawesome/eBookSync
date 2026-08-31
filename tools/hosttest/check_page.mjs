/*
 * The sync page, as far as it can be checked without a DOM.
 *
 * Which is further than it sounds: the things that went wrong here were not
 * behaviour, they were a stylesheet and a missing element id.
 *
 * The bug this exists for: `hidden` is `display: none` in the *user agent*
 * stylesheet, which loses to any author rule that sets `display` on the same
 * element -- so `main { display: grid }` left a `<main hidden>` on screen.
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

  check('the sync page makes hidden win', guardsHidden(css), true);

  const hazards = displayRulesFor(css, ['main']);
  check('and there is a reason the guard is needed', hazards.length > 0, true);

  /* Every element the JS reaches for has to exist, or a whole panel silently
   * does nothing. */
  const ids = [...html.matchAll(/id="([^"]+)"/g)].map((m) => m[1]);
  const missing = [];
  for (const use of main.matchAll(/\bel\('([^']+)'\)/g)) {
    if (!ids.includes(use[1])) missing.push(use[1]);
  }
  check('every element the page script reaches for exists', missing, []);
}

/* --- the page does not invent a library identity ------------------------- */
/*
 * The field list for ebooksync.json belongs in meta.js, next to the code that reads
 * it back. When main.js kept its own copy it left `libraryId` out, so the id
 * was read on every load and saved on none -- and every reconnect reported the
 * user's own calculator as holding a different library.
 */
{
  const main = read('web', 'js', 'main.js');

  check('main.js does not keep its own field list',
        /version: metaStore\.VERSION,\s*\n\s*lastSync:/.test(main), false);
  check('it asks meta.js what to save',
        /metaStore\.serialisable\(state\.meta\)/.test(main), true);
  check('and adopts the calculator\'s identity rather than minting one',
        /metaStore\.adoptLibraryId\(state\.meta, held\)/.test(main), true);
}

/* --- the page says which build it is ------------------------------------- */
/*
 * Without this, a stale cached module is indistinguishable from a fix that did
 * not work: both look like the same bug still happening. The header carries the
 * build so the two can be told apart by looking.
 */
{
  const html = read('web', 'index.html');
  const main = read('web', 'js', 'main.js');
  const version = read('web', 'js', 'version.js');

  check('the page has somewhere to show its build', /id="page-build"/.test(html), true);
  check('and version.js declares one', /export const PAGE_BUILD = \d+/.test(version), true);
  check('and the page fills it in', /pageBuild\.textContent/.test(main), true);
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
