/*
 * CRC-32, the ordinary reflected one (polynomial 0xEDB88320).
 *
 * Nothing else in this protocol is checksummed, and deliberately so: the wire
 * is a USB byte stream with its own integrity, and a comic that arrives damaged
 * is a smeared page. A program that arrives damaged is a calculator that will
 * not start the reader, which is worth a second of arithmetic to rule out.
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
