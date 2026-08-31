/*
 * Check the sync planner decides the right things.
 *
 * The planner is what deletes comics off the calculator, so its rules are worth
 * pinning down: keep the N most recently read, never push past the budget,
 * reclaim slots the library no longer knows about, and respect manual versus
 * automatic selection.
 *
 *   node tools/hosttest/check_planner.mjs
 */

import { plan } from '../../web/js/sync.js';
import { defaultMeta, mergeFromCalculator, reconcile } from '../../web/js/meta.js';

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

/* A library of two books; sizes are set so the budget maths is easy to read. */
function library() {
  return [
    {
      name: 'Book A',
      strips: [1, 2, 3, 4].map((n) => ({
        name: `00${n}.jpg`, handle: null, size: 1_000_000, lastModified: 0,
      })),
    },
    {
      name: 'Book B',
      strips: [1, 2].map((n) => ({
        name: `0${n}.jpg`, handle: null, size: 1_000_000, lastModified: 0,
      })),
    },
  ];
}

function setup(mutate = () => {}) {
  const books = library();
  const meta = reconcile(defaultMeta(), books);
  /* A known size per strip so the budget is predictable. */
  for (const book of Object.values(meta.books)) {
    for (const strip of Object.values(book.strips)) strip.deviceBytes = 100_000;
  }
  mutate(meta, books);
  return { meta, books };
}

const slotOf = (meta, book, file) => meta.books[book].strips[file].id;

/* --- manual selection only sends what is ticked ------------------------- */
{
  const { meta, books } = setup((m) => {
    m.books['Book A'].strips['001.jpg'].selected = true;
    m.books['Book B'].strips['02.jpg'].selected = true;
  });
  const result = plan(meta, books, []);
  check('manual: pushes', result.pushes.map((s) => s.file).sort(), ['001.jpg', '02.jpg']);
  check('manual: no deletes', result.deletes.length, 0);
}

/* --- auto selection sends unread strips regardless of ticks -------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.selection = 'auto';
    m.books['Book A'].strips['001.jpg'].read = true;
  });
  const result = plan(meta, books, []);
  check('auto: skips the read one', result.pushes.some((s) => s.file === '001.jpg'), false);
  check('auto: pushes the rest', result.pushes.length, 5);
}

/* --- already resident strips are not sent again -------------------------- */
{
  const { meta, books } = setup((m) => {
    m.books['Book A'].strips['001.jpg'].selected = true;
    m.books['Book A'].strips['002.jpg'].selected = true;
  });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 25, bytes: 100_000,
    read: false, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);
  const result = plan(meta, books, resident);
  check('resident: only the missing one', result.pushes.map((s) => s.file), ['002.jpg']);
}

/* --- auto-delete keeps the N most recently read -------------------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.keepRead = 2;
    const a = m.books['Book A'].strips;
    a['001.jpg'].read = true; a['001.jpg'].readAt = '2026-08-01T00:00:00Z';
    a['002.jpg'].read = true; a['002.jpg'].readAt = '2026-08-03T00:00:00Z';
    a['003.jpg'].read = true; a['003.jpg'].readAt = '2026-08-02T00:00:00Z';
    a['004.jpg'].read = true; a['004.jpg'].readAt = '2026-08-04T00:00:00Z';
  });
  const resident = ['001.jpg', '002.jpg', '003.jpg', '004.jpg'].map((file) => ({
    slot: slotOf(meta, 'Book A', file), chunkCount: 25, bytes: 100_000,
    read: true, readAt: 0, pos: 0, layer: 0,
  }));
  mergeFromCalculator(meta, resident);
  const result = plan(meta, books, resident);
  /* The two oldest reads go; 004 (newest) and 002 (next newest) stay. */
  check('keepRead: deletes the oldest two',
        result.deletes.map((s) => s.file).sort(), ['001.jpg', '003.jpg']);
}

