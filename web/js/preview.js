/*
 * Seeing a strip the way the calculator will show it.
 *
 * This does not draw the source image. It converts the strip exactly as a sync
 * would -- same worker, same settings, same conversion cache -- and then reads
 * the container back the way calc/src/render.c does: bands decompressed from
 * the chunks, 4bpp expanded through the strip's own 16-colour palette, the
 * viewport clipped to the current image. So what is on screen here is the
 * 16 colours, the despeckling and the scaling the calculator will get, not a
 * guess at them.
 *
 * Colours go through RGB1555, the format the calculator's palette holds, and
 * back out to 8 bits by replicating the top bits -- which is what the LCD's
 * own expansion does. The reader's chrome uses the same values ui.c sets.
 *
 * The decoding half is pure, so check_preview.mjs can hold it to the
 * calculator's renderer pixel for pixel; the controller underneath is the
 * dialog.
 */

import { decompress } from './zx0.js';

export const SCREEN_W = 320;
export const SCREEN_H = 240;
const HEADER_SIZE = 16;
const LAYER_SIZE = 12;
const BAND_SIZE = 5;
const BAND_HEIGHT = 32;
const COL_WIDTH = 320;

/* The reader's chrome, as ui_set_chrome_palette() sets it. */
export const UI_BG = 248;
const CHROME = {
  248: [248, 248, 248],   /* UI_BG */
  249: [24, 24, 24],      /* UI_FG */
  250: [40, 90, 200],     /* UI_ACCENT */
  251: [150, 150, 150],   /* UI_DIM */
};

/* The viewer's constants, from calc/src/viewer.c. */
const PAGE_STEP = SCREEN_H - 32;
const PROMPT_HEIGHT = 20;

/**
 * Parse a container's tables. `chunks` is its chunks in order, as the
 * converter returned them.
 */
export function parseContainer(chunks) {
  const head = chunks[0];
  const view = new DataView(head.buffer, head.byteOffset, head.byteLength);
  const magic = String.fromCharCode(...head.subarray(0, 4));
  if (magic !== 'CSX1') throw new Error('not a strip container');

  const layerCount = head[4];
  const paletteSize = view.getUint16(8, true);
  const bandCount = view.getUint16(10, true);
  const partCount = head[13];

  let pos = HEADER_SIZE;
  const palette = [];
  for (let i = 0; i < paletteSize; i++, pos += 2) palette.push(view.getUint16(pos, true));

  const layers = [];
  let bandBase = 0;
  for (let i = 0; i < layerCount; i++, pos += LAYER_SIZE) {
    const layer = {
      width: view.getUint16(pos, true),
      height: view.getUint16(pos + 2, true) | (head[pos + 4] << 16),
      cols: view.getUint16(pos + 6, true),
      bandsPerCol: view.getUint16(pos + 8, true),
      bandBase,
    };
    bandBase += layer.cols * layer.bandsPerCol;
    layers.push(layer);
  }

  const bands = [];
  for (let i = 0; i < bandCount; i++, pos += BAND_SIZE) {
    bands.push({ chunk: head[pos], offset: view.getUint16(pos + 1, true),
                 length: view.getUint16(pos + 3, true) });
  }

  /* parts[p][l]: the row image p starts on in layer l. One image is one part
   * starting at 0, whether or not the container carries a table. */
  const parts = [];
  if (partCount > 1) {
    for (let p = 0; p < partCount; p++) {
      const tops = [];
      for (let l = 0; l < layerCount; l++, pos += 3) {
        tops.push(view.getUint16(pos, true) | (head[pos + 2] << 16));
      }
      parts.push(tops);
    }
  } else {
    parts.push(layers.map(() => 0));
  }

  return { chunks, layers, palette, bands, parts };
}

/** Decompressed bands on demand, kept once decoded -- a preview is looked at
 *  back and forth, and the page has the memory the calculator does not. */
export class Decoder {
  constructor(container) {
    this.container = container;
    this.cache = new Map();
  }

  band(index) {
    let data = this.cache.get(index);
    if (!data) {
      const { chunk, offset, length } = this.container.bands[index];
      data = decompress(this.container.chunks[chunk].subarray(offset, offset + length));
      this.cache.set(index, data);
    }
    return data;
  }
}

/**
 * One screen of `layer` with its top-left at (vx, vy), as palette indices --
 * what render_view() leaves in the frame buffer. Rows at or past `limit` are
 * background, which is how the reader keeps the next image out of sight.
 */
