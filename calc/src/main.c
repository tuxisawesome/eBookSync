/*
 * eBookSync for the TI-84 Plus CE.
 *
 * Comics are converted on a computer into .csx containers (see docs/FORMAT.md)
 * and pushed over USB by the sync page; this program lists what arrived, reads
 * it, and remembers where you got to.
 */

#include "input.h"
#include "library.h"
#include "proto.h"
#include "render.h"
#include "update.h"
#include "ui.h"
#include "viewer.h"
#include "wall.h"

#include <fileioc.h>
#include <stdio.h>
#include <graphx.h>
#include <tice.h>

int main(void) {
    gfx_Begin();
    gfx_SetDrawBuffer();
    ui_set_chrome_palette();
    input_reset();

    /* The handlers live in ui.c because they have to be re-installed after a
     * sync as well as installed here; see ui_install_gc(). */
    ui_install_gc();

    /*
     * An empty calculator is the normal state before the first sync, not an
     * error. Quitting here would also make the reader impossible to use at all:
     * the sync screen is reached with 2nd from the book menu, so bailing out
     * before showing that menu means no comic can ever arrive.
     *
     * It happens here, before anything else, because the password is in the
     * index -- and the lock screen comes before render_init because the band
     * cache is the biggest allocation in this program and there is no reason to
     * take it for a prompt someone may not get past.
     */
    lib_open();

    /*
     * A wallpaper the index does not vouch for is wreckage: either somebody
     * deleted CSLIB to get past the prompt, or a sync died between storing the
     * wallpaper and recording it. Either way nothing is left that can say what
     * those bytes are, so they go -- before the prompt, so a deleted index
     * cannot even show the owner's wallpaper on the way past.
     */
    wall_sweep();

    if (!ui_password_gate()) {
        gfx_End();
        return 0;
    }

    if (!render_init()) {
        ui_message("Not enough free memory.", "Archive or delete some files.");
        gfx_End();
        return 1;
    }

    /*
     * A calculator that ran the eOS naming is still holding that library --
     * typically megabytes of it -- under names nothing here will ever read
     * again. Offer to reclaim it once; nothing else ever does, and the archive
     * is the whole budget.
     */
    if (lib_has_legacy()
        && ui_confirm("Old eOS comics are using", "space. Delete them?")) {
        ui_notice("Deleting old comics...", "This takes a moment.");
        uint16_t gone = lib_sweep_legacy();

        char message[40];
        sprintf(message, "Removed %u old file(s).", gone);
        ui_message(message, "Sync to refill the library.");
    }

    /*
     * A reader update cannot install itself -- this program is running from the
     * variable it would have to replace -- so prgmCSUP does it. Say so on the
     * way in, because a downloaded update that nobody knows about is the same
     * as no update at all.
     */
    update_manifest_t update;
    if (update_pending(&update) && update.target == UPDATE_TARGET_READER) {
        char line[40];
        sprintf(line, "Update ready: build %u.", update.build);
        ui_message(line, "Quit and run prgmCSUP.");
    }

    uint16_t book = 0;
    for (;;) {
        ui_result_t result = ui_book_menu(&book);
        if (result == UI_BACK)
            break;
        if (result == UI_SETUP) {
            ui_setup_screen();
            lib_open();
            book = 0;
            continue;
        }

        if (result == UI_SYNC) {
            /* The band cache is the biggest thing in RAM and sync needs room to
             * build variables before archiving them, so hand it back first. */
            render_free();
            ui_sync_run(false);
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
    ti_SetGCBehavior(NULL, NULL);
    gfx_End();
    return 0;
}
