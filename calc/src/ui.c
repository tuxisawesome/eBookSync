/*
 * The menus: the book and strip lists, bookmarks, settings, about, messages.
 *
 * Rows are drawn by blitting a title bitmap the sync app rendered on the
 * computer -- the calculator has no CJK font, so it never touches text layout.
 * Everything else is in the reader's own font (font.h), drawn through palette
 * ramps set from the current theme (theme.h), so it is anti-aliased against
 * whatever it sits on in either Dark or Light.
 *
 * The sync screen is not here: it runs with graphx handed back, and lives in
 * syncscreen.c.
 */

#include "ui.h"

#include "font.h"
#include "input.h"
#include "about.h"
#include "keyin.h"
#include "library.h"
#include "lock.h"
#include "render.h"
#include "theme.h"

#include <fileioc.h>
#include <graphx.h>
#include <stdio.h>
#include <string.h>
#include <sys/power.h>
#include <time.h>
#include <tice.h>

#define W GFX_LCD_WIDTH

/* ------------------------------------------------------------------ palette */

static void set_colour(uint8_t index, rgb_t colour) {
    gfx_palette[index] = theme_to_1555(colour);
}

/*
 * A ramp for anti-aliased text: the background, then a third, two thirds and
 * all of the way to the text colour. The middle steps lean a little towards
 * the text, because thin strokes are mostly partial coverage at this size and
 * an even ramp makes them look faint.
 */
static void set_ramp(uint8_t base, rgb_t bg, rgb_t fg) {
    set_colour(base, bg);
    set_colour(base + 1, theme_mix(bg, fg, 7));
    set_colour(base + 2, theme_mix(bg, fg, 12));
    set_colour(base + 3, fg);
}

void ui_set_chrome_palette(void) {
    const theme_t *t = theme_current();

    set_colour(UI_BG, t->bg);
    set_colour(UI_SURFACE, t->surface);
    set_colour(UI_FG, t->fg);
    set_colour(UI_DIM, t->dim);
    set_colour(UI_ACCENT, t->accent);
    set_colour(UI_ON_ACCENT, t->on_accent);
    set_colour(UI_SELECT_BG, t->select);
    set_colour(UI_WARN, t->warn);
    set_colour(UI_RULE, theme_mix(t->bg, t->dim, 3));
    set_colour(UI_ACCENT_SOFT, theme_mix(t->bg, t->accent, 6));
    gfx_palette[UI_BLACK] = 0;

    set_ramp(RAMP_FG, t->bg, t->fg);
    set_ramp(RAMP_DIM, t->bg, t->dim);
    set_ramp(RAMP_ACCENT, t->bg, t->accent);
    set_ramp(RAMP_FG_SEL, t->select, t->fg);
    set_ramp(RAMP_DIM_SEL, t->select, t->dim);
    set_ramp(RAMP_ACCENT_SEL, t->select, t->accent);
    set_ramp(RAMP_ON_ACCENT, t->accent, t->on_accent);
    set_ramp(RAMP_FG_SURFACE, t->surface, t->fg);
    set_ramp(RAMP_DIM_SURFACE, t->surface, t->dim);
    set_ramp(RAMP_ACCENT_SURFACE, t->surface, t->accent);
    set_ramp(RAMP_WARN, t->bg, t->warn);
}

/* ---------------------------------------------------------- garbage collect */

/*
 * The OS defragments the archive when it runs out of room, and it may decide to
 * do so on any archive write. It draws its own prompt and waits for a keypress,
 * and that prompt needs the LCD back in its normal mode -- graphx has it in
 * 8bpp, where the prompt is drawn into palettised memory and cannot be seen.
 *
 * Afterwards every pointer from ti_GetDataPtr has moved, so the index has to be
 * mapped again. Forgetting that leaves the reader drawing from wherever the
 * index used to be.
 */
static void gc_before(void) {
    gfx_End();
}

static void gc_after(void) {
    gfx_Begin();
    gfx_SetDrawBuffer();
    lib_open();
    ui_set_chrome_palette();
}

void ui_install_gc(void) {
    ti_SetGCBehavior(gc_before, gc_after);
}

void ui_present(bool drew) {
    gfx_SwapDraw();
    gfx_Wait();
    if (drew)
        gfx_Blit(gfx_screen);
}

/* ------------------------------------------------------------ the frame */

void ui_header(const char *text) {
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(0, 0, W, UI_HEADER_H);
    font_draw_fit(&font_bold, text, UI_MARGIN, 5, RAMP_ON_ACCENT, W - 2 * UI_MARGIN);
}

