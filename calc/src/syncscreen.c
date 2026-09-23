/*
 * The sync screen, drawn rather than typed.
 *
 * It used to be plain text on the operating system's homescreen, and for a
 * reason that still holds: usbdrvce fails transfers under "non-default lcd
 * parameters", and graphx's 8bpp mode is exactly such a parameter, so graphx
 * is handed back for the whole session. What that rules out is graphx, not
 * pixels. With the LCD in the operating system's own 16bpp mode this writes
 * straight into its memory -- which is not a parameter change -- in the same
 * font and colours as the rest of the reader. BlueObject's connect screen
 * (release 2.1.0) is where this came from.
 *
 * It is drawn in fields that remember what they last showed, so a pass that
 * changes nothing touches no pixels: the link loop asks for a redraw many
 * times a second, and a full repaint is 150 KB of LCD memory.
 *
 * What is still owed to the operating system is the homescreen itself. A
 * defragment draws the OS's prompt, in the OS's font, where the OS's cursor
 * is, and blocks until it is answered -- so before one, the screen is handed
 * back white and cleared (proto_set_os_screen), and after one it is painted
 * again from scratch.
 */

#include "ui.h"

#include "build.h"
#include "font.h"
#include "input.h"
#include "library.h"
#include "proto.h"
#include "render.h"
#include "theme.h"

#include <graphx.h>
#include <stdio.h>
#include <string.h>
#include <sys/lcd.h>
#include <tice.h>

/* ------------------------------------------------------------------ colours */

static struct {
    uint16_t bg, surface, fg, dim, accent, on_accent, select, warn, track;
} c;

static void load_colours(void) {
    const theme_t *t = theme_current();
    c.bg = theme_to_565(t->bg);
    c.surface = theme_to_565(t->surface);
    c.fg = theme_to_565(t->fg);
    c.dim = theme_to_565(t->dim);
    c.accent = theme_to_565(t->accent);
    c.on_accent = theme_to_565(t->on_accent);
    c.select = theme_to_565(t->select);
    c.warn = theme_to_565(t->warn);
    c.track = theme_to_565(theme_mix(t->bg, t->accent, 5));
}

/* ------------------------------------------------------------------ drawing */

/*
 * A filled rectangle, straight into the LCD's memory.
 *
 * The first row is written a pixel at a time and every other row is a copy of
 * it: a block copy on this processor is a couple of cycles a byte, and a
 * compiled per-pixel loop over the whole screen takes about half a second.
 */
static void fill(int x, int y, int w, int h, uint16_t colour) {
    if (x < 0) { w += x; x = 0; }
    if (y < 0) { h += y; y = 0; }
    if (x + w > LCD_WIDTH)
        w = LCD_WIDTH - x;
    if (y + h > LCD_HEIGHT)
        h = LCD_HEIGHT - y;
    if (w <= 0 || h <= 0)
        return;

    uint16_t *first = (uint16_t *)lcd_Ram + y * LCD_WIDTH + x;
    for (int i = 0; i < w; i++)
        first[i] = colour;
    uint16_t *row = first;
    for (int i = 1; i < h; i++) {
        row += LCD_WIDTH;
        memcpy(row, first, (size_t)w * 2);
    }
}

/*
 * One strip of screen with one string on it, remembered. A pass whose text
 * matches costs a strcmp; one that does not clears the strip -- the font is
 * proportional, so the old text cannot be measured out of the new -- and draws.
 */
typedef struct {
    int x, y, w;
    const ui_font_t *font;
    uint16_t *fg, *bg;
    char shown[48];
} field_t;

static void field_set(field_t *f, const char *text) {
    if (strncmp(f->shown, text, sizeof f->shown - 1) == 0)
        return;
    strncpy(f->shown, text, sizeof f->shown - 1);
    f->shown[sizeof f->shown - 1] = '\0';

    fill(f->x, f->y, f->w, f->font->height, *f->bg);
    font_draw565(f->font, text, f->x, f->y, *f->fg, *f->bg, f->w);
}

/* ------------------------------------------------------------------ layout */

#define MARGIN     14
#define HEADER_H   28
#define CARD_Y     44
#define CARD_H     104
#define LAMP_X     (MARGIN + 12)
#define LAMP_Y     (CARD_Y + 16)
#define SWEEP_X    (MARGIN + 12)
#define SWEEP_Y    (CARD_Y + 86)
#define SWEEP_SEGS 16
#define SWEEP_W    ((LCD_WIDTH - 2 * MARGIN - 24) / SWEEP_SEGS)
#define SWEEP_H    6
#define WARN_Y     156
#define DIAG_Y     188
#define FOOTER_Y   (LCD_HEIGHT - 24)

