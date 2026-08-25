/*
 * TI-84 Plus CE appvar files (.8xv).
 *
 * Only needed for the "export chunks to disk" escape hatch, so a strip can be
 * loaded with TI Connect CE or into CEmu without the USB path. The sync
 * protocol sends raw chunk payloads instead.
 *
 * Layout: an 8-byte signature, three fixed bytes, a 42-byte comment, the data
 * section length, the section itself, and a 16-bit sum of the section.
 */

const SIGNATURE = [0x2a, 0x2a, 0x54, 0x49, 0x38, 0x33, 0x46, 0x2a, 0x1a, 0x0a, 0x00];
const TYPE_APPVAR = 0x15;

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
