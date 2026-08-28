/*
 * Runs the reader's real sync loop against the wire model.
 *
 * Reads request packets on stdin, writes reply packets on stdout, and drives
 * calc/src/usb.c's proto_run() -- the actual scheduling loop, the actual
 * command handlers, the actual appvar writes. tools/hosttest/check_usb.mjs
 * puts the real web/js/usb.js on the other end of the pipe.
 *
 *   usb_probe [--lib DIR]
 */

#include "proto.h"
#include "fileioc.h"
#include "library.h"
#include "usbdrvce.h"

#include <dirent.h>
#include <stdlib.h>
#include <string.h>

uint8_t *read_appvar(const char *path, char *name, size_t *size);

/* proto_run calls this between requests; the reader draws a screen here. */
static bool progress(const char *state, uint8_t slot, uint8_t chunk, uint8_t count) {
    (void)slot;
    (void)chunk;
    (void)count;
    (void)state;
    /* Stop once the computer has hung up and nothing is left to read. */
    return !wire_out_drained();
}

int main(int argc, char **argv) {
    wire_reset();

    /*
     * Load every .8xv in the directory, not just the index. A strip is an index
     * entry plus its chunk appvars, and a test that seeds only the first is
     * testing a calculator that cannot exist.
     */
    if (argc >= 3 && strcmp(argv[1], "--lib") == 0) {
        DIR *dir = opendir(argv[2]);
        for (struct dirent *entry; dir && (entry = readdir(dir)); ) {
            const char *dot = strrchr(entry->d_name, '.');
            if (!dot || strcmp(dot, ".8xv") != 0)
                continue;

            char path[4096];
            snprintf(path, sizeof path, "%s/%s", argv[2], entry->d_name);

            char name[9];
            size_t size;
            uint8_t *data = read_appvar(path, name, &size);
            if (data) {
                shim_add_var(name, data, size);
                free(data);
            }
        }
        if (dir)
            closedir(dir);
    }

    /* main.c maps the index at startup, before ever reaching the sync screen,
     * and LIST reports what it found. Do the same here. */
    lib_open();

    /*
     * With --gc, the next archive triggers a defragment. The OS does that
     * whenever it runs out of room, it asks the user first so it takes as long
     * as it takes, and it moves every archived variable -- which invalidates
     * every pointer the reader is holding.
     */
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--gc") == 0)
            shim_force_gc();
    }

    bool ok = proto_run(progress, false);

    /*
     * With --save, write every variable out as <dir>/<NAME>.bin.
     *
     * A reply only ever says "OK". What a command actually left in flash --
     * whether INDEX_PUT carried the device block across, whether a chunk landed
     * whole -- is invisible from the wire, and this is the only way to look.
     */
    const char *save = NULL;
    for (int i = 1; i + 1 < argc; i++) {
        if (strcmp(argv[i], "--save") == 0)
            save = argv[i + 1];
    }
    if (save) {
        const char *name;
        const uint8_t *data;
        size_t size;
        for (int i = 0; shim_var_at(i, &name, &data, &size); i++) {
            char path[4096];
            snprintf(path, sizeof path, "%s/%s.bin", save, name);
            FILE *file = fopen(path, "wb");
            if (!file)
                continue;
            fwrite(data, 1, size, file);
            fclose(file);
        }
    }

    fprintf(stderr, "proto_run returned %d, overflows %d, os calls %u\n",
            ok, wire_overflows(), shim_os_calls());
    return wire_overflows() ? 1 : 0;
}