void ui_footer(const char *hints) {
    gfx_SetColor(UI_SURFACE);
    gfx_FillRectangle_NoClip(0, UI_FOOTER_Y, W, UI_FOOTER_H);

    /* "key label|key label": the key in the accent, its label beside it, and a
     * clear gap before the next pair. */
    int x = UI_MARGIN;
    int y = UI_FOOTER_Y + 5;
    char pair[32];
    while (*hints) {
        const char *end = strchr(hints, '|');
        size_t length = end ? (size_t)(end - hints) : strlen(hints);
        if (length >= sizeof pair)
            length = sizeof pair - 1;
        memcpy(pair, hints, length);
        pair[length] = '\0';

        char *label = strchr(pair, ' ');
        if (label)
            *label++ = '\0';
        x = font_draw(&font_small, pair, x, y, RAMP_ACCENT_SURFACE) + 4;
        if (label)
            x = font_draw(&font_small, label, x, y, RAMP_FG_SURFACE);
        x += 14;

        if (!end)
            break;
        hints = end + 1;
    }
}

void ui_panel(int x, int y, int w, int h) {
    gfx_SetColor(UI_SURFACE);
    gfx_FillRectangle_NoClip(x, y, w, h);
}

uint8_t ui_wrap(const char *text, int x, int y, int width, uint8_t line_h,
                uint8_t ramp, uint8_t max_lines) {
    char line[64];
    uint8_t lines = 0;

    while (*text && lines < max_lines) {
        while (*text == ' ')
            text++;

        /* Take words while they fit. A single word wider than the line is cut
         * rather than looping for ever. */
        size_t take = 0, fits = 0;
        for (;;) {
            size_t next = take;
            while (text[next] == ' ')
                next++;
            while (text[next] && text[next] != ' ')
                next++;
            if (next >= sizeof line)
                break;
            memcpy(line, text, next);
            line[next] = '\0';
            if (font_width(&font_body, line) > width && fits)
                break;
            fits = take = next;
            if (!text[next])
                break;
        }
        if (!fits)
            fits = strlen(text) < sizeof line ? strlen(text) : sizeof line - 1;

        memcpy(line, text, fits);
        line[fits] = '\0';
        if (lines + 1 == max_lines && text[fits])
            font_draw_fit(&font_body, line, x, y, ramp, width);
        else
            font_draw(&font_body, line, x, y, ramp);

        text += fits;
        y += line_h;
        lines++;
    }
    return lines;
}

void ui_draw_title(uint16_t title_offset, int x, int y, uint8_t ramp) {
    uint16_t width;
    uint8_t height;
    const uint8_t *bitmap = lib_title(title_offset, &width, &height);
    if (!bitmap)
        return;

    uint16_t stride = (width + 3) / 4;

    if (x + (int)width > W)
        width = (uint16_t)(W - x);

    for (uint8_t row = 0; row < height; row++) {
        int dst_y = y + row;
        if (dst_y < 0 || dst_y >= GFX_LCD_HEIGHT)
            continue;

        const uint8_t *src = bitmap + (uint24_t)row * stride;
        uint8_t *dst = &gfx_vbuffer[dst_y][x];
        for (uint16_t col = 0; col < width; col++) {
            /* Level 0 is background: skipping it leaves the row colour showing
             * and makes the common case a no-op. */
            uint8_t level = (src[col >> 2] >> (6 - 2 * (col & 3))) & 3;
            if (level)
                dst[col] = (uint8_t)(ramp + level);
        }
    }
}

void ui_draw_bookmark(int x, int y) {
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(x, y, 7, 10);
    /* The notch in the tail, in whatever is behind it. */
    gfx_SetColor(UI_BG);
    gfx_FillRectangle_NoClip(x + 3, y + 8, 1, 2);
    gfx_FillRectangle_NoClip(x + 2, y + 9, 3, 1);
}

void ui_draw_down_arrow(int x, int y) {
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(x + 3, y, 3, 3);
    for (int row = 0; row < 4; row++)
        gfx_FillRectangle_NoClip(x + row, y + 3 + row, 9 - 2 * row, 1);
}

/* A small right-pointing triangle, for Continue. */
static void draw_play(int x, int y, uint8_t colour) {
    gfx_SetColor(colour);
    for (int col = 0; col < 5; col++)
        gfx_FillRectangle_NoClip(x + col, y + col, 1, 11 - 2 * col);
}

/* ----------------------------------------------------------------- messages */

/* One or two lines, centred, the first in the bold face. */
static void draw_centred(const char *line1, const char *line2) {
    gfx_FillScreen(UI_BG);
    int y = line2 ? 92 : 104;
    font_draw_fit(&font_bold, line1, (W - font_width(&font_bold, line1)) / 2, y,
                  RAMP_FG, W - 2 * UI_MARGIN);
    if (line2)
        font_draw_fit(&font_body, line2, (W - font_width(&font_body, line2)) / 2,
                      y + 26, RAMP_DIM, W - 2 * UI_MARGIN);
}

void ui_notice(const char *line1, const char *line2) {
    draw_centred(line1, line2);
    gfx_SwapDraw();
    gfx_Blit(gfx_screen);
}

void ui_message(const char *line1, const char *line2) {
    draw_centred(line1, line2);
    font_draw(&font_small, "Press any key", (W - font_width(&font_small, "Press any key")) / 2,
              196, RAMP_DIM);
    gfx_SwapDraw();

    /* Whatever key got us here may still be held. Wait for it to come up
     * before listening, or the message vanishes the instant it is drawn. */
    input_reset();
    do {
        input_scan();
    } while (!input_idle());
    do {
        input_scan();
    } while (input_idle());
    do {
        input_scan();
    } while (!input_idle());
}

