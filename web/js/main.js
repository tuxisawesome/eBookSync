/*
 * The sync page: pick a library, tick what you want, send it.
 *
 * Everything that decides bytes lives elsewhere -- this wires the DOM to
 * fs/meta/sync and keeps the tree and the space meter honest.
 */

import * as cacheStore from './cache.js';
import * as fs from './fs.js';
import * as metaStore from './meta.js';
import * as syncEngine from './sync.js';
import { Calculator, isSupported as usbSupported } from './usb.js';

const el = (id) => document.getElementById(id);

const ui = {
  status: el('status'),
  unsupported: el('unsupported'),
  chooseFolder: el('choose-folder'),
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
  deviceStatus: el('device-status'),
  deviceFree: el('device-free'),
  deviceCount: el('device-count'),
  lastSync: el('last-sync'),
  selectionSummary: el('selection-summary'),
  meterFill: el('meter-fill'),
  planDialog: el('plan-dialog'),
  planBody: el('plan-body'),
  planGo: el('plan-go'),
  progressDialog: el('progress-dialog'),
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
  freeArchive: null,
  expanded: new Set(),
  filter: '',
  pool: null,
};

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

function stripsOf(bookName) {
  const book = state.meta.books[bookName];
  const scanned = state.books.find((entry) => entry.name === bookName);
  if (!book || !scanned) return [];
  return scanned.strips
    .filter((strip) => book.strips[strip.name])
    .map((strip) => ({
      file: strip.name,
      title: fs.titleFromFilename(strip.name),
      state: book.strips[strip.name],
    }));
}

function matchesFilter(text) {
  return !state.filter || text.toLowerCase().includes(state.filter);
}

/* ---------------------------------------------------------------- rendering */

function chip(text, kind) {
  const span = document.createElement('span');
  span.className = `chip ${kind}`;
  span.textContent = text;
  return span;
}

function stripChips(strip) {
  const chips = document.createElement('div');
  chips.className = 'chips';
  if (strip.state.onCalc) chips.append(chip('on calc', 'on-calc'));
  if (strip.state.read) chips.append(chip('read', 'read'));
  if (strip.state.selected && !strip.state.onCalc) chips.append(chip('queued', 'queued'));
  const size = strip.state.deviceBytes
    || syncEngine.estimateBytes(strip, state.meta.settings);
  chips.append(chip(kb(size), 'size'));
  return chips;
}

function renderTree() {
  ui.tree.replaceChildren();

  const visibleBooks = state.books.filter((book) => {
    if (!state.meta.books[book.name]) return false;
    if (!state.filter) return true;
    return matchesFilter(book.name)
      || stripsOf(book.name).some((strip) => matchesFilter(strip.title));
  });

  if (!visibleBooks.length) {
    const empty = document.createElement('p');
    empty.className = 'empty';
    empty.textContent = state.books.length
      ? 'Nothing matches that filter.'
      : 'No books found. Each book should be a folder of JPEGs.';
    ui.tree.append(empty);
    return;
  }

  for (const book of visibleBooks) {
    const strips = stripsOf(book.name);
    const shown = state.filter && !matchesFilter(book.name)
      ? strips.filter((strip) => matchesFilter(strip.title))
      : strips;

    const container = document.createElement('div');
    container.className = 'book';

    const row = document.createElement('div');
    row.className = 'row';

    const open = state.expanded.has(book.name) || Boolean(state.filter);
    const twisty = document.createElement('button');
    twisty.type = 'button';
    twisty.className = 'twisty';
    twisty.textContent = open ? '▾' : '▸';
    twisty.setAttribute('aria-label', open ? 'Collapse' : 'Expand');
    twisty.addEventListener('click', () => {
      if (state.expanded.has(book.name)) state.expanded.delete(book.name);
      else state.expanded.add(book.name);
      renderTree();
    });

    const label = document.createElement('label');
    const box = document.createElement('input');
    box.type = 'checkbox';
    const selectedCount = strips.filter((strip) => strip.state.selected).length;
    box.checked = selectedCount > 0 && selectedCount === strips.length;
    box.indeterminate = selectedCount > 0 && selectedCount < strips.length;
    box.addEventListener('change', () => {
      for (const strip of strips) strip.state.selected = box.checked;
      refreshSelection();
      renderTree();
    });

    const title = document.createElement('span');
    title.className = 'title';
    title.textContent = book.name;
    label.append(box, title);

    const readCount = strips.filter((strip) => strip.state.read).length;
    const chips = document.createElement('div');
    chips.className = 'chips';
    chips.append(chip(`${readCount}/${strips.length} read`, 'read'));

    row.append(twisty, label, chips);
    container.append(row);

    if (open) {
      let lastClicked = -1;
      shown.forEach((strip, position) => {
        const stripRow = document.createElement('div');
        stripRow.className = 'row strip-row';

        const stripLabel = document.createElement('label');
        const stripBox = document.createElement('input');
        stripBox.type = 'checkbox';
        stripBox.checked = strip.state.selected;
        stripBox.addEventListener('click', (event) => {
          /* Shift-click selects a range, the way file lists everywhere do. */
          if (event.shiftKey && lastClicked >= 0) {
            const [from, to] = [Math.min(lastClicked, position), Math.max(lastClicked, position)];
            for (let i = from; i <= to; i++) shown[i].state.selected = stripBox.checked;
          } else {
            strip.state.selected = stripBox.checked;
          }
          lastClicked = position;
          refreshSelection();
          renderTree();
        });

        const stripTitle = document.createElement('span');
        stripTitle.className = 'title';
        stripTitle.textContent = strip.title;
        stripLabel.append(stripBox, stripTitle);

        stripRow.append(stripLabel, stripChips(strip));
        container.append(stripRow);
      });
    }

    ui.tree.append(container);
  }
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

  ui.sync.disabled = !state.calculator || (!pending.length && !state.meta.settings.autoDelete);
  saveMetaSoon();
}

