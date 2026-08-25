/*
 * Turning full-colour pixels into the 16 the calculator can show.
 *
 * Three steps, in order: an edge-preserving despeckle, a median-cut palette,
 * then a nearest-colour mapping. Palette choice is an encoder decision rather
 * than part of the format -- the container stores the palette explicitly -- so
 * this does not have to match tools/csx byte for byte, only look right.
 */

/*
 * How far a pixel may move before despeckle leaves it alone.
 *
 * A plain 3x3 median removes JPEG ringing and shrinks the compressed strip by
 * about 20%, but it also erases the one-pixel strokes Chinese text is built
 * from -- the page turns into a smudge. Taking the median only where it barely
 * changes the pixel cleans up flat areas and leaves every edge, and so every
 * glyph, exactly as it was. Measured at 13% smaller with no visible cost; above
 * roughly 48 the strokes start thinning.
 */
export const DEFAULT_DESPECKLE = 32;

/* Median of nine bytes via a sorting network: 19 comparisons, no allocation. */
function median9(a0, a1, a2, a3, a4, a5, a6, a7, a8) {
  let t;
  if (a1 < a0) { t = a0; a0 = a1; a1 = t; }
  if (a4 < a3) { t = a3; a3 = a4; a4 = t; }
  if (a7 < a6) { t = a6; a6 = a7; a7 = t; }
  if (a2 < a1) { t = a1; a1 = a2; a2 = t; }
  if (a5 < a4) { t = a4; a4 = a5; a5 = t; }
  if (a8 < a7) { t = a7; a7 = a8; a8 = t; }
  if (a1 < a0) { t = a0; a0 = a1; a1 = t; }
  if (a4 < a3) { t = a3; a3 = a4; a4 = t; }
  if (a7 < a6) { t = a6; a6 = a7; a7 = t; }
  if (a3 < a0) { a3 = a0; }
  if (a5 > a8) { a5 = a8; }
  if (a4 < a1) { t = a1; a1 = a4; a4 = t; }
  if (a7 < a4) { a4 = a7; }
  if (a4 < a2) { a4 = a2; }
  if (a6 > a4) { a4 = a6; }
  if (a4 < a3) { a4 = a3; }
  if (a4 > a5) { a4 = a5; }
  return a4;
}

/**
 * Edge-preserving despeckle over RGBA bytes, returning a new buffer.
 * Border pixels are copied through untouched.
 */
export function despeckle(rgba, width, height, threshold = DEFAULT_DESPECKLE) {
  if (!threshold) return rgba;

  const out = new Uint8ClampedArray(rgba);
  const stride = width * 4;

  for (let y = 1; y < height - 1; y++) {
    for (let x = 1; x < width - 1; x++) {
      const centre = y * stride + x * 4;
      let worst = 0;
      const medians = [0, 0, 0];

      for (let c = 0; c < 3; c++) {
        const p = centre + c;
        const value = median9(
          rgba[p - stride - 4], rgba[p - stride], rgba[p - stride + 4],
          rgba[p - 4], rgba[p], rgba[p + 4],
          rgba[p + stride - 4], rgba[p + stride], rgba[p + stride + 4],
        );
        medians[c] = value;
        const delta = Math.abs(value - rgba[p]);
        if (delta > worst) worst = delta;
      }

      /* Only commit the median where it barely moved the pixel. */
      if (worst <= threshold) {
        out[centre] = medians[0];
        out[centre + 1] = medians[1];
        out[centre + 2] = medians[2];
      }
    }
  }
  return out;
}

/* Colours are bucketed to 5 bits per channel before any of this: it makes the
 * histogram 32768 entries instead of 16 million, and 5 bits is exactly what the
 * calculator's RGB1555 palette can express anyway. */
const BUCKET_BITS = 5;
const BUCKETS = 1 << (BUCKET_BITS * 3);

function histogram(rgba) {
  const counts = new Uint32Array(BUCKETS);
  for (let i = 0; i < rgba.length; i += 4) {
    const key = ((rgba[i] >> 3) << 10) | ((rgba[i + 1] >> 3) << 5) | (rgba[i + 2] >> 3);
    counts[key]++;
  }
  return counts;
}