bool ui_confirm(const char *line1, const char *line2) {
    bool dirty = true;
    bool drew = false;

    input_reset();
    for (;;) {
        if (dirty) {
            gfx_FillScreen(UI_BG);
            ui_header("Are you sure?");
            ui_panel(UI_MARGIN, 76, W - 2 * UI_MARGIN, line2 ? 68 : 48);
            font_draw_fit(&font_body, line1, UI_MARGIN * 2, 92, RAMP_FG_SURFACE,
                          W - 4 * UI_MARGIN);
            if (line2)
                font_draw_fit(&font_body, line2, UI_MARGIN * 2, 114, RAMP_FG_SURFACE,
                              W - 4 * UI_MARGIN);
            ui_footer("2nd Yes|clear No");
            dirty = false;
            drew = true;
        }

        ui_present(drew);
        drew = false;
        input_scan();

        /*
         * No lock check here. 2nd is "yes" on this screen, and a question that
         * answered itself by turning the calculator off would be worse than
         * one that cannot be locked out of. The same goes for the password
         * prompt, where 2nd switches case.
         */
        if (input_pressed(kb_Key2nd))
            return true;
        if (input_pressed(kb_KeyClear))
            return false;
    }
}

/* ------------------------------------------------------------------- lists */

/* Shared scrolling-list state and movement. */
typedef struct {
    uint16_t count;
    uint16_t selected;
    uint16_t first;
} menu_list_t;

static void list_move(menu_list_t *list, int delta) {
    if (!list->count)
        return;

    int target = (int)list->selected + delta;
    if (target < 0)
        target = 0;
    if (target >= (int)list->count)
        target = list->count - 1;
    list->selected = (uint16_t)target;

    if (list->selected < list->first)
        list->first = list->selected;
    else if (list->selected >= list->first + UI_LIST_ROWS)
        list->first = list->selected - UI_LIST_ROWS + 1;
}

static bool list_navigate(menu_list_t *list) {
    if (input_repeat(kb_KeyUp))
        list_move(list, -1);
    else if (input_repeat(kb_KeyDown))
        list_move(list, 1);
    else if (input_repeat(kb_KeyLeft))
        list_move(list, -UI_LIST_ROWS);
    else if (input_repeat(kb_KeyRight))
        list_move(list, UI_LIST_ROWS);
    else
        return false;
    return true;
}

static int row_y(uint16_t row) {
    return UI_LIST_TOP + row * UI_ROW_HEIGHT;
}

/*
 * A row's ground: the selection bar with an accent stripe down its left edge,
 * or a hairline under an ordinary row so a long list reads as rows rather than
 * as a column of text.
 */
static void draw_row_background(const menu_list_t *list, uint16_t row) {
    int y = row_y(row);
    if (list->first + row == list->selected) {
        gfx_SetColor(UI_SELECT_BG);
        gfx_FillRectangle_NoClip(0, y, W, UI_ROW_HEIGHT);
        gfx_SetColor(UI_ACCENT);
        gfx_FillRectangle_NoClip(0, y, 3, UI_ROW_HEIGHT);
    } else {
        gfx_SetColor(UI_RULE);
        gfx_FillRectangle_NoClip(UI_MARGIN, y + UI_ROW_HEIGHT - 1, W - 2 * UI_MARGIN, 1);
    }
}

static bool row_selected(const menu_list_t *list, uint16_t row) {
    return list->first + row == list->selected;
}

/* Scroll indicator down the right edge, drawn only when the list overflows. */
static void draw_scrollbar(const menu_list_t *list) {
    if (list->count <= UI_LIST_ROWS)
        return;

    int track_top = UI_LIST_TOP;
    int track_height = UI_LIST_ROWS * UI_ROW_HEIGHT;
    int thumb = track_height * UI_LIST_ROWS / list->count;
    if (thumb < 12)
        thumb = 12;
    int span = list->count - UI_LIST_ROWS;
    int offset = span ? (track_height - thumb) * list->first / span : 0;

    gfx_SetColor(UI_ACCENT_SOFT);
    gfx_FillRectangle_NoClip(W - 4, track_top, 2, track_height);
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(W - 5, track_top + offset, 4, thumb);
}

/* Where a title bitmap sits in a row: 16px tall, centred. */
#define TITLE_INSET ((UI_ROW_HEIGHT - 16) / 2)
/* And where a line of the body face sits. */
#define TEXT_INSET  ((UI_ROW_HEIGHT - 15) / 2)

/* -------------------------------------------------------------- status bar */

/*
 * Battery and free space, for the book list's header.
 *
 * Read once when the list is entered rather than every frame: os_ArcChk()
 * walks the archive, and neither number moves while somebody is choosing a
 * book. The lists come back through here after every strip read and every
 * sync, which is exactly when either could have changed.
 */
typedef struct {
    uint8_t battery;        /* 0 (nearly flat) to 4 (full) */
    bool charging;
    char free_text[16];     /* "1.2M free" */
} status_t;