/* --- auto-delete off deletes nothing ------------------------------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.autoDelete = false;
    m.books['Book A'].strips['001.jpg'].read = true;
  });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 25, bytes: 100_000,
    read: true, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);
  const result = plan(meta, books, resident);
  check('autoDelete off: nothing deleted', result.deletes.length, 0);
}

/* --- the budget trims the tail of the selection --------------------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.maxDeviceBytes = 250_000;      /* room for two 100 KB strips */
    for (const strip of Object.values(m.books['Book A'].strips)) strip.selected = true;
  });
  const result = plan(meta, books, []);
  check('budget: pushes what fits', result.pushes.length, 2);
  check('budget: reports the rest', result.skipped.length, 2);
  check('budget: projection stays inside', result.projectedBytes <= 250_000, true);
}

/* --- slots the library no longer knows about are reclaimed ---------------- */
{
  const { meta, books } = setup();
  const resident = [{ slot: 200, chunkCount: 4, bytes: 60_000, read: false, readAt: 0, pos: 0, layer: 0 }];
  mergeFromCalculator(meta, resident);
  const result = plan(meta, books, resident);
  check('orphans: found', result.orphans.map((o) => o.slot), [200]);
}

/* --- a read strip that is deleted stops being selected -------------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.keepRead = 0;
    m.books['Book A'].strips['001.jpg'].read = true;
    m.books['Book A'].strips['001.jpg'].selected = true;
  });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 25, bytes: 100_000,
    read: true, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);
  const result = plan(meta, books, resident);
  check('cleanup: the read strip is deleted', result.deletes.map((s) => s.file), ['001.jpg']);
  /* It is also a push candidate, because deleting frees the slot -- but that
   * would make it bounce straight back, so execute() clears `selected`. This
   * check pins the behaviour the planner is relied upon for. */
  check('cleanup: re-push is planned only once',
        result.pushes.filter((s) => s.file === '001.jpg').length <= 1, true);
}

/* --- free space on the device caps the budget ----------------------------- */
{
  const { meta, books } = setup((m) => {
    for (const strip of Object.values(m.books['Book A'].strips)) strip.selected = true;
  });
  const result = plan(meta, books, [], { freeArchive: 150_000 });
  check('freeArchive: caps the pushes', result.pushes.length, 1);
}

/* --- connecting ticks whatever is already on the calculator ------------- */
{
  const { meta, books } = setup();
  const slot = slotOf(meta, 'Book A', '001.jpg');
  const resident = [{
    slot, chunkCount: 25, bytes: 100_000, read: false, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);

  check('resident strips arrive ticked',
        meta.books['Book A'].strips['001.jpg'].selected, true);

  /* Ticked and resident: nothing to do. */
  const before = plan(meta, books, resident);
  check('a ticked resident strip is left alone',
        [before.pushes.length, before.deletes.length], [0, 0]);

  /* Unticking it is how you ask for it to go. */
  meta.books['Book A'].strips['001.jpg'].selected = false;
  const after = plan(meta, books, resident);
  check('unticking a resident strip removes it',
        after.deletes.map((s) => s.file), ['001.jpg']);
  check('and it is not re-sent in the same breath', after.pushes.length, 0);
}

/* --- a strip being removed is not also queued to be sent ----------------- */
{
  const { meta, books } = setup((m) => {
    m.settings.keepRead = 0;
    m.books['Book A'].strips['001.jpg'].read = true;
    m.books['Book A'].strips['001.jpg'].selected = true;
  });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 25, bytes: 100_000,
    read: true, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);

  const result = plan(meta, books, resident);
  check('cleanup deletes it', result.deletes.map((s) => s.file), ['001.jpg']);
  check('and does not immediately re-send it',
        result.pushes.filter((s) => s.file === '001.jpg').length, 0);
}

/* --- automatic selection ignores the ticks ------------------------------ */
{
  const { meta, books } = setup((m) => { m.settings.selection = 'auto'; });
  const resident = [{
    slot: slotOf(meta, 'Book A', '001.jpg'), chunkCount: 25, bytes: 100_000,
    read: false, readAt: 0, pos: 0, layer: 0,
  }];
  mergeFromCalculator(meta, resident);
  meta.books['Book A'].strips['001.jpg'].selected = false;

  const result = plan(meta, books, resident);
  check('auto mode does not remove unticked strips', result.deletes.length, 0);
}


console.log(`${checks - failures}/${checks} planner checks pass`);
process.exit(failures ? 1 : 0);
