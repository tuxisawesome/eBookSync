/*
 * Choosing which part of a photo becomes the lock screen.
 *
 * The calculator's screen is 320x240 and almost no photograph is, so something
 * has to decide what to throw away. Cropping to the middle is a guess, and it
 * is usually wrong -- the subject of a photo is rarely dead centre. This lets
 * the choice be made where it can actually be seen.
 *
 * The interaction is a fixed 4:3 window over a movable image rather than a
 * draggable rectangle over a fixed one. It is the same thing geometrically, but
 * the window is the calculator's screen at all times, so what you are looking
 * at is what you will get -- and there is no way to express an invalid crop,
 * because the image is clamped to always cover the window.
 *
 * The geometry is separated from the DOM on purpose: the clamping is the part
 * that is easy to get subtly wrong, and tools/hosttest/check_crop.mjs tests it
 * without a browser.
 */

/* The calculator's screen, and the aspect everything here is locked to. */
export const SCREEN_W = 320;
export const SCREEN_H = 240;

/*
 * What is written to wallpaper.jpg.
 *
 * Three times the screen. The calculator only ever sees 320x240 at 16 colours,
 * so this is not for it -- it is so that adjusting the crop later starts from
 * something better than an image that has already been thrown away once, and so
 * a future reader with a better screen is not stuck with 1996.
 */
export const OUTPUT_W = SCREEN_W * 3;
export const OUTPUT_H = SCREEN_H * 3;

export const JPEG_QUALITY = 0.9;

/* How far in the zoom slider goes, past the point where the image just fits. */
export const MAX_ZOOM = 6;

/* --------------------------------------------------------------- geometry */

/*
 * `scale` is screen pixels per image pixel, and `offset` is where the image's
 * top-left corner sits in screen coordinates -- so it is zero or negative,
 * because the image always covers the screen.
 */

/** The smallest scale at which the image still covers the whole screen. */
export function minimumScale(imageW, imageH) {
  if (!imageW || !imageH) return 1;
  return Math.max(SCREEN_W / imageW, SCREEN_H / imageH);
}

/**
 * Pull an offset back until the image covers the screen again.
 *
 * Every drag and every zoom goes through this, which is what makes a gap at the
 * edge unrepresentable rather than merely discouraged.
 */
export function clampOffset(imageW, imageH, scale, offsetX, offsetY) {
  const width = imageW * scale;
  const height = imageH * scale;

  /* If the image is somehow narrower than the screen -- only reachable by
   * asking for a scale below the minimum -- centre it rather than jamming it
   * against an edge, which at least looks deliberate. */
  const x = width <= SCREEN_W
    ? (SCREEN_W - width) / 2
    : Math.min(0, Math.max(SCREEN_W - width, offsetX));
  const y = height <= SCREEN_H
    ? (SCREEN_H - height) / 2
    : Math.min(0, Math.max(SCREEN_H - height, offsetY));

  return { x, y };
}

/** The part of the image the screen is showing, in image pixels. */
export function sourceRect(imageW, imageH, scale, offsetX, offsetY) {
  const { x, y } = clampOffset(imageW, imageH, scale, offsetX, offsetY);
  return {
    x: -x / scale,
    y: -y / scale,
    width: SCREEN_W / scale,
    height: SCREEN_H / scale,
  };
}

/**
 * Zoom about a fixed point, so the pixel under the cursor stays under it.
 *
 * Zooming about the top-left instead is the difference between adjusting a
 * crop and chasing it around the window.
 */
export function zoomAbout(imageW, imageH, scale, offsetX, offsetY, nextScale,
                          anchorX = SCREEN_W / 2, anchorY = SCREEN_H / 2) {
  const ratio = nextScale / scale;
  return clampOffset(
    imageW, imageH, nextScale,
    anchorX - (anchorX - offsetX) * ratio,
    anchorY - (anchorY - offsetY) * ratio,
  );
}

/** A crop that shows as much of the image as the screen's shape allows. */
export function initialCrop(imageW, imageH) {
  const scale = minimumScale(imageW, imageH);
  return {
    scale,
    ...clampOffset(imageW, imageH, scale,
                   (SCREEN_W - imageW * scale) / 2,
                   (SCREEN_H - imageH * scale) / 2),
  };
}

/* ------------------------------------------------------------------ the UI */

/* How big the preview is drawn. The crop itself is always in screen
 * coordinates; this is only how many real pixels each one is worth. */
const PREVIEW_ZOOM = 1.5;

async function bitmapFrom(blob) {
  const bitmap = await createImageBitmap(blob);
  return bitmap;
}

/**
 * Open the cropper on `blob`, and resolve with a 4:3 JPEG or null if cancelled.
 *
 * `elements` are the dialog's parts, passed in rather than looked up here so
 * this module never has to know the page's ids.
 */
