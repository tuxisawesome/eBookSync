/*
 * Talking to the calculator over USB serial.
 *
 * The calculator presents a USB CDC serial port (srldrvce on its side), and
 * this uses the Web Serial API. Chrome has it on macOS, Windows and Linux, and
 * a CDC device needs no driver on any of them -- the OS's own serial driver
 * claims it and Chrome talks through that.
 *
 * This replaced a hand-written vendor-class WebUSB device, which was the
 * original plan and could not be made to work: it needed descriptors, control
 * requests, endpoint lookup and packet-exact framing all correct at once, and
 * failed the same silent way every time. A serial port is a byte stream, which
 * is all this protocol ever wanted. See docs/PROTOCOL.md.
 */

/* srldrvce presents these -- the shared V-USB CDC identifiers. */
export const USB_VENDOR_ID = 0x16c0;
export const USB_PRODUCT_ID = 0x05e1;

export const PROTOCOL_VERSION = 3;

/*
 * The oldest calculator this page can still talk to at all.
 *
 * Protocol 1 is eBookSync, which has no UPDATE commands -- so there is no way
 * to push it a build that would fix that, and it has to be installed by hand
 * once. From 2 on, a calculator that is behind can always be brought forward
 * over the link, which is why hello() reports a mismatch instead of throwing:
 * refusing to talk to an old calculator would make the update unreachable on
 * exactly the calculators that need it.
 */
export const MIN_PROTOCOL_VERSION = 2;
const HEADER_SIZE = 8;

/*
 * The calculator ignores the baud rate -- it is a USB device pretending to be a
 * serial port, so there is no real UART to configure -- but the API insists.
 */
const BAUD_RATE = 115200;

/*
 * How long to wait for a reply before giving up.
 *
 * Long enough that a slow flash write does not look like a death, short enough
 * that a calculator which is not on its Sync screen tells you so promptly.
 */
const REPLY_TIMEOUT_MS = 30000;

/*
 * How long to wait once the calculator has said it is busy.
 *
 * The OS defragments the archive when it runs out of room, and it asks the user
 * to confirm first -- so this is bounded by a person noticing the calculator
 * and pressing a key, not by anything technical. Giving up during that would
 * abandon a strip half-written, leaving the two ends disagreeing about what is
 * stored. Waiting is always the safer error.
 */
const BUSY_TIMEOUT_MS = 15 * 60 * 1000;

export const CMD = {
  HELLO: 0x01,
  LIST: 0x02,
  PUT_CHUNK: 0x03,
  DEL: 0x04,
  INDEX_GET: 0x05,
  INDEX_PUT: 0x06,
  SPACE: 0x07,
  BYE: 0x08,
  RESET: 0x09,

  UPDATE_BEGIN: 0x0a,
  UPDATE_CHUNK: 0x0b,
  UPDATE_END: 0x0c,

  CLOCK_SET: 0x0d,
};

/*
 * Which program an UPDATE_* command is about.
 *
 * Each is installed by the other: the reader replaces CSUP during the sync
 * that brings it down, and CSUP replaces the reader when the user runs it. A
 * CE program runs in place inside its own variable and cannot overwrite itself,
 * which is the whole reason there are two. See calc/src/update.h.
 */
export const UPDATE_TARGET = { READER: 0, UPDATER: 1 };

/* HELLO's flag byte. */
export const FLAG_UPDATER = 0x01;   /* prgmCSUP is installed */
export const FLAG_ARMED = 0x02;     /* a reader update is waiting for it */

/* One update chunk, matching the calculator's payload buffer exactly. */
export const UPDATE_CHUNK_SIZE = 16384;

/* Not a reply: "still alive, the OS is defragmenting". See docs/PROTOCOL.md. */
const BUSY = 0xfe;

/* What HELLO reports about the library already on the calculator. */
/*
 * UNKNOWN is not a failure: it means this page has no library folder chosen, so
 * there was nothing to compare. Connecting to install an update alone is
 * ordinary, and that is not about comics.
 */
export const LIBRARY = { EMPTY: 0, SAME: 1, DIFFERENT: 2, UNKNOWN: 3 };

export const STATUS = {
  0: 'ok',
  1: 'unknown command',
  2: 'bad length',
  3: 'not enough archive space',
  4: 'could not write the variable',
  5: 'not found',
  6: 'payload ended early',
  7: 'the calculator cannot do that right now',
};

export class ProtocolError extends Error {
  constructor(cmd, status) {
    super(`command 0x${cmd.toString(16)} failed: ${STATUS[status] || `status ${status}`}`);
    this.name = 'ProtocolError';
    this.cmd = cmd;
    this.status = status;
  }
}

export function isSupported() {
  return typeof navigator !== 'undefined' && 'serial' in navigator;
}

export class Calculator {
  constructor(port) {
    this.port = port;
    this.seq = 0;
    this.reader = null;
    this.writer = null;
    /* Called when the calculator says it is defragmenting, so the page can say
     * so rather than looking stuck. */
    this.onBusy = null;
    /* Whatever arrived but has not been consumed yet: a stream gives no
     * guarantee about where reads land relative to messages. */
    this.pending = new Uint8Array(0);
  }

