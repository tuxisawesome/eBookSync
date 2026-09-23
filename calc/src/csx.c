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
#define HDR_PART_COUNT   13
#define HDR_SIZE         16

#define LAYER_ENTRY_SIZE 12
#define BAND_ENTRY_SIZE  5
#define PART_TOP_SIZE    3

static uint16_t read16(const uint8_t *p) {
    return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

static uint24_t read24(const uint8_t *p) {
    return (uint24_t)p[0] | ((uint24_t)p[1] << 8) | ((uint24_t)p[2] << 16);
}

static char hex_digit(uint8_t value) {
    return value < 10 ? (char)('0' + value) : (char)('A' + value - 10);
}

void csx_chunk_name(char *name, uint16_t slot, uint8_t chunk) {
    name[0] = 'C';
    name[1] = 'S';
    name[2] = hex_digit((slot >> 12) & 0x0F);
    name[3] = hex_digit((slot >> 8) & 0x0F);
    name[4] = hex_digit((slot >> 4) & 0x0F);
    name[5] = hex_digit(slot & 0x0F);
    name[6] = hex_digit(chunk >> 4);
    name[7] = hex_digit(chunk & 0x0F);
    name[8] = '\0';
}

/*
 * Map one appvar and keep the pointer to its data.
 *
 * ti_GetDataPtr on an archived variable points straight into flash, so nothing
 * is copied into RAM -- that is what makes it affordable to keep a whole strip
 * "open". The pointer stays valid until a garbage collect moves things around,
 * which cannot happen while we are only reading. The handle is closed
 * immediately because only a handful may be open at once.
 *
 * The slot is sixteen bits here and must stay that way: taking it as a uint8_t
 * silently read CS00<slot & 0xFF><chunk> for every slot from 256 up, which is
 * either a strip that will not open or, worse, another strip's bytes.
 */
static const uint8_t *map_chunk(uint16_t slot, uint8_t chunk) {
    char name[9];
    csx_chunk_name(name, slot, chunk);

    uint8_t handle = ti_Open(name, "r");
    if (!handle)
        return NULL;

    const uint8_t *data = ti_GetDataPtr(handle);
    ti_Close(handle);
    return data;
}

bool csx_open(csx_strip_t *strip, uint16_t slot) {
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

    /*
     * The part table follows the band table, so a container without one -- any
     * strip made from a single image, and every strip from before parts existed
     * -- lays out exactly as it always did. 0 and 1 both mean one image.
     *
     * Checked here rather than trusted: the viewer confines scrolling to one
     * part at a time, and a top past the end of its layer, or out of order,
     * would pin it somewhere it could never get out of.
     */
    strip->part_count = 1;
    strip->part_table = NULL;
    if (head[HDR_PART_COUNT] > 1) {
        strip->part_count = head[HDR_PART_COUNT];
        strip->part_table = pos + (uint24_t)strip->band_count * BAND_ENTRY_SIZE;
        if ((uint24_t)(strip->part_table - head)
                + (uint24_t)strip->part_count * strip->layer_count * PART_TOP_SIZE
                > CSX_CHUNK_SIZE)
            return false;
        for (uint8_t l = 0; l < strip->layer_count; l++) {
            if (csx_part_top(strip, l, 0) != 0)
                return false;
            for (uint8_t p = 1; p < strip->part_count; p++) {
                uint24_t top = csx_part_top(strip, l, p);
                if (top <= csx_part_top(strip, l, p - 1) || top >= strip->layer[l].height)
                    return false;
            }
        }
    }

    strip->chunk[0] = head;
    for (uint8_t i = 1; i < strip->chunk_count; i++) {
        strip->chunk[i] = map_chunk(slot, i);
        if (!strip->chunk[i])
            return false;
    }
    return true;
}

/*
 * Delete every chunk of a strip.
 *
 * Chunks are contiguous from 0, so stopping at the first gap is exact and
 * costs one lookup more than the strip has chunks.
 *
 * The tail past CSX_MAX_CHUNKS is for wreckage. A container built before the
 * encoder enforced the chunk ceiling can have chunks 64 and up; csx_open()
 * refuses it, and nothing else in the system can name those appvars -- DEL,
 * lib_reset() and the page's orphan pass all work in slots, not chunk indices
 * -- so they would sit in the archive for ever. They can only exist if the
 * strip filled the ceiling, so a gap below it still ends the search and an
 * ordinary strip costs no extra lookups at all.
 */
uint8_t csx_delete(uint16_t slot) {
    char name[9];
    uint16_t removed = 0;

    for (uint16_t chunk = 0; chunk < 256; chunk++) {
        csx_chunk_name(name, slot, (uint8_t)chunk);
        if (!ti_Delete(name)) {
            /* A gap below the ceiling ends the strip. A gap above it may not:
             * keep going to the end of the name space to be sure. */
            if (chunk < CSX_MAX_CHUNKS)
                break;
            continue;
        }
        removed++;
    }

    /* The reply carries this in one byte, and 256 would read as none. */
    return removed > 0xFF ? 0xFF : (uint8_t)removed;
}

uint24_t csx_part_top(const csx_strip_t *strip, uint8_t layer, uint8_t part) {
    if (!strip->part_table)
        return 0;
    return read24(strip->part_table
                  + ((uint24_t)part * strip->layer_count + layer) * PART_TOP_SIZE);
}

uint24_t csx_part_bottom(const csx_strip_t *strip, uint8_t layer, uint8_t part) {
    if (part + 1 < strip->part_count)
        return csx_part_top(strip, layer, part + 1);
    return strip->layer[layer].height;
}

uint8_t csx_part_at(const csx_strip_t *strip, uint8_t layer, uint24_t row) {
    uint8_t part = 0;
    while (part + 1 < strip->part_count && csx_part_top(strip, layer, part + 1) <= row)
        part++;
    return part;
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
