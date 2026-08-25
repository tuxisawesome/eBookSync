/*
 * Pre-rendering book and strip titles into 2bpp bitmaps.
 *
 * Titles come from folder and file names and will usually be Chinese. The
 * calculator has no CJK font and no text shaping, so the browser -- which has
 * both, and does per-glyph font fallback for free -- renders each title once
 * and the calculator only ever blits pixels.
 *
 * Two bits per pixel rather than one: at 13px a Chinese glyph is a dense
 * tangle of strokes, and four grey levels are the difference between legible
 * and a smudge. The calculator draws them through a four-entry palette ramp, so
 * one bitmap works on both normal and selected rows.
 */

export const TITLE_HEIGHT = 16;
export const FONT_SIZE = 13;

/* Widths the reader lays out for: a book row uses the full list width, a strip
 * row leaves space for the read marker and size. Keep in step with ui.c. */
export const BOOK_WIDTH = 300;
export const STRIP_WIDTH = 272;

const FONT_STACK = `${FONT_SIZE}px "Noto Sans SC", "Noto Sans CJK SC", "Source Han Sans SC", `
  + '"PingFang SC", "Microsoft YaHei", "Hiragino Sans GB", "WenQuanYi Zen Hei", sans-serif';

const ELLIPSIS = '…';

let canvas = null;
let context = null;
const cache = new Map();

function ensureContext(width) {
  if (!canvas) {
    canvas = typeof OffscreenCanvas !== 'undefined'
      ? new OffscreenCanvas(width, TITLE_HEIGHT)
      : document.createElement('canvas');
  }
  if (canvas.width < width) canvas.width = width;
  canvas.height = TITLE_HEIGHT;
  if (!context) {
    context = canvas.getContext('2d', { willReadFrequently: true });
    if (!context) throw new Error('cannot get a 2d context to render titles');
  }
  context.font = FONT_STACK;
  context.textBaseline = 'middle';
  return context;
}

function measure(ctx, text) {
  return Math.ceil(ctx.measureText(text).width);
}

/** Trim with an ellipsis until it fits. */
export function fit(ctx, text, maxWidth) {
  if (measure(ctx, text) <= maxWidth) return text;

  let low = 0;
  let high = text.length;
  while (low < high) {
    const mid = (low + high + 1) >> 1;
    if (measure(ctx, text.slice(0, mid) + ELLIPSIS) <= maxWidth) low = mid;
    else high = mid - 1;
  }
  return low ? text.slice(0, low) + ELLIPSIS : ELLIPSIS;
}

/**
 * Render a title to { width, height, packed }.
 *
 * Level 0 is background and 3 is full-strength text; the calculator maps those
 * onto its palette ramp and skips level 0 so the row colour shows through.
 */
export function renderTitle(text, maxWidth) {
  const key = `${maxWidth} ${text}`;
  const hit = cache.get(key);
  if (hit) return hit;

  const ctx = ensureContext(maxWidth + 8);
  const shown = fit(ctx, text, maxWidth);
  const width = Math.max(1, Math.min(measure(ctx, shown), maxWidth));

  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = '#fff';
  ctx.font = FONT_STACK;
  ctx.textBaseline = 'middle';
  ctx.fillText(shown, 0, TITLE_HEIGHT / 2);

  const image = ctx.getImageData(0, 0, width, TITLE_HEIGHT).data;
  const stride = (width + 3) >> 2;
  const packed = new Uint8Array(stride * TITLE_HEIGHT);

  for (let y = 0; y < TITLE_HEIGHT; y++) {
    const row = y * stride;
    for (let x = 0; x < width; x++) {
      /* White text on a transparent canvas: alpha is the coverage. */
      const level = image[(y * width + x) * 4 + 3] >> 6;
      if (level) packed[row + (x >> 2)] |= level << (6 - 2 * (x & 3));
    }
  }

  const result = { width, height: TITLE_HEIGHT, packed };
  cache.set(key, result);
  return result;
}

export function clearCache() {
  cache.clear();
}