export function renderViewport(decoder, layerIndex, vx, vy, limit = Infinity) {
  const { layers } = decoder.container;
  const layer = layers[layerIndex];
  const frame = new Uint8Array(SCREEN_W * SCREEN_H).fill(UI_BG);

  let xOff = 0;
  if (layer.width < SCREEN_W) {
    xOff = (SCREEN_W - layer.width) >> 1;
    vx = 0;
  }
  const bottom = Math.min(vy + SCREEN_H, limit, layer.height);

  for (let y = vy; y < bottom; y++) {
    const band = Math.floor(y / BAND_HEIGHT);
    const row = y - band * BAND_HEIGHT;
    for (let col = 0; col < layer.cols; col++) {
      const colLeft = col * COL_WIDTH;
      const width = Math.min(COL_WIDTH, layer.width - colLeft);
      if (colLeft + width <= vx || colLeft >= vx + SCREEN_W) continue;

      const stride = (width + 1) >> 1;
      const pixels = decoder.band(layer.bandBase + col * layer.bandsPerCol + band);
      const from = Math.max(vx, colLeft);
      const to = Math.min(vx + SCREEN_W, colLeft + width);
      const dstRow = (y - vy) * SCREEN_W;
      for (let x = from; x < to; x++) {
        const sx = x - colLeft;
        const byte = pixels[row * stride + (sx >> 1)];
        frame[dstRow + (x - vx) + xOff] = sx & 1 ? byte & 0x0f : byte >> 4;
      }
    }
  }
  return frame;
}

/** RGB1555, as the calculator's palette holds it, to 8-bit RGB. */
export function rgbFrom1555(colour) {
  const five = (v) => (v << 3) | (v >> 2);
  return [five((colour >> 10) & 31), five((colour >> 5) & 31), five(colour & 31)];
}

/* ------------------------------------------------------------- the dialog */

/**
 * A reader in a dialog.
 *
 * `load(detail)` returns a converted container for the strip at that detail
 * level; `nextTitle` is the strip after it in its book, for the bar at the end.
 * Keys are the reader's: arrows pan, + and - zoom, 2 and enter page down, 8
 * pages up, and down at the end of an image goes on to the next. Buttons do
 * the same for anyone without the keyboard to hand.
 */
export class Preview {
  constructor({ dialog, canvas, info, detail, buttons }) {
    this.dialog = dialog;
    this.canvas = canvas;
    this.info = info;
    this.detail = detail;
    this.ctx = canvas.getContext('2d');
    this.image = this.ctx.createImageData(SCREEN_W, SCREEN_H);
    canvas.width = SCREEN_W;
    canvas.height = SCREEN_H;

    this.onKey = (event) => this.#key(event);
    dialog.addEventListener('keydown', this.onKey);
    dialog.addEventListener('close', () => { this.decoder = null; });
    canvas.addEventListener('wheel', (event) => {
      event.preventDefault();
      this.#pan(0, Math.sign(event.deltaY) * 26);
    }, { passive: false });
    detail.addEventListener('change', () => this.#reload());

    const act = { up: () => this.#backward(), down: () => this.#onward(),
                  in: () => this.#zoom(1), out: () => this.#zoom(-1) };
    for (const [name, button] of Object.entries(buttons)) {
      button.addEventListener('click', () => { act[name](); this.canvas.focus(); });
    }
  }

  async open({ title, nextTitle, detail, load, maxBytes }) {
    this.title = title;
    this.nextTitle = nextTitle;
    this.load = load;
    this.maxBytes = maxBytes;
    this.detail.value = detail;
    this.dialog.showModal();
    this.canvas.focus();
    await this.#reload();
  }

  async #reload() {
    this.decoder = null;
    this.#message('Converting…');
    this.info.textContent = `${this.title} — converting at this detail level…`;
    try {
      const container = await this.load(this.detail.value);
      const parsed = parseContainer(container.chunks);
      this.decoder = new Decoder(parsed);
      this.state = { layer: 0, part: 0, vx: 0, vy: 0 };

      const kb = (bytes) => `${Math.round(bytes / 1024)} KB`;
      const images = parsed.parts.length > 1 ? ` · ${parsed.parts.length} images` : '';
      const sizes = parsed.layers.map((l) => `${l.width}×${l.height}`).join(', ');
      const over = container.totalBytes > this.maxBytes
        ? ` — too big for the calculator to open (over ${kb(this.maxBytes)})` : '';
      this.info.textContent = `${this.title}: ${kb(container.totalBytes)}, `
        + `${container.chunks.length} chunks${images} · ${sizes}${over}`;
      this.#draw();
    } catch (error) {
      this.#message('Could not convert this strip.');
      this.info.textContent = error.message;
    }
  }

  /* --- the reader's movement, from calc/src/viewer.c --- */

  #top() { return this.decoder.container.parts[this.state.part][this.state.layer]; }

  #bottom() {
    const { parts, layers } = this.decoder.container;
    const next = parts[this.state.part + 1];
    return next ? next[this.state.layer] : layers[this.state.layer].height;
  }

