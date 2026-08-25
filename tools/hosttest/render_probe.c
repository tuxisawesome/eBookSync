/*
 * Drives the real calculator renderer on the host.
 *
 * Reads a directory of .8xv chunk files, opens the strip through csx.c, renders
 * viewports through render.c, and writes each resulting 320x240 frame of
 * palette indices to stdout. tools/hosttest/check.py compares those bytes with
 * what the Python decoder produces for the same viewport.
 *
 *   render_probe <chunk-dir> <slot> [layer,vx,vy ...]
 */

#include "csx.h"
#include "graphx.h"
#include "render.h"

#include <dirent.h>
#include <stdlib.h>
#include <string.h>

uint8_t *read_appvar(const char *path, char *name, size_t *size);

static int load_directory(const char *path) {
    DIR *dir = opendir(path);
    if (!dir) {
        fprintf(stderr, "cannot open %s\n", path);
        return 0;
    }

    int loaded = 0;
    struct dirent *entry;
    while ((entry = readdir(dir))) {
        const char *dot = strrchr(entry->d_name, '.');
        if (!dot || strcmp(dot, ".8xv") != 0)
            continue;

        char full[4096];
        snprintf(full, sizeof full, "%s/%s", path, entry->d_name);

        char name[9];
        size_t size;
        uint8_t *data = read_appvar(full, name, &size);
        if (!data) {
            fprintf(stderr, "bad appvar: %s\n", full);
            continue;
        }
        shim_add_var(name, data, size);
        free(data);
        loaded++;
    }
    closedir(dir);
    return loaded;
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: render_probe <chunk-dir> <slot> [layer,vx,vy ...]\n");
        return 2;
    }

    if (!load_directory(argv[1]))
        return 1;

    csx_strip_t strip;
    if (!csx_open(&strip, (uint8_t)atoi(argv[2]))) {
        fprintf(stderr, "csx_open failed\n");
        return 1;
    }

    fprintf(stderr, "layers=%u chunks=%u bands=%u\n",
            strip.layer_count, strip.chunk_count, strip.band_count);
    for (uint8_t i = 0; i < strip.layer_count; i++)
        fprintf(stderr, "  layer %u: %ux%u cols=%u bands/col=%u base=%u\n", i,
                strip.layer[i].width, strip.layer[i].height, strip.layer[i].cols,
                strip.layer[i].bands_per_col, strip.layer[i].band_base);

    if (!render_init()) {
        fprintf(stderr, "render_init failed\n");
        return 1;
    }

    for (int i = 3; i < argc; i++) {
        unsigned layer, vx, vy;
        if (sscanf(argv[i], "%u,%u,%u", &layer, &vx, &vy) != 3) {
            fprintf(stderr, "bad viewport %s\n", argv[i]);
            return 2;
        }
        render_view(&strip, (uint8_t)layer, vx, vy);
        fwrite(shim_vbuffer, 1, sizeof shim_vbuffer, stdout);
    }

    render_free();
    return 0;
}
