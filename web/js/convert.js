/*
 * Building a .csx container: indexed layers in, calculator chunks out.
 *
 * This is the pure half of the conversion -- no canvas, no DOM -- so it can be
 * tested against the calculator's own reader. Acquiring and scaling the image
 * lives in worker/convert.js.
 *
 * See docs/FORMAT.md for the byte layout and why it is shaped this way.
 */

import { compress, DEFAULT_OFFSET_LIMIT } from './zx0.js';

export const MAGIC = 'CSX1';
export const BAND_HEIGHT = 32;
export const COL_WIDTH = 320;
export const CHUNK_SIZE = 16384;
export const PALETTE_SIZE = 16;

const HEADER_SIZE = 16;
const LAYER_SIZE = 12;
const BAND_SIZE = 5;

/**
 * The appvar one chunk of a strip lives in: `EO<slot><chunk>`, both hex.
 *
 * The page never creates these -- the calculator does, from the slot and index
 * in the PUT_CHUNK header -- but the name is part of the format, and it has
 * three implementations that have to agree: calc/src/csx.c, tools/csx/format.py
 * and this one. The host tests compare them.
 */
export function chunkName(slot, chunk) {
  if (!Number.isInteger(slot) || slot < 0 || slot > 0xff) {
    throw new Error(`strip slot ${slot} out of range 0-255`);
  }
  if (!Number.isInteger(chunk) || chunk < 0 || chunk > 0xff) {
    throw new Error(`chunk index ${chunk} out of range 0-255`);
  }
  const hex = (value) => value.toString(16).toUpperCase().padStart(2, '0');
  return `EO${hex(slot)}${hex(chunk)}`;
}

/* Named zoom ladders. The first entry is always the fit-width reading view. */
export const LAYER_PRESETS = {
  fit: [320],
  'fit+1.5x': [320, 480],
  'fit+2x': [320, 640],
};
export const DEFAULT_PRESET = 'fit+1.5x';

export function layerGeometry(width, height) {
  return {
    width,
    height,
    cols: Math.ceil(width / COL_WIDTH),
    bandsPerCol: Math.ceil(height / BAND_HEIGHT),
  };
}

export function colWidth(layer, col) {
  return Math.min(COL_WIDTH, layer.width - col * COL_WIDTH);
}

export function bandRows(layer, band) {
  return Math.min(BAND_HEIGHT, layer.height - band * BAND_HEIGHT);
}

export function stride(layer, col) {
  return (colWidth(layer, col) + 1) >> 1;
}

/** Pack one band of one column into 4bpp, two pixels per byte, high nibble first. */
export function packBand(indices, layer, col, band) {
  const width = colWidth(layer, col);
  const rows = bandRows(layer, band);
  const rowBytes = stride(layer, col);
  const x0 = col * COL_WIDTH;
  const y0 = band * BAND_HEIGHT;

  const out = new Uint8Array(rowBytes * rows);
  for (let y = 0; y < rows; y++) {
    const src = (y0 + y) * layer.width + x0;
    const dst = y * rowBytes;
    let x = 0;
    for (; x + 1 < width; x += 2) {
      out[dst + (x >> 1)] = (indices[src + x] << 4) | indices[src + x + 1];
    }
    if (x < width) out[dst + rowBytes - 1] = indices[src + x] << 4;
  }
  return out;
}

/**
 * Place compressed bands into fixed-size chunks.
 *
 * First-fit decreasing, and no band is ever allowed to straddle a chunk: that
 * is what lets the calculator hand zx0_Decompress a pointer straight into flash
 * with no staging copy. Chunk 0 is pre-charged with the header so the packer
 * cannot place a band on top of it.
 */
function packChunks(layers, palette, bands) {
  const tableSize = HEADER_SIZE + palette.length * 2
    + layers.length * LAYER_SIZE + bands.length * BAND_SIZE;
  if (tableSize > CHUNK_SIZE) {
    throw new Error(`band table needs ${tableSize} bytes but a chunk holds ${CHUNK_SIZE}`);
  }

  const fill = [tableSize];
  const entries = new Array(bands.length);

  const order = bands.map((_, i) => i).sort((a, b) => bands[b].length - bands[a].length);
  for (const index of order) {
    const size = bands[index].length;
    if (size > CHUNK_SIZE) throw new Error(`band ${index} is ${size} bytes, larger than a chunk`);

    let chunk = fill.findIndex((used) => CHUNK_SIZE - used >= size);
    if (chunk < 0) {
      chunk = fill.length;
      fill.push(0);
    }
    entries[index] = { chunk, offset: fill[chunk], length: size };
    fill[chunk] += size;
  }

  const chunks = fill.map((size) => new Uint8Array(size));
  bands.forEach((payload, i) => {
    chunks[entries[i].chunk].set(payload, entries[i].offset);
  });

  const table = new DataView(chunks[0].buffer, chunks[0].byteOffset, tableSize);
  let pos = 0;
  for (const ch of MAGIC) table.setUint8(pos++, ch.charCodeAt(0));
  table.setUint8(pos++, layers.length);
  table.setUint8(pos++, BAND_HEIGHT);
  table.setUint16(pos, COL_WIDTH, true); pos += 2;
  table.setUint16(pos, palette.length, true); pos += 2;
  table.setUint16(pos, bands.length, true); pos += 2;
  table.setUint8(pos++, chunks.length);
  pos += 3;   /* reserved */

  for (const colour of palette) { table.setUint16(pos, colour, true); pos += 2; }

  for (const layer of layers) {
    table.setUint16(pos, layer.width, true); pos += 2;
    table.setUint16(pos, layer.height & 0xffff, true); pos += 2;
    table.setUint8(pos++, layer.height >>> 16);
    pos += 1;   /* reserved */
    table.setUint16(pos, layer.cols, true); pos += 2;
    table.setUint16(pos, layer.bandsPerCol, true); pos += 2;
    pos += 2;   /* reserved */
  }

  for (const entry of entries) {
    table.setUint8(pos++, entry.chunk);
    table.setUint16(pos, entry.offset, true); pos += 2;
    table.setUint16(pos, entry.length, true); pos += 2;
  }

  if (pos !== tableSize) throw new Error(`header wrote ${pos} bytes, expected ${tableSize}`);
  return { chunks, entries };
}

/**
 * Build a container.
 *
 * `layers` is an array of { width, height, indices }, largest zoom last, all
 * sharing `palette` (16 RGB1555 values). `onProgress` is called with a fraction
 * as bands are compressed.
 */
export function buildContainer({ layers, palette, offsetLimit = DEFAULT_OFFSET_LIMIT,
                                 onProgress = null }) {
  if (palette.length !== PALETTE_SIZE) {
    throw new Error(`expected ${PALETTE_SIZE} palette entries, got ${palette.length}`);
  }

  const geometry = layers.map((layer) => layerGeometry(layer.width, layer.height));
  const raw = [];
  geometry.forEach((layer, index) => {
    for (let col = 0; col < layer.cols; col++) {
      for (let band = 0; band < layer.bandsPerCol; band++) {
        raw.push(packBand(layers[index].indices, layer, col, band));
      }
    }
  });

  const compressed = raw.map((payload, i) => {
    if (onProgress && (i & 15) === 0) onProgress(i / raw.length);
    return compress(payload, offsetLimit);
  });
  if (onProgress) onProgress(1);

  const { chunks } = packChunks(geometry, palette, compressed);
  return {
    chunks,
    layers: geometry,
    palette,
    rawBytes: raw.reduce((sum, b) => sum + b.length, 0),
    totalBytes: chunks.reduce((sum, c) => sum + c.length, 0),
  };
}
