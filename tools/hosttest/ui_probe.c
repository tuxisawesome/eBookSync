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

#include <ti/flags.h>

#include <dirent.h>
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
uint24_t proto_bytes(void) { return 0; }
uint8_t proto_library_state(void) { return 0; }
uint8_t proto_collections(void) { return 0; }

static const struct { const char *name; kb_lkey_t key; } KEYS[] = {
    { "up", kb_KeyUp }, { "down", kb_KeyDown }, { "left", kb_KeyLeft },
    { "right", kb_KeyRight }, { "enter", kb_KeyEnter }, { "clear", kb_KeyClear },
    { "2nd", kb_Key2nd }, { "mode", kb_KeyMode }, { "del", kb_KeyDel },
    { "add", kb_KeyAdd }, { "sub", kb_KeySub }, { "idle", 0 },
    { "on", kb_KeyOn },

    /* Enough of the keypad to type. keyin.c reads the letters printed on the
     * keys, so "math" types A, "1" types Y, and so on. */
    { "alpha", kb_KeyAlpha }, { "yequ", kb_KeyYequ },
    { "0", kb_Key0 }, { "1", kb_Key1 }, { "2", kb_Key2 }, { "3", kb_Key3 },
    { "4", kb_Key4 }, { "5", kb_Key5 }, { "6", kb_Key6 }, { "7", kb_Key7 },
    { "8", kb_Key8 }, { "9", kb_Key9 },
    { "math", kb_KeyMath }, { "apps", kb_KeyApps }, { "prgm", kb_KeyPrgm },
    { "sin", kb_KeySin }, { "cos", kb_KeyCos }, { "tan", kb_KeyTan },
    { "ln", kb_KeyLn }, { "log", kb_KeyLog }, { "sto", kb_KeySto },
    { "square", kb_KeySquare }, { "recip", kb_KeyRecip },
    { "comma", kb_KeyComma }, { "decpnt", kb_KeyDecPnt }, { "chs", kb_KeyChs },
    { "lparen", kb_KeyLParen }, { "rparen", kb_KeyRParen },
    { "mul", kb_KeyMul }, { "div", kb_KeyDiv }, { "power", kb_KeyPower },
};

/*
 * Whether the reader ever asked the OS to power the calculator down.
 *
 * Only the lock screen does, so this is how a test tells "it locked" from "it
 * drew something that looked like a lock". Printed from atexit because the
 * interesting cases are the ones where the reader never returns -- a lock that
 * holds is a program still running when the script runs out.
 */
static void report(void) {
    printf("apd %d\n", (os_Flags[OS_FLAGS_APD] >> OS_FLAGS_APD_RUNNING) & 1);
}

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
        /* Every .8xv in the directory, not just the index: the reader's screens
         * read the chat appvars too, and a screen tested without them is a
         * screen tested in a state that cannot occur. */
        DIR *dir = opendir(argv[arg + 1]);
        if (!dir) {
            fprintf(stderr, "cannot read %s\n", argv[arg + 1]);
            return 2;
        }
        for (struct dirent *entry; (entry = readdir(dir)); ) {
            const char *dot = strrchr(entry->d_name, '.');
            if (!dot || strcmp(dot, ".8xv") != 0)
                continue;

            char path[4096];
            snprintf(path, sizeof path, "%s/%s", argv[arg + 1], entry->d_name);

            char name[9];
            size_t size;
            uint8_t *data = read_appvar(path, name, &size);
            if (data) {
                shim_add_var(name, data, size);
                free(data);
            }
        }
        closedir(dir);
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

        /*
         * "a+b" holds both at once, which is the only way to script a chord --
         * and 2nd+ON, the lock combination, is one.
         */
        kb_lkey_t keys[4];
        int count = 0;
        for (char *part = strtok(name, "+"); part && count < 4;
             part = strtok(NULL, "+")) {
            keys[count++] = lookup(part);
        }

        /* A key has to come up before it can go down again, so every press is
         * followed by an idle frame unless the caller asked to hold it. */
        shim_keys_add_many(keys, count, frames);
        if (!colon) shim_keys_add(0, 1);
    }

    atexit(report);

    int result = reader_main();
    printf("returned %d after %ld scans\n", result, shim_scan_count());
    return 0;
}
