/*
 * Converting one strip, off the main thread.
 *
 * Decode, scale to each zoom layer, despeckle, quantise to 16 colours, then
 * hand the indexed pixels to convert.js to be banded, compressed and chunked.
 * The ZX0 parse is the expensive part -- tens of seconds for a long strip -- so
 * this has to be somewhere that is not the UI thread.
 *
 * Results are cached by the caller against the source file's hash, so this runs
 * once per strip per settings change and never again.
 */

import { buildContainer, LAYER_PRESETS } from '../convert.js';
import { despeckle, DEFAULT_DESPECKLE, mapToPalette, medianCut, rgbTo1555 } from '../quantize.js';

/* Read pixels back in horizontal slices. A 2x layer of a long webtoon is well
 * over ten thousand pixels tall, and browsers cap both canvas dimensions and
 * total canvas area; slicing keeps every intermediate comfortably small. */
const SLICE_ROWS = 1024;

/* The calculator's screen, which is the whole of a wallpaper. */
const SCREEN_W = 320;
const SCREEN_H = 240;

/*
 * The lock screen wallpaper: exactly one screen, cropped to fill it.
 *
 * A 320x240 image is a very short strip, so it goes through the same encoder as
 * everything else and comes out as an ordinary .csx container -- which is why
 * the calculator needs no wallpaper format, no wallpaper decoder and no
 * wallpaper transfer command. Cover rather than letterbox: bars down the side
 * of a lock screen look like a mistake.
 */
async function coverScreen(blob) {
  const bitmap = await createImageBitmap(blob);
  const scale = Math.max(SCREEN_W / bitmap.width, SCREEN_H / bitmap.height);
  const width = Math.round(bitmap.width * scale);
  const height = Math.round(bitmap.height * scale);

  const canvas = new OffscreenCanvas(SCREEN_W, SCREEN_H);
  const ctx = canvas.getContext('2d', { willReadFrequently: true });
  ctx.drawImage(bitmap, (SCREEN_W - width) / 2, (SCREEN_H - height) / 2, width, height);
  bitmap.close();

  return {
    width: SCREEN_W,
    height: SCREEN_H,
    rgba: ctx.getImageData(0, 0, SCREEN_W, SCREEN_H).data,
  };
}

async function scaleTo(blob, width) {
  const probe = await createImageBitmap(blob);
  const height = Math.max(1, Math.round(probe.height * width / probe.width));
  probe.close();
  return createImageBitmap(blob, {
    resizeWidth: width,
    resizeHeight: height,
    resizeQuality: 'high',
  });
}

function readPixels(bitmap) {
  const { width, height } = bitmap;
  const canvas = new OffscreenCanvas(width, Math.min(height, SLICE_ROWS));
  const ctx = canvas.getContext('2d', { willReadFrequently: true });
  const out = new Uint8ClampedArray(width * height * 4);

  for (let top = 0; top < height; top += SLICE_ROWS) {
    const rows = Math.min(SLICE_ROWS, height - top);
    canvas.height = rows;
    ctx.clearRect(0, 0, width, rows);
    ctx.drawImage(bitmap, 0, -top);
    out.set(ctx.getImageData(0, 0, width, rows).data, top * width * 4);
  }
  return { width, height, rgba: out };
}

async function convert(blob, settings, report) {
  const threshold = settings.despeckle ?? DEFAULT_DESPECKLE;
  const rendered = [];

  if (settings.wallpaper) {
    /* One layer, screen-sized. No zoom ladder: there is nothing to zoom into. */
    report({ stage: 'scaling', width: SCREEN_W });
    const image = await coverScreen(blob);

    report({ stage: 'denoising', width: SCREEN_W });
    image.rgba = despeckle(image.rgba, image.width, image.height, threshold);
    rendered.push(image);
  } else {
    const widths = LAYER_PRESETS[settings.detail] || LAYER_PRESETS['fit+1.5x'];
    for (const width of widths) {
      report({ stage: 'scaling', width });
      const bitmap = await scaleTo(blob, width);
      const image = readPixels(bitmap);
      bitmap.close();

      report({ stage: 'denoising', width });
      image.rgba = despeckle(image.rgba, image.width, image.height, threshold);
      rendered.push(image);
    }
  }

  /* One palette for the whole strip, chosen from the fit-width layer, so
   * zooming never shifts the colours. */
  report({ stage: 'palette' });
  const rgbPalette = medianCut(rendered[0].rgba, settings.colors || 16);
  while (rgbPalette.length < 16) rgbPalette.push([0, 0, 0]);

  const layers = rendered.map((image, index) => {
    report({ stage: 'mapping', width: image.width, index });
    return {
      width: image.width,
      height: image.height,
      indices: mapToPalette(image.rgba, rgbPalette),
    };
  });

  const container = buildContainer({
    layers,
    palette: rgbPalette.map(([r, g, b]) => rgbTo1555(r, g, b)),
    onProgress: (fraction) => report({ stage: 'compressing', fraction }),
  });

  return {
    chunks: container.chunks,
    totalBytes: container.totalBytes,
    rawBytes: container.rawBytes,
    layers: container.layers,
  };
}

self.onmessage = async (event) => {
  const { id, blob, settings } = event.data;
  const report = (progress) => self.postMessage({ id, progress });

  try {
    const result = await convert(blob, settings, report);
    /* Transfer the chunks rather than copying them: a long strip is half a
     * megabyte and structured cloning it would double the peak memory. */
    self.postMessage({ id, result }, result.chunks.map((chunk) => chunk.buffer));
  } catch (error) {
    self.postMessage({ id, error: error && error.message ? error.message : String(error) });
  }
};
