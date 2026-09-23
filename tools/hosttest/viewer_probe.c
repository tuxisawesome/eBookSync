/*
 * Drives the reader's real strip viewer on the host.
 *
 * Links calc/src/viewer.c with the renderer, the container parser and the
 * index, loads a library from a directory of appvars, and feeds viewer_run()
 * a scripted sequence of keypresses. What comes back is how it ended and what
 * it saved -- position, layer, flags and the strip recorded as last read --
 * which is everything the viewer's paging, parts and bookmarks decide.
 *
 *   viewer_probe --lib DIR <strip-index> key[:frames] ...
 *
 * With SHIM_TEXT set the text it draws is logged too, which is how the bar at
 * the bottom of an image is checked.
 */

#include "keys.h"
#include "library.h"
#include "render.h"
#include "shim.h"
#include "viewer.h"

#include <dirent.h>
#include <stdlib.h>
#include <string.h>

uint8_t *read_appvar(const char *path, char *name, size_t *size);

/* ui.c is linked for its drawing helpers, and it reaches the sync screen. */
typedef bool (*proto_progress_t)(const char *, uint8_t, uint8_t, uint8_t);
bool proto_run(proto_progress_t progress, bool echo_only) {
    (void)progress;
    (void)echo_only;
    return true;
}
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
    { "mode", kb_KeyMode }, { "del", kb_KeyDel }, { "add", kb_KeyAdd },
    { "sub", kb_KeySub }, { "alpha", kb_KeyAlpha }, { "2", kb_Key2 },
    { "8", kb_Key8 }, { "idle", 0 },
};

static kb_lkey_t lookup(const char *name) {
    for (size_t i = 0; i < sizeof KEYS / sizeof *KEYS; i++) {
        if (strcmp(KEYS[i].name, name) == 0) return KEYS[i].key;
    }
    fprintf(stderr, "unknown key \"%s\"\n", name);
    exit(2);
}

static int load_directory(const char *path) {
    DIR *dir = opendir(path);
    if (!dir) {
        fprintf(stderr, "cannot read %s\n", path);
        return 0;
    }
    int loaded = 0;
    for (struct dirent *entry; (entry = readdir(dir)); ) {
        const char *dot = strrchr(entry->d_name, '.');
        if (!dot || strcmp(dot, ".8xv") != 0)
            continue;

        char full[4096];
        snprintf(full, sizeof full, "%s/%s", path, entry->d_name);
        char name[9];
        size_t size;
        uint8_t *data = read_appvar(full, name, &size);
        if (data) {
            shim_add_var(name, data, size);
            free(data);
            loaded++;
        }
    }
    closedir(dir);
    return loaded;
}

int main(int argc, char **argv) {
    if (argc < 4 || strcmp(argv[1], "--lib") != 0) {
        fprintf(stderr, "usage: viewer_probe --lib DIR <strip-index> key[:frames] ...\n");
        return 2;
    }
    shim_keys_clear();
    if (!load_directory(argv[2]))
        return 2;
    uint16_t index = (uint16_t)atoi(argv[3]);

    /* A quiet moment first. input_reset() treats whatever is held when the
     * viewer opens as already down -- the enter that opened the strip is not a
     * page turn -- so a script that pressed on its very first frame would lose
     * that press, as a person never could. */
    shim_keys_add(0, 5);

    for (int arg = 4; arg < argc; arg++) {
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
        shim_keys_add(lookup(name), frames);
        if (!colon) shim_keys_add(0, 1);
    }
    /* However the script ends, clear then leaves: a viewer still running when
     * the keys run out would otherwise never report what it saved. */
    shim_keys_add(0, 4);
    shim_keys_add(kb_KeyClear, 4);

    if (!lib_open() || !render_init()) {
        fprintf(stderr, "no library, or no memory for the band cache\n");
        return 1;
    }

    view_result_t result = viewer_run(index);
    static const char *const NAMES[] = { "back", "next", "failed" };
    printf("result %s\n", NAMES[result]);

    lib_open();
    lib_strip_t strip;
    lib_get_strip(index, &strip);
    printf("saved pos %u layer %u read %u bookmark %u\n", (unsigned)strip.pos,
           strip.layer, (strip.flags & LIB_FLAG_READ) ? 1 : 0,
           (strip.flags & LIB_FLAG_BOOKMARK) ? 1 : 0);
    uint16_t last = lib_last_strip();
    if (last == LIB_NONE)
        printf("last none\n");
    else
        printf("last %u\n", last);

    render_free();
    return 0;
}
