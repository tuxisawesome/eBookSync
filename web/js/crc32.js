/*
 * CRC-32, the ordinary reflected one (polynomial 0xEDB88320).
 *
 * This has to agree with calc/src/crc32.c byte for byte, because that is the
 * end that checks the answer: the calculator CRCs a chunk where it lies in
 * flash and compares it with the number sent from here. The two implementations
 * are deliberately separate rather than shared -- there is no way to share code
 * between a browser and an eZ80 -- so keep them in step by hand.
 *
 * Table-free, a byte at a time. A 256-entry table would be faster in a browser
 * but the calculator cannot afford one, and matching shapes is worth more here
 * than the microseconds.
 */

export function crc32(bytes) {
  let crc = 0xffffffff;
  for (let i = 0; i < bytes.length; i++) {
    crc ^= bytes[i];
    for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
  }
  return (crc ^ 0xffffffff) >>> 0;
}
