/*
 * The chat records the calculator stores, packed and parsed.
 *
 * The other half of this is calc/src/chat.c. Neither reads the other's code,
 * and tools/hosttest/check_chat.mjs runs one against the other -- the same
 * discipline the library index and the .csx container are held to, and for the
 * same reason: a format with two implementations has two chances to be wrong.
 *
 * Everything here is ASCII. The calculator has no CJK font, which is why comic
 * titles are pre-rendered bitmaps; a chat message cannot be, so anything the
 * calculator cannot draw is folded down before it goes over the wire rather
 * than arriving as blanks. See `toCalculatorText`.
 */

export const VERSION = 1;

export const TABLE_MAGIC = 'ECH1';
export const OUTBOX_MAGIC = 'EOU1';

export const MAX_CONVERSATIONS = 16;
export const NAME_MAX = 16;
export const SENDER_MAX = 12;
export const BODY_MAX = 200;

export const TABLE_HEADER = 12;
export const TABLE_RECORD = 24;
export const MESSAGE_HEADER = 11;
export const OUTBOX_HEADER = 8;
export const OUTBOX_RECORD_HEADER = 11;

export const FLAG_MINE = 0x01;

const encoder = new TextEncoder();

/**
 * Fold text down to what the calculator's 8x8 font can draw.
 *
 * Done here rather than on the calculator because this is where there is a
 * Unicode library, a normaliser and room to spare. Accented Latin loses its
 * accents, which is legible; everything else becomes '?', which is at least
 * honest about having lost something.
 */
export function toCalculatorText(text, limit) {
  const stripped = String(text ?? '')
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '');

  let out = '';
  for (const character of stripped) {
    const code = character.codePointAt(0);
    if (code === 9) out += ' ';
    else if (code === 10 || code === 13) out += ' ';
    else if (code >= 0x20 && code < 0x7f) out += character;
    else out += '?';
  }

  /* Collapse the runs of '?' a dropped word leaves behind, which are noise
   * rather than information. */
  out = out.replace(/\?{2,}/g, '?').trim();
  return limit ? out.slice(0, limit) : out;
}

function writeAscii(view, at, text, length) {
  const bytes = encoder.encode(text);
  for (let i = 0; i < length; i++) view.setUint8(at + i, i < bytes.length ? bytes[i] : 0);
}

function readAscii(bytes) {
  let out = '';
  for (const byte of bytes) {
    if (!byte) break;
    out += String.fromCharCode(byte);
  }
  return out;
}

/**
 * The conversation table the computer pushes with CHAT_ROSTER_PUT.
 *
 * `lastServerId` and `bytes` go out as zeros: the calculator is the only thing
 * that knows how far it has read and how much it is holding, and it splices its
 * own values back in -- the same arrangement as the library index's device
 * block.
 */
export function packTable(conversations) {
  const kept = conversations.slice(0, MAX_CONVERSATIONS);
  const out = new Uint8Array(TABLE_HEADER + kept.length * TABLE_RECORD);
  const view = new DataView(out.buffer);

  for (let i = 0; i < 4; i++) view.setUint8(i, TABLE_MAGIC.charCodeAt(i));
  view.setUint8(4, VERSION);
  view.setUint8(5, kept.length);
  /* nextSeq (6..10) and the reserved pair are the calculator's; leave zero. */

  kept.forEach((conversation, index) => {
    const at = TABLE_HEADER + index * TABLE_RECORD;
    view.setUint16(at, conversation.id, true);
    view.setUint32(at + 2, 0, true);
    view.setUint16(at + 6, 0, true);
    writeAscii(view, at + 8, toCalculatorText(conversation.name, NAME_MAX), NAME_MAX);
  });

  return out;
}

export function parseTable(bytes) {
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  if (bytes.length < TABLE_HEADER) throw new Error('chat table is too short');
  for (let i = 0; i < 4; i++) {
    if (view.getUint8(i) !== TABLE_MAGIC.charCodeAt(i)) throw new Error('not a chat table');
  }

  const count = view.getUint8(5);
  const conversations = [];
  for (let i = 0; i < count; i++) {
    const at = TABLE_HEADER + i * TABLE_RECORD;
    conversations.push({
      id: view.getUint16(at, true),
      lastServerId: view.getUint32(at + 2, true),
      bytes: view.getUint16(at + 6, true),
      name: readAscii(bytes.subarray(at + 8, at + 8 + NAME_MAX)),
    });
  }

  return { version: view.getUint8(4), nextSeq: view.getUint32(6, true), conversations };
}

