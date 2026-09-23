/*
 * Check the library's files: what a scan finds, and that editing a library
 * never loses a strip's images.
 *
 * web/js/fs.js runs on the File System Access API, which node does not have, so
 * this gives it an in-memory directory tree with the same handle interface --
 * values(), getDirectoryHandle(), getFileHandle(), removeEntry(),
 * createWritable() -- and no move(), so every rename and move goes the long way
 * round, which is the path that has to be right.
 *
 * The case that matters most is a folder strip: a folder of images inside a
 * book. Renaming its book used to move only the files at the top of the book
 * and then delete the old folder recursively, which would have thrown every
 * folder strip away.
 *
 *   node tools/hosttest/check_fs.mjs
 */

import * as fs from '../../web/js/fs.js';

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

async function rejects(label, promise) {
  checks++;
  try {
    await promise;
    failures++;
    console.log(`  FAIL ${label}: did not throw`);
  } catch {
    /* expected */
  }
}

/* --- an in-memory directory tree ----------------------------------------- */

class MemFile {
  constructor(name, bytes) {
    this.kind = 'file';
    this.name = name;
    this.bytes = bytes;
    this.modified = 1;
  }

  async getFile() {
    return new File([this.bytes], this.name, { lastModified: this.modified });
  }

  async createWritable() {
    const parts = [];
    return {
      write: async (data) => {
        parts.push(data instanceof Blob ? new Uint8Array(await data.arrayBuffer())
          : typeof data === 'string' ? new TextEncoder().encode(data) : data);
      },
      close: async () => {
        this.bytes = new Uint8Array(await new Blob(parts).arrayBuffer());
        this.modified++;
      },
    };
  }
}

class MemDir {
  constructor(name) {
    this.kind = 'directory';
    this.name = name;
    this.entries = new Map();
  }

  async* values() {
    yield* [...this.entries.values()];
  }

  async getDirectoryHandle(name, { create = false } = {}) {
    const entry = this.entries.get(name);
    if (entry && entry.kind === 'directory') return entry;
    if (entry || !create) throw new DOMException(`${name} not found`, 'NotFoundError');
    const dir = new MemDir(name);
    this.entries.set(name, dir);
    return dir;
  }

  async getFileHandle(name, { create = false } = {}) {
    const entry = this.entries.get(name);
    if (entry && entry.kind === 'file') return entry;
    if (entry || !create) throw new DOMException(`${name} not found`, 'NotFoundError');
    const file = new MemFile(name, new Uint8Array());
    this.entries.set(name, file);
    return file;
  }

  async removeEntry(name, { recursive = false } = {}) {
    const entry = this.entries.get(name);
    if (!entry) throw new DOMException(`${name} not found`, 'NotFoundError');
    if (entry.kind === 'directory' && entry.entries.size && !recursive) {
      throw new DOMException(`${name} is not empty`, 'InvalidModificationError');
    }
    this.entries.delete(name);
  }
}

/** Build a tree from { name: 'contents' | { ...nested } }. */
function tree(spec, name = 'root') {
  const dir = new MemDir(name);
  for (const [child, value] of Object.entries(spec)) {
    dir.entries.set(child, typeof value === 'string'
      ? new MemFile(child, new TextEncoder().encode(value))
      : tree(value, child));
  }
  return dir;
}

/** The tree back out, for comparing: files as their text. */
async function dump(dir) {
  const out = {};
  for (const [name, entry] of [...dir.entries].sort(([a], [b]) => a.localeCompare(b))) {
    out[name] = entry.kind === 'file' ? new TextDecoder().decode(entry.bytes) : await dump(entry);
  }
  return out;
}

/* In the order dump() lists things, so the two compare as JSON. */
function sortedKeys(object) {
  return Object.fromEntries(Object.entries(object).sort(([a], [b]) => a.localeCompare(b)));
}

const EPISODE = sortedKeys({ '10.png': 'ten', '2.jpg': 'two', 'B.webp': 'bee', 'a.gif': 'ay',
                             'notes.txt': 'not an image' });

function library() {
  return tree({
    'Book A': {
      '001.jpg': 'one',
      '002.png': 'two',
      '第3话': { ...EPISODE },
      'empty folder': {},
      'cover.txt': 'not a comic',
    },
    'Book B': { '01.webp': 'b1' },
    'wallpaper.jpg': 'not a book',
  });
}

