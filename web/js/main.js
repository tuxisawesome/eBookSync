/*
 * The sync page: arrange a library, tick what you want, send it.
 *
 * Everything that decides bytes lives elsewhere -- this wires the DOM to
 * fs/meta/sync, keeps the tree and the space meter honest, and makes the
 * library editable: drop files in, create and delete and rename books and
 * strips, and drag them into the order you want to read them.
 *
 * Order lives in eos.json, not in filenames, and flows straight through
 * to the calculator: CSLIB lists books and strips in array order and the reader
 * draws them in the order it finds them.
 */

import * as cacheStore from './cache.js';
import * as crop from './crop.js';
import * as fs from './fs.js';
import * as libraryStore from './library.js';
import * as metaStore from './meta.js';
import * as syncEngine from './sync.js';
import * as updater from './update.js';
import { PAGE_BUILD } from './version.js';
import {
  Calculator, LIBRARY, MIN_PROTOCOL_VERSION, PROTOCOL_VERSION, WALLPAPER_SLOT,
  isSupported as linkSupported,
} from './link.js';

const el = (id) => document.getElementById(id);

const ui = {
  status: el('status'),
  unsupported: el('unsupported'),
  chooseFolder: el('choose-folder'),
  newBook: el('new-book'),
  reset: el('reset-calculator'),
  connect: el('connect'),
  sync: el('sync'),
  tree: el('tree'),
  filter: el('filter'),
  detail: el('detail'),
  selection: el('selection'),
  autoDelete: el('auto-delete'),
  keepRead: el('keep-read'),
  keepReadValue: el('keep-read-value'),
  keepReadField: el('keep-read-field'),
  budget: el('budget'),
  wallpaperFile: el('wallpaper-file'),
  wallpaperCurrent: el('wallpaper-current'),
  wallpaperPreview: el('wallpaper-preview'),
  wallpaperClear: el('wallpaper-clear'),
  wallpaperRecrop: el('wallpaper-recrop'),
  cropDialog: el('crop-dialog'),
  cropCanvas: el('crop-canvas'),
  cropZoom: el('crop-zoom'),
  cropReset: el('crop-reset'),
  cropCancel: el('crop-cancel'),
  cropUse: el('crop-use'),
  deviceStatus: el('device-status'),
  deviceFree: el('device-free'),
  deviceCount: el('device-count'),
  deviceLibrary: el('device-library'),
  deviceBuild: el('device-build'),
  pageBuild: el('page-build'),
  update: el('update'),
  updateNotice: el('update-notice'),
  lastSync: el('last-sync'),
  selectionSummary: el('selection-summary'),
  meterFill: el('meter-fill'),
  planDialog: el('plan-dialog'),
  planBody: el('plan-body'),
  planGo: el('plan-go'),
  progressDialog: el('progress-dialog'),
  progressTitle: el('progress-title'),
  progressStatus: el('progress-status'),
  progressFill: el('progress-fill'),
  progressLog: el('progress-log'),
  progressStop: el('progress-stop'),
  progressClose: el('progress-close'),
};

const state = {
  root: null,
  books: [],
  meta: metaStore.defaultMeta(),
  calculator: null,
  resident: [],
  deviceIndex: null,
  library: null,
  freeArchive: null,
  /* The HELLO reply, so the rest of the page can see the protocol version and
   * build number rather than only what they happened to be used for. */
  hello: null,
  /* The builds staged next to this page, and what this calculator needs of
   * them. Null until a calculator answers, and when the page is opened off
   * disk, where fetch cannot reach a relative path. */
  catalogue: null,
  updatePlan: null,
  expanded: new Set(),
  filter: '',
  pool: null,
  busy: false,

  /*
   * wallpaper.jpg as it is on disk right now: `{ file, hash }`, or null if
   * there is not one. Hashed on load and after every change, because whether it
   * needs sending is a comparison against the hash the calculator was last
   * given -- see meta.wallpaper.
   */
  wallpaper: null,

  /* The object URL behind the preview thumbnail, so it can be revoked. */
  wallpaperUrl: null,
};

/* What is currently being dragged inside the tree, if anything. dataTransfer
 * cannot be read during dragover, so the payload has to live here. */
let dragging = null;

/* Anchor for shift-click range selection. */
let lastClicked = { book: null, index: -1 };

/* ------------------------------------------------------------------ helpers */