/** One stored message: header, sender, body. */
export function packMessage(message) {
  const sender = encoder.encode(toCalculatorText(message.sender, SENDER_MAX));
  const body = encoder.encode(toCalculatorText(message.body, BODY_MAX));

  const out = new Uint8Array(MESSAGE_HEADER + sender.length + body.length);
  const view = new DataView(out.buffer);
  view.setUint32(0, message.serverId, true);
  view.setUint32(4, message.sentAt, true);
  view.setUint8(8, message.mine ? FLAG_MINE : 0);
  view.setUint8(9, sender.length);
  view.setUint8(10, body.length);
  out.set(sender, MESSAGE_HEADER);
  out.set(body, MESSAGE_HEADER + sender.length);
  return out;
}

export function packMessages(messages) {
  const parts = messages.map(packMessage);
  const total = parts.reduce((sum, part) => sum + part.length, 0);
  const out = new Uint8Array(total);
  let at = 0;
  for (const part of parts) {
    out.set(part, at);
    at += part.length;
  }
  return out;
}

export function parseMessages(bytes) {
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const messages = [];

  let at = 0;
  while (at < bytes.length) {
    if (bytes.length - at < MESSAGE_HEADER) throw new Error('truncated message record');
    const senderLength = view.getUint8(at + 9);
    const bodyLength = view.getUint8(at + 10);
    const total = MESSAGE_HEADER + senderLength + bodyLength;
    if (at + total > bytes.length) throw new Error('truncated message record');

    messages.push({
      serverId: view.getUint32(at, true),
      sentAt: view.getUint32(at + 4, true),
      mine: (view.getUint8(at + 8) & FLAG_MINE) !== 0,
      sender: readAscii(bytes.subarray(at + MESSAGE_HEADER, at + MESSAGE_HEADER + senderLength)),
      body: readAscii(bytes.subarray(at + MESSAGE_HEADER + senderLength, at + total)),
    });
    at += total;
  }
  return messages;
}

/**
 * How much of a run of messages fits in one CHAT_IN_PUT.
 *
 * The calculator's payload buffer is one chunk, and a record must never be
 * split across two commands -- the far end appends what it is given and walks
 * it as whole records afterwards.
 */
export function batchMessages(messages, limit) {
  const batches = [];
  let current = [];
  let size = 0;

  for (const message of messages) {
    const packed = packMessage(message);
    if (packed.length > limit) continue;           /* cannot ever be sent */
    if (size + packed.length > limit) {
      batches.push(current);
      current = [];
      size = 0;
    }
    current.push(message);
    size += packed.length;
  }

  if (current.length) batches.push(current);
  return batches;
}

/** One record out of the calculator's outbox, as CHAT_OUT_GET returns it. */
export function parseOutboxRecord(bytes) {
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  if (bytes.length < OUTBOX_RECORD_HEADER) throw new Error('truncated outbox record');

  const length = view.getUint8(10);
  if (OUTBOX_RECORD_HEADER + length > bytes.length) throw new Error('truncated outbox record');

  return {
    conversationId: view.getUint16(0, true),
    seq: view.getUint32(2, true),
    composedAt: view.getUint32(6, true),
    body: readAscii(bytes.subarray(OUTBOX_RECORD_HEADER, OUTBOX_RECORD_HEADER + length)),
  };
}

/** What CHAT_STATE reports. */
export function parseState(bytes) {
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  if (bytes.length < 2) throw new Error('short chat state');

  const count = view.getUint8(1);
  const conversations = [];
  for (let i = 0; i < count; i++) {
    const at = 2 + i * 6;
    conversations.push({
      id: view.getUint16(at, true),
      lastServerId: view.getUint32(at + 2, true),
    });
  }

  const tail = 2 + count * 6;
  return {
    version: view.getUint8(0),
    conversations,
    outboxCount: view.getUint16(tail, true),
    outboxBytes: view.getUint16(tail + 2, true),
  };
}
