#ifndef RENDER_H
#define RENDER_H

#include <stdbool.h>

#include "csx.h"

/*
 * Palette indices for the reader's own chrome, well clear of the 16 the artwork
 * uses. ui_set_chrome_palette() fills them all from the current theme.
 *
 * The flat colours come first. Then the ramps: four entries each, background
 * then three levels of coverage towards the text colour, which is what the
 * font (font.h) and the pre-rendered titles are drawn through. There is one
 * ramp for every pairing of text colour and background the screens use, so
 * anti-aliased text is blended against what is really behind it.
 */
#define UI_BG           200
#define UI_SURFACE      201
#define UI_FG           202
#define UI_DIM          203
#define UI_ACCENT       204
#define UI_ON_ACCENT    205
#define UI_SELECT_BG    206
#define UI_WARN         207
#define UI_RULE         208   /* hairlines between rows: a touch off the background */
#define UI_ACCENT_SOFT  209   /* the accent faded into the background, for tracks */

#define UI_RAMP(n)          (212 + 4 * (n))
#define RAMP_FG             UI_RAMP(0)    /* text on the background */
#define RAMP_DIM            UI_RAMP(1)
#define RAMP_ACCENT         UI_RAMP(2)
#define RAMP_FG_SEL         UI_RAMP(3)    /* text on a selected row */
#define RAMP_DIM_SEL        UI_RAMP(4)
#define RAMP_ACCENT_SEL     UI_RAMP(5)
#define RAMP_ON_ACCENT      UI_RAMP(6)    /* text on the header */
#define RAMP_FG_SURFACE     UI_RAMP(7)    /* text on footers and panels */
#define RAMP_DIM_SURFACE    UI_RAMP(8)
#define RAMP_ACCENT_SURFACE UI_RAMP(9)
#define RAMP_WARN           UI_RAMP(10)   /* ends at 255 */

/* What the page's title bitmaps are drawn through. */
#define UI_TEXT_RAMP        RAMP_FG
#define UI_TEXT_RAMP_SEL    RAMP_FG_SEL

/* The lock screen's blank: plain black whatever the theme. */
#define UI_BLACK            210

/* Allocate the band cache. Returns the number of slots obtained (0 on failure);
 * more slots mean fewer re-decompressions when panning back and forth. */
uint8_t render_init(void);
void render_free(void);

/* Drop every cached band. Must be called whenever the open strip changes. */
void render_reset(void);

/* Load the strip's 16 artwork colours plus the reader's chrome into the LCD
 * palette. */
void render_set_palette(const csx_strip_t *strip);

/*
 * Draw the viewport of `layer` whose top-left corner is at (vx, vy) in layer
 * coordinates, into the current draw buffer.
 *
 * Nothing at or below row `limit` is drawn; the screen shows the background
 * there instead. That is how a strip made of several images keeps the next
 * image out of sight while the reader is still on this one -- a short image
 * leaves the rest of the screen empty rather than showing what comes after.
 * Pass the layer height to draw everything.
 */
void render_view(const csx_strip_t *strip, uint8_t layer, uint24_t vx, uint24_t vy,
                 uint24_t limit);

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