export async function open(blob, elements) {
  const { dialog, canvas, zoom, reset, use, cancel } = elements;
  const bitmap = await bitmapFrom(blob);

  const context = canvas.getContext('2d');
  canvas.width = SCREEN_W * PREVIEW_ZOOM;
  canvas.height = SCREEN_H * PREVIEW_ZOOM;

  const smallest = minimumScale(bitmap.width, bitmap.height);
  let view = initialCrop(bitmap.width, bitmap.height);

  const draw = () => {
    context.clearRect(0, 0, canvas.width, canvas.height);
    const rect = sourceRect(bitmap.width, bitmap.height, view.scale, view.x, view.y);
    context.drawImage(bitmap, rect.x, rect.y, rect.width, rect.height,
                      0, 0, canvas.width, canvas.height);
  };

  const setScale = (next, anchorX, anchorY) => {
    const wanted = Math.max(smallest, Math.min(smallest * MAX_ZOOM, next));
    const moved = zoomAbout(bitmap.width, bitmap.height, view.scale, view.x, view.y,
                            wanted, anchorX, anchorY);
    view = { scale: wanted, ...moved };
    zoom.value = String(view.scale / smallest);
    draw();
  };

  /* Drag to move. Pointer events rather than mouse events, so this works with a
   * finger and a stylus without a second code path. */
  let dragging = null;
  const onPointerDown = (event) => {
    dragging = { x: event.clientX, y: event.clientY };
    canvas.setPointerCapture(event.pointerId);
  };
  const onPointerMove = (event) => {
    if (!dragging) return;
    /* The canvas is drawn PREVIEW_ZOOM times life size and may be scaled again
     * by the layout, so a pixel of movement is not a pixel of crop. */
    const perPixel = SCREEN_W / canvas.getBoundingClientRect().width;
    view = {
      scale: view.scale,
      ...clampOffset(bitmap.width, bitmap.height, view.scale,
                     view.x + (event.clientX - dragging.x) * perPixel,
                     view.y + (event.clientY - dragging.y) * perPixel),
    };
    dragging = { x: event.clientX, y: event.clientY };
    draw();
  };
  const onPointerUp = () => { dragging = null; };

  const onWheel = (event) => {
    event.preventDefault();
    const rect = canvas.getBoundingClientRect();
    const anchorX = (event.clientX - rect.left) / rect.width * SCREEN_W;
    const anchorY = (event.clientY - rect.top) / rect.height * SCREEN_H;
    setScale(view.scale * (event.deltaY < 0 ? 1.1 : 1 / 1.1), anchorX, anchorY);
  };

  const onZoom = () => setScale(smallest * Number(zoom.value));
  const onReset = () => { view = initialCrop(bitmap.width, bitmap.height);
                          zoom.value = '1'; draw(); };

  /* The dialog owns its own buttons: it is the thing that knows what "done"
   * means here, and Escape has to land in the same place as Cancel. */
  const onUse = () => dialog.close('use');
  const onCancel = () => dialog.close('cancel');

  zoom.min = '1';
  zoom.max = String(MAX_ZOOM);
  zoom.step = '0.01';
  zoom.value = '1';

  canvas.addEventListener('pointerdown', onPointerDown);
  canvas.addEventListener('pointermove', onPointerMove);
  canvas.addEventListener('pointerup', onPointerUp);
  canvas.addEventListener('pointercancel', onPointerUp);
  canvas.addEventListener('wheel', onWheel, { passive: false });
  zoom.addEventListener('input', onZoom);
  reset.addEventListener('click', onReset);
  use.addEventListener('click', onUse);
  cancel.addEventListener('click', onCancel);

  draw();
  dialog.returnValue = '';
  dialog.showModal();

  await new Promise((resolve) => dialog.addEventListener('close', resolve, { once: true }));

  canvas.removeEventListener('pointerdown', onPointerDown);
  canvas.removeEventListener('pointermove', onPointerMove);
  canvas.removeEventListener('pointerup', onPointerUp);
  canvas.removeEventListener('pointercancel', onPointerUp);
  canvas.removeEventListener('wheel', onWheel);
  zoom.removeEventListener('input', onZoom);
  reset.removeEventListener('click', onReset);
  use.removeEventListener('click', onUse);
  cancel.removeEventListener('click', onCancel);

  if (dialog.returnValue !== 'use') {
    bitmap.close();
    return null;
  }

  const cropped = await render(bitmap, view);
  bitmap.close();
  return cropped;
}

/* Draw the chosen region at output size and encode it. */
async function render(bitmap, view) {
  const rect = sourceRect(bitmap.width, bitmap.height, view.scale, view.x, view.y);
  const canvas = new OffscreenCanvas(OUTPUT_W, OUTPUT_H);
  const context = canvas.getContext('2d');
  context.drawImage(bitmap, rect.x, rect.y, rect.width, rect.height,
                    0, 0, OUTPUT_W, OUTPUT_H);
  return canvas.convertToBlob({ type: 'image/jpeg', quality: JPEG_QUALITY });
}
