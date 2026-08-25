/*
 * Reading a strip: pan, zoom, and remember where you were.
 *
 * The viewport is held in the coordinates of the current layer. Zooming keeps
 * whatever is in the middle of the screen in the middle of the screen by
 * rescaling the viewport between the two layers' coordinate spaces.
 */

#include "viewer.h"

#include "csx.h"
#include "input.h"
#include "library.h"
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

/* Frames the position overlay stays up after the last keypress. */
#define OVERLAY_FRAMES  60

/* Scrolling this far marks the strip read. */
#define READ_THRESHOLD_NUM 95
#define READ_THRESHOLD_DEN 100

typedef struct {
    const csx_strip_t *strip;
    uint8_t layer;
    uint24_t vx, vy;
} view_t;

static uint24_t max_scroll(uint24_t content, uint24_t window) {
    return content > window ? content - window : 0;
}

static void clamp(view_t *view) {
    const csx_layer_t *layer = &view->strip->layer[view->layer];
    uint24_t max_x = max_scroll(layer->width, GFX_LCD_WIDTH);
    uint24_t max_y = max_scroll(layer->height, GFX_LCD_HEIGHT);
    if (view->vx > max_x)
        view->vx = max_x;
    if (view->vy > max_y)
        view->vy = max_y;
}

static void pan(view_t *view, int dx, int dy) {
    const csx_layer_t *layer = &view->strip->layer[view->layer];
    uint24_t max_x = max_scroll(layer->width, GFX_LCD_WIDTH);
    uint24_t max_y = max_scroll(layer->height, GFX_LCD_HEIGHT);

    if (dx < 0)
        view->vx = (uint24_t)(-dx) > view->vx ? 0 : view->vx + dx;
    else if (dx > 0)
        view->vx = view->vx + dx > max_x ? max_x : view->vx + dx;

    if (dy < 0)
        view->vy = (uint24_t)(-dy) > view->vy ? 0 : view->vy + dy;
    else if (dy > 0)
        view->vy = view->vy + dy > max_y ? max_y : view->vy + dy;
}

/* Move to another layer, keeping the centre of the screen fixed. Widths are
 * used for the ratio rather than heights: they are small enough that the
 * multiply cannot overflow. */
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
    return (unsigned)((uint32_t)view->vy * 100 / span);
}

static bool at_end(const view_t *view) {
    const csx_layer_t *layer = &view->strip->layer[view->layer];
    uint32_t seen = (uint32_t)view->vy + GFX_LCD_HEIGHT;
    return seen * READ_THRESHOLD_DEN >= (uint32_t)layer->height * READ_THRESHOLD_NUM;
}

static void draw_overlay(const view_t *view, bool marked_read) {
    const csx_layer_t *layer = &view->strip->layer[view->layer];
    uint24_t span = max_scroll(layer->height, GFX_LCD_HEIGHT);

    int track = GFX_LCD_HEIGHT;
    int thumb = span ? (int)((uint32_t)GFX_LCD_HEIGHT * GFX_LCD_HEIGHT / layer->height) : track;
    if (thumb < 10)
        thumb = 10;
    int offset = span ? (int)((uint32_t)(track - thumb) * view->vy / span) : 0;

    gfx_SetColor(UI_DIM);
    gfx_FillRectangle_NoClip(GFX_LCD_WIDTH - 4, 0, 4, GFX_LCD_HEIGHT);
    gfx_SetColor(UI_ACCENT);
    gfx_FillRectangle_NoClip(GFX_LCD_WIDTH - 4, offset, 4, thumb);

    /* Zoom relative to the fit-width layer, to one decimal: the 480px layer is
     * 1.5x, and integer division by the screen width would call it 1x. */
    unsigned zoom = (unsigned)layer->width * 10 / view->strip->layer[0].width;

    char line[24];
    sprintf(line, "%u.%ux %u%%%s", zoom / 10, zoom % 10,
            progress_percent(view), marked_read ? " read" : "");

    gfx_SetColor(UI_BG);
    gfx_FillRectangle_NoClip(0, 0, (int)strlen(line) * 8 + 8, 14);
    gfx_SetTextFGColor(UI_FG);
    gfx_SetTextBGColor(UI_BG);
    gfx_PrintStringXY(line, 4, 3);
}

bool viewer_run(uint16_t strip_index) {
    lib_strip_t entry;
    lib_get_strip(strip_index, &entry);

    csx_strip_t strip;
    if (!csx_open(&strip, entry.slot)) {
        ui_message("Cannot open this strip.", "Re-sync it from the computer.");
        return false;
    }

    render_reset();
    render_set_palette(&strip);
    ui_set_chrome_palette();

    view_t view = { &strip, entry.layer, 0, entry.pos };
    if (view.layer >= strip.layer_count)
        view.layer = 0;
    clamp(&view);

    bool marked_read = (entry.flags & LIB_FLAG_READ) != 0;
    bool dirty = true;
    unsigned overlay = OVERLAY_FRAMES;

    input_reset();
    for (;;) {
        if (dirty) {
            render_view(&strip, view.layer, view.vx, view.vy);
            if (overlay)
                draw_overlay(&view, marked_read);
            gfx_SwapDraw();
            dirty = false;
        }

        input_scan();

        unsigned held = input_held_frames();
        int step = PAN_STEP_SLOW;
        if (held >= PAN_ACCEL_FAST)
            step = PAN_STEP_FAST;
        else if (held >= PAN_ACCEL_MED)
            step = PAN_STEP_MED;

        bool acted = false;
        if (input_repeat(kb_KeyDown)) { pan(&view, 0, step); acted = true; }
        else if (input_repeat(kb_KeyUp)) { pan(&view, 0, -step); acted = true; }
        else if (input_repeat(kb_KeyRight)) { pan(&view, step, 0); acted = true; }
        else if (input_repeat(kb_KeyLeft)) { pan(&view, -step, 0); acted = true; }

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
     * flash write -- hence once on the way out, never while scrolling. */
    entry.pos = view.vy;
    entry.layer = view.layer;
    if (marked_read && !(entry.flags & LIB_FLAG_READ))
        entry.read_at = (uint32_t)time(NULL);
    entry.flags = marked_read ? (uint8_t)(entry.flags | LIB_FLAG_READ)
                              : (uint8_t)(entry.flags & ~LIB_FLAG_READ);
    lib_save_strip(strip_index, &entry);

    render_reset();
    return true;
}