function kb(bytes) {
  if (bytes === null || bytes === undefined) return '—';
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`;
  return `${(bytes / 1024 / 1024).toFixed(2)} MB`;
}

function setStatus(text, kind = '') {
  ui.status.textContent = text;
  ui.status.className = `notice${kind ? ` ${kind}` : ''}`;
}

function matchesFilter(text) {
  return !state.filter || text.toLowerCase().includes(state.filter);
}

/** Strips of one book, in stored order, as { file, title, state }. */
function stripsOf(bookName) {
  return metaStore.stripNames(state.meta, bookName).map((file) => ({
    file,
    title: fs.titleFromFilename(file),
    state: state.meta.books[bookName].strips[file],
  }));
}

/* ---------------------------------------------------------------- rendering */

function chip(text, kind) {
  const span = document.createElement('span');
  span.className = `chip ${kind}`;
  span.textContent = text;
  return span;
}

function actionButton(label, title, handler) {
  const button = document.createElement('button');
  button.type = 'button';
  button.className = 'action';
  button.textContent = label;
  button.title = title;
  button.setAttribute('aria-label', title);
  button.addEventListener('click', (event) => {
    event.preventDefault();
    event.stopPropagation();
    handler();
  });
  return button;
}

function stripChips(strip) {
  const chips = document.createElement('div');
  chips.className = 'chips';
  if (strip.state.onCalc) chips.append(chip('on calc', 'on-calc'));
  if (strip.state.read) chips.append(chip('read', 'read'));
  if (strip.state.selected && !strip.state.onCalc) chips.append(chip('queued', 'queued'));
  const size = strip.state.deviceBytes || syncEngine.estimateBytes(strip, state.meta.settings);
  chips.append(chip(kb(size), 'size'));
  return chips;
}

/*
 * Drag and drop does two different jobs on the same rows: reordering inside the
 * tree, and importing files from outside it. They are told apart by whether
 * `dragging` is set -- an internal drag always sets it on dragstart.
 */
function makeDropTarget(row, target) {
  /*
   * What a drop on this row would mean, worked out fresh from the pointer.
   *
   * Deliberately not remembered between dragover and drop: dragleave fires
   * whenever the pointer crosses into a child element, so any state kept in CSS
   * classes gets cleared mid-drag and every drop would land in the wrong place.
   */
  const intent = (event) => {
    if (state.busy) return null;

    if (!dragging) {
      /* A drag from outside: only meaningful over a book. */
      if (target.kind !== 'book') return null;
      if (!Array.from(event.dataTransfer.types).includes('Files')) return null;
      return { kind: 'import' };
    }

    if (dragging.kind === 'strip' && target.kind === 'book' && dragging.book !== target.book) {
      return { kind: 'move-into' };
    }
    if (dragging.kind !== target.kind) return null;
    if (dragging.kind === 'strip' && dragging.book !== target.book) return null;

    const box = row.getBoundingClientRect();
    return { kind: 'reorder', after: event.clientY > box.top + box.height / 2 };
  };

  const clear = () => row.classList.remove('drop-before', 'drop-after', 'drop-into');

  row.addEventListener('dragover', (event) => {
    const what = intent(event);
    if (!what) return;

    event.preventDefault();
    event.stopPropagation();
    if (what.kind === 'reorder') {
      row.classList.toggle('drop-after', what.after);
      row.classList.toggle('drop-before', !what.after);
      row.classList.remove('drop-into');
    } else {
      event.dataTransfer.dropEffect = what.kind === 'import' ? 'copy' : 'move';
      row.classList.add('drop-into');
      row.classList.remove('drop-before', 'drop-after');
    }
  });

  row.addEventListener('dragleave', clear);

  row.addEventListener('drop', (event) => {
    const what = intent(event);
    clear();
    if (!what) return;

    event.preventDefault();
    event.stopPropagation();

    if (what.kind === 'import') {
      /* Read the drop now: a DataTransfer is only alive during its event. */
      importDrop(fs.readDrop(event.dataTransfer), target.book);
    } else if (what.kind === 'move-into') {
      opMoveStripToBook(dragging.book, dragging.file, target.book);
    } else if (dragging.kind === 'book') {
      opReorderBook(dragging.book, target.index + (what.after ? 1 : 0));
    } else {
      opReorderStrip(dragging.book, dragging.file, target.index + (what.after ? 1 : 0));
    }
  });
}

function makeDraggable(row, payload) {
  row.draggable = true;
  row.addEventListener('dragstart', (event) => {
    if (state.busy) {
      event.preventDefault();
      return;
    }
    dragging = payload;
    row.classList.add('dragging');
    event.dataTransfer.effectAllowed = 'move';
    /* Some browsers refuse to start a drag with no payload at all. */
    event.dataTransfer.setData('text/plain', payload.file || payload.book);
  });
  row.addEventListener('dragend', () => {
    dragging = null;
    row.classList.remove('dragging');
  });
}

function renderBookRow(bookName, index, strips, open) {
  const row = document.createElement('div');
  row.className = 'row book-row';

  const twisty = document.createElement('button');
  twisty.type = 'button';
  twisty.className = 'twisty';
  twisty.textContent = open ? '▾' : '▸';
  twisty.setAttribute('aria-label', open ? 'Collapse' : 'Expand');
  twisty.addEventListener('click', () => {
    if (state.expanded.has(bookName)) state.expanded.delete(bookName);
    else state.expanded.add(bookName);
    renderTree();
  });

  const label = document.createElement('label');
  const box = document.createElement('input');
  box.type = 'checkbox';
  const selected = strips.filter((strip) => strip.state.selected).length;
  box.checked = selected > 0 && selected === strips.length;
  box.indeterminate = selected > 0 && selected < strips.length;
  box.disabled = !strips.length;
  box.addEventListener('change', () => {
    for (const strip of strips) strip.state.selected = box.checked;
    refreshSelection();
    renderTree();
  });

  const title = document.createElement('span');
  title.className = 'title';
  title.textContent = bookName;
  label.append(box, title);

  const actions = document.createElement('div');
  actions.className = 'actions';
  actions.append(
    actionButton('↑', 'Move this book up', () => opReorderBook(bookName, index - 1)),
    actionButton('↓', 'Move this book down', () => opReorderBook(bookName, index + 2)),
    actionButton('✎', 'Rename this book', () => opRenameBook(bookName)),
    actionButton('✕', 'Delete this book', () => opDeleteBook(bookName)),
  );

  const chips = document.createElement('div');
  chips.className = 'chips';
  const read = strips.filter((strip) => strip.state.read).length;
  chips.append(chip(`${read}/${strips.length} read`, 'read'));

  row.append(twisty, label, chips, actions);
  makeDraggable(row, { kind: 'book', book: bookName, index });
  makeDropTarget(row, { kind: 'book', book: bookName, index });
  return row;
}

function renderStripRow(bookName, strip, index, siblings) {
  const row = document.createElement('div');
  row.className = 'row strip-row';

  const label = document.createElement('label');
  const box = document.createElement('input');
  box.type = 'checkbox';
  box.checked = strip.state.selected;
  box.addEventListener('click', (event) => {
    /* Shift-click selects a range, the way file lists everywhere do. */
    if (event.shiftKey && lastClicked.book === bookName && lastClicked.index >= 0) {
      const [from, to] = [Math.min(lastClicked.index, index), Math.max(lastClicked.index, index)];
      for (let i = from; i <= to; i++) siblings[i].state.selected = box.checked;
    } else {
      strip.state.selected = box.checked;
    }
    lastClicked = { book: bookName, index };
    refreshSelection();
    renderTree();
  });

  const title = document.createElement('span');
  title.className = 'title';
  title.textContent = strip.title;
  label.append(box, title);

  const actions = document.createElement('div');
  actions.className = 'actions';
  actions.append(
    actionButton('↑', 'Move this strip up', () => opReorderStrip(bookName, strip.file, index - 1)),
    actionButton('↓', 'Move this strip down', () => opReorderStrip(bookName, strip.file, index + 2)),
    actionButton('✎', 'Rename this strip', () => opRenameStrip(bookName, strip.file)),
    actionButton('✕', 'Delete this strip', () => opDeleteStrip(bookName, strip.file)),
  );

  row.append(label, stripChips(strip), actions);
  makeDraggable(row, { kind: 'strip', book: bookName, file: strip.file, index });
  makeDropTarget(row, { kind: 'strip', book: bookName, file: strip.file, index });
  return row;
}

function renderTree() {
  ui.tree.replaceChildren();

  const names = metaStore.bookNames(state.meta).filter((name) => {
    if (!state.filter) return true;
    return matchesFilter(name) || stripsOf(name).some((strip) => matchesFilter(strip.title));
  });

  if (!names.length) {
    const empty = document.createElement('p');
    empty.className = 'empty';
    empty.textContent = metaStore.bookNames(state.meta).length
      ? 'Nothing matches that filter.'
      : 'No books yet. Drop a folder of images here, or press New book.';
    ui.tree.append(empty);
    return;
  }

  names.forEach((bookName, index) => {
    const strips = stripsOf(bookName);
    const shown = state.filter && !matchesFilter(bookName)
      ? strips.filter((strip) => matchesFilter(strip.title))
      : strips;

    const container = document.createElement('div');
    container.className = 'book';

    const open = state.expanded.has(bookName) || Boolean(state.filter);
    container.append(renderBookRow(bookName, index, strips, open));

    if (open) {
      if (!strips.length) {
        const empty = document.createElement('p');
        empty.className = 'empty-book';
        empty.textContent = 'Empty. Drop images on this book to add them.';
        container.append(empty);
      }
      /* Rows carry their index within the full list, not the filtered one, so
       * reordering while filtering still moves things where you expect. */
      for (const strip of shown) {
        container.append(renderStripRow(bookName, strip,
                                        strips.findIndex((each) => each.file === strip.file),
                                        strips));
      }
    }

    ui.tree.append(container);
  });
}

function refreshSelection() {
  const strips = metaStore.flatten(state.meta, state.books);
  const selected = state.meta.settings.selection === 'auto'
    ? strips.filter((strip) => !strip.state.read)
    : strips.filter((strip) => strip.state.selected);

  const pending = selected.filter((strip) => !strip.state.onCalc);
  const residentBytes = strips
    .filter((strip) => strip.state.onCalc)
    .reduce((sum, strip) => sum + (strip.state.deviceBytes || 0), 0);
  const pendingBytes = pending.reduce(
    (sum, strip) => sum + (strip.state.deviceBytes
      || syncEngine.estimateBytes(strip, state.meta.settings)), 0,
  );

  const budget = state.meta.settings.maxDeviceBytes;
  const total = residentBytes + pendingBytes;

  ui.selectionSummary.textContent = selected.length
    ? `${selected.length} selected · ${kb(total)} of ${kb(budget)}`
    : `Nothing selected · ${kb(residentBytes)} on the calculator`;

  const fraction = budget ? Math.min(1, total / budget) : 0;
  ui.meterFill.style.width = `${fraction * 100}%`;
  ui.meterFill.classList.toggle('over', total > budget);

  ui.sync.disabled = !state.calculator || state.busy;
  saveMetaSoon();
}

function refreshDevice() {
  ui.deviceStatus.textContent = state.calculator ? 'Connected' : 'Not connected';
  ui.deviceFree.textContent = kb(state.freeArchive);
  ui.deviceCount.textContent = state.calculator ? String(state.resident.length) : '—';
  ui.lastSync.textContent = state.meta.lastSync
    ? new Date(state.meta.lastSync).toLocaleString()
    : 'Never';

  const library = {
    [LIBRARY.EMPTY]: 'empty',
    [LIBRARY.SAME]: 'this one',
    [LIBRARY.DIFFERENT]: 'a different one',
    [LIBRARY.UNKNOWN]: 'not compared — no folder chosen',
  };
  ui.deviceLibrary.textContent = state.calculator
    ? (library[state.library] || '—') : '—';

  /* Erasing is only ever offered when we know what is there. With no folder
   * chosen nothing has been compared, and offering to wipe somebody's comics on
   * that basis would be reckless. */
  ui.reset.hidden = !state.calculator
    || state.library === LIBRARY.UNKNOWN
    || (state.library === LIBRARY.EMPTY && state.resident.length === 0);
  refreshUpdate();
}

/* The build row, the notice and the Update button, from state alone. */
function refreshUpdate() {
  const { hello, updatePlan } = state;

  ui.deviceBuild.textContent = hello && hello.build ? `build ${hello.build}` : '—';

  const wanted = updatePlan && (updatePlan.reader || updatePlan.updater);
  ui.update.hidden = !wanted;
  if (wanted) {
    ui.update.textContent = updatePlan.reader
      ? `Update the calculator to build ${updatePlan.build}…`
      : 'Install the updater…';
  }

  /*
   * A reader update that has been sent is not installed yet, and cannot be: the
   * reader is running from the variable prgmCSUP has to replace. Saying which
   * build is waiting is the difference between "this worked, go and run the
   * updater" and "this appears to have done nothing".
   */
  if (hello && hello.updateArmed) {
    ui.updateNotice.hidden = false;
    const which = hello.armedBuild ? `Build ${hello.armedBuild}` : 'An update';
    ui.updateNotice.textContent = `${which} is on the calculator, waiting to be `
      + 'installed. Quit the reader, run prgmCSUP, then run COMICS again. '
      + `It is still running build ${hello.build} until you do.`;
  } else {
    ui.updateNotice.hidden = true;
  }
}

function refreshSettings() {
  const { settings } = state.meta;
  ui.detail.value = settings.detail;
  ui.selection.value = settings.selection;
  ui.autoDelete.checked = settings.autoDelete;
  ui.keepRead.value = String(settings.keepRead);
  ui.keepReadValue.textContent = String(settings.keepRead);
  ui.keepReadField.hidden = !settings.autoDelete;
  ui.budget.value = String(Math.round(settings.maxDeviceBytes / 1024));
}

/* ---------------------------------------------------------------- wallpaper */

/*
 * Read wallpaper.jpg back off the disk and show it.
 *
 * The file is the source of truth, not the metadata: dropping a new one into
 * the folder by hand has to work, and the hash is what decides whether the
 * calculator needs sending a new one.
 */
async function loadWallpaper() {
  if (state.wallpaperUrl) {
    URL.revokeObjectURL(state.wallpaperUrl);
    state.wallpaperUrl = null;
  }

  const file = state.root
    ? await fs.readFile(state.root, metaStore.WALLPAPER_FILENAME)
    : null;

  state.wallpaper = file ? { file, hash: await fs.hashFile(file) } : null;

  ui.wallpaperCurrent.hidden = !file;
  if (file) {
    state.wallpaperUrl = URL.createObjectURL(file);
    ui.wallpaperPreview.src = state.wallpaperUrl;
  } else {
    ui.wallpaperPreview.removeAttribute('src');
  }
}

/*
 * Ask the calculator whether it really still has the wallpaper.
 *
 * `meta.wallpaper` is only the page's record of having sent one, and the
 * calculator can have lost it since: erased, given to a different library, or
 * its index deleted -- which takes the wallpaper with it by design. Believing
 * that record over the calculator is why a folder that already had a
 * wallpaper.jpg would sync without ever sending it.
 *
 * The same correction mergeFromCalculator() makes for `onCalc`, for the same
 * reason: what is on the calculator is a question for the calculator.
 */
async function reconcileWallpaper() {
  if (!state.meta.wallpaper || !state.calculator) return;

  const verdict = await state.calculator.verifyStrip(WALLPAPER_SLOT);
  if (verdict.checked && !verdict.ok) state.meta.wallpaper = null;
}

/*
 * What the next sync should do about it.
 *
 * Recomputed rather than remembered, so the answer follows the file on disk
 * even when it was changed outside this page.
 */
function wallpaperPlan() {
  return syncEngine.planWallpaper(state.meta, state.wallpaper && state.wallpaper.file,
                                  state.wallpaper && state.wallpaper.hash);
}

/*
 * The crop dialog's parts, gathered once.
 *
 * crop.js is handed these rather than looking them up, so the geometry module
 * never has to know the page's ids -- which is what lets its arithmetic be
 * tested without a browser.
 */
function cropElements() {
  return {
    dialog: ui.cropDialog,
    canvas: ui.cropCanvas,
    zoom: ui.cropZoom,
    reset: ui.cropReset,
    use: ui.cropUse,
    cancel: ui.cropCancel,
  };
}

/*
 * Crop, then save.
 *
 * Almost no photograph is 320x240, so something has to decide what to throw
 * away, and the middle is usually the wrong guess. What lands in the library
 * folder is the cropped 4:3 image -- `wallpaper.jpg` is what gets sent, so it
 * should be what you chose to send.
 */
async function chooseWallpaper(file) {
  if (!state.root) {
    setStatus('Choose the folder holding your comics first.', 'error');
    return;
  }

  let cropped;
  try {
    cropped = await crop.open(file, cropElements());
  } catch (error) {
    setStatus(`That image could not be opened: ${error.message}`, 'error');
    return;
  }
  if (!cropped) return;      /* cancelled */

  await runOp('Saving the wallpaper…', async () => {
    await fs.writeFile(state.root, metaStore.WALLPAPER_FILENAME, cropped);
  });
  await loadWallpaper();
  refreshSelection();
}

/*
 * Adjust the crop of the wallpaper already in the folder.
 *
 * Only ever tighter -- what is on disk has been cropped once already -- which
 * is why it is stored at three times the screen rather than at it.
 */
async function recropWallpaper() {
  if (!state.wallpaper) return;
  await chooseWallpaper(state.wallpaper.file);
}

async function removeWallpaper() {
  if (!state.root) return;

  await runOp('Removing the wallpaper…', async () => {
    await fs.removeFile(state.root, metaStore.WALLPAPER_FILENAME);
  });
  await loadWallpaper();
  refreshSelection();
}

/* --------------------------------------------------------------- persistence */

let saveTimer = null;
function saveMetaSoon() {
  if (!state.root) return;
  clearTimeout(saveTimer);
  saveTimer = setTimeout(() => { saveMetaNow(); }, 400);
}

async function saveMetaNow() {
  if (!state.root) return;
  clearTimeout(saveTimer);
  try {
    await metaStore.save(state.root, serialisableMeta());
  } catch (error) {
    setStatus(`Could not write ${metaStore.META_FILENAME}: ${error.message}`, 'error');
  }
}

/* The in-memory metadata carries live file handles; strip them before writing. */
/* meta.js owns the field list, beside the code that reads it back. Keeping the
 * two apart is how `libraryId` came to be loaded and never saved. */
function serialisableMeta() {
  return metaStore.serialisable(state.meta);
}

/* --------------------------------------------------------- library editing */

/**
 * Run an operation that touches the disk.
 *
 * Everything is serialised behind `busy` -- two overlapping renames of the same
 * book would race on the filesystem -- and every one ends with a rescan, so the
 * tree always shows what is actually there rather than what we hoped.
 */
async function runOp(label, action) {
  if (state.busy || !state.root) return;
  state.busy = true;
  ui.tree.classList.add('busy');
  setStatus(label, 'busy');

  try {
    await action();
    await rescan();
    await saveMetaNow();
    setStatus(label.replace(/…$/, '') + ' — done.');
  } catch (error) {
    if (error.name !== 'AbortError') setStatus(error.message, 'error');
    /* The disk may have changed before the failure, so resync the view. */
    try {
      await rescan();
    } catch { /* the rescan error is less interesting than the original */ }
  } finally {
    state.busy = false;
    ui.tree.classList.remove('busy');
    renderTree();
    refreshSelection();
  }
}

async function rescan() {
  state.books = await fs.scanLibrary(state.root);
  metaStore.reconcile(state.meta, state.books);
  if (state.resident.length) metaStore.mergeFromCalculator(state.meta, state.resident);
}

function opReorderBook(bookName, toIndex) {
  metaStore.reorderBook(state.meta, bookName, toIndex);
  saveMetaSoon();
  renderTree();
  refreshSelection();
}

function opReorderStrip(bookName, file, toIndex) {
  metaStore.reorderStrip(state.meta, bookName, file, toIndex);
  saveMetaSoon();
  renderTree();
  refreshSelection();
}

function opNewBook() {
  const name = window.prompt('Name for the new book');
  if (name === null) return;
  runOp(`Creating "${name}"…`, async () => {
    const created = await fs.createBook(state.root, name);
    metaStore.addBookKey(state.meta, created);
    state.expanded.add(created);
  });
}

function opRenameBook(bookName) {
  const name = window.prompt('Rename this book', bookName);
  if (name === null || name === bookName) return;
  runOp(`Renaming "${bookName}"…`, async () => {
    const renamed = await fs.renameBook(state.root, bookName, name);
    metaStore.renameBookKey(state.meta, bookName, renamed);
    if (state.expanded.delete(bookName)) state.expanded.add(renamed);
  });
}

function opDeleteBook(bookName) {
  const strips = stripsOf(bookName);
  const onCalc = strips.filter((strip) => strip.state.onCalc).length;
  const warning = onCalc
    ? `\n\n${onCalc} of them are on the calculator and will be removed on the next sync.`
    : '';
  if (!window.confirm(
    `Delete "${bookName}" and its ${strips.length} strip(s) from disk?${warning}`
    + '\n\nThis cannot be undone.',
  )) return;

  runOp(`Deleting "${bookName}"…`, async () => {
    await fs.deleteBook(state.root, bookName);
    metaStore.removeBookKey(state.meta, bookName);
    state.expanded.delete(bookName);
  });
}

function opRenameStrip(bookName, file) {
  const name = window.prompt('Rename this strip', fs.titleFromFilename(file));
  if (name === null) return;
  runOp(`Renaming "${file}"…`, async () => {
    const renamed = await fs.renameStrip(state.root, bookName, file, name);
    metaStore.renameStripKey(state.meta, bookName, file, renamed);
  });
}

function opDeleteStrip(bookName, file) {
  const strip = state.meta.books[bookName].strips[file];
  const warning = strip && strip.onCalc
    ? '\n\nIt is on the calculator and will be removed on the next sync.'
    : '';
  if (!window.confirm(`Delete "${file}" from disk?${warning}\n\nThis cannot be undone.`)) return;

  runOp(`Deleting "${file}"…`, async () => {
    await fs.deleteStrip(state.root, bookName, file);
    metaStore.removeStripKey(state.meta, bookName, file);
  });
}

function opMoveStripToBook(fromBook, file, toBook) {
  runOp(`Moving "${file}" to "${toBook}"…`, async () => {
    const name = await fs.moveStripToBook(state.root, fromBook, toBook, file);
    metaStore.moveStripKey(state.meta, fromBook, toBook, file);
    if (name !== file) metaStore.renameStripKey(state.meta, toBook, file, name);
    state.expanded.add(toBook);
  });
}

/**
 * Files dropped from outside.
 *
 * Loose images go into `bookName`; a dropped folder becomes a book of its own,
 * which is the shape a downloaded chapter usually arrives in.
 *
 * `pending` is the promise fs.readDrop returned. It has to be started inside
 * the drop event itself -- a DataTransfer is dead the moment the handler
 * returns -- so the caller starts it and we only await the result.
 */
function importDrop(pending, bookName) {
  runOp('Importing…', async () => {
    const { loose, folders } = await pending;
    if (!loose.length && !folders.size) {
      throw new Error('Nothing to import — drop JPEG files or a folder of them.');
    }

    if (loose.length) {
      if (!bookName) throw new Error('Drop loose images onto a book, or drop a whole folder.');
      setStatus(`Importing ${loose.length} file(s) into "${bookName}"…`, 'busy');
      await fs.importFiles(state.root, bookName, loose, ({ index, total, name }) => {
        setStatus(`Importing ${index + 1}/${total}: ${name}`, 'busy');
      });
      state.expanded.add(bookName);
    }

    for (const [folder, files] of folders) {
      const created = state.meta.books[folder]
        ? folder
        : await fs.createBook(state.root, folder).catch(() => folder);
      if (!state.meta.books[created]) metaStore.addBookKey(state.meta, created);

      setStatus(`Importing ${files.length} file(s) into "${created}"…`, 'busy');
      await fs.importFiles(state.root, created, files, ({ index, total, name }) => {
        setStatus(`Importing ${index + 1}/${total}: ${name}`, 'busy');
      });
      state.expanded.add(created);
    }
  });
}

/* --------------------------------------------------------------------- flow */

async function loadLibrary(root) {
  state.root = root;
  setStatus('Scanning the library…', 'busy');

  state.books = await fs.scanLibrary(root);
  state.meta = metaStore.reconcile(await metaStore.load(root), state.books);

  const strips = metaStore.flatten(state.meta, state.books).length;
  setStatus(`${metaStore.bookNames(state.meta).length} books, ${strips} strips.`);

  ui.newBook.disabled = false;
  refreshSettings();
  await loadWallpaper();
  renderTree();
  refreshSelection();
  refreshDevice();
  await saveMetaNow();
}

async function connect() {
  try {
    setStatus('Waiting for the calculator…', 'busy');
    const calculator = await Calculator.request();
    await calculator.open();

    /* The OS asks before defragmenting, so this can sit for a long time. Say
     * what is happening rather than letting the page look wedged. */
    calculator.onBusy = () => {
      setStatus('The calculator is defragmenting its archive. Answer the prompt '
        + 'on it to continue — this can take a while.', 'busy');
      ui.progressStatus.textContent = 'Calculator is defragmenting — answer the '
        + 'prompt on it. Waiting…';
    };

    /*
     * With no library folder chosen, send a zero id rather than the one
     * defaultMeta() minted. All-zero means "no identity" to the calculator, so
     * it reports itself as empty rather than as holding somebody else's comics
     * -- which is what a random id would have looked like. Connecting for the
     * an update alone is a perfectly ordinary thing to want.
     */
    const libraryId = state.root
      ? metaStore.libraryIdBytes(state.meta)
      : new Uint8Array(16);

    const hello = await calculator.hello(libraryId);
    state.calculator = calculator;
    state.hello = hello;
    state.library = hello.library;
    state.freeArchive = hello.freeArchive;

    /*
     * Work out what there is to push before anything else uses the link. The
     * builds are static files next to this page, so this is a fetch, not a
     * conversation with the calculator -- and it returns null when the page was
     * opened off disk, where a relative fetch cannot reach.
     */
    state.catalogue = await updater.loadCatalogue();
    state.updatePlan = updater.plan(hello, state.catalogue);

    /* Nothing below this speaks the calculator's dialect, so stop here and say
     * so. The link stays open: an update is pushed over it, not around it. */
    const compatibility = describeCompatibility(hello);
    if (!compatibility.canSync) {
      state.resident = [];
      state.deviceIndex = null;
      renderTree();
      refreshSelection();
      refreshDevice();
      setStatus(compatibility.message, 'error');
      return;
    }

    /*
     * The CE's clock is very often unset, and read timestamps depend on it.
     * A failure here is not worth abandoning a sync over -- worst case the
     * calculator keeps its own idea of the time.
     */
    try {
      await calculator.setClock(Math.floor(Date.now() / 1000));
    } catch { /* not fatal */ }

    state.resident = await calculator.list();
    state.deviceIndex = await calculator.getIndex();

    /*
     * A library folder with no identity takes the calculator's.
     *
     * That is the state left behind by every version that read `libraryId` and
     * dropped it again on save: the folder has no claim on anything, so the
     * calculator it is plugged into is the one it belongs to. Minting a fresh
     * identity here would declare a calculator full of this folder's own comics
     * to be somebody else's -- which is exactly what it used to do, on every
     * single reconnect.
     */
    if (!state.meta.libraryId) {
      const held = state.deviceIndex && state.deviceIndex.length
        ? metaStore.libraryIdHex(libraryStore.parseIndex(state.deviceIndex).libraryId)
        : null;
      metaStore.adoptLibraryId(state.meta, held);
      state.library = held ? LIBRARY.SAME : state.library;
      await saveMetaNow();
    }

    metaStore.mergeFromCalculator(state.meta, state.resident);
    await reconcileWallpaper();

    if (hello.library === LIBRARY.DIFFERENT) {
      /*
       * These comics came from a different library folder. Syncing on top would
       * leave the calculator holding strips this library cannot account for, so
       * offer to clear it rather than merging two libraries by accident.
       */
      setStatus('This calculator holds a different library. Erase it to sync this one.',
                'error');
      ui.reset.hidden = false;
    } else {
      ui.reset.hidden = state.resident.length === 0;
      setStatus(state.root
        ? `Connected. ${state.resident.length} strips on the calculator.`
        : 'Connected. Choose a comics folder to sync a library.');
    }

    renderTree();
    refreshSelection();
    refreshDevice();
    await saveMetaNow();
  } catch (error) {
    state.calculator = null;
    state.hello = null;
    state.updatePlan = null;
    refreshDevice();
    setStatus(describeConnectError(error), 'error');
  }
}

/**
 * What this page can do with the calculator that just answered HELLO.
 *
 * link.js reports a version mismatch rather than throwing on it, because the
 * update travels over this same link: a page that refused to talk to an
 * out-of-date calculator could never push it the build that would fix it.
 * Deciding what to offer is this function's job.
 */
function describeCompatibility(hello) {
  if (hello.version < MIN_PROTOCOL_VERSION) {
    return {
      canSync: false,
      canUpdate: false,
      message: `This calculator is running eBookSync (protocol ${hello.version}), which `
        + 'cannot be updated over the cable. Install COMICS.8xp once with TI Connect CE or '
        + 'ticalc.link, and everything after that arrives over this link.',
    };
  }
  if (hello.version > PROTOCOL_VERSION) {
    return {
      canSync: false,
      canUpdate: false,
      message: `The calculator speaks protocol ${hello.version} and this page speaks `
        + `${PROTOCOL_VERSION} -- the page is the out-of-date half. Reload it, or pull the `
        + 'latest sync page.',
    };
  }
  if (!hello.compatible) {
    return {
      canSync: false,
      canUpdate: true,
      message: `This calculator speaks protocol ${hello.version}; this page speaks `
        + `${PROTOCOL_VERSION}. Update the reader to sync your library.`,
    };
  }
  return { canSync: true, canUpdate: true, message: null };
}

function describeConnectError(error) {
  if (error.name === 'NotFoundError') {
    return 'No calculator chosen. Run COMICS, press 2nd for the Sync screen, plug the '
      + 'cable in, then try again.';
  }
  if (error.name === 'InvalidStateError') {
    return 'That port is already open. Close any other program using it (a serial '
      + 'monitor, say) and try again.';
  }
  if (error.name === 'NetworkError') {
    return `Could not open the calculator's serial port: ${error.message}. `
      + 'On Linux your user may need to be in the dialout group.';
  }
  return `Could not connect: ${error.message}`;
}