function refreshDevice() {
  ui.deviceStatus.textContent = state.calculator ? 'Connected' : 'Not connected';
  ui.deviceFree.textContent = kb(state.freeArchive);
  ui.deviceCount.textContent = state.calculator ? String(state.resident.length) : '—';
  ui.lastSync.textContent = state.meta.lastSync
    ? new Date(state.meta.lastSync).toLocaleString()
    : 'Never';
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

/* --------------------------------------------------------------- persistence */

let saveTimer = null;
function saveMetaSoon() {
  if (!state.root) return;
  clearTimeout(saveTimer);
  saveTimer = setTimeout(() => {
    metaStore.save(state.root, serialisableMeta()).catch((error) => {
      setStatus(`Could not write ${metaStore.META_FILENAME}: ${error.message}`, 'error');
    });
  }, 400);
}

/* The in-memory metadata carries live file handles; strip them before writing. */
function serialisableMeta() {
  return JSON.parse(JSON.stringify({
    version: metaStore.VERSION,
    lastSync: state.meta.lastSync,
    settings: state.meta.settings,
    books: state.meta.books,
  }));
}

/* --------------------------------------------------------------------- flow */

async function loadLibrary(root) {
  state.root = root;
  setStatus('Scanning the library…', 'busy');

  state.books = await fs.scanLibrary(root);
  state.meta = metaStore.reconcile(await metaStore.load(root), state.books);

  const strips = state.books.reduce((sum, book) => sum + book.strips.length, 0);
  setStatus(`${state.books.length} books, ${strips} strips.`);

  refreshSettings();
  renderTree();
  refreshSelection();
  refreshDevice();
  await metaStore.save(root, serialisableMeta());
}

async function connect() {
  try {
    setStatus('Waiting for the calculator…', 'busy');
    const calculator = await Calculator.request();
    await calculator.open();

    const hello = await calculator.hello();
    state.calculator = calculator;
    state.freeArchive = hello.freeArchive;
    state.resident = await calculator.list();

    metaStore.mergeFromCalculator(state.meta, state.resident);
    setStatus(`Connected. ${state.resident.length} strips on the calculator.`);

    renderTree();
    refreshSelection();
    refreshDevice();
    await metaStore.save(state.root, serialisableMeta());
  } catch (error) {
    state.calculator = null;
    refreshDevice();
    setStatus(describeConnectError(error), 'error');
  }
}

function describeConnectError(error) {
  if (error.name === 'NotFoundError') {
    return 'No calculator chosen. Run COMICS, press 2nd for the Sync screen, then try again.';
  }
  if (error.name === 'SecurityError' || error.name === 'NetworkError') {
    return `Could not open the calculator: ${error.message}. On Linux you may need the udev rule from docs/PROTOCOL.md.`;
  }
  return `Could not connect: ${error.message}`;
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
  list(`Remove ${plan.orphans.length} unknown strip(s):`, plan.orphans,
       (orphan) => `slot ${orphan.slot}`);

  if (plan.skipped.length) {
    const warning = document.createElement('p');
    warning.className = 'warn';
    warning.textContent = `${plan.skipped.length} selected strip(s) will not fit in the space `
      + 'budget and are being left behind. Raise the budget, lower the detail level, '
      + 'or read and remove something first.';
    parts.push(warning);
  }

  if (!plan.pushes.length && !plan.deletes.length && !plan.orphans.length) {
    const nothing = document.createElement('p');
    nothing.textContent = 'Nothing to do — the calculator already matches your selection.';
    parts.push(nothing);
  }

  ui.planBody.replaceChildren(...parts);
  ui.planGo.disabled = !plan.pushes.length && !plan.deletes.length && !plan.orphans.length;
}

async function runSync() {
  const plan = syncEngine.plan(state.meta, state.books, state.resident,
                               { freeArchive: state.freeArchive });
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
      onStatus: (text) => {
        ui.progressStatus.textContent = text;
        appendLog(text);
        done++;
        ui.progressFill.style.width = `${Math.min(100, (done / (total + 2)) * 100)}%`;
      },
      onProgress: (progress) => {
        if (progress.phase === 'send') {
          ui.progressStatus.textContent =
            `Sending ${progress.strip.title} — chunk ${progress.chunk}/${progress.chunks}`;
        } else if (progress.stage === 'compressing') {
          ui.progressStatus.textContent =
            `Compressing ${progress.strip.title} — ${Math.round(progress.fraction * 100)}%`;
        } else if (progress.stage) {
          ui.progressStatus.textContent = `${progress.stage} ${progress.strip.title}`;
        }
      },
    });

    if (result.aborted) {
      appendLog('Stopped. Chunks already sent stay on the calculator; syncing again resumes.');
      ui.progressStatus.textContent = 'Stopped';
    } else {
      appendLog('Done.');
      ui.progressStatus.textContent = 'Finished';
      ui.progressFill.style.width = '100%';
    }

    state.resident = await state.calculator.list();
    state.freeArchive = await state.calculator.freeSpace();
    metaStore.mergeFromCalculator(state.meta, state.resident);
    await metaStore.save(state.root, serialisableMeta());
  } catch (error) {
    appendLog(`Failed: ${error.message}`);
    ui.progressStatus.textContent = 'Something went wrong';
    /* The connection is the usual casualty; make the user reconnect rather than
     * leaving a half-dead device handle around. */
    state.calculator = null;
  } finally {
    ui.progressStop.hidden = true;
    ui.progressClose.hidden = false;
    renderTree();
    refreshSelection();
    refreshDevice();
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
}

