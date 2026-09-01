/*
 * eBookSync updater.
 *
 * The one job: replace prgmCOMICS with the build the sync page pushed. It exists
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
#include <stdbool.h>
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

/*
 * Install one target. Returns false if it was armed and could not be done.
 *
 * Verified again here, and not only when it arrived. The chunks have been
 * sitting in the archive since the sync -- through however many garbage
 * collects and however many other programs -- and this is the last moment at
 * which finding them damaged costs nothing. A moment later the program they
 * replace is already gone.
 */
static bool install(uint8_t target, uint8_t row) {
    update_manifest_t manifest;
    if (!update_pending(target, &manifest))
        return true;               /* nothing armed for this one */

    const char *name = update_target_name(target);
    if (!name)
        return true;

    char line[27];
    sprintf(line, "%s: build %u...", name, manifest.build);
    say(row, line);

    if (!update_verify(&manifest)) {
        update_discard(target);
        sprintf(line, "%s: damaged, dropped.", name);
        say(row, line);
        return false;
    }

    if (!update_install(name, &manifest)) {
        sprintf(line, "%s: no room.", name);
        say(row, line);
        return false;
    }

    /* Only now, with the new program safely in place. */
    update_discard(target);
    sprintf(line, "%s: build %u done.", name, manifest.build);
    say(row, line);
    return true;
}

int main(void) {
    os_ClrHome();
    say(0, "eBookSync updater");

    update_manifest_t manifest;
    if (!update_pending(UPDATE_TARGET_READER, &manifest)) {
        say(2, "Nothing to install.");
        say(4, "Sync first, then run this.");
        wait_for_key();
        return 0;
    }

    bool ok = install(UPDATE_TARGET_READER, 2);

    say(4, ok ? "Run COMICS." : "Sync again to retry.");
    wait_for_key();
    return ok ? 0 : 1;
}
