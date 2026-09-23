/*
 * Reading a strip: pan, page, zoom, and remember where you were.
 *
 * The viewport is held in the coordinates of the current layer. Zooming keeps
 * whatever is in the middle of the screen in the middle of the screen by
 * rescaling the viewport between the two layers' coordinate spaces.
 *
 * A strip stitched from several images is read one image -- one part -- at a
 * time. The view is confined to the current part and nothing below it is
 * drawn, so a short image leaves the rest of the screen empty rather than
 * showing the next one underneath. At the bottom a bar says what comes next,
 * and a fresh press of down goes there: the next part, or at the end of the
 * last one the next strip of the book.
 *
 * A fresh press, not a held one. Holding down to scroll has to stop at the end
 * of an image, or a long hold would carry straight through every image in the
 * strip and into the next strip without anyone having seen the bar.
 */

#include "viewer.h"

#include "csx.h"
#include "font.h"
#include "input.h"
#include "library.h"
#include "lock.h"
#include "render.h"
#include "ui.h"

#include <graphx.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

/* Panning starts gentle so short taps nudge, then accelerates while held. */
#define PAN_STEP_SLOW   6
#define PAN_STEP_MED    14
#define PAN_STEP_FAST   26
#define PAN_ACCEL_MED   10
#define PAN_ACCEL_FAST  24

/* A page is a screen, less a band's worth kept on screen so the eye has
 * somewhere to land -- a line cut in half at the bottom is still readable at
 * the top of the next page. */
#define PAGE_OVERLAP    32
#define PAGE_STEP       (GFX_LCD_HEIGHT - PAGE_OVERLAP)

/* Frames the position overlay stays up after the last keypress. */
#define OVERLAY_FRAMES  60

/* The bar at the bottom of an image that says what the next press does. */
#define PROMPT_HEIGHT   20

/* Scrolling this far marks the strip read. */
#define READ_THRESHOLD_NUM 95
#define READ_THRESHOLD_DEN 100

typedef struct {
    const csx_strip_t *strip;
    uint8_t layer;
    uint8_t part;
    uint24_t vx, vy;
} view_t;

static uint24_t max_scroll(uint24_t content, uint24_t window) {
    return content > window ? content - window : 0;
}

static uint24_t part_top(const view_t *view) {
    return csx_part_top(view->strip, view->layer, view->part);
}

static uint24_t part_bottom(const view_t *view) {
    return csx_part_bottom(view->strip, view->layer, view->part);
}

/*
 * The lowest the view may go in the current part: its last row just above the
 * prompt bar, or its top at the top when it is too short for that.
 *
 * The room for the bar is scrolled past the end of the image rather than laid
 * over it, and render_view() leaves those rows empty -- so the bar never hides
 * the last line of anything.
 */
static uint24_t part_max_y(const view_t *view) {
    uint24_t top = part_top(view);
    uint24_t bottom = part_bottom(view) + PROMPT_HEIGHT;
    return bottom - top > GFX_LCD_HEIGHT ? bottom - GFX_LCD_HEIGHT : top;
}

static bool at_part_end(const view_t *view) {
    return view->vy >= part_max_y(view);
}

static bool at_part_start(const view_t *view) {
    return view->vy <= part_top(view);
}

static void clamp(view_t *view) {
    const csx_layer_t *layer = &view->strip->layer[view->layer];
    uint24_t max_x = max_scroll(layer->width, GFX_LCD_WIDTH);
    if (view->vx > max_x)
        view->vx = max_x;

    uint24_t min_y = part_top(view);
    uint24_t max_y = part_max_y(view);
    if (view->vy < min_y)
        view->vy = min_y;
    if (view->vy > max_y)
        view->vy = max_y;
}

