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

/* --- the splash keeps the app out of reach until a calculator connects ---- */
/*
 * It has to be up from the first paint -- before any script has run -- and the
 * app behind it has to be inert from the first paint too, or there is a moment
 * where the library can be clicked into. Then main.js takes over, keyed on the
 * connection and nothing else.
 */
{
  const html = read('web', 'index.html');
  const css = read('web', 'css', 'app.css');
  const main = read('web', 'js', 'main.js');

  const splash = /<div id="splash"[^>]*>/.exec(html);
  check('there is a splash', Boolean(splash), true);
  check('and it is showing before any script runs', /\bhidden\b/.test(splash[0]), false);
  check('it is not a <dialog>, which Escape can close', /<dialog id="splash"/.test(html), false);

  /* Everything outside the splash and the dialogs starts inert. */
  const body = html.slice(html.indexOf('<body>'), html.indexOf('<script'));
  const topLevel = [...body.matchAll(/^<(header|main|footer|p|div|section|aside)\b[^>]*>/gms)]
    .map((m) => m[0])
    .filter((tag) => !/id="splash"/.test(tag));
  check('the app behind it starts inert',
        topLevel.filter((tag) => !/\binert\b/.test(tag)), []);

  check('it covers the whole window',
        /\.splash\s*\{[^}]*position:\s*fixed[^}]*inset:\s*0/.test(withoutComments(css)), true);
  check('and sets display, so it needs the hidden guard',
        displayRulesFor(css, ['.splash']).length > 0 || /\.splash\s*\{[^}]*display/.test(css), true);

  check('it offers the reader for download',
        /id="splash-download"[^>]*href="comics\/COMICS\.8xp"|href="comics\/COMICS\.8xp"[^>]*id="splash-download"/.test(html),
        true);
  /* The link is relative to the page, so it is web/comics/COMICS.8xp: where
   * stage_update.sh puts every build, and where the updater fetches from. */
  const stage = read('tools', 'stage_update.sh');
  check('and the file it offers is the one every build is staged to',
        /out="\$root\/web\/comics"/.test(stage) && /"\$out\/COMICS\.8xp"/.test(stage), true);
  check('and it is there to download', read('web', 'comics', 'COMICS.8xp').length > 0, true);

  check('it is open exactly while no calculator is connected',
        /const open = !state\.calculator;/.test(main), true);
  check('and follows every change to the connection',
        /function refreshDevice\(\) \{[^}]*refreshSplash\(\);/.test(main), true);
  check('its connect button connects',
        /splashConnect\.addEventListener\('click', connectFromSplash\)/.test(main), true);

  /* And it is the only way in. A second Connect button in the header raced the
   * splash: two ways to start the same connection, one of them unreachable
   * half the time. */
  check('there is no other connect button', /id="connect"/.test(html), false);
  const callers = [...main.matchAll(/(?<!function )(?<![\w.])connect\(\)/g)].length;
  check('and connect() is called from the splash alone', callers, 1);
}

/* --- the page wears the calculator's theme ------------------------------- */
/*
 * Purple Dark and Light, the calculator's own colours, chosen by what the
 * calculator reports in HELLO -- not by the computer's setting -- and applied
 * before the stylesheet paints so the page never flashes the other theme.
 */
{
  const html = read('web', 'index.html');
  const css = withoutComments(read('web', 'css', 'app.css'));
  const main = read('web', 'js', 'main.js');
  const theme = read('calc', 'src', 'theme.c');

  check('there is a dark theme, on :root', /:root\s*\{[^}]*--accent:\s*#8b5cf6/.test(css), true);
  check('and a light one', /:root\[data-theme="light"\]\s*\{[^}]*--accent:\s*#6d28d9/.test(css), true);
  check('with the calculator\'s accents', /0x8b, 0x5c, 0xf6/.test(theme) && /0x6d, 0x28, 0xd9/.test(theme), true);
  check('the computer\'s setting no longer decides', /prefers-color-scheme/.test(css), false);

  const script = html.indexOf("localStorage.getItem('ebooksync-theme')");
  const sheet = html.indexOf('css/app.css');
  check('the saved theme is applied before the stylesheet', script > 0 && script < sheet, true);
  check('connecting takes the calculator\'s theme', /if \(hello\.theme\) applyTheme\(hello\.theme\);/.test(main), true);
  check('and saves it for next time', /localStorage\.setItem\('ebooksync-theme'/.test(main), true);
}

/* --- the glass is three.js, vendored, and optional ------------------------ */
/*
 * The glass is rendered by three.js from files next to the page: an import map
 * names them, nothing is fetched from a CDN, and the licence travels with them.
 * It is optional in the strongest sense -- imported on its own and caught -- so
 * a browser that cannot run it gets the flat page, not a broken one.
 */
{
  const html = read('web', 'index.html');
  const main = read('web', 'js', 'main.js');
  const glassSource = read('web', 'js', 'glass.js');

  const map = JSON.parse(/<script type="importmap">([\s\S]*?)<\/script>/.exec(html)[1]);
  const three = map.imports.three;
  check('the import map names a vendored three.js', three.startsWith('./vendor/three/'), true);
  let present = true;
  try {
    const module = read('web', three);
    /* three.module imports its core by a relative name; that has to be there too. */
    for (const [, dep] of module.matchAll(/from\s*["'](\.\/[^"']+)["']/g)) {
      read('web', 'vendor', 'three', dep.slice(2));
    }
    for (const [, addon] of glassSource.matchAll(/from 'three\/addons\/([^']+)'/g)) {
      read('web', 'vendor', 'three', 'addons', addon);
    }
  } catch {
    present = false;
  }
  check('and every file it and glass.js import is there', present, true);
  check('with its licence', /MIT License/.test(read('web', 'vendor', 'three', 'LICENSE')), true);
  check('the import map comes before any module', html.indexOf('type="importmap"') < html.indexOf('type="module"'), true);

  const pages = ['index.html', 'js/main.js', 'js/glass.js', 'css/app.css'].map((f) => read('web', ...f.split('/')));
  check('nothing is fetched from a CDN', pages.some((text) => /cdn\.jsdelivr|unpkg\.com|cdnjs/.test(text)), false);

  check('glass.js is imported on its own, and a failure is caught',
        /import\('\.\/glass\.js'\)[\s\S]*?\.catch\(/.test(main), true);
  check('and main.js does not import it statically', /^import .*glass\.js/m.test(main), false);
  check('glass-3d is only set once the glass is running',
        /classList\.add\('glass-3d'\)/.test(glassSource) && !/glass-3d/.test(html), true);
  check('the library is hidden, not only covered, behind a see-through splash',
        /splash-up/.test(main) && /\.glass-3d\.splash-up/.test(read('web', 'css', 'app.css')), true);
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