/** Has the order or have the titles changed since the calculator was written? */
function indexIsStale() {
  if (!state.calculator) return false;
  try {
    const next = syncEngine.buildIndexFor(state.meta, state.books);
    const current = state.deviceIndex;
    if (!current || current.length !== next.length) return true;
    return !next.every((byte, i) => byte === current[i]);
  } catch {
    return false;
  }
}

function describePlan(plan) {
  const parts = [];

  const list = (title, items, render) => {
    if (!items.length) return;
    const heading = document.createElement('p');
    heading.textContent = title;
    const ul = document.createElement('ul');
    for (const item of items.slice(0, 12)) {
      const li = document.createElement('li');
      li.textContent = render(item);
      ul.append(li);
    }
    if (items.length > 12) {
      const li = document.createElement('li');
      li.textContent = `…and ${items.length - 12} more`;
      ul.append(li);
    }
    parts.push(heading, ul);
  };

  list(`Send ${plan.pushes.length} strip(s):`, plan.pushes,
       (strip) => `${strip.book} — ${strip.title}`);
  list(`Remove ${plan.deletes.length} read strip(s):`, plan.deletes,
       (strip) => `${strip.book} — ${strip.title}`);
  list(`Remove ${plan.orphans.length} strip(s) no longer in the library:`, plan.orphans,
       (orphan) => `slot ${orphan.slot}`);

  if (plan.indexStale) {
    const note = document.createElement('p');
    note.textContent = 'Update the book and strip order and titles on the calculator.';
    parts.push(note);
  }

  if (plan.skipped.length) {
    const warning = document.createElement('p');
    warning.className = 'warn';
    warning.textContent = `${plan.skipped.length} selected strip(s) will not fit in the space `
      + 'budget and are being left behind. Raise the budget, lower the detail level, '
      + 'or read and remove something first.';
    parts.push(warning);
  }

  /*
   * Strips already known to be too big for the reader to open. Only strips
   * converted before have a real size to judge, so this is a heads-up rather
   * than the check -- execute() measures the container it actually built.
   */
  if (plan.oversize && plan.oversize.length) {
    const warning = document.createElement('p');
    warning.className = 'warn';
    warning.textContent = `${plan.oversize.length} strip(s) are larger than the `
      + `${kb(plan.oversize[0].ceiling)} the calculator can open and will be left off. `
      + 'Choose a lower detail level for them, or split the images.';
    parts.push(warning);
  }

  if (plan.wallpaper) {
    const note = document.createElement('p');
    note.textContent = plan.wallpaper.action === 'remove'
      ? 'Remove the lock screen wallpaper.'
      : 'Send the lock screen wallpaper.';
    parts.push(note);
  }

  if (plan.empty) {
    const nothing = document.createElement('p');
    nothing.textContent = 'Nothing to do — the calculator already matches your library.';
    parts.push(nothing);
  }

  ui.planBody.replaceChildren(...parts);
  ui.planGo.disabled = plan.empty;
}