/**
 * Median-cut palette selection. Returns `colors` entries of [r, g, b],
 * each already snapped to the 5-bit grid the LCD palette uses.
 */
export function medianCut(rgba, colors = 16) {
  const counts = histogram(rgba);

  const present = [];
  for (let key = 0; key < BUCKETS; key++) {
    if (counts[key]) present.push(key);
  }
  if (!present.length) return [[0, 0, 0]];

  const channel = (key, c) => (key >> (10 - c * 5)) & 31;

  let boxes = [present];
  while (boxes.length < colors) {
    /* Split the box with the largest population-weighted extent: splitting a
     * big flat area of near-identical colour helps nobody. */
    let target = -1;
    let bestScore = 0;
    let bestChannel = 0;

    boxes.forEach((box, index) => {
      if (box.length < 2) return;
      let weight = 0;
      for (const key of box) weight += counts[key];

      for (let c = 0; c < 3; c++) {
        let low = 31;
        let high = 0;
        for (const key of box) {
          const value = channel(key, c);
          if (value < low) low = value;
          if (value > high) high = value;
        }
        const score = (high - low) * Math.log2(weight + 1);
        if (score > bestScore) {
          bestScore = score;
          target = index;
          bestChannel = c;
        }
      }
    });

    if (target < 0) break;

    const box = boxes[target];
    box.sort((a, b) => channel(a, bestChannel) - channel(b, bestChannel));

    /* Cut at the population median, not the middle of the list. */
    let total = 0;
    for (const key of box) total += counts[key];
    let running = 0;
    let cut = 0;
    for (let i = 0; i < box.length - 1; i++) {
      running += counts[box[i]];
      if (running * 2 >= total) { cut = i + 1; break; }
    }
    if (cut === 0) cut = box.length >> 1;

    boxes.splice(target, 1, box.slice(0, cut), box.slice(cut));
  }

  return boxes.map((box) => {
    let weight = 0;
    let r = 0;
    let g = 0;
    let b = 0;
    for (const key of box) {
      const count = counts[key];
      weight += count;
      r += channel(key, 0) * count;
      g += channel(key, 1) * count;
      b += channel(key, 2) * count;
    }
    if (!weight) return [0, 0, 0];
    return [
      Math.round(r / weight) << 3,
      Math.round(g / weight) << 3,
      Math.round(b / weight) << 3,
    ];
  });
}

/**
 * Map RGBA pixels to palette indices by nearest colour.
 *
 * Every distinct 5-bit colour is resolved once into a lookup table, so the
 * per-pixel cost is a shift and an array read no matter how big the image is.
 */
export function mapToPalette(rgba, palette) {
  const lookup = new Uint8Array(BUCKETS).fill(0xff);
  const out = new Uint8Array(rgba.length / 4);

  for (let i = 0, p = 0; i < rgba.length; i += 4, p++) {
    const key = ((rgba[i] >> 3) << 10) | ((rgba[i + 1] >> 3) << 5) | (rgba[i + 2] >> 3);
    let index = lookup[key];
    if (index === 0xff) {
      const r = ((key >> 10) & 31) << 3;
      const g = ((key >> 5) & 31) << 3;
      const b = (key & 31) << 3;
      let best = 0;
      let bestDistance = Infinity;
      for (let c = 0; c < palette.length; c++) {
        const dr = r - palette[c][0];
        const dg = g - palette[c][1];
        const db = b - palette[c][2];
        const distance = dr * dr + dg * dg + db * db;
        if (distance < bestDistance) { bestDistance = distance; best = c; }
      }
      index = best;
      lookup[key] = index;
    }
    out[p] = index;
  }
  return out;
}

/** Pack a colour the way graphx's gfx_RGBTo1555 does. */
export function rgbTo1555(r, g, b) {
  return ((r >> 3) << 10) | ((g >> 3) << 5) | (b >> 3);
}
