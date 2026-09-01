/*
 * The book and strip lists.
 *
 * Rows are drawn by blitting a title bitmap the sync app rendered on the
 * computer -- the calculator has no CJK font, so it never touches text layout.
 * Only fixed ASCII chrome uses the built-in graphx font.
 */

#include "ui.h"

#include "input.h"
#include "about.h"
#include "keyin.h"
#include "library.h"
#include "lock.h"
#include "proto.h"
#include "render.h"

#include <fileioc.h>
#include <graphx.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <tice.h>

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
    ui_set_chrome_palette();
    lib_open();
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

void ui_notice(const char *line1, const char *line2) {
    gfx_FillScreen(UI_BG);
    gfx_SetTextFGColor(UI_FG);
    gfx_SetTextBGColor(UI_BG);
    gfx_PrintStringXY(line1, 10, 100);
    if (line2)
        gfx_PrintStringXY(line2, 10, 118);
    gfx_SwapDraw();
    gfx_Blit(gfx_screen);
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

bool ui_confirm(const char *line1, const char *line2) {
    bool dirty = true;
    bool drew = false;

    input_reset();
    for (;;) {
        if (dirty) {
            gfx_FillScreen(UI_BG);
            ui_header("Are you sure?");
            gfx_SetTextFGColor(UI_FG);
            gfx_SetTextBGColor(UI_BG);
            gfx_PrintStringXY(line1, 10, 90);
            if (line2)
                gfx_PrintStringXY(line2, 10, 108);
            ui_footer("2nd  yes          clear  no");
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
        if (input_pressed(kb_Key2nd))
            return true;
        if (input_pressed(kb_KeyClear))
            return false;
    }
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
    bool drew = false;

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
            ui_footer("enter open  2nd sync  del read  mode setup");
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
            *selection = list.selected;
            return UI_CHOSE;
        }
        if (input_pressed(kb_Key2nd))
            return UI_SYNC;
        if (input_pressed(kb_KeyMode)) {
            *selection = list.selected;
            return UI_SETUP;
        }

        /* Mark the whole book read, or unread if it already is. */
        if (input_pressed(kb_KeyDel) && list.count) {
            lib_book_t book;
            lib_get_book(list.selected, &book);
            if (book.strip_count) {
                lib_set_book_read(&book, lib_book_read_count(&book) != book.strip_count);
                dirty = true;
            }
        }
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
    bool drew = false;

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
            ui_footer("enter read   del mark   clear back");
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
        if (input_pressed(kb_KeyClear))
            return UI_BACK;
    }
}

/*
 * Scrollable text, drawn with the built-in font.
 *
 * The content comes from about.txt in the repository; tools/make_about.sh bakes
 * it into about.h on every build, because the calculator has no way to read the
 * repository for itself.
 */
