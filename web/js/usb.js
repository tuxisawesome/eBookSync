/*
 * WebUSB transport for the sync protocol.
 *
 * The calculator must be running the reader and sitting on its Sync screen:
 * only then does it present the vendor-specific device this claims. See
 * docs/PROTOCOL.md, and keep the constants in step with calc/src/proto.h.
 */

export const VENDOR_ID = 0x1209;
export const PRODUCT_ID = 0x0001;
export const PROTOCOL_VERSION = 1;

const EP_OUT = 1;
const EP_IN = 2;
const HEADER_SIZE = 8;

/* The calculator's endpoints are 64 bytes -- it is a full-speed device. */
const PACKET_SIZE = 64;

/*
 * How long to wait for the calculator to answer before giving up.
 *
 * Archiving a chunk can take a while, and a garbage collect longer still, so
 * this is generous. It exists so that a calculator that is wedged or not
 * actually on its sync screen produces an error you can act on, rather than a
 * page that sits there saying "waiting" forever.
 */
const REPLY_TIMEOUT_MS = 20000;

/* Must match STREAM_BUFFER in calc/src/usb.c: the calculator reads a payload in
 * posts of this size, and a transfer larger than one post would leave a partial
 * packet stranded between them. A multiple of PACKET_SIZE, necessarily. */
const MAX_PAYLOAD_TRANSFER = 8 * PACKET_SIZE;

export const CMD = {
  HELLO: 0x01,
  LIST: 0x02,
  PUT_CHUNK: 0x03,
  DEL: 0x04,
  INDEX_GET: 0x05,
  INDEX_PUT: 0x06,
  SPACE: 0x07,
  BYE: 0x08,
};

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
  return typeof navigator !== 'undefined' && 'usb' in navigator;
}

export class Calculator {
  constructor(device) {
    this.device = device;
    this.seq = 0;
  }

  /** Prompt for the calculator, or reuse one already granted. */
  static async request() {
    if (!isSupported()) {
      throw new Error('This browser has no WebUSB. Use Chrome, Edge or another Chromium browser.');
    }
    const filters = [{ vendorId: VENDOR_ID, productId: PRODUCT_ID }];
    const granted = await navigator.usb.getDevices();
    const device = granted.find((d) => d.vendorId === VENDOR_ID && d.productId === PRODUCT_ID)
      || await navigator.usb.requestDevice({ filters });
    return new Calculator(device);
  }

  async open() {
    await this.device.open();
    if (this.device.configuration === null) await this.device.selectConfiguration(1);
    await this.device.claimInterface(0);
  }

  async close() {
    try {
      await this.device.releaseInterface(0);
    } finally {
      await this.device.close();
    }
  }

  async #send(bytes) {
    const result = await this.device.transferOut(EP_OUT, bytes);
    if (result.status !== 'ok') throw new Error(`USB write ${result.status}`);
    if (result.bytesWritten !== bytes.length) {
      throw new Error(`USB write short: ${result.bytesWritten}/${bytes.length}`);
    }
  }

  /* Reject rather than hang, so a wedged calculator is reportable. */
  static #withTimeout(promise, what) {
    let timer;
    const timeout = new Promise((_, reject) => {
      timer = setTimeout(
        () => reject(new Error(`the calculator did not respond to ${what} within `
          + `${REPLY_TIMEOUT_MS / 1000}s -- check it is on the Sync screen`)),
        REPLY_TIMEOUT_MS,
      );
    });
    return Promise.race([promise, timeout]).finally(() => clearTimeout(timer));
  }

  async #receive(length, what) {
    const out = new Uint8Array(length);
    let filled = 0;
    while (filled < length) {
      const result = await Calculator.#withTimeout(
        this.device.transferIn(EP_IN, length - filled), what,
      );
      if (result.status !== 'ok') throw new Error(`USB read ${result.status}`);
      const chunk = new Uint8Array(result.data.buffer, result.data.byteOffset,
                                   result.data.byteLength);
      if (!chunk.length) throw new Error('calculator sent an empty packet');
      out.set(chunk.subarray(0, length - filled), filled);
      filled += chunk.length;
    }
    return out;
  }

  /**
   * Send one request and wait for its reply.
   *
   * Strictly one request in flight at a time: the calculator has no room to
   * queue work, and lockstep makes recovery after an unplug trivial.
   *
   * The header goes out as a transfer of its own, and so does the payload.
   * That is not tidiness -- USB is packet-based, and the calculator posts an
   * 8-byte receive for the header. Bundling the two into one transfer would put
   * both in a single 64-byte packet, and everything past the header would
   * overflow the endpoint and be thrown away.
   */
  async request(cmd, payload = new Uint8Array(0), arg = 0) {
    const seq = (this.seq = (this.seq + 1) & 0xff);
    const what = `command 0x${cmd.toString(16).padStart(2, '0')}`;

    const header = new Uint8Array(HEADER_SIZE);
    const view = new DataView(header.buffer);
    view.setUint8(0, cmd);
    view.setUint8(1, seq);
    view.setUint16(2, arg, true);
    view.setUint32(4, payload.length, true);
    await this.#send(header);

    /* Split the payload on packet boundaries for the same reason: the
     * calculator receives it in STREAM_BUFFER-sized posts. */
    for (let sent = 0; sent < payload.length; sent += MAX_PAYLOAD_TRANSFER) {
      await this.#send(payload.subarray(sent, sent + MAX_PAYLOAD_TRANSFER));
    }

    const reply = await this.#receive(HEADER_SIZE, what);
    const replyView = new DataView(reply.buffer);
    const replyCmd = replyView.getUint8(0);
    const replySeq = replyView.getUint8(1);
    const status = replyView.getUint16(2, true);
    const length = replyView.getUint32(4, true);

    if (replySeq !== seq) {
      throw new Error(`out of step: expected reply ${seq}, got ${replySeq}`);
    }
    const body = length ? await this.#receive(length, what) : new Uint8Array(0);
    if (status !== 0) throw new ProtocolError(replyCmd, status);
    return body;
  }

  async hello() {
    const body = await this.request(CMD.HELLO);
    if (body.length < 6) throw new Error('short HELLO reply');
    const version = body[0];
    if (version !== PROTOCOL_VERSION) {
      throw new Error(`calculator speaks protocol ${version}, this page speaks ${PROTOCOL_VERSION}`
        + ' -- update the reader on the calculator');
    }
    return {
      version,
      freeArchive: body[1] | (body[2] << 8) | (body[3] << 16),
      maxChunks: body[4],
      chunkSize: body[5] * 256,
    };
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
    /* Slot and index go in the header's arg, not at the front of the payload:
     * the calculator reads the header and the payload as separate USB
     * transfers, and anything prepended to the payload would be stuck in the
     * same packet as the chunk data. */
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
