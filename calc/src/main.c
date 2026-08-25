/*
 * eBookSync reader for the TI-84 Plus CE.
 *
 * Comics are converted on a computer into .csx containers (see docs/FORMAT.md)
 * and pushed over USB by the sync app; this program lists what arrived, reads
 * it, and remembers where you got to.
 */

#include "input.h"
#include "library.h"
#include "proto.h"
#include "render.h"
#include "ui.h"
#include "viewer.h"

#include <graphx.h>
#include <tice.h>

int main(void) {
    gfx_Begin();
    gfx_SetDrawBuffer();
    ui_set_chrome_palette();
    input_reset();

    if (!render_init()) {
        ui_message("Not enough free memory.", "Archive or delete some files.");
        gfx_End();
        return 1;
    }

    /*
     * An empty calculator is the normal state before the first sync, not an
     * error. Quitting here would also make the reader impossible to use at all:
     * the sync screen is reached with 2nd from the book menu, so bailing out
     * before showing that menu means no comic can ever arrive.
     */
    lib_open();

    uint16_t book = 0;
    for (;;) {
        ui_result_t result = ui_book_menu(&book);
        if (result == UI_BACK)
            break;
        if (result == UI_SYNC) {
            /* The band cache is the biggest thing in RAM and sync needs room to
             * build variables before archiving them, so hand it back first. */
            render_free();
            ui_sync_screen();
            lib_open();
            if (!render_init()) {
                ui_message("Not enough free memory.", "Archive or delete some files.");
                break;
            }
            book = 0;
            continue;
        }

        for (;;) {
            uint16_t strip;
            if (ui_strip_menu(book, &strip) != UI_CHOSE)
                break;
            viewer_run(strip);
            ui_set_chrome_palette();
        }
    }

    render_free();
    gfx_End();
    return 0;
}
