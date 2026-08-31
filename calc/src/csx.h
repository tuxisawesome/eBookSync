/*
 * The .csx container as the calculator sees it.
 *
 * Strips are stored as a run of 16 KB appvars named CS<slot><chunk>, with the
 * slot in four hex digits and the chunk in two. That is eight characters, which
 * is every character an appvar name has -- and it is why a slot is 16 bits: the
 * name is the constraint, and this spends all of it.
 * Concatenated they form one container: a header, palette, layer table and band
 * table, followed by ZX0-compressed bands. Bands never straddle a chunk, so
 * every band can be handed to zx0_Decompress as a pointer straight into flash.
 *
 * See docs/FORMAT.md for the byte layout and the reasoning behind it.
 */

#ifndef CSX_H
#define CSX_H

#include <stdbool.h>
#include <stdint.h>

#define CSX_MAGIC          "CSX1"
#define CSX_BAND_HEIGHT    32
#define CSX_COL_WIDTH      320
#define CSX_CHUNK_SIZE     16384
#define CSX_PALETTE_SIZE   16

#define CSX_MAX_CHUNKS     64
#define CSX_MAX_LAYERS     4

/* Largest decompressed band: a full-width column, 4bpp. */
#define CSX_BAND_MAX       (CSX_COL_WIDTH / 2 * CSX_BAND_HEIGHT)

typedef struct {
    uint16_t width;
    uint24_t height;
    uint16_t cols;
    uint16_t bands_per_col;
    uint16_t band_base;   /* index of this layer's first band */
} csx_layer_t;

typedef struct {
    uint16_t slot;
    uint8_t chunk_count;
    uint8_t layer_count;
    uint16_t band_count;
    const uint8_t *chunk[CSX_MAX_CHUNKS];
    const uint8_t *band_table;          /* 5 bytes per band, inside chunk 0 */
    csx_layer_t layer[CSX_MAX_LAYERS];
    uint16_t palette[CSX_PALETTE_SIZE];
} csx_strip_t;

/* Fill in `name` with the appvar name for one chunk. Needs 9 bytes. */
/* `name` must have room for 9 bytes: eight characters and a terminator. */
void csx_chunk_name(char *name, uint16_t slot, uint8_t chunk);

/* Map every chunk of a strip. Returns false if a chunk is missing or the
 * container is malformed. */
bool csx_open(csx_strip_t *strip, uint16_t slot);

/* Delete every chunk of a strip. Returns the number of appvars removed. */
uint8_t csx_delete(uint16_t slot);

/* Locate one band's compressed payload. */
const uint8_t *csx_band(const csx_strip_t *strip, uint16_t index, uint16_t *length);

/* Band index for a (layer, column, band) triple. */
static inline uint16_t csx_band_index(const csx_strip_t *strip, uint8_t layer,
                                      uint16_t col, uint16_t band) {
    const csx_layer_t *l = &strip->layer[layer];
    return l->band_base + col * l->bands_per_col + band;
}

/* Pixels in a column: the last one is narrower when the layer is not a
 * multiple of CSX_COL_WIDTH. */
static inline uint16_t csx_col_width(const csx_layer_t *layer, uint16_t col) {
    uint24_t left = layer->width - (uint24_t)col * CSX_COL_WIDTH;
    return left < CSX_COL_WIDTH ? (uint16_t)left : CSX_COL_WIDTH;
}

/* Rows in a band: the last one is shorter. */
static inline uint8_t csx_band_rows(const csx_layer_t *layer, uint16_t band) {
    uint24_t left = layer->height - (uint24_t)band * CSX_BAND_HEIGHT;
    return left < CSX_BAND_HEIGHT ? (uint8_t)left : CSX_BAND_HEIGHT;
}

/* Packed 4bpp bytes per row of a column. */
static inline uint16_t csx_stride(const csx_layer_t *layer, uint16_t col) {
    return (csx_col_width(layer, col) + 1) / 2;
}

#endif /* CSX_H */