/*
 * The largest strip the attached calculator can open, in chunks.
 *
 * HELLO has always carried this and the page has always ignored it, which is
 * how strips the reader could never open came to be synced as though they were
 * fine. With nothing connected, fall back to what this build of the reader
 * uses.
 */
function deviceMaxChunks() {
  return (state.hello && state.hello.maxChunks) || syncEngine.MAX_CHUNKS;
}

async function runSync() {
  const compatibility = state.hello && describeCompatibility(state.hello);
  if (compatibility && !compatibility.canSync) {
    setStatus(compatibility.message, 'error');
    return;
  }

  if (!state.root) {
    setStatus('Choose the folder holding your comics before syncing a library. '
      + 'Updating the calculator works without one.', 'error');
    return;
  }

  if (state.library === LIBRARY.DIFFERENT) {
    setStatus('This calculator holds a different library. Erase it first.', 'error');
    return;
  }

  const plan = syncEngine.plan(state.meta, state.books, state.resident, {
    freeArchive: state.freeArchive,
    indexStale: indexIsStale(),
    maxChunks: deviceMaxChunks(),
    wallpaper: wallpaperPlan(),
  });
  describePlan(plan);

  ui.planDialog.returnValue = '';
  ui.planDialog.showModal();
  await new Promise((resolve) => ui.planDialog.addEventListener('close', resolve, { once: true }));
  if (ui.planDialog.returnValue !== 'go') return;

  const controller = new AbortController();
  const log = [];
  const total = plan.pushes.length + plan.deletes.length + plan.orphans.length;
  let done = 0;

  const appendLog = (line) => {
    log.push(line);
    ui.progressLog.textContent = log.slice(-200).join('\n');
    ui.progressLog.scrollTop = ui.progressLog.scrollHeight;
  };

  ui.progressStatus.textContent = 'Starting…';
  ui.progressFill.style.width = '0%';
  ui.progressLog.textContent = '';
  ui.progressClose.hidden = true;
  ui.progressStop.hidden = false;
  ui.progressDialog.showModal();
  ui.progressStop.onclick = () => {
    controller.abort();
    ui.progressStatus.textContent = 'Stopping after the current step…';
  };

  state.pool = state.pool || new syncEngine.ConversionPool();

  try {
    const result = await syncEngine.execute(state.calculator, state.meta, state.books, plan, {
      pool: state.pool,
      signal: controller.signal,
      maxChunks: deviceMaxChunks(),
      onStatus: (text) => {
        ui.progressStatus.textContent = text;
        appendLog(text);
        done++;
        ui.progressFill.style.width = `${Math.min(100, (done / (total + 2)) * 100)}%`;
      },
      onProgress: (progress) => {
        if (progress.phase === 'send') {
          const rate = progress.rate ? ` — ${progress.rate} KB/s` : '';
          ui.progressStatus.textContent =
            `Sending ${progress.strip.title} — chunk ${progress.chunk}/${progress.chunks}${rate}`;
        } else if (progress.stage === 'compressing') {
          ui.progressStatus.textContent =
            `Compressing ${progress.strip.title} — ${Math.round(progress.fraction * 100)}%`;
        } else if (progress.stage) {
          ui.progressStatus.textContent = `${progress.stage} ${progress.strip.title}`;
        }
      },
    });

    /*
     * Strips that did not make it. Reported one by one and left off the
     * calculator, so the next sync sends them again -- silence here is what
     * turned three bad strips into a mystery a week later.
     */
    const failures = result.failures || [];
    for (const failure of failures) appendLog(`Not sent: ${failure.reason}`);

    if (result.aborted) {
      appendLog('Stopped. Chunks already sent stay on the calculator; syncing again resumes.');
      ui.progressStatus.textContent = 'Stopped';
    } else if (failures.length) {
      ui.progressStatus.textContent = failures.length === 1
        ? '1 strip could not be sent'
        : `${failures.length} strips could not be sent`;
      ui.progressFill.style.width = '100%';
    } else {
      appendLog('Done.');
      ui.progressStatus.textContent = 'Finished';
      ui.progressFill.style.width = '100%';
    }

    state.resident = await state.calculator.list();
    state.freeArchive = await state.calculator.freeSpace();
    state.deviceIndex = await state.calculator.getIndex();
    metaStore.mergeFromCalculator(state.meta, state.resident);
    await saveMetaNow();
  } catch (error) {
    appendLog(`Failed: ${error.message}`);
    ui.progressStatus.textContent = 'Something went wrong';
    /* The connection is the usual casualty; make the user reconnect rather than
     * leaving a half-dead device handle around. */
    state.calculator = null;
    state.deviceIndex = null;
  } finally {
    ui.progressStop.hidden = true;
    ui.progressClose.hidden = false;
    renderTree();
    refreshSelection();
    refreshDevice();
  }
}