void ui_about_screen(void) {
    const int rows = 11;              /* lines that fit between the bars */
    int first = 0;
    bool dirty = true;
    bool drew = false;

    input_reset();
    for (;;) {
        if (dirty) {
            gfx_FillScreen(UI_BG);
            ui_header("About");

            gfx_SetTextFGColor(UI_FG);
            gfx_SetTextBGColor(UI_BG);
            for (int row = 0; row < rows; row++) {
                int line = first + row;
                if (line >= (int)ABOUT_LINES)
                    break;
                gfx_PrintStringXY(about_text[line], 8, UI_LIST_TOP + row * 18);
            }

            if ((int)ABOUT_LINES > rows) {
                int track = rows * 18;
                int thumb = track * rows / (int)ABOUT_LINES;
                if (thumb < 8)
                    thumb = 8;
                int span = (int)ABOUT_LINES - rows;
                gfx_SetColor(UI_DIM);
                gfx_FillRectangle_NoClip(GFX_LCD_WIDTH - 4,
                                         UI_LIST_TOP + (track - thumb) * first / span,
                                         3, thumb);
            }

            ui_footer("up/down  scroll        clear  back");
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

        if (ui_confirm("Remove the password?", "2nd removes, clear changes it")) {
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

void ui_setup_screen(void) {
    static const char *const entries[] = {
        "Password",
        "Erase the library",
        "Link echo test",
        "About",
    };
    const uint8_t count = sizeof entries / sizeof *entries;

    uint8_t selected = 0;
    bool dirty = true;
    bool drew = false;
    char line[40];

    input_reset();
    for (;;) {
        if (dirty) {
            gfx_FillScreen(UI_BG);
            ui_header("Settings");

            gfx_SetTextFGColor(UI_DIM);
            gfx_SetTextBGColor(UI_BG);

            uint16_t read = 0;
            for (uint16_t i = 0; i < lib_book_count(); i++) {
                lib_book_t book;
                lib_get_book(i, &book);
                read += lib_book_read_count(&book);
            }
            sprintf(line, "%u books, %u strips, %u read",
                    lib_book_count(), lib_strip_count(), read);
            gfx_PrintStringXY(line, 10, 30);

            for (uint8_t i = 0; i < count; i++) {
                int y = 70 + i * UI_ROW_HEIGHT;
                gfx_SetColor(i == selected ? UI_SELECT_BG : UI_BG);
                gfx_FillRectangle_NoClip(0, y - 4, GFX_LCD_WIDTH, UI_ROW_HEIGHT);
                gfx_SetTextFGColor(UI_FG);
                gfx_SetTextBGColor(i == selected ? UI_SELECT_BG : UI_BG);
                gfx_PrintStringXY(entries[i], 16, y);
            }

            gfx_SetTextFGColor(UI_DIM);
            gfx_SetTextBGColor(UI_BG);
            switch (selected) {
                case 0:
                    gfx_PrintStringXY(lib_password_set()
                        ? "Asked for when eBookSync starts."
                        : "No password set.", 10, 140);
                    gfx_PrintStringXY("It keeps people out of your", 10, 158);
                    gfx_PrintStringXY("comics, not a determined one.", 10, 176);
                    break;
                case 1:
                    gfx_PrintStringXY("Deletes every comic on this", 10, 140);
                    gfx_PrintStringXY("calculator. The computer keeps", 10, 158);
                    gfx_PrintStringXY("its copies.", 10, 176);
                    break;
                case 2:
                    gfx_PrintStringXY("Echoes bytes straight back to", 10, 140);
                    gfx_PrintStringXY("the computer. For working out", 10, 158);
                    gfx_PrintStringXY("why a sync will not start.", 10, 176);
                    break;
                default:
                    break;
            }

            ui_footer("enter  choose          clear  back");
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

        if (input_repeat(kb_KeyUp) && selected) {
            selected--;
            dirty = true;
        } else if (input_repeat(kb_KeyDown) && selected + 1 < count) {
            selected++;
            dirty = true;
        }

        if (input_pressed(kb_KeyEnter)) {
            switch (selected) {
                case 0:
                    password_screen();
                    break;

                case 1:
                    if (ui_confirm("Erase every comic on this", "calculator?")) {
                        uint16_t removed = lib_reset();
                        char message[40];
                        sprintf(message, "Removed %u strip(s).", removed);
                        ui_message(message, "Sync again to refill it.");
                    }
                    break;

                case 2:
                    ui_sync_run(true);
                    break;

                default:
                    ui_about_screen();
                    break;
            }
            input_reset();
            dirty = true;
        }

        if (input_pressed(kb_KeyClear))
            return;
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

    for (uint8_t tries = UI_PASSWORD_TRIES; tries; tries--) {
        char hint[40];
        if (tries == UI_PASSWORD_TRIES)
            hint[0] = '\0';
        else
            sprintf(hint, "%u attempt(s) left.", tries);

        char entered[LIB_PASSWORD_MAX + 1];
        if (!keyin_text("Locked", hint[0] ? hint : NULL, entered,
                        LIB_PASSWORD_MAX, KEYIN_MASKED, NULL, lock_backdrop()))
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

    sprintf(line, "%u done, %uK moved", sync_chunks_received,
            (unsigned)(proto_bytes() / 1024));
    sync_line(3, line);

    sprintf(line, "req %u cmd %u err %u", proto_requests(), proto_last_command(),
            proto_errors());
    sync_line(5, line);

    sprintf(line, "open %u loops %u", proto_open_error(), (unsigned)proto_loops());
    sync_line(6, line);

    if (proto_collections()) {
        sprintf(line, "defragmented %u time(s)", proto_collections());
        sync_line(4, line);
    }

    if (proto_library_state() == PROTO_LIBRARY_DIFFERENT) {
        sync_line(7, "Different library! del=erase");
    } else {
        sync_line(7, "");
    }

    sync_line(8, "[clear] stop syncing");
}

/*
 * Called from the protocol loop every turn, so it has to be cheap.
 *
 * It used to scan the keypad and compare status strings on every single turn.
 * kb_Scan() disables interrupts and waits for a hardware scan -- around a
 * millisecond -- and the loop's turn rate is exactly what drains srldrvce's
 * ring buffer, so paying that every turn throttled the whole transfer. The
 * keypad is polled often enough to feel instant and no more.
 */
#define POLL_EVERY  32      /* turns between keypad scans */
#define REDRAW_EVERY 4096   /* turns between status redraws while busy */

static bool sync_progress(const char *state, uint8_t slot, uint8_t chunk,
                          uint8_t chunk_count) {
    (void)slot;
    (void)chunk;
    (void)chunk_count;

    static uint8_t poll;
    static uint24_t drawn_at;
    static uint16_t drawn_requests;

    /* Redraw when a command completes, or occasionally while one is in flight
     * so the byte counter moves. Each redraw is several OS text calls. */
    bool changed = false;
    if (proto_requests() != drawn_requests) {
        drawn_requests = proto_requests();
        sync_chunks_received = drawn_requests;
        changed = true;
    }
    if (proto_loops() - drawn_at >= REDRAW_EVERY) {
        drawn_at = proto_loops();
        changed = true;
    }
    if (changed) {
        snprintf(sync_state, sizeof sync_state, "%s", state);
        sync_draw();
    }

    if (++poll < POLL_EVERY)
        return true;
    poll = 0;

    input_scan();

    /* Erasing is offered here too, because this is where the mismatch shows. */
    if (input_pressed(kb_KeyDel)
        && proto_library_state() == PROTO_LIBRARY_DIFFERENT) {
        lib_reset();
        snprintf(sync_state, sizeof sync_state, "Erased -- sync again");
        sync_draw();
    }

    return !input_pressed(kb_KeyClear);
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

    /*
     * Plain kb_Scan(), as srl_echo uses.
     *
     * kb_Scan() disables interrupts, which looked like a hazard next to an
     * interrupt-driven USB driver, so this used to put the keypad in continuous
     * mode instead. But srl_echo calls kb_Scan() in its loop and works, and
     * continuous mode did not help -- so this matches the example rather than
     * the theory.
     */
    bool ok = proto_run(sync_progress, echo_only);

    os_ClrHome();
    gfx_Begin();
    gfx_SetDrawBuffer();
    ui_set_chrome_palette();

    /* proto_run() installs its own garbage-collect handlers and clears them on
     * the way out, so the menus' pair has to go back. Without this every
     * collect for the rest of the session draws the OS prompt into 8bpp
     * memory, where nobody can see it and nobody can answer it. */
    ui_install_gc();

    if (!ok)
        ui_message("Could not take over USB.", "Unplug the cable and retry.");
}