static void read_status(status_t *status) {
    status->battery = boot_GetBatteryStatus();
    if (status->battery > 4)
        status->battery = 4;
    status->charging = boot_BatteryCharging() != 0;

    os_ArcChk();
    uint24_t free = os_TempFreeArc;
    if (free >= 1024UL * 1024) {
        unsigned tenths = (unsigned)(free / (1024UL * 1024 / 10));
        sprintf(status->free_text, "%u.%uM free", tenths / 10, tenths % 10);
    } else {
        sprintf(status->free_text, "%uK free", (unsigned)(free / 1024));
    }
}

/* Right-aligned in the header: free space, then a battery gauge. */
static void draw_status(const status_t *status) {
    int battery_x = W - UI_MARGIN - 20;

    font_draw_right(&font_small, status->free_text, battery_x - 8, 8, RAMP_ON_ACCENT);

    /* Body, terminal, and one block per level. A nearly flat battery shows its
     * last block in the warning colour, so the gauge says "charge me" before
     * the OS has to. */
    gfx_SetColor(UI_ON_ACCENT);
    gfx_Rectangle_NoClip(battery_x, 9, 18, 10);
    gfx_FillRectangle_NoClip(battery_x + 18, 12, 2, 4);
    gfx_SetColor(status->battery <= 1 && !status->charging ? UI_WARN : UI_ON_ACCENT);
    for (uint8_t i = 0; i < status->battery; i++)
        gfx_FillRectangle_NoClip(battery_x + 2 + i * 4, 11, 3, 6);

    /* On charge: a bar under the gauge. */
    if (status->charging) {
        gfx_SetColor(UI_ON_ACCENT);
        gfx_FillRectangle_NoClip(battery_x, 21, 18, 1);
    }
}

/* ---------------------------------------------------------------- the books */

/* Pinned rows above the books, in the order they are drawn. */
typedef struct {
    uint16_t last;          /* the strip last read, or LIB_NONE */
    uint16_t bookmarks;     /* how many strips are bookmarked */
    uint16_t count;         /* how many pinned rows there are */
} pinned_t;

static void read_pinned(pinned_t *pinned) {
    pinned->last = lib_last_strip();
    pinned->bookmarks = lib_bookmark_count();
    pinned->count = (pinned->last != LIB_NONE) + (pinned->bookmarks != 0);
}

static bool row_is_continue(const pinned_t *pinned, uint16_t row) {
    return pinned->last != LIB_NONE && row == 0;
}

static bool row_is_bookmarks(const pinned_t *pinned, uint16_t row) {
    return pinned->bookmarks && row == pinned->count - 1;
}

static void draw_pinned_row(const pinned_t *pinned, uint16_t row, int y, bool selected) {
    uint8_t accent = selected ? RAMP_ACCENT_SEL : RAMP_ACCENT;

    if (row_is_continue(pinned, row)) {
        draw_play(UI_MARGIN, y + 7, UI_ACCENT);
        int x = font_draw(&font_bold, "Continue", UI_MARGIN + 14, y + TEXT_INSET - 1, accent);
        lib_strip_t strip;
        lib_get_strip(pinned->last, &strip);
        ui_draw_title(strip.title, x + 10, y + TITLE_INSET,
                      selected ? RAMP_FG_SEL : RAMP_FG);
    } else {
        char line[24];
        ui_draw_bookmark(UI_MARGIN, y + 8);
        sprintf(line, "Bookmarks (%u)", pinned->bookmarks);
        font_draw(&font_bold, line, UI_MARGIN + 14, y + TEXT_INSET - 1, accent);
    }
}