  /** Prompt for the calculator's serial port, or reuse one already granted. */
  static async request() {
    if (!isSupported()) {
      throw new Error('This browser has no Web Serial. Use Chrome, Edge or another '
        + 'Chromium browser.');
    }

    const filters = [{ usbVendorId: USB_VENDOR_ID, usbProductId: USB_PRODUCT_ID }];
    const granted = await navigator.serial.getPorts();
    const known = granted.find((port) => {
      const info = port.getInfo();
      return info.usbVendorId === USB_VENDOR_ID && info.usbProductId === USB_PRODUCT_ID;
    });

    return new Calculator(known || await navigator.serial.requestPort({ filters }));
  }

  async open() {
    await this.port.open({ baudRate: BAUD_RATE });
    this.reader = this.port.readable.getReader();
    this.writer = this.port.writable.getWriter();
    this.pending = new Uint8Array(0);
  }

  async close() {
    try {
      if (this.reader) {
        await this.reader.cancel().catch(() => {});
        this.reader.releaseLock();
        this.reader = null;
      }
      if (this.writer) {
        this.writer.releaseLock();
        this.writer = null;
      }
    } finally {
      await this.port.close();
    }
  }

  async #send(bytes) {
    await this.writer.write(bytes);
  }

  /* Reject rather than hang, so a wedged calculator is reportable. */
  static #withTimeout(promise, what, limit) {
    let timer;
    const timeout = new Promise((_, reject) => {
      timer = setTimeout(
        () => reject(new Error(`the calculator did not respond to ${what} within `
          + `${Math.round(limit / 1000)}s -- check it is on the Sync screen`)),
        limit,
      );
    });
    return Promise.race([promise, timeout]).finally(() => clearTimeout(timer));
  }

  /** Read exactly `length` bytes off the stream. */
  async #receive(length, what, limit = REPLY_TIMEOUT_MS) {
    while (this.pending.length < length) {
      const { value, done } = await Calculator.#withTimeout(this.reader.read(), what, limit);
      if (done) throw new Error('the calculator closed the connection');
      if (!value || !value.length) continue;

      const merged = new Uint8Array(this.pending.length + value.length);
      merged.set(this.pending, 0);
      merged.set(value, this.pending.length);
      this.pending = merged;
    }

    const out = this.pending.slice(0, length);
    this.pending = this.pending.slice(length);
    return out;
  }

  /**
   * Send one request and wait for its reply.
   *
   * Strictly one request in flight at a time: the calculator has no room to
   * queue work, and lockstep makes recovery after an unplug trivial.
   */
  async request(cmd, payload = new Uint8Array(0), arg = 0) {
    const seq = (this.seq = (this.seq + 1) & 0xff);
    const what = `command 0x${cmd.toString(16).padStart(2, '0')}`;

    const message = new Uint8Array(HEADER_SIZE + payload.length);
    const view = new DataView(message.buffer);
    view.setUint8(0, cmd);
    view.setUint8(1, seq);
    view.setUint16(2, arg, true);
    view.setUint32(4, payload.length, true);
    message.set(payload, HEADER_SIZE);
    await this.#send(message);

    /*
     * Read reply headers until the one for this request turns up.
     *
     * Two things can come first. A BUSY notice means the OS has started
     * defragmenting the archive and is waiting on the user, so the wait becomes
     * effectively unbounded -- abandoning it there is what would leave a strip
     * half-written. And a reply carrying an older sequence number is the late
     * answer to a request that already timed out, which is worth discarding
     * quietly rather than treating as a fault.
     */
    let limit = REPLY_TIMEOUT_MS;
    for (;;) {
      const reply = await this.#receive(HEADER_SIZE, what, limit);
      const replyView = new DataView(reply.buffer);
      const replyCmd = replyView.getUint8(0);
      const replySeq = replyView.getUint8(1);
      const status = replyView.getUint16(2, true);
      const length = replyView.getUint32(4, true);

      if (replyCmd === BUSY) {
        limit = BUSY_TIMEOUT_MS;
        if (this.onBusy) this.onBusy();
        continue;
      }

      const body = length ? await this.#receive(length, what, limit) : new Uint8Array(0);

      if (replySeq !== seq) continue;      /* a stale answer; keep looking */
      if (status !== 0) throw new ProtocolError(replyCmd, status);
      return body;
    }
  }

  /**
   * Open the conversation.
   *
   * `libraryId` identifies this library folder. The calculator compares it with
   * whatever it is already holding and says whether they match, so a calculator
   * carrying a different library is noticed before anything is sent to it.
   */
  async hello(libraryId = new Uint8Array(16)) {
    const body = await this.request(CMD.HELLO, libraryId);
    if (body.length < 6) throw new Error('short HELLO reply');

    /*
     * A version mismatch is reported, not thrown. Throwing here is what would
     * make an out-of-date calculator unfixable: the update travels over this
     * same link, so the page has to stay on speaking terms with a calculator
     * that is behind for long enough to push it forward. main.js decides what
     * to offer -- see describeCompatibility().
     */
    const version = body[0];
    return {
      version,
      compatible: version === PROTOCOL_VERSION,
      updatable: version >= MIN_PROTOCOL_VERSION && version <= PROTOCOL_VERSION,
      freeArchive: body[1] | (body[2] << 8) | (body[3] << 16),
      maxChunks: body[4],
      chunkSize: body[5] * 256,
      library: body.length > 6 ? body[6] : LIBRARY.EMPTY,
      /* Added in protocol 2; an older reader simply does not send these. */
      build: body.length >= 9 ? body[7] | (body[8] << 8) : 0,
      flags: body.length >= 10 ? body[9] : 0,
      hasUpdater: body.length >= 10 && (body[9] & FLAG_UPDATER) !== 0,
      updateArmed: body.length >= 10 && (body[9] & FLAG_ARMED) !== 0,
      /*
       * Which build is waiting for prgmCSUP, or 0.
       *
       * `build` above is what is *running*, and a reader update does not change
       * that until the updater has been run -- so without this a page cannot
       * tell an update it has just sent from one that is genuinely missing, and
       * offers to send the same build again for ever.
       */
      armedBuild: body.length >= 12 ? body[10] | (body[11] << 8) : 0,
    };
  }

  /**
   * Announce an update: what it is, how big, and what it should add up to.
   *
   * Anything already half-received on the calculator is swept here, so a sync
   * that died partway through costs nothing but the bytes it moved.
   */
  async updateBegin(target, { build, bytes, chunks, crc }) {
    const payload = new Uint8Array(12);
    const view = new DataView(payload.buffer);
    view.setUint16(0, build, true);
    view.setUint32(2, bytes, true);
    view.setUint16(6, chunks, true);
    view.setUint32(8, crc, true);
    await this.request(CMD.UPDATE_BEGIN, payload, target);
  }

  async updateChunk(target, index, chunk) {
    await this.request(CMD.UPDATE_CHUNK, chunk, target | (index << 8));
  }

  /**
   * Finish an update: the calculator checksums what it stored and either
   * installs it (the updater) or arms it for prgmCSUP (the reader).
   *
   * A CRC mismatch comes back as a ProtocolError with status 6, and nothing has
   * been replaced at that point -- the damaged image is discarded on the
   * calculator rather than left where something could install it.
   */
  async updateEnd(target) {
    await this.request(CMD.UPDATE_END, new Uint8Array(0), target);
  }

  /** Set the calculator's clock, so read timestamps mean something. */
  async setClock(unixSeconds) {
    const payload = new Uint8Array(4);
    new DataView(payload.buffer).setUint32(0, unixSeconds, true);
    await this.request(CMD.CLOCK_SET, payload);
  }

  /** Erase every comic on the calculator. Returns how many strips went. */
  async resetLibrary() {
    const body = await this.request(CMD.RESET);
    return body.length >= 2 ? body[0] | (body[1] << 8) : 0;
  }

  async list() {
    const body = await this.request(CMD.LIST);
    const view = new DataView(body.buffer, body.byteOffset, body.byteLength);
    const count = view.getUint16(0, true);

    const strips = [];
    for (let i = 0; i < count; i++) {
      const at = 2 + i * 15;
      strips.push({
        slot: view.getUint16(at, true),
        chunkCount: view.getUint8(at + 2),
        bytes: view.getUint8(at + 3) | (view.getUint8(at + 4) << 8) | (view.getUint8(at + 5) << 16),
        read: (view.getUint8(at + 6) & 1) !== 0,
        readAt: view.getUint32(at + 7, true),
        pos: view.getUint8(at + 11) | (view.getUint8(at + 12) << 8) | (view.getUint8(at + 13) << 16),
        layer: view.getUint8(at + 14),
      });
    }
    return strips;
  }

  /**
   * One chunk of a strip.
   *
   * The slot takes the whole of `arg`, so the chunk index goes at the front of
   * the payload. A library may hold more than 256 strips and a slot is 16 bits;
   * there is no room left in the header for both. See docs/PROTOCOL.md.
   */
  async putChunk(slot, index, chunk) {
    const payload = new Uint8Array(1 + chunk.length);
    payload[0] = index;
    payload.set(chunk, 1);
    await this.request(CMD.PUT_CHUNK, payload, slot);
  }

  async deleteStrip(slot) {
    try {
      const body = await this.request(CMD.DEL, new Uint8Array(0), slot);
      return body[0] || 0;
    } catch (error) {
      /* Deleting something that was already gone is not a failure. */
      if (error instanceof ProtocolError && error.status === 5) return 0;
      throw error;
    }
  }

  async getIndex() {
    return this.request(CMD.INDEX_GET);
  }

  async putIndex(bytes) {
    await this.request(CMD.INDEX_PUT, bytes);
  }

  async freeSpace() {
    const body = await this.request(CMD.SPACE);
    return body[0] | (body[1] << 8) | (body[2] << 16);
  }

  async bye() {
    await this.request(CMD.BYE);
  }
}
