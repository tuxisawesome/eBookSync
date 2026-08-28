#include "crc32.h"

uint32_t crc32_update(uint32_t crc, const uint8_t *data, size_t length) {
    while (length--) {
        crc ^= *data++;
        for (uint8_t bit = 0; bit < 8; bit++)
            crc = (crc >> 1) ^ (0xEDB88320u & -(crc & 1));
    }
    return crc;
}
