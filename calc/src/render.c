/*
 * Drawing a strip: decompress the bands the viewport touches, expand them from
 * 4bpp to the 8bpp frame buffer.
 *
 * A 240px-tall viewport spans eight or nine 32-row bands, so redrawing from
 * scratch every frame would mean ~45 KB of ZX0 per frame. Instead decompressed
 * bands are kept in an LRU cache: scrolling exposes at most one new band per
 * 32 pixels travelled, so a steady scroll costs one 5 KB decompression per
 * frame and everything else is a straight copy.
 */

#include "render.h"

#include <compression.h>
#include <graphx.h>
#include <stdlib.h>
#include <string.h>

#define CACHE_SLOTS_MAX 12
#define CACHE_SLOTS_MIN 2
#define BAND_NONE       0xFFFF

static uint8_t *cache_data[CACHE_SLOTS_MAX];
static uint16_t cache_band[CACHE_SLOTS_MAX];
static uint16_t cache_used[CACHE_SLOTS_MAX];
static uint8_t cache_slots;
static uint16_t cache_clock;

/* expand[byte] holds the two pixels of a packed 4bpp byte in memory order, so
 * one 16-bit store writes both. The eZ80 has no alignment requirement, so this
 * works at any destination address. */
static uint16_t expand[256];

uint8_t render_init(void) {
    for (unsigned i = 0; i < 256; i++)
        expand[i] = (uint16_t)(i >> 4) | (uint16_t)((i & 0x0F) << 8);

    cache_slots = 0;
    for (uint8_t i = 0; i < CACHE_SLOTS_MAX; i++) {
        uint8_t *block = malloc(CSX_BAND_MAX);
        if (!block)
            break;
        cache_data[i] = block;
        cache_slots++;
    }

    if (cache_slots < CACHE_SLOTS_MIN) {
        render_free();
        return 0;
    }

    render_reset();
    return cache_slots;
}

void render_free(void) {
    for (uint8_t i = 0; i < cache_slots; i++)
        free(cache_data[i]);
    cache_slots = 0;
}

void render_reset(void) {
    for (uint8_t i = 0; i < cache_slots; i++) {
        cache_band[i] = BAND_NONE;
        cache_used[i] = 0;
    }
    cache_clock = 0;
}

const uint8_t *render_band(const csx_strip_t *strip, uint16_t index) {
    for (uint8_t i = 0; i < cache_slots; i++) {
        if (cache_band[i] == index) {
            cache_used[i] = ++cache_clock;
            return cache_data[i];
        }
    }

    uint8_t victim = 0;
    for (uint8_t i = 1; i < cache_slots; i++) {
        if (cache_used[i] < cache_used[victim])
            victim = i;
    }

    uint16_t length;
    const uint8_t *payload = csx_band(strip, index, &length);
    if (!payload) {
        cache_band[victim] = BAND_NONE;
        return NULL;
    }

    zx0_Decompress(cache_data[victim], payload);
    cache_band[victim] = index;
    cache_used[victim] = ++cache_clock;
    return cache_data[victim];
}

void render_set_palette(const csx_strip_t *strip) {
    for (uint8_t i = 0; i < CSX_PALETTE_SIZE; i++)
        gfx_palette[i] = strip->palette[i];
}

/* Copy `count` pixels of one band row into the frame buffer. */
static void blit_row(const uint8_t *src, uint16_t src_x, uint8_t *dst, uint16_t count) {
    src += src_x >> 1;

    if (src_x & 1) {
        *dst++ = *src++ & 0x0F;
        count--;
    }
    while (count >= 2) {
        *(uint16_t *)dst = expand[*src++];
        dst += 2;
        count -= 2;
    }
    if (count)
        *dst = *src >> 4;
}

/*
 * Draw a whole 320-wide layer at 1:1, without the band cache.
 *
 * `scratch` is one CSX_BAND_MAX buffer the caller owns. render_view() goes
 * through render_band(), which needs render_init() to have taken its 60 KB --
 * and the lock screen has to draw before that happens, because the password
 * gate deliberately runs before the band cache is allocated. There is no reason
 * to take the biggest allocation in the program for a prompt somebody may not
 * get past, and a full-screen image is eight bands drawn once, so a cache would
 * buy nothing anyway.
 */
