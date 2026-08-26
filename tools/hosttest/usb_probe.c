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
#include "library.h"
#include "usbdrvce.h"

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

    if (argc >= 3 && strcmp(argv[1], "--lib") == 0) {
        char path[4096];
        snprintf(path, sizeof path, "%s/CSLIB.8xv", argv[2]);

        char name[9];
        size_t size;
        uint8_t *data = read_appvar(path, name, &size);
        if (data) {
            shim_add_var(name, data, size);
            free(data);
        }
    }

    /* main.c maps the index at startup, before ever reaching the sync screen,
     * and LIST reports what it found. Do the same here. */
    lib_open();

    bool ok = proto_run(progress, false);

    fprintf(stderr, "proto_run returned %d, overflows %d\n", ok, wire_overflows());
    return wire_overflows() ? 1 : 0;
}