/* --- what a scan finds ---------------------------------------------------- */
{
  const root = library();
  const books = await fs.scanLibrary(root);
  const a = books.find((book) => book.name === 'Book A');

  check('scan: books', books.map((book) => book.name), ['Book A', 'Book B']);
  check('scan: images of any kind, and a folder, are strips',
        a.strips.map((strip) => [strip.name, strip.kind]),
        [['001.jpg', 'file'], ['002.png', 'file'], ['第3话', 'folder']]);
  check('scan: a folder with no images is not a strip',
        a.strips.some((strip) => strip.name === 'empty folder'), false);

  const episode = a.strips.find((strip) => strip.kind === 'folder');
  check('scan: a folder strip reads its images 0-9 then A-Z, 10 after 2',
        episode.parts.map((part) => part.name), ['2.jpg', '10.png', 'a.gif', 'B.webp']);
  check('scan: a folder strip is as big as its images', episode.size, 3 + 3 + 2 + 3);
  check('scan: the title of a folder strip is its name', fs.titleFromFilename(episode.name), '第3话');

  const files = await fs.stripFiles(episode);
  check('stripFiles: the images, in reading order',
        await Promise.all(files.map((file) => file.text())), ['two', 'ten', 'ay', 'bee']);

  /* The hash is what the conversion cache is keyed on: any change to the
   * images, or to their order, has to change it. */
  const before = await fs.hashStrip(episode);
  check('hashStrip: stable', await fs.hashStrip(episode), before);
  const single = a.strips[0];
  check('hashStrip: an image hashes as itself',
        await fs.hashStrip(single), await fs.hashFile(await single.handle.getFile()));

  const folder = root.entries.get('Book A').entries.get('第3话');
  folder.entries.set('11.jpg', new MemFile('11.jpg', new TextEncoder().encode('eleven')));
  const grown = (await fs.scanLibrary(root))[0].strips.find((strip) => strip.kind === 'folder');
  check('hashStrip: adding an image changes it', (await fs.hashStrip(grown)) !== before, true);
  check('scan: and so does the stamp', grown.stamp !== episode.stamp, true);
}

/* --- editing never loses a folder strip's images --------------------------- */
{
  const root = library();
  await fs.renameBook(root, 'Book A', 'Book A, renamed');
  check('renameBook: the folder strip and all its images go with the book',
        (await dump(root))['Book A, renamed']['第3话'], EPISODE);
  check('renameBook: and the old book is gone', root.entries.has('Book A'), false);
}
{
  const root = library();
  const name = await fs.renameStrip(root, 'Book A', '第3话', '第三话');
  check('renameStrip: a folder strip is renamed without an extension', name, '第三话');
  check('renameStrip: with its images', (await dump(root))['Book A']['第三话'], EPISODE);
  check('renameStrip: an image keeps its extension',
        await fs.renameStrip(root, 'Book A', '001.jpg', 'first'), 'first.jpg');
  /* An image keeps its extension, so it cannot land on a folder's name -- but
   * a folder strip renamed to an image's name would. */
  await rejects('renameStrip: a folder strip onto a name already taken',
                fs.renameStrip(root, 'Book A', '第三话', 'first.jpg'));
}
{
  const root = library();
  root.entries.get('Book B').entries.set('第3话', new MemDir('第3话'));
  root.entries.get('Book B').entries.get('第3话').entries.set('0.jpg',
    new MemFile('0.jpg', new TextEncoder().encode('other')));

  const name = await fs.moveStripToBook(root, 'Book A', 'Book B', '第3话');
  check('moveStripToBook: a folder strip lands under a free name', name, '第3话 (2)');
  check('moveStripToBook: with its images', (await dump(root))['Book B']['第3话 (2)'], EPISODE);
  check('moveStripToBook: without disturbing the one already there',
        (await dump(root))['Book B']['第3话'], { '0.jpg': 'other' });
  check('moveStripToBook: and it is gone from where it was',
        root.entries.get('Book A').entries.has('第3话'), false);
}
{
  const root = library();
  await fs.deleteStrip(root, 'Book A', '第3话');
  check('deleteStrip: a folder strip goes, images and all',
        root.entries.get('Book A').entries.has('第3话'), false);
}

/* --- importing ------------------------------------------------------------- */
{
  const root = library();
  const files = [new File(['x'], '1.jpg'), new File(['y'], '0.png'), new File(['z'], 'read me.txt')];
  const name = await fs.importFolderStrip(root, 'Book A', '第3话', files);
  check('importFolderStrip: next to one of the same name, under a free name', name, '第3话 (2)');
  check('importFolderStrip: the images, and only the images',
        (await dump(root))['Book A']['第3话 (2)'], { '0.png': 'y', '1.jpg': 'x' });
  check('importFolderStrip: which scan as one strip',
        (await fs.scanLibrary(root))[0].strips.filter((strip) => strip.kind === 'folder')
          .map((strip) => strip.name), ['第3话', '第3话 (2)']);
}

console.log(`${checks - failures}/${checks} library file checks pass`);
process.exit(failures ? 1 : 0);
