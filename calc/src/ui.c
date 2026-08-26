/*
 * The book and strip lists.
 *
 * Rows are drawn by blitting a title bitmap the sync app rendered on the
 * computer -- the calculator has no CJK font, so it never touches text layout.
 * Only fixed ASCII chrome uses the built-in graphx font.
 */

#include "ui.h"

#include "input.h"
#include "library.h"
#include "proto.h"
#include "render.h"

#include <graphx.h>
#include <stdio.h>
#include <tice.h>
#include <string.h>

#define LIST_X        10
#define TITLE_INSET   2

static void set_rgb(uint8_t index, uint8_t r, uint8_t g, uint8_t b) {
    gfx_palette[index] = (uint16_t)(((r >> 3) << 10) | ((g >> 3) << 5) | (b >> 3));
}

/* Blend two colours; used to build the four-level ramps the 2bpp titles are
 * drawn through, so text sits correctly on both row backgrounds. */
static void set_ramp(uint8_t base, uint8_t br, uint8_t bg_, uint8_t bb,
                     uint8_t fr, uint8_t fg, uint8_t fb) {
    for (uint8_t level = 0; level < 4; level++) {
        set_rgb(base + level,
                (uint8_t)(br + (fr - br) * level / 3),
                (uint8_t)(bg_ + (fg - bg_) * level / 3),
                (uint8_t)(bb + (fb - bb) * level / 3));
    }
}

void ui_set_chrome_palette(void) {
    set_rgb(UI_BG, 248, 248, 248);
    set_rgb(UI_FG, 24, 24, 24);
    set_rgb(UI_ACCENT, 40, 90, 200);
    set_rgb(UI_DIM, 150, 150, 150);
    set_rgb(UI_SELECT_BG, 198, 218, 255);

    set_ramp(UI_TEXT_RAMP, 248, 248, 248, 24, 24, 24);
    set_ramp(UI_TEXT_RAMP_SEL, 198, 218, 255, 16, 24, 48);
}

void ui_header(const char *text) {
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(0, 0, GFX_LCD_WIDTH, UI_LIST_TOP - 4);
    gfx_SetTextFGColor(UI_BG);
    gfx_SetTextBGColor(UI_ACCENT);
    gfx_PrintStringXY(text, 6, 5);
}

void ui_footer(const char *text) {
    gfx_SetColor(UI_DIM);
    gfx_FillRectangle_NoClip(0, GFX_LCD_HEIGHT - 16, GFX_LCD_WIDTH, 16);
    gfx_SetTextFGColor(UI_BG);
    gfx_SetTextBGColor(UI_DIM);
    gfx_PrintStringXY(text, 6, GFX_LCD_HEIGHT - 12);
}

