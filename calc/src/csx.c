#include "csx.h"

#include <fileioc.h>
#include <string.h>

/* Offsets into the container header, see docs/FORMAT.md. */
#define HDR_MAGIC        0
#define HDR_LAYER_COUNT  4
#define HDR_BAND_HEIGHT  5
#define HDR_COL_WIDTH    6
#define HDR_PALETTE_SIZE 8
#define HDR_BAND_COUNT   10
#define HDR_CHUNK_COUNT  12
#define HDR_SIZE         16

#define LAYER_ENTRY_SIZE 12
#define BAND_ENTRY_SIZE  5

static uint16_t read16(const uint8_t *p) {
    return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

static uint24_t read24(const uint8_t *p) {
    return (uint24_t)p[0] | ((uint24_t)p[1] << 8) | ((uint24_t)p[2] << 16);
}

static char hex_digit(uint8_t value) {
    return value < 10 ? (char)('0' + value) : (char)('A' + value - 10);
}

void csx_chunk_name(char *name, uint8_t slot, uint8_t chunk) {
    name[0] = 'E';
    name[1] = 'O';
    name[2] = hex_digit(slot >> 4);
    name[3] = hex_digit(slot & 0x0F);
    name[4] = hex_digit(chunk >> 4);
    name[5] = hex_digit(chunk & 0x0F);
    name[6] = '\0';
}

/*
 * Map one appvar and keep the pointer to its data.
 *
 * ti_GetDataPtr on an archived variable points straight into flash, so nothing
 * is copied into RAM -- that is what makes it affordable to keep a whole strip
 * "open". The pointer stays valid until a garbage collect moves things around,
 * which cannot happen while we are only reading. The handle is closed
 * immediately because only a handful may be open at once.
 */
static const uint8_t *map_chunk(uint8_t slot, uint8_t chunk) {
    char name[9];
    csx_chunk_name(name, slot, chunk);

    uint8_t handle = ti_Open(name, "r");
    if (!handle)
        return NULL;

    const uint8_t *data = ti_GetDataPtr(handle);
    ti_Close(handle);
    return data;
}

bool csx_open(csx_strip_t *strip, uint8_t slot) {
    memset(strip, 0, sizeof *strip);
    strip->slot = slot;

    const uint8_t *head = map_chunk(slot, 0);
    if (!head || memcmp(head + HDR_MAGIC, CSX_MAGIC, 4) != 0)
        return false;

    /* Anything encoded with different geometry than this build expects would
     * silently render as garbage, so refuse it outright. */
    if (head[HDR_BAND_HEIGHT] != CSX_BAND_HEIGHT ||
        read16(head + HDR_COL_WIDTH) != CSX_COL_WIDTH ||
        read16(head + HDR_PALETTE_SIZE) != CSX_PALETTE_SIZE)
        return false;

    strip->layer_count = head[HDR_LAYER_COUNT];
    strip->chunk_count = head[HDR_CHUNK_COUNT];
    strip->band_count = read16(head + HDR_BAND_COUNT);
    if (strip->layer_count == 0 || strip->layer_count > CSX_MAX_LAYERS ||
        strip->chunk_count == 0 || strip->chunk_count > CSX_MAX_CHUNKS)
        return false;

    const uint8_t *pos = head + HDR_SIZE;
    for (uint8_t i = 0; i < CSX_PALETTE_SIZE; i++, pos += 2)
        strip->palette[i] = read16(pos);

    uint16_t band_base = 0;
    for (uint8_t i = 0; i < strip->layer_count; i++, pos += LAYER_ENTRY_SIZE) {
        csx_layer_t *layer = &strip->layer[i];
        layer->width = read16(pos);
        layer->height = read24(pos + 2);
        layer->cols = read16(pos + 6);
        layer->bands_per_col = read16(pos + 8);
        layer->band_base = band_base;
        band_base += layer->cols * layer->bands_per_col;
    }
    if (band_base != strip->band_count)
        return false;

    strip->band_table = pos;

    strip->chunk[0] = head;
    for (uint8_t i = 1; i < strip->chunk_count; i++) {
        strip->chunk[i] = map_chunk(slot, i);
        if (!strip->chunk[i])
            return false;
    }
    return true;
}

uint8_t csx_delete(uint8_t slot) {
    char name[9];
    uint8_t removed = 0;

    for (uint8_t chunk = 0; chunk < CSX_MAX_CHUNKS; chunk++) {
        csx_chunk_name(name, slot, chunk);
        if (!ti_Delete(name))
            break;
        removed++;
    }
    return removed;
}

const uint8_t *csx_band(const csx_strip_t *strip, uint16_t index, uint16_t *length) {
    if (index >= strip->band_count)
        return NULL;

    const uint8_t *entry = strip->band_table + (uint24_t)index * BAND_ENTRY_SIZE;
    uint8_t chunk = entry[0];
    if (chunk >= strip->chunk_count)
        return NULL;

    *length = read16(entry + 3);
    return strip->chunk[chunk] + read16(entry + 1);
}