ui_result_t ui_book_menu(uint16_t *row, uint16_t *chosen) {
    pinned_t pinned;
    read_pinned(&pinned);
    status_t status;
    read_status(&status);

    menu_list_t list = { pinned.count + lib_book_count(), *row, 0 };
    list_move(&list, 0);

    char line[24];
    bool dirty = true;
    bool drew = false;

    for (;;) {
        if (dirty) {
            gfx_FillScreen(UI_BG);
            ui_header("Library");
            draw_status(&status);

            if (!lib_book_count()) {
                const char *empty = "No comics yet";
                const char *hint = "Press mode, then Sync, to fill it.";
                font_draw(&font_bold, empty, (W - font_width(&font_bold, empty)) / 2, 100, RAMP_FG);
                font_draw(&font_body, hint, (W - font_width(&font_body, hint)) / 2, 124, RAMP_DIM);
            }

            for (uint16_t screen_row = 0; screen_row < UI_LIST_ROWS; screen_row++) {
                uint16_t index = list.first + screen_row;
                if (index >= list.count)
                    break;

                draw_row_background(&list, screen_row);
                int y = row_y(screen_row);
                bool selected = row_selected(&list, screen_row);

                if (index < pinned.count) {
                    draw_pinned_row(&pinned, index, y, selected);
                    /* A firmer rule under the last pinned row, so they read as
                     * shortcuts rather than as two more books. */
                    if (index + 1 == pinned.count && !selected) {
                        gfx_SetColor(UI_ACCENT_SOFT);
                        gfx_FillRectangle_NoClip(UI_MARGIN, y + UI_ROW_HEIGHT - 1,
                                                 W - 2 * UI_MARGIN, 1);
                    }
                    continue;
                }

                lib_book_t book;
                lib_get_book(index - pinned.count, &book);
                ui_draw_title(book.title, UI_MARGIN, y + TITLE_INSET,
                              selected ? RAMP_FG_SEL : RAMP_FG);

                /* How far through: the count, in the accent once finished. */
                uint16_t read = lib_book_read_count(&book);
                sprintf(line, "%u/%u", read, book.strip_count);
                uint8_t ramp = read == book.strip_count && read
                    ? (selected ? RAMP_ACCENT_SEL : RAMP_ACCENT)
                    : (selected ? RAMP_DIM_SEL : RAMP_DIM);
                font_draw_right(&font_small, line, W - UI_MARGIN, y + 7, ramp);
            }

            draw_scrollbar(&list);
            ui_footer("enter Open|del Mark read|mode Settings");
            dirty = false;
            drew = true;
        }

        ui_present(drew);
        drew = false;
        input_scan();

        /*
         * Before anything else looks at those keys. The combination holds 2nd,
         * and 2nd on the book list opens the sync screen -- so a screen that
         * checked its own keys first would go there instead of locking.
         */
        if (lock_poll()) {
            dirty = true;
            continue;
        }
        if (list_navigate(&list))
            dirty = true;
        if (input_pressed(kb_KeyEnter) && list.count) {
            *row = list.selected;
            if (row_is_continue(&pinned, list.selected)) {
                *chosen = pinned.last;
                return UI_CONTINUE;
            }
            if (row_is_bookmarks(&pinned, list.selected))
                return UI_BOOKMARKS;
            *chosen = list.selected - pinned.count;
            return UI_CHOSE;
        }
        if (input_pressed(kb_KeyMode)) {
            *row = list.selected;
            return UI_SETUP;
        }

        /* Mark the whole book read, or unread if it already is. */
        if (input_pressed(kb_KeyDel) && list.selected >= pinned.count
            && list.count > pinned.count) {
            lib_book_t book;
            lib_get_book(list.selected - pinned.count, &book);
            if (book.strip_count) {
                lib_set_book_read(&book, lib_book_read_count(&book) != book.strip_count);
                dirty = true;
            }
        }
        if (input_pressed(kb_KeyClear))
            return UI_BACK;
    }
}

/* One strip's row: read mark, title, bookmark ribbon and size. Shared by a
 * book's list and the bookmarks list. */
static void draw_strip_row(uint16_t strip_index, int y, bool selected) {
    lib_strip_t strip;
    lib_get_strip(strip_index, &strip);

    /* Read: a small filled dot in the accent, where an unread strip has none. */
    if (strip.flags & LIB_FLAG_READ) {
        gfx_SetColor(UI_ACCENT);
        gfx_FillRectangle_NoClip(UI_MARGIN, y + 11, 5, 5);
        gfx_FillRectangle_NoClip(UI_MARGIN + 1, y + 10, 3, 7);
        gfx_FillRectangle_NoClip(UI_MARGIN - 1, y + 12, 7, 3);
    }

    ui_draw_title(strip.title, UI_MARGIN + 14, y + TITLE_INSET,
                  selected ? RAMP_FG_SEL : RAMP_FG);

    char line[12];
    sprintf(line, "%uK", (unsigned)(strip.bytes / 1024));
    int size_x = W - UI_MARGIN - font_width(&font_small, line);
    if (strip.flags & LIB_FLAG_BOOKMARK) {
        /* Over the end of a long title: the title is ellipsised well short of
         * the size column anyway, but the ribbon must not be lost under it. */
        gfx_SetColor(selected ? UI_SELECT_BG : UI_BG);
        gfx_FillRectangle_NoClip(size_x - 18, y + 1, 16, UI_ROW_HEIGHT - 2);
        ui_draw_bookmark(size_x - 14, y + 8);
    }
    font_draw(&font_small, line, size_x, y + 7, selected ? RAMP_DIM_SEL : RAMP_DIM);
}

static void toggle_bookmark(uint16_t strip_index) {
    lib_strip_t strip;
    lib_get_strip(strip_index, &strip);
    strip.flags ^= LIB_FLAG_BOOKMARK;
    lib_save_strip(strip_index, &strip);
}

