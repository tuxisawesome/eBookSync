/*
 * The wallpaper cropper's geometry.
 *
 * The interaction is a fixed 320x240 window over a movable image, and the whole
 * correctness of it is one rule: the image must cover the window, always. Break
 * that and the crop has a strip of nothing down one side, which the encoder
 * then dutifully turns into a band of whatever the canvas was cleared to -- a
 * black bar on the lock screen that looks like a bug in the calculator rather
 * than a bad drag in a browser.
 *
 * Every drag and every zoom goes through clampOffset(), so this tests that one
 * function hard and the things built on it lightly. No DOM: web/js/crop.js
 * keeps the geometry separate from the dialog for exactly this reason.
 *
 *   node tools/hosttest/check_crop.mjs
 */

import {
  SCREEN_W, SCREEN_H, MAX_ZOOM,
  clampOffset, initialCrop, minimumScale, sourceRect, zoomAbout,
} from '../../web/js/crop.js';

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

function near(label, actual, expected, tolerance = 1e-9) {
  checks++;
  if (!(Math.abs(actual - expected) <= tolerance)) {
    failures++;
    console.log(`  FAIL ${label}: got ${actual}, want ${expected}`);
  }
}

/* A spread of shapes: wider than the screen, taller, square, and one already
 * exactly 4:3 -- the last is the case where the minimum scale shows everything
 * and there is nothing to drag, which is easy to get wrong by an epsilon. */
const SHAPES = [
  [4032, 3024],   /* a phone photo, already 4:3 */
  [4000, 1000],   /* a panorama */
  [1000, 4000],   /* portrait */
  [1000, 1000],   /* square */
  [160, 120],     /* smaller than the screen, and 4:3 */
  [100, 500],     /* smaller than the screen in one axis only */
];

/* --- the image always covers the screen ----------------------------------- */
{
  let gaps = 0;
  let outside = 0;

  for (const [w, h] of SHAPES) {
    const smallest = minimumScale(w, h);

    for (const zoom of [1, 1.0001, 1.5, 3, MAX_ZOOM]) {
      const scale = smallest * zoom;

      /* Shove it well past every edge, which is what a fast drag does. */
      for (const ox of [-1e6, -w * scale, -1, 0, 1, 1e6]) {
        for (const oy of [-1e6, -h * scale, -1, 0, 1, 1e6]) {
          const { x, y } = clampOffset(w, h, scale, ox, oy);

          if (x > 1e-9 || y > 1e-9) gaps++;
          if (x + w * scale < SCREEN_W - 1e-9) gaps++;
          if (y + h * scale < SCREEN_H - 1e-9) gaps++;

          const rect = sourceRect(w, h, scale, ox, oy);
          if (rect.x < -1e-9 || rect.y < -1e-9) outside++;
          if (rect.x + rect.width > w + 1e-9) outside++;
          if (rect.y + rect.height > h + 1e-9) outside++;
        }
      }
    }
  }

  check('no drag can leave a gap at any edge', gaps, 0);
  check('and the crop never reads outside the image', outside, 0);
}

/* --- the minimum scale is exactly cover, not more -------------------------- */
{
  for (const [w, h] of SHAPES) {
    const scale = minimumScale(w, h);
    const covers = w * scale >= SCREEN_W - 1e-9 && h * scale >= SCREEN_H - 1e-9;
    check(`${w}x${h}: the minimum scale covers`, covers, true);

    /* And one hair below it does not, which is what makes it the minimum. */
    const short = w * scale * 0.999 < SCREEN_W - 1e-9 || h * scale * 0.999 < SCREEN_H - 1e-9;
    check(`${w}x${h}: and nothing smaller does`, short, true);
  }
}

/* --- an image already the right shape needs no cropping -------------------- */
{
  const view = initialCrop(640, 480);
  const rect = sourceRect(640, 480, view.scale, view.x, view.y);
  near('4:3 source: x', rect.x, 0);
  near('4:3 source: y', rect.y, 0);
  near('4:3 source: width', rect.width, 640);
  near('4:3 source: height', rect.height, 480);
}

/* --- the initial crop is centred ------------------------------------------ */
/*
 * Centred is only a starting point -- the whole feature exists because centred
 * is usually the wrong answer -- but it has to be the *middle*, not a corner.
 */
{
  const view = initialCrop(4000, 1000);   /* a panorama: crops left and right */
  const rect = sourceRect(4000, 1000, view.scale, view.x, view.y);
  near('panorama: takes the full height', rect.height, 1000);
  near('panorama: and the middle of the width', rect.x + rect.width / 2, 2000);

  const tall = initialCrop(1000, 4000);
  const tallRect = sourceRect(1000, 4000, tall.scale, tall.x, tall.y);
  near('portrait: takes the full width', tallRect.width, 1000);
  near('portrait: and the middle of the height', tallRect.y + tallRect.height / 2, 2000);
}

/* --- zooming holds the point under the cursor ------------------------------ */
/*
 * Zoom about the top-left instead and adjusting a crop turns into chasing it
 * around the window, which is the difference between a tool and a toy.
 */
{
  const [w, h] = [2000, 2000];
  const smallest = minimumScale(w, h);
  const start = initialCrop(w, h);

  /* The centre of the window, in image pixels, before and after. */
  const before = sourceRect(w, h, start.scale, start.x, start.y);
  const centreBefore = { x: before.x + before.width / 2, y: before.y + before.height / 2 };

  const zoomed = zoomAbout(w, h, start.scale, start.x, start.y, smallest * 2);
  const after = sourceRect(w, h, smallest * 2, zoomed.x, zoomed.y);
  const centreAfter = { x: after.x + after.width / 2, y: after.y + after.height / 2 };

  near('zooming about the centre holds it: x', centreAfter.x, centreBefore.x, 1e-6);
  near('zooming about the centre holds it: y', centreAfter.y, centreBefore.y, 1e-6);

  /* And it really did zoom in. */
  check('zooming in shows less of the image', after.width < before.width, true);
}

/* --- zooming out cannot escape -------------------------------------------- */
/*
 * The anchor arithmetic pushes the offset around, and at the minimum scale
 * there is nowhere legal to be but flush. A clamp applied before the zoom
 * rather than after would let a corner slip out here.
 */
{
  const [w, h] = [4000, 1000];
  const smallest = minimumScale(w, h);
  const zoomedIn = zoomAbout(w, h, smallest, ...Object.values(initialCrop(w, h)).slice(1),
                             smallest * 4, 0, 0);

  const out = zoomAbout(w, h, smallest * 4, zoomedIn.x, zoomedIn.y, smallest,
                        SCREEN_W, SCREEN_H);
  const rect = sourceRect(w, h, smallest, out.x, out.y);
  check('zooming back out stays inside the image',
        rect.x >= -1e-9 && rect.x + rect.width <= w + 1e-9, true);
}

console.log(`${checks - failures}/${checks} crop checks pass`);
process.exit(failures ? 1 : 0);
