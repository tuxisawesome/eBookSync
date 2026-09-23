#include "keyin.h"

#include "font.h"

#include "input.h"
#include "render.h"
#include "ui.h"

#include <graphx.h>
#include <string.h>

/*
 * The keypad, as characters.
 *
 * `plain` is what the key says in white and `letter` is what it says in green,
 * so the physical keyboard is the only legend anyone needs. Keys with neither
 * are simply absent from this table.
 */
typedef struct {
    uint8_t group;
    uint8_t mask;
    char plain;
    char letter;
} keyin_key_t;

static const keyin_key_t KEYS[] = {
    /* group 2 */
    { 2, 0x02, 0,   'X' },   /* sto-> */
    { 2, 0x04, 0,   'S' },   /* ln */
    { 2, 0x08, 0,   'N' },   /* log */
    { 2, 0x10, 0,   'I' },   /* x^2 */
    { 2, 0x20, 0,   'D' },   /* x^-1 */
    { 2, 0x40, 0,   'A' },   /* math */

    /* group 3 */
    { 3, 0x01, '0', ' ' },
    { 3, 0x02, '1', 'Y' },
    { 3, 0x04, '4', 'T' },
    { 3, 0x08, '7', 'O' },
    { 3, 0x10, ',', 'J' },
    { 3, 0x20, 0,   'E' },   /* sin */
    { 3, 0x40, 0,   'B' },   /* apps */

    /* group 4 */
    { 4, 0x01, '.', ':' },
    { 4, 0x02, '2', 'Z' },
    { 4, 0x04, '5', 'U' },
    { 4, 0x08, '8', 'P' },
    { 4, 0x10, '(', 'K' },
    { 4, 0x20, 0,   'F' },   /* cos */
    { 4, 0x40, 0,   'C' },   /* prgm */

    /* group 5 */
    { 5, 0x01, '-', '?' },   /* (-) */
    /* alpha+3 is theta on the keypad, which is not ASCII and not worth a glyph
     * here; the key still types a 3. */
    { 5, 0x02, '3', 0   },
    { 5, 0x04, '6', 'V' },
    { 5, 0x08, '9', 'Q' },
    { 5, 0x10, ')', 'L' },
    { 5, 0x20, 0,   'G' },   /* tan */

    /* group 6 */
    { 6, 0x02, '+', '"' },
    { 6, 0x04, '-', 'W' },
    { 6, 0x08, '*', 'R' },
    { 6, 0x10, '/', 'M' },
    { 6, 0x20, '^', 'H' },
};

#define KEY_COUNT (sizeof KEYS / sizeof *KEYS)

/* Where the typed text sits. */
#define BOX_X       UI_MARGIN
#define BOX_Y       84
#define BOX_W       (GFX_LCD_WIDTH - BOX_X * 2)
#define BOX_H       34
#define TEXT_PAD    12

static void draw(const char *prompt, const char *hint, const char *text,
                 uint8_t length, keyin_style_t style, bool alpha, bool lower,
                 keyin_backdrop_t backdrop) {
    if (backdrop)
        backdrop();
    else
        gfx_FillScreen(UI_BG);
    ui_header(prompt);

    if (hint)
        font_draw_fit(&font_body, hint, BOX_X, 52, RAMP_DIM, BOX_W);

    /* The field: a panel with an accent underline, like an input on a page. */
    ui_panel(BOX_X, BOX_Y, BOX_W, BOX_H);
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(BOX_X, BOX_Y + BOX_H - 2, BOX_W, 2);

    /* Scroll with the cursor rather than clipping the front: what someone is
     * typing right now is the part they need to see. The font is proportional,
     * so how much fits is measured rather than counted. */
    char shown[KEYIN_MAX + 2];
    uint8_t first = 0;
    for (;;) {
        uint8_t at = 0;
        for (uint8_t i = first; i < length; i++)
            shown[at++] = style == KEYIN_MASKED ? '*' : text[i];
        shown[at++] = '_';
        shown[at] = '\0';
        if (first >= length || font_width(&font_body, shown) <= BOX_W - 2 * TEXT_PAD)
            break;
        first++;
    }
    font_draw(&font_body, shown, BOX_X + TEXT_PAD, BOX_Y + 9, RAMP_FG_SURFACE);

    /* Which keys are typing what: a pill for the mode, and how to change it. */
    const char *mode = alpha ? (lower ? "abc" : "ABC") : "123";
    int mode_w = font_width(&font_bold, mode) + 16;
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(BOX_X, BOX_Y + BOX_H + 12, mode_w, 20);
    font_draw(&font_bold, mode, BOX_X + 8, BOX_Y + BOX_H + 14, RAMP_ON_ACCENT);
    font_draw(&font_body, "alpha letters, 2nd case, del erases",
              BOX_X + mode_w + 10, BOX_Y + BOX_H + 15, RAMP_DIM);

    ui_footer("enter Done|clear Back");
}

bool keyin_text(const char *prompt, const char *hint, char *out, uint8_t max,
                keyin_style_t style, const char *initial,
                keyin_backdrop_t backdrop) {
    if (max > KEYIN_MAX)
        max = KEYIN_MAX;

    uint8_t length = 0;
    if (initial) {
        while (length < max && initial[length]) {
            out[length] = initial[length];
            length++;
        }
    }
    out[length] = '\0';

    bool alpha = false;
    bool lower = false;
    bool dirty = true;
    bool drew = false;

    /* A backdrop may be showing a clock, and a clock that only moves when
     * somebody types is not a clock. Redraw about once a second. */
    unsigned since_redraw = 0;

    input_reset();
    for (;;) {
        if (dirty) {
            draw(prompt, hint, out, length, style, alpha, lower, backdrop);
            dirty = false;
            drew = true;
            since_redraw = 0;
        }

        ui_present(drew);
        drew = false;
        input_scan();

        if (backdrop && ++since_redraw >= 60)
            dirty = true;

        if (input_pressed(kb_KeyEnter)) {
            out[length] = '\0';
            return true;
        }
        if (input_pressed(kb_KeyClear))
            return false;

        if (input_pressed(kb_KeyAlpha)) {
            alpha = !alpha;
            dirty = true;
            continue;
        }
        if (input_pressed(kb_Key2nd)) {
            lower = !lower;
            dirty = true;
            continue;
        }

        /* Backspace repeats, because holding it is how anyone clears a typo. */
        if (input_repeat(kb_KeyDel)) {
            if (length) {
                out[--length] = '\0';
                dirty = true;
            }
            continue;
        }

        if (length >= max)
            continue;

        for (uint8_t i = 0; i < KEY_COUNT; i++) {
            kb_lkey_t key = (kb_lkey_t)((KEYS[i].group << 8) | KEYS[i].mask);
            if (!input_pressed(key))
                continue;

            char c = alpha ? KEYS[i].letter : KEYS[i].plain;
            if (!c)
                continue;
            if (alpha && lower && c >= 'A' && c <= 'Z')
                c = (char)(c + ('a' - 'A'));

            out[length++] = c;
            out[length] = '\0';
            dirty = true;
            break;
        }
    }
}