/**
 * Push the staged build.
 *
 * The reader half is not installed by this -- it cannot be, since the reader is
 * running from the variable that has to be replaced -- so the honest report at
 * the end is "sent, now go and run prgmCSUP". The updater half is installed by
 * the reader as it arrives, and needs nothing from the user at all.
 */
async function runUpdate() {
  const { calculator, catalogue, updatePlan } = state;
  if (!calculator || !catalogue || !updatePlan) return;
  if (!updatePlan.reader && !updatePlan.updater) return;

  const summary = updatePlan.reader
    ? `Send build ${updatePlan.build} to the calculator?\n\n`
      + 'Nothing is replaced until you quit the reader and run prgmCSUP. '
      + 'Your comics are not touched.'
    : 'Install the updater on the calculator?\n\nThis is what applies future updates.';
  if (!window.confirm(summary)) return;

  ui.progressTitle.textContent = 'Updating the calculator';
  ui.progressStatus.textContent = 'Starting…';
  ui.progressLog.textContent = '';
  ui.progressFill.style.width = '0%';
  ui.progressStop.hidden = true;
  ui.progressClose.hidden = true;
  ui.progressDialog.showModal();

  const log = (line) => {
    ui.progressStatus.textContent = line;
    ui.progressLog.textContent += `${line}\n`;
    ui.progressLog.scrollTop = ui.progressLog.scrollHeight;
  };

  try {
    const done = await updater.execute(calculator, catalogue, updatePlan, { onStatus: log });

    /* Ask again rather than assuming: the calculator is the only thing that
     * knows what it now holds, and it has just been written to. */
    state.hello = await calculator.hello(metaStore.libraryIdBytes(state.meta));
    state.updatePlan = updater.plan(state.hello, catalogue);

    if (done.reader) {
      log(`Build ${updatePlan.build} is on the calculator, waiting to be installed.`);
      log('Quit the reader and run prgmCSUP, then run COMICS again.');
      setStatus(`Build ${updatePlan.build} sent. Quit the reader and run prgmCSUP `
        + 'to install it, then run COMICS again. The calculator still reports the '
        + 'old build until you do — that is expected.');
    } else {
      log('The updater is installed.');
      setStatus('The updater is installed.');
    }
    ui.progressFill.style.width = '100%';
  } catch (error) {
    log(`Failed: ${error.message}`);
    setStatus(`Could not update the calculator: ${error.message}`, 'error');
  } finally {
    ui.progressStop.hidden = true;
    ui.progressClose.hidden = false;
    refreshDevice();
  }
}

