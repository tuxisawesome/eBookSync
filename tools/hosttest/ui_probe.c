/*
 * Drives the reader's real menu loop on the host.
 *
 * Links calc/src/main.c, ui.c, input.c and library.c against the shim, feeds a
 * scripted sequence of keypresses, and reports whether main() returned. That is
 * the difference between "the app closed" and "the app is still up", which is
 * otherwise only observable on hardware.
 *
 *   ui_probe [--lib DIR] key[:frames] ...
 *
 * Exit status: 0 if main() returned (the app closed), 7 if it was still running
 * when the script ran out, 2 on a usage error.
 */

#include "keys.h"
#include "library.h"
#include "shim.h"

#include <stdlib.h>
#include <string.h>

uint8_t *read_appvar(const char *path, char *name, size_t *size);

/* calc/src/main.c is compiled with -Dmain=reader_main so this file can own the
 * real entry point. */
int reader_main(void);

/* main.c reaches these; neither is what this probe is about. */
bool viewer_run(uint16_t strip_index) {
    printf("viewer %u\n", strip_index);
    return true;
}

typedef bool (*proto_progress_t)(const char *, uint8_t, uint8_t, uint8_t);
bool proto_run(proto_progress_t progress, bool echo_only) {
    (void)echo_only;
    printf("sync\n");
    if (progress) progress("Waiting for computer", 0, 0, 0);
    return true;
}

/* The sync screen displays these; the protocol itself is check_usb.mjs's job. */
uint16_t proto_requests(void) { return 0; }
uint8_t proto_last_command(void) { return 0; }
uint16_t proto_errors(void) { return 0; }
uint8_t proto_open_error(void) { return 0; }
uint24_t proto_loops(void) { return 0; }

static const struct { const char *name; kb_lkey_t key; } KEYS[] = {
    { "up", kb_KeyUp }, { "down", kb_KeyDown }, { "left", kb_KeyLeft },
    { "right", kb_KeyRight }, { "enter", kb_KeyEnter }, { "clear", kb_KeyClear },
    { "2nd", kb_Key2nd }, { "mode", kb_KeyMode }, { "del", kb_KeyDel },
    { "add", kb_KeyAdd }, { "sub", kb_KeySub }, { "idle", 0 },
};

static kb_lkey_t lookup(const char *name) {
    for (size_t i = 0; i < sizeof KEYS / sizeof *KEYS; i++) {
        if (strcmp(KEYS[i].name, name) == 0) return KEYS[i].key;
    }
    fprintf(stderr, "unknown key \"%s\"\n", name);
    exit(2);
}

int main(int argc, char **argv) {
    shim_keys_clear();

    int arg = 1;
    if (arg + 1 < argc && strcmp(argv[arg], "--lib") == 0) {
        char path[4096];
        snprintf(path, sizeof path, "%s/CSLIB.8xv", argv[arg + 1]);

        char name[9];
        size_t size;
        uint8_t *data = read_appvar(path, name, &size);
        if (!data) {
            fprintf(stderr, "cannot read %s\n", path);
            return 2;
        }
        shim_add_var(name, data, size);
        free(data);
        arg += 2;
    }

    for (; arg < argc; arg++) {
        char name[32];
        int frames = 1;
        const char *colon = strchr(argv[arg], ':');
        if (colon) {
            size_t length = (size_t)(colon - argv[arg]);
            if (length >= sizeof name) return 2;
            memcpy(name, argv[arg], length);
            name[length] = '\0';
            frames = atoi(colon + 1);
        } else {
            snprintf(name, sizeof name, "%s", argv[arg]);
        }

        /* A key has to come up before it can go down again, so every press is
         * followed by an idle frame unless the caller asked to hold it. */
        shim_keys_add(lookup(name), frames);
        if (!colon) shim_keys_add(0, 1);
    }

    int result = reader_main();
    printf("returned %d after %ld scans\n", result, shim_scan_count());
    return 0;
}
