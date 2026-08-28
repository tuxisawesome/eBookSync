/*
 * eOS updater.
 *
 * The one job: replace prgmEOS with the build the sync page pushed. It exists
 * because a CE program runs in place inside its own variable and so cannot
 * overwrite itself -- see calc/src/update.h for the two-program arrangement
 * this is one half of.
 *
 * It runs on the homescreen with no graphx, and shares only the manifest and
 * chunk handling with the reader, so there is one implementation of the format
 * rather than two that can drift.
 *
 * The reader installs this program, so an updater that turns out to be wrong
 * can still be fixed over the link. It should nonetheless change as rarely as
 * anything in this repository.
 */

#include "update.h"

#include <fileioc.h>
#include <stdio.h>
#include <tice.h>

static void say(uint8_t row, const char *text) {
    os_SetCursorPos(row, 0);
    os_PutStrFull(text);
}

static void wait_for_key(void) {
    while (os_GetCSC())
        ;
    while (!os_GetCSC())
        ;
}

int main(void) {
    os_ClrHome();
    say(0, "eOS updater");

    update_manifest_t manifest;
    if (!update_pending(&manifest) || manifest.target != UPDATE_TARGET_READER) {
        say(2, "Nothing to install.");
        say(4, "Sync first, then run this.");
        wait_for_key();
        return 0;
    }

    char line[27];
    sprintf(line, "Installing build %u...", manifest.build);
    say(2, line);

    /*
     * Checked again here, and not only when it arrived. The chunks have been
     * sitting in the archive since the sync -- through however many garbage
     * collects and however many other programs -- and this is the last moment
     * at which finding them damaged costs nothing. A moment later prgmEOS is
     * already gone.
     */
    if (!update_verify(&manifest)) {
        update_discard();
        say(4, "The update was damaged.");
        say(5, "It has been discarded.");
        say(7, "Sync again to retry.");
        wait_for_key();
        return 1;
    }

    if (!update_install(UPDATE_READER_NAME, &manifest)) {
        say(4, "Could not install it.");
        say(5, "Free some archive space");
        say(6, "and run this again.");
        wait_for_key();
        return 1;
    }

    /* Only now, with the new reader safely in place. */
    update_discard();

    sprintf(line, "Updated to build %u.", manifest.build);
    say(4, line);
    say(6, "Run prgmEOS.");
    wait_for_key();
    return 0;
}