async function resetCalculator() {
  if (!state.calculator) return;
  if (!window.confirm('Erase every comic on the calculator?\n\n'
      + 'Your files here are untouched; the calculator can be refilled by syncing.')) {
    return;
  }

  try {
    setStatus('Erasing the calculator…', 'busy');
    const removed = await state.calculator.resetLibrary();

    state.resident = await state.calculator.list();
    state.deviceIndex = await state.calculator.getIndex();
    state.library = LIBRARY.EMPTY;

    /* Nothing is on it now, so nothing should claim to be. */
    for (const book of Object.values(state.meta.books)) {
      for (const strip of Object.values(book.strips)) {
        strip.onCalc = false;
        strip.chunkCount = 0;
        strip.deviceBytes = 0;
      }
    }

    await saveMetaNow();
    setStatus(`Erased ${removed} strip(s). Tick what you want and sync.`);
    ui.reset.hidden = true;
    renderTree();
    refreshSelection();
    refreshDevice();
  } catch (error) {
    setStatus(`Could not erase the calculator: ${error.message}`, 'error');
  }
}

/* ------------------------------------------------------------------- wiring */

function bindSettings() {
  ui.detail.addEventListener('change', () => {
    state.meta.settings.detail = ui.detail.value;
    renderTree();
    refreshSelection();
  });
  ui.selection.addEventListener('change', () => {
    state.meta.settings.selection = ui.selection.value;
    renderTree();
    refreshSelection();
  });
  ui.autoDelete.addEventListener('change', () => {
    state.meta.settings.autoDelete = ui.autoDelete.checked;
    ui.keepReadField.hidden = !ui.autoDelete.checked;
    refreshSelection();
  });
  ui.keepRead.addEventListener('input', () => {
    state.meta.settings.keepRead = Number(ui.keepRead.value);
    ui.keepReadValue.textContent = ui.keepRead.value;
    refreshSelection();
  });
  ui.budget.addEventListener('change', () => {
    const value = Math.max(100, Number(ui.budget.value) || 100);
    state.meta.settings.maxDeviceBytes = value * 1024;
    ui.budget.value = String(value);
    refreshSelection();
  });
  ui.filter.addEventListener('input', () => {
    state.filter = ui.filter.value.trim().toLowerCase();
    renderTree();
  });

  ui.wallpaperFile.addEventListener('change', async () => {
    const [file] = ui.wallpaperFile.files;
    /* Clear the picker either way, so choosing the same file twice still
     * fires -- the file on disk may have changed underneath it. */
    ui.wallpaperFile.value = '';
    if (file) await chooseWallpaper(file);
  });

  ui.wallpaperClear.addEventListener('click', () => { removeWallpaper(); });
  ui.wallpaperRecrop.addEventListener('click', () => { recropWallpaper(); });

}