ui_result_t ui_strip_menu(uint16_t book_index, uint16_t *selection) {
    lib_book_t book;
    lib_get_book(book_index, &book);

    /* Open on the first strip not yet read: that is almost always the one
     * wanted, and in a long book it is the one furthest from the top. */
    menu_list_t list = { book.strip_count, lib_first_unread(&book), 0 };
    list_move(&list, 0);
    bool dirty = true;
    bool drew = false;

    for (;;) {
        if (dirty) {
            gfx_FillScreen(UI_BG);
            /* The book's own title across the top, rather than a word. */
            gfx_SetColor(UI_ACCENT);
            gfx_FillRectangle_NoClip(0, 0, W, UI_HEADER_H);
            ui_draw_title(book.title, UI_MARGIN, (UI_HEADER_H - 16) / 2, RAMP_ON_ACCENT);

            for (uint16_t row = 0; row < UI_LIST_ROWS; row++) {
                uint16_t index = list.first + row;
                if (index >= list.count)
                    break;

                draw_row_background(&list, row);
                draw_strip_row(book.strip_first + index, row_y(row), row_selected(&list, row));
            }

            draw_scrollbar(&list);
            ui_footer("enter Read|del Mark read|alpha Bookmark");
            dirty = false;
            drew = true;
        }

        ui_present(drew);
        drew = false;
        input_scan();

        if (lock_poll()) {
            dirty = true;
            continue;
        }
        if (list_navigate(&list))
            dirty = true;
        if (input_pressed(kb_KeyEnter) && list.count) {
            *selection = book.strip_first + list.selected;
            return UI_CHOSE;
        }
        if (input_pressed(kb_KeyDel) && list.count) {
            lib_strip_t strip;
            uint16_t index = book.strip_first + list.selected;
            lib_get_strip(index, &strip);
            strip.flags ^= LIB_FLAG_READ;
            if (strip.flags & LIB_FLAG_READ)
                strip.read_at = lib_now();
            lib_save_strip(index, &strip);
            lib_get_book(book_index, &book);
            dirty = true;
        }
        if (input_pressed(kb_KeyAlpha) && list.count) {
            toggle_bookmark(book.strip_first + list.selected);
            lib_get_book(book_index, &book);
            dirty = true;
        }
        if (input_pressed(kb_KeyClear))
            return UI_BACK;
    }
}

ui_result_t ui_bookmark_menu(uint16_t *selection) {
    menu_list_t list = { lib_bookmark_count(), 0, 0 };
    bool dirty = true;
    bool drew = false;

    /* Where the previous visit left off, if that strip is still bookmarked. */
    for (uint16_t i = 0; i < list.count; i++) {
        if (lib_bookmark_at(i) == *selection) {
            list.selected = i;
            break;
        }
    }
    list_move(&list, 0);

    for (;;) {
        if (!list.count)
            return UI_BACK;

        if (dirty) {
            gfx_FillScreen(UI_BG);
            ui_header("Bookmarks");

            for (uint16_t row = 0; row < UI_LIST_ROWS; row++) {
                uint16_t index = list.first + row;
                if (index >= list.count)
                    break;

                draw_row_background(&list, row);
                draw_strip_row(lib_bookmark_at(index), row_y(row), row_selected(&list, row));
            }

            draw_scrollbar(&list);
            ui_footer("enter Read|alpha Remove|clear Back");
            dirty = false;
            drew = true;
        }

        ui_present(drew);
        drew = false;
        input_scan();

        if (lock_poll()) {
            dirty = true;
            continue;
        }
        if (list_navigate(&list))
            dirty = true;
        if (input_pressed(kb_KeyEnter)) {
            *selection = lib_bookmark_at(list.selected);
            return UI_CHOSE;
        }
        if (input_pressed(kb_KeyAlpha)) {
            toggle_bookmark(lib_bookmark_at(list.selected));
            list.count = lib_bookmark_count();
            list_move(&list, 0);
            dirty = true;
        }
        if (input_pressed(kb_KeyClear))
            return UI_BACK;
    }
}

/* ------------------------------------------------------------------- about */

/*
 * One line of about.txt.
 *
 * The file is laid out for a fixed-width font, and this one is proportional,
 * so the layout is read rather than reproduced: leading spaces become an
 * indent, a run of two or more spaces after some text is a column break -- the
 * key tables line up on it -- and a line in capitals is a heading.
 */
#define ABOUT_LINE_H  16
#define ABOUT_KEY_COL 64

static void draw_about_line(const char *line, int y) {
    int indent = 0;
    while (line[indent] == ' ')
        indent++;
    const char *text = line + indent;
    if (!*text)
        return;

    bool heading = false;
    for (const char *p = text; *p; p++) {
        if (*p >= 'a' && *p <= 'z') {
            heading = false;
            break;
        }
        if (*p >= 'A' && *p <= 'Z')
            heading = true;
    }
    if (heading) {
        font_draw(&font_bold, text, UI_MARGIN, y, RAMP_ACCENT);
        return;
    }

    int x = UI_MARGIN + indent * 4;
    const char *gap = strstr(text, "  ");
    if (!gap) {
        font_draw_fit(&font_body, text, x, y, RAMP_FG, W - x - UI_MARGIN);
        return;
    }

    char key[24];
    size_t length = (size_t)(gap - text);
    if (length >= sizeof key)
        length = sizeof key - 1;
    memcpy(key, text, length);
    key[length] = '\0';
    while (*gap == ' ')
        gap++;

    font_draw(&font_body, key, x, y, RAMP_ACCENT);
    font_draw_fit(&font_body, gap, x + ABOUT_KEY_COL, y, RAMP_FG, W - x - ABOUT_KEY_COL - UI_MARGIN);
}

