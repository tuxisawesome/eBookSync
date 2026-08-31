/*
 * TI-84 Plus CE variable files (.8xv appvars, .8xp programs).
 *
 * Writing is only needed for the "export chunks to disk" escape hatch, so a
 * strip can be loaded with TI Connect CE or into CEmu without the USB path --
 * the sync protocol sends raw chunk payloads instead.
 *
 * Reading is what the self-update needs: web/comics/COMICS.8xp is a file in this
 * format, and what goes over the link is the program body inside it, not the
 * wrapper. The calculator creates the variable itself.
 *
 * Layout: an 8-byte signature, three fixed bytes, a 42-byte comment, the data
 * section length, the section itself, and a 16-bit sum of the section.
 */

const SIGNATURE = [0x2a, 0x2a, 0x54, 0x49, 0x38, 0x33, 0x46, 0x2a, 0x1a, 0x0a, 0x00];
const TYPE_APPVAR = 0x15;

/* Protected programs are what the CE toolchain emits; plain ones read the same. */
export const TYPE_PROGRAM = 0x05;
export const TYPE_PROTECTED_PROGRAM = 0x06;

/* A variable's length field is 16 bit, so this is a hard ceiling. */
export const MAX_VAR_SIZE = 0xffff - 2;

export function encodeName(name) {
  if (!/^[A-Z][A-Z0-9]{0,7}$/.test(name)) {
    throw new Error(`appvar name "${name}" must be 1-8 uppercase letters/digits, not starting with a digit`);
  }
  const out = new Uint8Array(8);
  for (let i = 0; i < name.length; i++) out[i] = name.charCodeAt(i);
  return out;
}

export function writeAppvar(name, payload, { archived = true, comment = 'eBookSync' } = {}) {
  if (payload.length > MAX_VAR_SIZE) {
    throw new Error(`${payload.length} bytes exceeds the ${MAX_VAR_SIZE} byte appvar limit`);
  }

  const varData = new Uint8Array(2 + payload.length);
  varData[0] = payload.length & 0xff;
  varData[1] = payload.length >> 8;
  varData.set(payload, 2);

  const entry = new Uint8Array(17 + varData.length);
  let pos = 0;
  entry[pos++] = 13; entry[pos++] = 0;                                  /* header length */
  entry[pos++] = varData.length & 0xff; entry[pos++] = varData.length >> 8;
  entry[pos++] = TYPE_APPVAR;
  entry.set(encodeName(name), pos); pos += 8;
  entry[pos++] = 0;                                                     /* version */
  entry[pos++] = archived ? 0x80 : 0x00;
  entry[pos++] = varData.length & 0xff; entry[pos++] = varData.length >> 8;
  entry.set(varData, pos);

  let checksum = 0;
  for (const byte of entry) checksum = (checksum + byte) & 0xffff;

  const file = new Uint8Array(55 + entry.length + 2);
  file.set(SIGNATURE, 0);
  for (let i = 0; i < Math.min(comment.length, 42); i++) file[11 + i] = comment.charCodeAt(i);
  file[53] = entry.length & 0xff;
  file[54] = entry.length >> 8;
  file.set(entry, 55);
  file[55 + entry.length] = checksum & 0xff;
  file[56 + entry.length] = checksum >> 8;
  return file;
}

/**
 * Read one variable out of a .8xv or .8xp file.
 *
 * Returns `{ name, type, archived, body }`, where `body` is the variable's
 * contents with the file wrapper and the length fields stripped -- for a
 * program, exactly the bytes the calculator has to end up holding.
 *
 * Deliberately strict. This is the one path where a malformed file becomes a
 * program the calculator will try to run, so anything that does not parse
 * cleanly is refused here rather than pushed and found out later.
 */
export function readVariable(bytes) {
  const data = new Uint8Array(bytes);
  if (data.length < 57) throw new Error('not a TI variable file: too short');
  for (let i = 0; i < SIGNATURE.length; i++) {
    if (data[i] !== SIGNATURE[i]) throw new Error('not a TI variable file: bad signature');
  }

  const sectionLength = data[53] | (data[54] << 8);
  if (55 + sectionLength + 2 > data.length) {
    throw new Error('TI variable file is truncated');
  }

  let checksum = 0;
  for (let i = 55; i < 55 + sectionLength; i++) checksum = (checksum + data[i]) & 0xffff;
  const stored = data[55 + sectionLength] | (data[56 + sectionLength] << 8);
  if (checksum !== stored) throw new Error('TI variable file checksum does not match');

  const entry = data.subarray(55, 55 + sectionLength);
  const headerLength = entry[0] | (entry[1] << 8);
  if (headerLength !== 13) {
    throw new Error(`unsupported variable entry header (${headerLength} bytes)`);
  }

  const type = entry[4];
  let name = '';
  for (let i = 5; i < 13; i++) {
    if (entry[i] === 0 || entry[i] === 0x20) break;
    name += String.fromCharCode(entry[i]);
  }

  /* The variable data is preceded by its own 16-bit length, which is two bytes
   * shorter than the entry's own length field claims. */
  const varData = entry.subarray(2 + headerLength + 2);
  const bodyLength = varData[0] | (varData[1] << 8);
  if (bodyLength + 2 > varData.length) throw new Error('variable data is truncated');

  return {
    name,
    type,
    archived: (entry[14] & 0x80) !== 0,
    body: varData.slice(2, 2 + bodyLength),
  };
}