/* Dropping on the tree background rather than on a book: only whole folders
 * make sense there, since loose files would have no book to go into. */
function bindTreeDrop() {
  ui.tree.addEventListener('dragover', (event) => {
    if (dragging || state.busy || !state.root) return;
    if (!event.dataTransfer.types.includes('Files')) return;
    event.preventDefault();
    event.dataTransfer.dropEffect = 'copy';
    ui.tree.classList.add('drop-into');
  });
  ui.tree.addEventListener('dragleave', (event) => {
    if (event.target === ui.tree) ui.tree.classList.remove('drop-into');
  });
  ui.tree.addEventListener('drop', (event) => {
    ui.tree.classList.remove('drop-into');
    if (dragging || state.busy || !state.root) return;
    event.preventDefault();
    importDrop(fs.readDrop(event.dataTransfer), null);
  });
  /* Without this the browser navigates away when a drop misses a target. */
  window.addEventListener('dragover', (event) => event.preventDefault());
  window.addEventListener('drop', (event) => event.preventDefault());
}

async function start() {
  if (!fs.isSupported() || !linkSupported()) {
    ui.unsupported.hidden = false;
    ui.chooseFolder.disabled = true;
    return;
  }

  /*
   * Say which build this is, in the page and in the console.
   *
   * Pages caches JavaScript and an ES module graph caches each file on its own,
   * so a fix that has not reached the browser yet looks exactly like a fix that
   * did not work. This is how to tell those apart without guessing.
   */
  ui.pageBuild.textContent = `build ${PAGE_BUILD}`;
  console.info(`eBookSync sync page, build ${PAGE_BUILD}`);

  bindSettings();
  bindTreeDrop();
  refreshSettings();

  ui.chooseFolder.addEventListener('click', async () => {
    try {
      await loadLibrary(await fs.pickDirectory());
    } catch (error) {
      if (error.name !== 'AbortError') setStatus(`Could not open that folder: ${error.message}`, 'error');
    }
  });

  ui.newBook.addEventListener('click', opNewBook);
  ui.update.addEventListener('click', runUpdate);
  ui.reset.addEventListener('click', resetCalculator);
  ui.connect.addEventListener('click', connect);
  ui.sync.addEventListener('click', runSync);
  ui.progressClose.addEventListener('click', () => ui.progressDialog.close());

  /* If we already have permission from last time, pick up where we left off. */
  const remembered = await fs.restoreDirectory();
  if (remembered) await loadLibrary(remembered);
  else ui.chooseFolder.focus();

  window.addEventListener('beforeunload', () => {
    if (state.pool) state.pool.terminate();
  });
}

start().catch((error) => setStatus(`Startup failed: ${error.message}`, 'error'));

/* Exposed for the browser console: clearing the conversion cache is the fix for
 * "it converted something wrong", and there is no reason to spend UI on it. */
window.ebooksync = { state, cache: cacheStore };
