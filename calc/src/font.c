#include "font.h"

#include <graphx.h>
#include <string.h>
#include <sys/lcd.h>

/*
 * The host tests cannot see pixels, so under the shim every string drawn is
 * reported too. SHIM_H is only ever defined there.
 */
#ifdef SHIM_H
void shim_text_log(const char *text, int x, int y);
#define TEXT_LOG(text, x, y) shim_text_log(text, x, y)
#else
#define TEXT_LOG(text, x, y) ((void)0)
#endif

static const ui_glyph_t *glyph(const ui_font_t *font, char ch) {
    unsigned char code = (unsigned char)ch;
    if (code < 32 || code > 126)
        code = '?';
    return &font->glyphs[code - 32];
}

int font_width(const ui_font_t *font, const char *text) {
    int width = 0;
    for (; *text; text++)
        width += glyph(font, *text)->advance;
    return width;
}

/* One glyph through a palette ramp. */
static void blit(const ui_font_t *font, const ui_glyph_t *g, int x, int y, uint8_t ramp) {
    const uint8_t *bits = font->bits + g->offset;
    uint8_t stride = (uint8_t)((g->width + 3) / 4);
    x -= g->shift;

    for (uint8_t row = 0; row < font->height; row++, bits += stride) {
        int dy = y + row;
        if (dy < 0 || dy >= GFX_LCD_HEIGHT)
            continue;
        uint8_t *dst = &gfx_vbuffer[dy][0];
        for (uint8_t col = 0; col < g->width; col++) {
            uint8_t level = (bits[col >> 2] >> (6 - 2 * (col & 3))) & 3;
            int dx = x + col;
            if (level && dx >= 0 && dx < GFX_LCD_WIDTH)
                dst[dx] = (uint8_t)(ramp + level);
        }
    }
}

int font_draw(const ui_font_t *font, const char *text, int x, int y, uint8_t ramp) {
    TEXT_LOG(text, x, y);
    for (; *text; text++) {
        const ui_glyph_t *g = glyph(font, *text);
        blit(font, g, x, y, ramp);
        x += g->advance;
    }
    return x;
}

/* How much of `text` fits in `max_width`, leaving room for "..." if it all
 * does not. */
static size_t fitting(const ui_font_t *font, const char *text, int max_width, bool *cut) {
    if (font_width(font, text) <= max_width) {
        *cut = false;
        return strlen(text);
    }
    *cut = true;
    int budget = max_width - font_width(font, "...");
    size_t n = 0;
    for (int used = 0; text[n]; n++) {
        used += glyph(font, text[n])->advance;
        if (used > budget)
            break;
    }
    /* Not ending on a space, which would put the dots after a gap. */
    while (n && text[n - 1] == ' ')
        n--;
    return n;
}

int font_draw_fit(const ui_font_t *font, const char *text, int x, int y, uint8_t ramp,
                  int max_width) {
    bool cut;
    size_t n = fitting(font, text, max_width, &cut);
    if (!cut)
        return font_draw(font, text, x, y, ramp);

    char buf[64];
    if (n > sizeof buf - 4)
        n = sizeof buf - 4;
    memcpy(buf, text, n);
    strcpy(buf + n, "...");
    return font_draw(font, buf, x, y, ramp);
}

int font_draw_right(const ui_font_t *font, const char *text, int right, int y, uint8_t ramp) {
    return font_draw(font, text, right - font_width(font, text), y, ramp);
}

/* Mix two 5-6-5 colours, `level` thirds of the way from bg to fg. */
static uint16_t mix565(uint16_t bg, uint16_t fg, uint8_t level) {
    if (level == 3)
        return fg;
    unsigned r = ((bg >> 11) * (3 - level) + (fg >> 11) * level) / 3;
    unsigned g = (((bg >> 5) & 63) * (3 - level) + ((fg >> 5) & 63) * level) / 3;
    unsigned b = ((bg & 31) * (3 - level) + (fg & 31) * level) / 3;
    return (uint16_t)((r << 11) | (g << 5) | b);
}

int font_draw565(const ui_font_t *font, const char *text, int x, int y,
                 uint16_t fg, uint16_t bg, int max_width) {
    bool cut;
    size_t n = fitting(font, text, max_width, &cut);
    TEXT_LOG(text, x, y);

    uint16_t ramp[4] = { bg, mix565(bg, fg, 1), mix565(bg, fg, 2), fg };
    uint16_t *screen = (uint16_t *)lcd_Ram;

    for (size_t i = 0; i < n + (cut ? 3 : 0); i++) {
        const ui_glyph_t *g = glyph(font, i < n ? text[i] : '.');
        const uint8_t *bits = font->bits + g->offset;
        uint8_t stride = (uint8_t)((g->width + 3) / 4);
        int gx = x - g->shift;

        for (uint8_t row = 0; row < font->height; row++, bits += stride) {
            int dy = y + row;
            if (dy < 0 || dy >= LCD_HEIGHT)
                continue;
            uint16_t *dst = screen + dy * LCD_WIDTH;
            for (uint8_t col = 0; col < g->width; col++) {
                uint8_t level = (bits[col >> 2] >> (6 - 2 * (col & 3))) & 3;
                int dx = gx + col;
                if (level && dx >= 0 && dx < LCD_WIDTH)
                    dst[dx] = ramp[level];
            }
        }
        x += g->advance;
    }
    return x;
}