static void pan(view_t *view, int dx, int dy) {
    const csx_layer_t *layer = &view->strip->layer[view->layer];
    uint24_t max_x = max_scroll(layer->width, GFX_LCD_WIDTH);
    uint24_t min_y = part_top(view);
    uint24_t max_y = part_max_y(view);

    if (dx < 0)
        view->vx = (uint24_t)(-dx) > view->vx ? 0 : view->vx + dx;
    else if (dx > 0)
        view->vx = view->vx + dx > max_x ? max_x : view->vx + dx;

    if (dy < 0)
        view->vy = view->vy < min_y + (uint24_t)(-dy) ? min_y : view->vy + dy;
    else if (dy > 0)
        view->vy = view->vy + dy > max_y ? max_y : view->vy + dy;
}

/* Go to another part, at its top or -- coming back up into it -- its bottom. */
static void go_part(view_t *view, uint8_t part, bool at_bottom) {
    view->part = part;
    view->vy = at_bottom ? part_max_y(view) : part_top(view);
}

/*
 * Move to another layer, keeping the centre of the screen fixed. Widths are
 * used for the ratio rather than heights: they are small enough that the
 * multiply cannot overflow.
 *
 * The part stays the same one. Every layer holds the same images in the same
 * order, only at another size, so the image being read is the image being
 * read at any zoom; the clamp then keeps the view inside it.
 */
static void set_layer(view_t *view, uint8_t target) {
    if (target >= view->strip->layer_count || target == view->layer)
        return;

    uint16_t from = view->strip->layer[view->layer].width;
    uint16_t to = view->strip->layer[target].width;

    uint24_t centre_x = view->vx + GFX_LCD_WIDTH / 2;
    uint24_t centre_y = view->vy + GFX_LCD_HEIGHT / 2;

    uint32_t new_x = (uint32_t)centre_x * to / from;
    uint32_t new_y = (uint32_t)centre_y * to / from;

    view->layer = target;
    view->vx = new_x > GFX_LCD_WIDTH / 2 ? (uint24_t)(new_x - GFX_LCD_WIDTH / 2) : 0;
    view->vy = new_y > GFX_LCD_HEIGHT / 2 ? (uint24_t)(new_y - GFX_LCD_HEIGHT / 2) : 0;
    clamp(view);
}

static unsigned progress_percent(const view_t *view) {
    const csx_layer_t *layer = &view->strip->layer[view->layer];
    uint24_t span = max_scroll(layer->height, GFX_LCD_HEIGHT);
    if (!span)
        return 100;
    uint32_t percent = (uint32_t)view->vy * 100 / span;
    return percent > 100 ? 100 : (unsigned)percent;
}

static bool at_end(const view_t *view) {
    const csx_layer_t *layer = &view->strip->layer[view->layer];
    uint32_t seen = (uint32_t)view->vy + GFX_LCD_HEIGHT;
    return seen * READ_THRESHOLD_DEN >= (uint32_t)layer->height * READ_THRESHOLD_NUM;
}

static void draw_overlay(const view_t *view, bool marked_read, bool bookmarked) {
    const csx_layer_t *layer = &view->strip->layer[view->layer];
    uint24_t span = max_scroll(layer->height, GFX_LCD_HEIGHT);

    /* Where in the strip: a slim track down the right edge. */
    int track = GFX_LCD_HEIGHT;
    int thumb = span ? (int)((uint32_t)GFX_LCD_HEIGHT * GFX_LCD_HEIGHT / layer->height) : track;
    if (thumb < 12)
        thumb = 12;
    uint24_t vy = view->vy > span ? span : view->vy;
    int offset = span ? (int)((uint32_t)(track - thumb) * vy / span) : 0;

    gfx_SetColor(UI_ACCENT_SOFT);
    gfx_FillRectangle_NoClip(GFX_LCD_WIDTH - 3, 0, 3, GFX_LCD_HEIGHT);
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(GFX_LCD_WIDTH - 4, offset, 4, thumb);

    /* Zoom relative to the fit-width layer, to one decimal: the 480px layer is
     * 1.5x, and integer division by the screen width would call it 1x. */
    unsigned zoom = (unsigned)layer->width * 10 / view->strip->layer[0].width;

    char line[32];
    char part[12] = "";
    if (view->strip->part_count > 1)
        sprintf(part, "  p%u/%u", view->part + 1, view->strip->part_count);
    sprintf(line, "%u.%ux  %u%%%s%s", zoom / 10, zoom % 10,
            progress_percent(view), part, marked_read ? "  read" : "");

    /* A pill in the top corner, padded, with the ribbon inside it when the
     * strip is bookmarked. */
    int text_w = font_width(&font_small, line);
    int pill_w = text_w + 16 + (bookmarked ? 14 : 0);
    ui_panel(6, 6, pill_w, 20);
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(6, 6, 2, 20);
    font_draw(&font_small, line, 14, 9, RAMP_FG_SURFACE);
    if (bookmarked)
        ui_draw_bookmark(14 + text_w + 6, 11);
}

