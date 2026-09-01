/*
 * CRC-32, the ordinary reflected one (polynomial 0xEDB88320).
 *
 * Used for two things: the program image an update carries, and every chunk of
 * every comic.
 *
 * Comics were left unchecked for a long time on the argument that a damaged one
 * is only a smeared page. It is not. The reader refuses a container it cannot
 * parse, and it has no way to say what went wrong or when -- so a chunk damaged
 * during a sync becomes a strip that will not open, discovered days later with
 * the cable put away. PUT_CHUNK now carries a CRC and the calculator reads the
 * appvar back out of flash to check it, which covers the flash write as well as
 * the wire.
 *
 * Computed a byte at a time with no lookup table. A 256-entry table would be a
 * kilobyte of the reader's very limited RAM to save a few tenths of a second,
 * once, on an operation that already waits on flash.
 */

#ifndef CRC32_H
#define CRC32_H

#include <stddef.h>
#include <stdint.h>

#define CRC32_INIT 0xFFFFFFFFu

uint32_t crc32_update(uint32_t crc, const uint8_t *data, size_t length);

/* The final inversion. `crc32_update` leaves the running value uninverted. */
static inline uint32_t crc32_finish(uint32_t crc) { return crc ^ 0xFFFFFFFFu; }

#endif /* CRC32_H */