async function start() {
  if (!fs.isSupported() || !usbSupported()) {
    ui.unsupported.hidden = false;
    ui.chooseFolder.disabled = true;
    return;
  }

  bindSettings();
  refreshSettings();

  ui.chooseFolder.addEventListener('click', async () => {
    try {
      await loadLibrary(await fs.pickDirectory());
      ui.connect.disabled = false;
    } catch (error) {
      if (error.name !== 'AbortError') setStatus(`Could not open that folder: ${error.message}`, 'error');
    }
  });

  ui.connect.addEventListener('click', connect);
  ui.sync.addEventListener('click', runSync);
  ui.progressClose.addEventListener('click', () => ui.progressDialog.close());

  /* If we already have permission from last time, pick up where we left off. */
  const remembered = await fs.restoreDirectory();
  if (remembered) {
    await loadLibrary(remembered);
    ui.connect.disabled = false;
  } else {
    ui.chooseFolder.focus();
  }

  window.addEventListener('beforeunload', () => {
    if (state.pool) state.pool.terminate();
  });
}

start().catch((error) => setStatus(`Startup failed: ${error.message}`, 'error'));

/* Exposed for the browser console: clearing the conversion cache is the fix for
 * "it converted something wrong", and there is no reason to spend UI on it. */
window.ebooksync = { state, cache: cacheStore };