/*
 * Scrollable text, in the reader's own font.
 *
 * The content comes from about.txt in the repository; tools/make_about.sh bakes
 * it into about.h on every build, because the calculator has no way to read
 * the repository for itself.
 */
void ui_about_screen(void) {
    const int top = UI_HEADER_H + 8;
    const int rows = (UI_FOOTER_Y - top - 4) / ABOUT_LINE_H;
    int first = 0;
    bool dirty = true;
    bool drew = false;

    input_reset();
    for (;;) {
        if (dirty) {
            gfx_FillScreen(UI_BG);
            ui_header("About");

            for (int row = 0; row < rows; row++) {
                int line = first + row;
                if (line >= (int)ABOUT_LINES)
                    break;
                draw_about_line(about_text[line], top + row * ABOUT_LINE_H);
            }

            if ((int)ABOUT_LINES > rows) {
                int track = rows * ABOUT_LINE_H;
                int thumb = track * rows / (int)ABOUT_LINES;
                if (thumb < 12)
                    thumb = 12;
                int span = (int)ABOUT_LINES - rows;
                gfx_SetColor(UI_ACCENT_SOFT);
                gfx_FillRectangle_NoClip(W - 4, top, 2, track);
                gfx_SetColor(UI_ACCENT);
                gfx_FillRectangle_NoClip(W - 5, top + (track - thumb) * first / span, 4, thumb);
            }

            ui_footer("arrows Scroll|clear Back");
            dirty = false;
            drew = true;
        }

        ui_present(drew);
        drew = false;
        input_scan();

        if (lock_poll()) {
            dirty = true;
            continue;
        }

        int last = (int)ABOUT_LINES - rows;
        if (last < 0)
            last = 0;

        if (input_repeat(kb_KeyUp) && first > 0) {
            first--;
            dirty = true;
        } else if (input_repeat(kb_KeyDown) && first < last) {
            first++;
            dirty = true;
        } else if (input_repeat(kb_KeyLeft)) {
            first = first > rows ? first - rows : 0;
            dirty = true;
        } else if (input_repeat(kb_KeyRight)) {
            first = first + rows < last ? first + rows : last;
            dirty = true;
        }

        if (input_pressed(kb_KeyClear))
            return;
    }
}

/* ---------------------------------------------------------------- settings */

/*
 * Set, change or remove the password.
 *
 * Changing it needs the current one. Not because a bypass is hard -- see
 * lib_password_check() -- but because a settings screen that lets anyone who
 * reached it change the lock is not a lock at all, and this screen is reachable
 * from behind the prompt.
 */
static void password_screen(void) {
    char entered[LIB_PASSWORD_MAX + 1];

    if (lib_password_set()) {
        if (!keyin_text("Current password", NULL, entered,
                        LIB_PASSWORD_MAX, KEYIN_MASKED, NULL, NULL))
            return;
        if (!lib_password_check(entered)) {
            lib_password_note_failure();
            ui_message("Wrong password.", "Nothing was changed.");
            return;
        }

        if (ui_confirm("Remove the password?", "2nd removes it, clear changes it.")) {
            ui_message(lib_password_store(NULL) ? "Password removed."
                                                : "Could not save that.", NULL);
            return;
        }
    }

    if (!keyin_text("New password", "alpha for letters, del to fix", entered,
                    LIB_PASSWORD_MAX, KEYIN_MASKED, NULL, NULL))
        return;

    if (!*entered) {
        ui_message("Nothing entered.", "The password is unchanged.");
        return;
    }

    char again[LIB_PASSWORD_MAX + 1];
    if (!keyin_text("Type it again", NULL, again, LIB_PASSWORD_MAX, KEYIN_MASKED,
                   NULL, NULL))
        return;

    if (strcmp(entered, again) != 0) {
        ui_message("Those do not match.", "The password is unchanged.");
        return;
    }

    if (!lib_password_store(entered)) {
        ui_message("Could not save that.", "Is the archive full?");
        return;
    }

    ui_message("Password set.", "You will be asked on startup.");
}

enum { SET_SYNC, SET_THEME, SET_PASSWORD, SET_ERASE, SET_ABOUT, SET_COUNT };

static const char *const SETTING_NAMES[SET_COUNT] = {
    "Sync with a computer",
    "Theme",
    "Password",
    "Erase the library",
    "About",
};

static const char *setting_detail(uint8_t which) {
    switch (which) {
        case SET_SYNC:
            return "Plug in the cable, then press Connect calculator on the sync page.";
        case SET_THEME:
            return "Purple, dark or light. Left and right, or enter, to change it.";
        case SET_PASSWORD:
            return lib_password_set()
                ? "Asked for when eBookSync starts. It keeps people out of your "
                  "comics, not a determined one."
                : "No password set. One keeps people out of your comics, not a "
                  "determined one.";
        case SET_ERASE:
            return "Deletes every comic on this calculator. The computer keeps its copies.";
        default:
            return "Keys, locking, and where this came from.";
    }
}