bool render_draw_full(const csx_strip_t *strip, uint8_t *scratch) {
    const csx_layer_t *layer = &strip->layer[0];
    if (layer->width != GFX_LCD_WIDTH || layer->cols != 1)
        return false;

    uint16_t stride = csx_stride(layer, 0);

    for (uint16_t band = 0; band < layer->bands_per_col; band++) {
        uint16_t top = band * CSX_BAND_HEIGHT;
        if (top >= GFX_LCD_HEIGHT)
            break;

        uint16_t length;
        const uint8_t *payload = csx_band(strip, csx_band_index(strip, 0, 0, band), &length);
        if (!payload)
            return false;
        zx0_Decompress(scratch, payload);

        uint8_t rows = csx_band_rows(layer, band);
        if (top + rows > GFX_LCD_HEIGHT)
            rows = (uint8_t)(GFX_LCD_HEIGHT - top);

        for (uint8_t row = 0; row < rows; row++)
            blit_row(scratch + (uint24_t)row * stride, 0,
                     &gfx_vbuffer[top + row][0], GFX_LCD_WIDTH);
    }
    return true;
}

void render_view(const csx_strip_t *strip, uint8_t layer_index, uint24_t vx, uint24_t vy) {
    const csx_layer_t *layer = &strip->layer[layer_index];

    /* A layer narrower than the screen is centred, and cannot pan sideways. */
    uint16_t x_off = 0;
    if (layer->width < GFX_LCD_WIDTH) {
        x_off = (GFX_LCD_WIDTH - layer->width) / 2;
        vx = 0;
    }

    gfx_FillScreen(UI_BG);

    uint16_t first_col = (uint16_t)(vx / CSX_COL_WIDTH);
    uint16_t last_col = (uint16_t)((vx + GFX_LCD_WIDTH - 1) / CSX_COL_WIDTH);
    if (last_col >= layer->cols)
        last_col = layer->cols - 1;

    uint16_t first_band = (uint16_t)(vy / CSX_BAND_HEIGHT);
    uint16_t last_band = (uint16_t)((vy + GFX_LCD_HEIGHT - 1) / CSX_BAND_HEIGHT);
    if (last_band >= layer->bands_per_col)
        last_band = layer->bands_per_col - 1;

    for (uint16_t col = first_col; col <= last_col; col++) {
        uint16_t col_width = csx_col_width(layer, col);
        uint16_t stride = csx_stride(layer, col);

        /* Horizontal overlap between this column and the viewport. */
        uint24_t col_left = (uint24_t)col * CSX_COL_WIDTH;
        uint16_t src_x = (uint16_t)(vx > col_left ? vx - col_left : 0);
        int24_t dst_x = (int24_t)col_left - (int24_t)vx + x_off;
        if (dst_x < 0)
            dst_x = 0;
        uint16_t count = col_width - src_x;
        if (count > GFX_LCD_WIDTH - dst_x)
            count = GFX_LCD_WIDTH - dst_x;
        if ((int24_t)count <= 0)
            continue;

        for (uint16_t band = first_band; band <= last_band; band++) {
            const uint8_t *pixels = render_band(strip, csx_band_index(strip, layer_index, col, band));
            if (!pixels)
                continue;

            /* Vertical overlap between this band and the viewport. */
            uint24_t band_top = (uint24_t)band * CSX_BAND_HEIGHT;
            uint8_t rows = csx_band_rows(layer, band);
            uint8_t src_y = (uint8_t)(vy > band_top ? vy - band_top : 0);
            int24_t dst_y = (int24_t)band_top - (int24_t)vy;
            if (dst_y < 0)
                dst_y = 0;
            uint8_t height = rows - src_y;
            if (height > GFX_LCD_HEIGHT - dst_y)
                height = (uint8_t)(GFX_LCD_HEIGHT - dst_y);

            for (uint8_t row = 0; row < height; row++) {
                blit_row(pixels + (uint24_t)(src_y + row) * stride, src_x,
                         &gfx_vbuffer[dst_y + row][dst_x], count);
            }
        }
    }
}