/*
 * What the next press does, drawn across the bottom of the screen at the end
 * of an image: the next image, the next strip by its title, or nothing more.
 */
static void draw_prompt(const view_t *view, uint16_t next_strip) {
    int y = GFX_LCD_HEIGHT - PROMPT_HEIGHT;

    gfx_SetColor(UI_SURFACE);
    gfx_FillRectangle_NoClip(0, y, GFX_LCD_WIDTH, PROMPT_HEIGHT);
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(0, y, GFX_LCD_WIDTH, 2);
    ui_draw_down_arrow(UI_MARGIN, y + 7);

    char line[32];
    int x = UI_MARGIN + 18;
    if (view->part + 1 < view->strip->part_count) {
        sprintf(line, "Part %u of %u", view->part + 2, view->strip->part_count);
        font_draw(&font_body, line, x, y + 3, RAMP_FG_SURFACE);
        font_draw_right(&font_small, "press down", GFX_LCD_WIDTH - UI_MARGIN, y + 5,
                        RAMP_DIM_SURFACE);
    } else if (next_strip != LIB_NONE) {
        x = font_draw(&font_body, "Next:", x, y + 3, RAMP_ACCENT_SURFACE);
        lib_strip_t next;
        lib_get_strip(next_strip, &next);
        ui_draw_title(next.title, x + 6, y + 2, RAMP_FG_SURFACE);
    } else {
        font_draw(&font_body, "End of book", x, y + 3, RAMP_DIM_SURFACE);
    }
}