/* Flip between the themes, save it, and repaint in it straight away. */
static void next_theme(void) {
    uint8_t theme = (uint8_t)((lib_theme() + 1) % THEME_COUNT);
    lib_set_theme(theme);
    ui_set_chrome_palette();
}

ui_result_t ui_setup_screen(void) {
    menu_list_t list = { SET_COUNT, 0, 0 };
    bool dirty = true;
    bool drew = false;
    char line[40];

    input_reset();
    for (;;) {
        if (dirty) {
            gfx_FillScreen(UI_BG);
            ui_header("Settings");

            uint16_t read = 0;
            for (uint16_t i = 0; i < lib_book_count(); i++) {
                lib_book_t book;
                lib_get_book(i, &book);
                read += lib_book_read_count(&book);
            }
            sprintf(line, "%u books, %u strips, %u read",
                    lib_book_count(), lib_strip_count(), read);
            font_draw_right(&font_small, line, W - UI_MARGIN, 8, RAMP_ON_ACCENT);

            for (uint8_t i = 0; i < SET_COUNT; i++) {
                draw_row_background(&list, i);
                int y = row_y(i);
                bool selected = row_selected(&list, i);
                font_draw(&font_body, SETTING_NAMES[i], UI_MARGIN, y + TEXT_INSET,
                          selected ? RAMP_FG_SEL : RAMP_FG);

                if (i == SET_THEME) {
                    const char *name = theme_current()->name;
                    font_draw_right(&font_body, name, W - UI_MARGIN, y + TEXT_INSET,
                                    selected ? RAMP_ACCENT_SEL : RAMP_ACCENT);
                }
            }

            /* What the highlighted entry does, in a panel under the list. */
            int panel_y = row_y(SET_COUNT) + 6;
            ui_panel(UI_MARGIN, panel_y, W - 2 * UI_MARGIN, UI_FOOTER_Y - panel_y - 6);
            ui_wrap(setting_detail((uint8_t)list.selected), UI_MARGIN + 10, panel_y + 5,
                    W - 2 * UI_MARGIN - 20, 16, RAMP_FG_SURFACE, 2);

            ui_footer("enter Choose|clear Back");
            dirty = false;
            drew = true;
        }

        ui_present(drew);
        drew = false;
        input_scan();

        if (lock_poll()) {
            dirty = true;
            continue;
        }

        if (input_repeat(kb_KeyUp) || input_repeat(kb_KeyDown)) {
            list_move(&list, input_down(kb_KeyUp) ? -1 : 1);
            dirty = true;
        } else if (list.selected == SET_THEME
                   && (input_pressed(kb_KeyLeft) || input_pressed(kb_KeyRight))) {
            next_theme();
            dirty = true;
        }

        if (input_pressed(kb_KeyEnter)) {
            switch (list.selected) {
                case SET_SYNC:
                    /* Handed back to main(): the band cache is the biggest
                     * thing in RAM and sync needs the room to build variables
                     * before archiving them. */
                    return UI_SYNC;

                case SET_THEME:
                    next_theme();
                    break;

                case SET_PASSWORD:
                    password_screen();
                    break;

                case SET_ERASE:
                    if (ui_confirm("Erase every comic on this", "calculator?")) {
                        uint16_t removed = lib_reset();
                        char message[40];
                        sprintf(message, "Removed %u strip(s).", removed);
                        ui_message(message, "Sync again to refill it.");
                    }
                    break;

                default:
                    ui_about_screen();
                    break;
            }
            input_reset();
            dirty = true;
        }

        if (input_pressed(kb_KeyClear))
            return UI_BACK;
    }
}

/* ---------------------------------------------------------------- password */

/*
 * The lock screen.
 *
 * Deliberately says nothing about whose calculator this is or what is on it: a
 * prompt that advertises a library is an invitation. It reports failed attempts
 * on the way in, though, because that is the part that is actually worth
 * knowing and the part nothing else would ever tell you.
 */
bool ui_password_gate(void) {
    if (!lib_password_set())
        return true;

    /* The same thing the lock screen shows: wallpaper and clock first, and the
     * prompt only once somebody presses a key. */
    lock_wake_screen();

    for (uint8_t tries = UI_PASSWORD_TRIES; tries; tries--) {
        char hint[40];
        if (tries == UI_PASSWORD_TRIES)
            hint[0] = '\0';
        else
            sprintf(hint, "%u attempt(s) left.", tries);

        char entered[LIB_PASSWORD_MAX + 1];
        if (!keyin_text("Locked", hint[0] ? hint : NULL, entered,
                        LIB_PASSWORD_MAX, KEYIN_MASKED, NULL, NULL))
            return false;

        if (lib_password_check(entered)) {
            uint8_t failures = lib_password_failures();
            lib_password_clear_failures();

            if (failures) {
                char line[40];
                sprintf(line, "%u failed attempt(s) since", failures);
                ui_message(line, "you last unlocked this.");
            }
            return true;
        }

        lib_password_note_failure();
        ui_message("Wrong password.", tries > 1 ? "Try again." : "Closing.");
    }

    return false;
}
