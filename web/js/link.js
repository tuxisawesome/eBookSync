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

export const PROTOCOL_VERSION = 1;
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
};

/* Not a reply: "still alive, the OS is defragmenting". See docs/PROTOCOL.md. */
const BUSY = 0xfe;

/* What HELLO reports about the library already on the calculator. */
export const LIBRARY = { EMPTY: 0, SAME: 1, DIFFERENT: 2 };

export const STATUS = {
  0: 'ok',
  1: 'unknown command',
  2: 'bad length',
  3: 'not enough archive space',
  4: 'could not write the variable',
  5: 'not found',
  6: 'payload ended early',
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

    const version = body[0];
    if (version !== PROTOCOL_VERSION) {
      throw new Error(`calculator speaks protocol ${version}, this page speaks `
        + `${PROTOCOL_VERSION} -- update the reader on the calculator`);
    }
    return {
      version,
      freeArchive: body[1] | (body[2] << 8) | (body[3] << 16),
      maxChunks: body[4],
      chunkSize: body[5] * 256,
      library: body.length > 6 ? body[6] : LIBRARY.EMPTY,
    };
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
      const at = 2 + i * 14;
      strips.push({
        slot: view.getUint8(at),
        chunkCount: view.getUint8(at + 1),
        bytes: view.getUint8(at + 2) | (view.getUint8(at + 3) << 8) | (view.getUint8(at + 4) << 16),
        read: (view.getUint8(at + 5) & 1) !== 0,
        readAt: view.getUint32(at + 6, true),
        pos: view.getUint8(at + 10) | (view.getUint8(at + 11) << 8) | (view.getUint8(at + 12) << 16),
        layer: view.getUint8(at + 13),
      });
    }
    return strips;
  }

  async putChunk(slot, index, chunk) {
    await this.request(CMD.PUT_CHUNK, chunk, slot | (index << 8));
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
