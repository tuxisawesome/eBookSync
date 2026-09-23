/*
 * The reader's own font: proportional, anti-aliased, in three faces.
 *
 * graphx's built-in font is 8x8 and fixed width, which in a 20-pixel row reads
 * as cramped. These are rendered from DejaVu Sans by tools/make_font.py into
 * fontdata.c, as 2bpp coverage -- the same form as the page's titles -- and
 * drawn through a four-entry palette ramp, so text is anti-aliased against
 * whatever it sits on. See render.h for the ramps.
 *
 * Only printable ASCII is included; anything else draws as '?'.
 */

#ifndef FONT_H
#define FONT_H

#include <stdbool.h>
#include <stdint.h>

typedef struct {
    uint16_t offset;    /* into the face's packed bits */
    uint8_t width;      /* pixels in the cell */
    uint8_t advance;    /* how far the pen moves */
    uint8_t shift;      /* ink that overhangs to the left of the pen */
} ui_glyph_t;

typedef struct {
    uint8_t height;     /* rows in every cell */
    uint8_t ascent;     /* rows above the baseline */
    const ui_glyph_t *glyphs;   /* ' ' to '~' */
    const uint8_t *bits;
} ui_font_t;

extern const ui_font_t font_body;    /* 12px: lists, prose, values */
extern const ui_font_t font_bold;    /* 13px bold: headers, emphasis */
extern const ui_font_t font_small;   /* 10px: key hints, diagnostics */

/* Pixels a string advances across. */
int font_width(const ui_font_t *font, const char *text);

/*
 * Draw into graphx's draw buffer through `ramp`: palette entries ramp+1..ramp+3
 * are the three coverage levels, light to full. Level 0 is not drawn, so the
 * background shows through. Clipped to the screen. Returns where the pen ends.
 */
int font_draw(const ui_font_t *font, const char *text, int x, int y, uint8_t ramp);

/* The same, but no wider than `max_width`: a string that would not fit is cut
 * and ends in "...". */
int font_draw_fit(const ui_font_t *font, const char *text, int x, int y, uint8_t ramp,
                  int max_width);

/* Right-aligned so that it ends at `right`. */
int font_draw_right(const ui_font_t *font, const char *text, int right, int y, uint8_t ramp);

/*
 * Straight into the LCD in the operating system's own 16bpp mode, blending
 * `fg` over `bg` -- both 5-6-5, blue first. For the sync screen, which runs
 * with graphx handed back.
 */
int font_draw565(const ui_font_t *font, const char *text, int x, int y,
                 uint16_t fg, uint16_t bg, int max_width);

#endif /* FONT_H */