static field_t f_state   = { MARGIN + 30, CARD_Y + 12, 250, &font_bold, &c.fg, &c.surface, { 0 } };
static field_t f_link    = { MARGIN + 30, CARD_Y + 32, 250, &font_body, &c.dim, &c.surface, { 0 } };
static field_t f_moved   = { MARGIN + 12, CARD_Y + 58, 260, &font_body, &c.fg, &c.surface, { 0 } };
static field_t f_warn    = { MARGIN + 12, WARN_Y + 7, 270, &font_body, &c.warn, &c.bg, { 0 } };
static field_t f_counts  = { MARGIN, DIAG_Y, 292, &font_small, &c.dim, &c.bg, { 0 } };
static field_t f_loops   = { MARGIN, DIAG_Y + 13, 292, &font_small, &c.dim, &c.bg, { 0 } };

static field_t *const fields[] = { &f_state, &f_link, &f_moved, &f_warn, &f_counts, &f_loops };
#define FIELD_COUNT (sizeof fields / sizeof fields[0])

/* The lamp and the sweep are pixels, not text; -1 is "nothing drawn yet". */
static int lamp_shown;
static int sweep_shown;
static bool warn_shown;

/*
 * How many turns of the link loop move the sweep on by one segment. The loop
 * runs as fast as the machine allows; this puts a segment every 512 turns,
 * which is quick enough to look alive and slow enough to follow.
 */
#define SWEEP_SHIFT 9

static void lamp_set(int lit) {
    if (lit == lamp_shown)
        return;
    uint16_t colour = lit ? c.accent : c.dim;
    /* A rounded dot: a square with its corners knocked off. */
    fill(LAMP_X + 1, LAMP_Y, 8, 10, colour);
    fill(LAMP_X, LAMP_Y + 1, 10, 8, colour);
    lamp_shown = lit;
}

/*
 * A segment walking a track for as long as the loop turns. A still screen
 * cannot say whether the link is wedged or merely idle; this answers it from
 * across the room, and stops dead the moment the loop does.
 */
static void sweep_set(int seg) {
    if (seg == sweep_shown)
        return;
    if (sweep_shown >= 0)
        fill(SWEEP_X + sweep_shown * SWEEP_W, SWEEP_Y, SWEEP_W, SWEEP_H, c.track);
    fill(SWEEP_X + seg * SWEEP_W, SWEEP_Y, SWEEP_W, SWEEP_H, c.accent);
    sweep_shown = seg;
}

static void draw_frame(void) {
    char line[24];

    fill(0, 0, LCD_WIDTH, LCD_HEIGHT, c.bg);
    fill(0, 0, LCD_WIDTH, HEADER_H, c.accent);
    font_draw565(&font_bold, "Sync with a computer", MARGIN, 5, c.on_accent, c.accent, 220);
    sprintf(line, "build %u", (unsigned)COMICS_BUILD);
    font_draw565(&font_small, line, LCD_WIDTH - MARGIN - font_width(&font_small, line), 8,
                 c.on_accent, c.accent, 80);

    fill(MARGIN, CARD_Y, LCD_WIDTH - 2 * MARGIN, CARD_H, c.surface);
    fill(SWEEP_X, SWEEP_Y, SWEEP_SEGS * SWEEP_W, SWEEP_H, c.track);

    fill(0, FOOTER_Y, LCD_WIDTH, 24, c.surface);
    int x = font_draw565(&font_small, "clear", MARGIN, FOOTER_Y + 5, c.accent, c.surface, 60);
    font_draw565(&font_small, "Stop syncing", x + 4, FOOTER_Y + 5, c.fg, c.surface, 200);

    for (unsigned i = 0; i < FIELD_COUNT; i++)
        fields[i]->shown[0] = '\0';   /* about pixels no longer there */
    lamp_shown = -1;
    sweep_shown = -1;
    warn_shown = false;
}

static const char *sync_state;
static uint8_t sync_chunks;