  #maxY() {
    const top = this.#top();
    const bottom = this.#bottom() + PROMPT_HEIGHT;
    return bottom - top > SCREEN_H ? bottom - SCREEN_H : top;
  }

  #atEnd() { return this.state.vy >= this.#maxY(); }

  #clamp() {
    const layer = this.decoder.container.layers[this.state.layer];
    this.state.vx = Math.max(0, Math.min(this.state.vx, Math.max(0, layer.width - SCREEN_W)));
    this.state.vy = Math.max(this.#top(), Math.min(this.state.vy, this.#maxY()));
  }

  #pan(dx, dy) {
    if (!this.decoder) return;
    this.state.vx += dx;
    this.state.vy += dy;
    this.#clamp();
    this.#draw();
  }

  #onward() {
    if (!this.decoder) return;
    if (this.#atEnd()) {
      if (this.state.part + 1 < this.decoder.container.parts.length) {
        this.state.part++;
        this.state.vy = this.#top();
        this.#draw();
      }
      return;
    }
    this.#pan(0, PAGE_STEP);
  }

  #backward() {
    if (!this.decoder) return;
    if (this.state.vy <= this.#top() && this.state.part > 0) {
      this.state.part--;
      this.state.vy = this.#maxY();
      this.#draw();
      return;
    }
    this.#pan(0, -PAGE_STEP);
  }

  #zoom(direction) {
    if (!this.decoder) return;
    const { layers } = this.decoder.container;
    const target = this.state.layer + direction;
    if (target < 0 || target >= layers.length) return;

    const ratio = layers[target].width / layers[this.state.layer].width;
    const centreX = (this.state.vx + SCREEN_W / 2) * ratio;
    const centreY = (this.state.vy + SCREEN_H / 2) * ratio;
    this.state.layer = target;
    this.state.vx = Math.max(0, Math.round(centreX - SCREEN_W / 2));
    this.state.vy = Math.max(0, Math.round(centreY - SCREEN_H / 2));
    this.#clamp();
    this.#draw();
  }

  #key(event) {
    const moves = {
      ArrowUp: () => this.#pan(0, -14), ArrowDown: () => (this.#atEnd() ? this.#onward() : this.#pan(0, 14)),
      ArrowLeft: () => this.#pan(-14, 0), ArrowRight: () => this.#pan(14, 0),
      2: () => this.#onward(), Enter: () => this.#onward(), 8: () => this.#backward(),
      '+': () => this.#zoom(1), '=': () => this.#zoom(1), '-': () => this.#zoom(-1),
    };
    const move = moves[event.key];
    if (!move || event.target === this.detail) return;
    /* An arrow held down repeats; only a fresh press goes on past the end of
     * an image, as on the calculator. */
    if (event.key === 'ArrowDown' && event.repeat && this.#atEnd()) {
      event.preventDefault();
      return;
    }
    event.preventDefault();
    move();
  }

  /* --- drawing --- */

  #draw() {
    const { container } = this.decoder;
    const { layer, vx, vy } = this.state;
    const frame = renderViewport(this.decoder, layer, vx, vy, this.#bottom());

    const colours = container.palette.map(rgbFrom1555);
    const out = this.image.data;
    for (let i = 0; i < frame.length; i++) {
      const [r, g, b] = frame[i] < 16 ? colours[frame[i]] : CHROME[frame[i]] || CHROME[UI_BG];
      out[i * 4] = r;
      out[i * 4 + 1] = g;
      out[i * 4 + 2] = b;
      out[i * 4 + 3] = 255;
    }
    this.ctx.putImageData(this.image, 0, 0);

    if (this.#atEnd()) this.#drawPrompt();
  }

  /* The bar the reader draws at the end of an image, in its colours. The
   * calculator's own font is a fixed 8-pixel one; a monospace face at that
   * size is the nearest thing to hand. */
  #drawPrompt() {
    const { ctx } = this;
    const y = SCREEN_H - PROMPT_HEIGHT;
    const rgb = (index) => `rgb(${CHROME[index].join(',')})`;
    ctx.fillStyle = rgb(248);
    ctx.fillRect(0, y, SCREEN_W, PROMPT_HEIGHT);
    ctx.fillStyle = rgb(250);
    ctx.fillRect(0, y, SCREEN_W, 2);
    ctx.fillRect(11, y + 6, 3, 3);
    for (let row = 0; row < 4; row++) ctx.fillRect(8 + row, y + 9 + row, 9 - 2 * row, 1);

    ctx.font = '8px monospace';
    ctx.textBaseline = 'top';
    const parts = this.decoder.container.parts.length;
    if (this.state.part + 1 < parts) {
      ctx.fillStyle = rgb(249);
      ctx.fillText(`Part ${this.state.part + 2} of ${parts}`, 24, y + 7);
      ctx.fillStyle = rgb(251);
      ctx.fillText('press down', SCREEN_W - 88, y + 7);
    } else if (this.nextTitle) {
      ctx.fillStyle = rgb(249);
      ctx.fillText(`Next: ${this.nextTitle}`, 24, y + 7);
    } else {
      ctx.fillStyle = rgb(251);
      ctx.fillText('End of book', 24, y + 7);
    }
  }

  #message(text) {
    const { ctx } = this;
    ctx.fillStyle = `rgb(${CHROME[248].join(',')})`;
    ctx.fillRect(0, 0, SCREEN_W, SCREEN_H);
    ctx.fillStyle = `rgb(${CHROME[251].join(',')})`;
    ctx.font = '10px monospace';
    ctx.textBaseline = 'top';
    ctx.fillText(text, 10, 110);
  }
}