view_result_t viewer_run(uint16_t strip_index) {
    lib_strip_t entry;
    lib_get_strip(strip_index, &entry);

    csx_strip_t strip;
    if (!csx_open(&strip, entry.slot)) {
        ui_message("Cannot open this strip.", "Re-sync it from the computer.");
        return VIEW_FAILED;
    }

    /* The strip after this one in its book, if there is one: what pressing on
     * past the end of the last image opens. */
    uint16_t next_strip = LIB_NONE;
    uint16_t book_index = lib_book_of(strip_index);
    if (book_index != LIB_NONE) {
        lib_book_t book;
        lib_get_book(book_index, &book);
        if (strip_index + 1 < book.strip_first + book.strip_count)
            next_strip = strip_index + 1;
    }

    render_reset();
    render_set_palette(&strip);
    ui_set_chrome_palette();

    view_t view = { &strip, entry.layer, 0, 0, entry.pos };
    if (view.layer >= strip.layer_count)
        view.layer = 0;
    if (view.vy >= strip.layer[view.layer].height)
        view.vy = 0;
    view.part = csx_part_at(&strip, view.layer, view.vy);
    clamp(&view);

    bool marked_read = (entry.flags & LIB_FLAG_READ) != 0;
    bool bookmarked = (entry.flags & LIB_FLAG_BOOKMARK) != 0;
    bool dirty = true;
    unsigned overlay = OVERLAY_FRAMES;
    view_result_t result = VIEW_BACK;

    input_reset();
    for (;;) {
        if (dirty) {
            render_view(&strip, view.layer, view.vx, view.vy, part_bottom(&view));
            if (at_part_end(&view))
                draw_prompt(&view, next_strip);
            if (overlay)
                draw_overlay(&view, marked_read, bookmarked);
            gfx_SwapDraw();
            dirty = false;
        }

        input_scan();

        /* 2nd+ON reaches the viewer too. The lock puts palette entries 0-15
         * back the way it found them, so the strip only needs drawing again. */
        if (lock_poll()) {
            dirty = true;
            overlay = OVERLAY_FRAMES;
        }

        /*
         * Where the view was before this frame's keys, because that is what
         * decides whether a press goes on to the next image: only a press made
         * while the bar was already showing does.
         */
        bool was_at_end = at_part_end(&view);
        bool was_at_start = at_part_start(&view);
        bool acted = false;

        bool onward = input_pressed(kb_KeyDown) || input_pressed(kb_Key2)
                      || input_pressed(kb_KeyEnter);
        bool backward = input_pressed(kb_KeyUp) || input_pressed(kb_Key8);

        if (onward && was_at_end) {
            if (view.part + 1 < strip.part_count) {
                go_part(&view, view.part + 1, false);
                input_claim(kb_KeyDown);
                acted = true;
            } else if (next_strip != LIB_NONE) {
                result = VIEW_NEXT;
                break;
            }
        } else if (backward && was_at_start && view.part > 0) {
            go_part(&view, view.part - 1, true);
            input_claim(kb_KeyUp);
            acted = true;
        } else if (input_pressed(kb_Key2) || input_pressed(kb_KeyEnter)) {
            pan(&view, 0, PAGE_STEP);
            acted = true;
        } else if (input_pressed(kb_Key8)) {
            pan(&view, 0, -PAGE_STEP);
            acted = true;
        } else {
            unsigned held = input_held_frames();
            int step = PAN_STEP_SLOW;
            if (held >= PAN_ACCEL_FAST)
                step = PAN_STEP_FAST;
            else if (held >= PAN_ACCEL_MED)
                step = PAN_STEP_MED;

            if (input_repeat(kb_KeyDown)) { pan(&view, 0, step); acted = true; }
            else if (input_repeat(kb_KeyUp)) { pan(&view, 0, -step); acted = true; }
            else if (input_repeat(kb_KeyRight)) { pan(&view, step, 0); acted = true; }
            else if (input_repeat(kb_KeyLeft)) { pan(&view, -step, 0); acted = true; }
        }

        if (input_pressed(kb_KeyAdd)) {
            set_layer(&view, view.layer + 1);
            acted = true;
        } else if (input_pressed(kb_KeySub)) {
            if (view.layer)
                set_layer(&view, view.layer - 1);
            acted = true;
        } else if (input_pressed(kb_KeyMode)) {
            set_layer(&view, view.layer ? 0 : (uint8_t)(strip.layer_count - 1));
            acted = true;
        }

        if (input_pressed(kb_KeyDel)) {
            marked_read = !marked_read;
            acted = true;
        }
        if (input_pressed(kb_KeyAlpha)) {
            bookmarked = !bookmarked;
            acted = true;
        }

        if (!marked_read && at_end(&view))
            marked_read = true;

        if (acted) {
            overlay = OVERLAY_FRAMES;
            dirty = true;
        } else if (overlay) {
            if (--overlay == 0)
                dirty = true;
        }

        if (input_pressed(kb_KeyClear))
            break;
    }

    /* Persist where we got to. The index lives in the archive, so this is a
     * flash write -- hence once on the way out, never while scrolling. Going on
     * to the next strip means this one was finished, so it is read, and it
     * starts from the top if it is opened again. */
    entry.pos = result == VIEW_NEXT ? 0 : view.vy;
    entry.layer = view.layer;
    if (result == VIEW_NEXT)
        marked_read = true;
    if (marked_read && !(entry.flags & LIB_FLAG_READ))
        entry.read_at = lib_now();
    entry.flags = marked_read ? (uint8_t)(entry.flags | LIB_FLAG_READ)
                              : (uint8_t)(entry.flags & ~LIB_FLAG_READ);
    entry.flags = bookmarked ? (uint8_t)(entry.flags | LIB_FLAG_BOOKMARK)
                             : (uint8_t)(entry.flags & ~LIB_FLAG_BOOKMARK);
    lib_save_strip_as_last(strip_index, &entry);

    render_reset();
    return result;
}