void ui_draw_title(uint16_t title_offset, int x, int y, bool selected) {
    uint16_t width;
    uint8_t height;
    const uint8_t *bitmap = lib_title(title_offset, &width, &height);
    if (!bitmap)
        return;

    uint8_t ramp = selected ? UI_TEXT_RAMP_SEL : UI_TEXT_RAMP;
    uint16_t stride = (width + 3) / 4;

    if (x + (int)width > GFX_LCD_WIDTH)
        width = (uint16_t)(GFX_LCD_WIDTH - x);

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

void ui_message(const char *line1, const char *line2) {
    gfx_FillScreen(UI_BG);
    gfx_SetTextFGColor(UI_FG);
    gfx_SetTextBGColor(UI_BG);
    gfx_PrintStringXY(line1, 10, 100);
    if (line2)
        gfx_PrintStringXY(line2, 10, 118);
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

static void draw_row_background(const menu_list_t *list, uint16_t row) {
    bool selected = list->first + row == list->selected;
    gfx_SetColor(selected ? UI_SELECT_BG : UI_BG);
    gfx_FillRectangle_NoClip(0, UI_LIST_TOP + row * UI_ROW_HEIGHT,
                             GFX_LCD_WIDTH, UI_ROW_HEIGHT);
}

/* Scroll indicator down the right edge, drawn only when the list overflows. */
static void draw_scrollbar(const menu_list_t *list) {
    if (list->count <= UI_LIST_ROWS)
        return;

    int track_top = UI_LIST_TOP;
    int track_height = UI_LIST_ROWS * UI_ROW_HEIGHT;
    int thumb = track_height * UI_LIST_ROWS / list->count;
    if (thumb < 8)
        thumb = 8;
    int span = list->count - UI_LIST_ROWS;
    int offset = span ? (track_height - thumb) * list->first / span : 0;

    gfx_SetColor(UI_DIM);
    gfx_FillRectangle_NoClip(GFX_LCD_WIDTH - 4, track_top + offset, 3, thumb);
}

ui_result_t ui_book_menu(uint16_t *selection) {
    menu_list_t list = { lib_book_count(), *selection, 0 };
    list_move(&list, 0);

    char line[24];
    bool dirty = true;

    for (;;) {
        if (dirty) {
            gfx_FillScreen(UI_BG);
            ui_header("Books");

            if (!list.count) {
                gfx_SetTextFGColor(UI_DIM);
                gfx_SetTextBGColor(UI_BG);
                gfx_PrintStringXY("No comics yet.", 10, 90);
                gfx_PrintStringXY("Press 2nd to sync from a computer.", 10, 108);
            }

            for (uint16_t row = 0; row < UI_LIST_ROWS; row++) {
                uint16_t index = list.first + row;
                if (index >= list.count)
                    break;

                draw_row_background(&list, row);

                lib_book_t book;
                lib_get_book(index, &book);

                int y = UI_LIST_TOP + row * UI_ROW_HEIGHT;
                ui_draw_title(book.title, LIST_X, y + TITLE_INSET,
                              index == list.selected);

                sprintf(line, "%u/%u", lib_book_read_count(&book), book.strip_count);
                gfx_SetTextFGColor(UI_DIM);
                gfx_SetTextBGColor(index == list.selected ? UI_SELECT_BG : UI_BG);
                gfx_PrintStringXY(line, GFX_LCD_WIDTH - 8 - (int)strlen(line) * 8,
                                  y + 6);
            }

            draw_scrollbar(&list);
            ui_footer("enter open  2nd sync  alpha echo  clear quit");
            gfx_SwapDraw();
            dirty = false;
        }

        input_scan();
        if (list_navigate(&list))
            dirty = true;
        if (input_pressed(kb_KeyEnter) && list.count) {
            *selection = list.selected;
            return UI_CHOSE;
        }
        if (input_pressed(kb_Key2nd))
            return UI_SYNC;
        if (input_pressed(kb_KeyAlpha))
            return UI_ECHO;
        if (input_pressed(kb_KeyClear))
            return UI_BACK;
    }
}

ui_result_t ui_strip_menu(uint16_t book_index, uint16_t *selection) {
    lib_book_t book;
    lib_get_book(book_index, &book);

    menu_list_t list = { book.strip_count, 0, 0 };
    char line[24];
    bool dirty = true;

    for (;;) {
        if (dirty) {
            gfx_FillScreen(UI_BG);
            ui_header("Strips");

            for (uint16_t row = 0; row < UI_LIST_ROWS; row++) {
                uint16_t index = list.first + row;
                if (index >= list.count)
                    break;

                draw_row_background(&list, row);

                lib_strip_t strip;
                lib_get_strip(book.strip_first + index, &strip);

                int y = UI_LIST_TOP + row * UI_ROW_HEIGHT;
                bool selected = index == list.selected;
                gfx_SetTextBGColor(selected ? UI_SELECT_BG : UI_BG);

                if (strip.flags & LIB_FLAG_READ) {
                    gfx_SetTextFGColor(UI_ACCENT);
                    gfx_PrintStringXY("*", 2, y + 6);
                }

                ui_draw_title(strip.title, LIST_X + 8, y + TITLE_INSET, selected);

                sprintf(line, "%uK", (unsigned)(strip.bytes / 1024));
                gfx_SetTextFGColor(UI_DIM);
                gfx_PrintStringXY(line, GFX_LCD_WIDTH - 8 - (int)strlen(line) * 8,
                                  y + 6);
            }

            draw_scrollbar(&list);
            ui_footer("enter read   clear back");
            gfx_SwapDraw();
            dirty = false;
        }

        input_scan();
        if (list_navigate(&list))
            dirty = true;
        if (input_pressed(kb_KeyEnter) && list.count) {
            *selection = book.strip_first + list.selected;
            return UI_CHOSE;
        }
        if (input_pressed(kb_KeyClear))
            return UI_BACK;
    }
}

/* ------------------------------------------------------------- sync screen */

/*
 * The sync screen runs on the OS text display, with graphx shut down.
 *
 * That is not a style choice. usbdrvce notes that transfers fail when
 * "non-default cpu speed or lcd parameters are in effect", and gfx_Begin() puts
 * the LCD into 8bpp palettised mode -- exactly such a parameter change. The one
 * device-mode program in the toolchain that is known to work, srl_echo, makes
 * no graphx calls at all and runs on the homescreen. With graphx running, this
 * loop froze inside usb_HandleEvents(); handing the LCD back for the duration
 * is the difference between the two.
 */

static uint8_t sync_chunks_received;
static bool sync_echo_mode;
static char sync_state[32];

/* The homescreen is 26 columns; pad so a shorter line erases the last one. */
static void sync_line(uint8_t row, const char *text) {
    char padded[27];
    unsigned i = 0;
    while (i < 26 && text[i]) {
        padded[i] = text[i];
        i++;
    }
    while (i < 26)
        padded[i++] = ' ';
    padded[26] = '\0';

    os_SetCursorPos(row, 0);
    os_PutStrFull(padded);
}

static void sync_draw(void) {
    char line[40];

    sync_line(0, sync_echo_mode ? "eBookSync - ECHO TEST" : "eBookSync");
    sync_line(2, sync_state);

    sprintf(line, "%u chunks received", sync_chunks_received);
    sync_line(3, line);

    sprintf(line, "req %u cmd %u err %u", proto_requests(), proto_last_command(),
            proto_errors());
    sync_line(5, line);

    sprintf(line, "sch %u loops %u", proto_schedule_error(), (unsigned)proto_loops());
    sync_line(6, line);

    sync_line(8, "[clear] stop syncing");
}

/* Called from the protocol loop between requests. Returning false stops it. */
static bool sync_progress(const char *state, uint8_t slot, uint8_t chunk,
                          uint8_t chunk_count) {
    (void)slot;
    (void)chunk;
    (void)chunk_count;

    bool changed = strcmp(sync_state, state) != 0;
    if (changed)
        snprintf(sync_state, sizeof sync_state, "%s", state);

    if (strcmp(state, "Receiving") == 0) {
        sync_chunks_received++;
        changed = true;
    }

    static uint16_t drawn_requests;
    if (proto_requests() != drawn_requests) {
        drawn_requests = proto_requests();
        changed = true;
    }

    /* A slow heartbeat, so the loop counter visibly moves while the loop is
     * alive. Writing to the OS display is expensive, so not every time round. */
    if ((proto_loops() & 0x7FF) == 0)
        changed = true;

    if (changed) {
        proto_mark(PROTO_PHASE_DRAW);
        sync_draw();
    }

    input_scan();
    return !input_pressed(kb_KeyClear);
}

void ui_sync_screen(void) {
    ui_sync_run(false);
}

/*
 * The echo mode is reached with alpha from the book list. It exists to tell a
 * broken protocol apart from a broken link -- see proto_run.
 */
void ui_sync_run(bool echo_only) {
    sync_echo_mode = echo_only;
    sync_chunks_received = 0;
    snprintf(sync_state, sizeof sync_state, "Starting...");
    input_reset();

    /* Hand the LCD back to the OS before touching USB; see the note above. */
    gfx_End();
    os_ClrHome();
    sync_draw();

    /* kb_Scan() disables interrupts, and the sync loop spins as fast as it can;
     * let the keypad controller scan itself instead. */
    input_begin_continuous();
    bool ok = proto_run(sync_progress, echo_only);
    input_end_continuous();

    os_ClrHome();
    gfx_Begin();
    gfx_SetDrawBuffer();
    ui_set_chrome_palette();

    if (!ok)
        ui_message("Could not take over USB.", "Unplug the cable and retry.");
}
