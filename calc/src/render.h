#ifndef RENDER_H
#define RENDER_H

#include <stdbool.h>

#include "csx.h"

/* Palette indices above the 16 the artwork uses, for the reader's own chrome.
 * The two 4-entry ramps are what pre-rendered 2bpp titles are drawn through. */
#define UI_BG           248
#define UI_FG           249
#define UI_ACCENT       250
#define UI_DIM          251
#define UI_SELECT_BG    252
#define UI_TEXT_RAMP    240   /* 240..243, light to dark on the list background */
#define UI_TEXT_RAMP_SEL 244  /* 244..247, the same ramp on a selected row */

/* Allocate the band cache. Returns the number of slots obtained (0 on failure);
 * more slots mean fewer re-decompressions when panning back and forth. */
uint8_t render_init(void);
void render_free(void);

/* Drop every cached band. Must be called whenever the open strip changes. */
void render_reset(void);

/* Load the strip's 16 artwork colours plus the reader's chrome into the LCD
 * palette. */
void render_set_palette(const csx_strip_t *strip);

/* Draw the viewport of `layer` whose top-left corner is at (vx, vy) in layer
 * coordinates, into the current draw buffer. */
void render_view(const csx_strip_t *strip, uint8_t layer, uint24_t vx, uint24_t vy);

/*
 * Draw a whole 320-wide layer 0 at 1:1, decompressing through `scratch` rather
 * than the band cache -- so it works before render_init() has been called, and
 * costs one CSX_BAND_MAX buffer instead of sixty kilobytes. False if the strip
 * is not screen-shaped. Used for the lock screen wallpaper.
 */
bool render_draw_full(const csx_strip_t *strip, uint8_t *scratch);

/* Decompress a band, or return it from the cache. NULL if the band is bad. */
const uint8_t *render_band(const csx_strip_t *strip, uint16_t index);

#endif /* RENDER_H */