static void draw_fields(void) {
    char line[48];

    field_set(&f_state, sync_state ? sync_state : "Starting...");
    bool open = proto_connected();
    lamp_set(open ? 1 : 0);
    field_set(&f_link, open ? "Connected to the sync page"
                            : "Press Connect calculator on the sync page");

    sprintf(line, "%u KB received, %u request%s", (unsigned)(proto_bytes() / 1024),
            (unsigned)proto_requests(), proto_requests() == 1 ? "" : "s");
    field_set(&f_moved, line);

    /* The one thing on this screen somebody has to act on: comics from another
     * library folder. del erases them, the same as it always has here. */
    bool different = proto_library_state() == PROTO_LIBRARY_DIFFERENT;
    if (different != warn_shown) {
        fill(MARGIN, WARN_Y, LCD_WIDTH - 2 * MARGIN, 26, different ? c.surface : c.bg);
        if (different)
            fill(MARGIN, WARN_Y, 3, 26, c.warn);
        f_warn.bg = different ? &c.surface : &c.bg;
        f_warn.shown[0] = '\0';
        warn_shown = different;
    }
    field_set(&f_warn, different ? "Another library is on here. del erases it." : "");

    /*
     * The strip along the bottom. Every number PROTOCOL.md calls the diagnosis
     * stays on screen: "nothing ever arrived", "requests arrive but replies
     * fail" and "the link dropped" are three faults, and these tell them apart.
     */
    sprintf(line, "req %u   cmd %u   err %u   defrag %u", proto_requests(),
            proto_last_command(), proto_errors(), proto_collections());
    field_set(&f_counts, line);
    sprintf(line, "loops %u   open %u", (unsigned)proto_loops(), proto_open_error());
    field_set(&f_loops, line);
}

/*
 * Hand the homescreen back, because the OS is about to draw on it and block.
 * White, cleared, and the cursor home: the prompt is a full-width thing that
 * scrolls the homescreen under itself, so no part of a drawn screen can be
 * allowed to stay under it.
 */
static void os_screen(void) {
    fill(0, 0, LCD_WIDTH, LCD_HEIGHT, 0xFFFF);
    os_ClrHome();
}

/* ------------------------------------------------------------- the session */

/*
 * How often the loop looks at the keypad, and how often it redraws. kb_Scan()
 * disables interrupts for about a millisecond, and the USB driver is
 * interrupt-driven, so scanning every turn starves it. RESYNC_EVERY is rarer
 * and repaints everything, for a defragment nobody announced: the OS may
 * collect on a write that was predicted to fit, and then only a timed repaint
 * ever paints over what its prompt left behind.
 */
#define POLL_EVERY     32
#define REDRAW_EVERY   4096
#define RESYNC_EVERY   65536u

static unsigned sync_turns;
static bool sync_stop;

static bool sync_progress(const char *state, uint8_t slot, uint8_t chunk,
                          uint8_t chunk_count) {
    (void)slot;
    (void)chunk;
    (void)chunk_count;

    bool changed = state != sync_state;
    sync_state = state;

    if ((sync_turns % POLL_EVERY) == 0) {
        input_scan();
        if (input_pressed(kb_KeyClear))
            sync_stop = true;

        /* Erasing is offered here too, because this is where the mismatch shows. */
        if (input_pressed(kb_KeyDel)
            && proto_library_state() == PROTO_LIBRARY_DIFFERENT) {
            lib_reset();
            sync_state = "Erased. Sync again.";
            changed = true;
        }

        sweep_set((int)((proto_loops() >> SWEEP_SHIFT) & (SWEEP_SEGS - 1)));
    }

    if (proto_screen_dirty()
        || (sync_turns && (sync_turns % RESYNC_EVERY) == 0)) {
        draw_frame();
        changed = true;
    }

    if (changed || (sync_turns % REDRAW_EVERY) == 0 || proto_requests() != sync_chunks) {
        sync_chunks = (uint8_t)proto_requests();
        draw_fields();
    }

    sync_turns++;
    return !sync_stop;
}

void ui_sync_run(void) {
    sync_state = NULL;
    sync_turns = 0;
    sync_stop = false;
    sync_chunks = 0;
    input_reset();

    /* Hand the LCD back to the OS before touching USB; see the top of this
     * file. Then draw in its mode. */
    gfx_End();
    os_ClrHome();
    load_colours();
    draw_frame();
    draw_fields();

    proto_set_os_screen(os_screen);
    bool ok = proto_run(sync_progress, false);
    proto_set_os_screen(NULL);

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
