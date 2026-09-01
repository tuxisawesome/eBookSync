/*
 * What prgmCSUP does, without prgmCSUP.
 *
 * calc/updater/src/main.c is a handful of prints around three calls into
 * calc/src/update.c: read the manifest, checksum the chunks, write the program.
 * This runs those three against a seeded appvar directory so the half of the
 * update that never touches the wire is testable too -- and it is the half that
 * replaces prgmCOMICS, so getting it wrong means a calculator that will not start.
 *
 *   update_probe <dir-with-8xv-files> <out-dir>
 */

#include "update.h"

#include "fileioc.h"
#include "shim.h"

#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

uint8_t *read_appvar(const char *path, char *name, size_t *size);

static void load_all(const char *directory) {
    DIR *dir = opendir(directory);
    for (struct dirent *entry; dir && (entry = readdir(dir)); ) {
        const char *dot = strrchr(entry->d_name, '.');
        if (!dot || strcmp(dot, ".8xv") != 0)
            continue;

        char path[4096];
        snprintf(path, sizeof path, "%s/%s", directory, entry->d_name);

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

static void save_all(const char *directory) {
    const char *name;
    const uint8_t *data;
    size_t size;
    for (int i = 0; shim_var_at(i, &name, &data, &size); i++) {
        char path[4096];
        snprintf(path, sizeof path, "%s/%s.bin", directory, name);
        FILE *file = fopen(path, "wb");
        if (!file)
            continue;
        fwrite(data, 1, size, file);
        fclose(file);
    }
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: update_probe <in-dir> <out-dir> [target]\n");
        return 2;
    }

    /* Which target to install, defaulting to the reader. prgmCSUP tries every
     * one; this does the one it is asked about, so a test can watch them
     * separately. */
    uint8_t target = argc >= 4 ? (uint8_t)atoi(argv[3]) : UPDATE_TARGET_READER;

    load_all(argv[1]);

    update_manifest_t manifest;
    if (!update_pending(target, &manifest)) {
        printf("nothing pending\n");
        save_all(argv[2]);
        return 0;
    }

    printf("pending target=%u build=%u bytes=%lu chunks=%u\n",
           manifest.target, manifest.build,
           (unsigned long)manifest.bytes, manifest.chunks);

    const char *name = update_target_name(target);
    if (!name) {
        printf("unknown target\n");
        save_all(argv[2]);
        return 0;
    }

    if (!update_verify(&manifest)) {
        update_discard(target);
        printf("damaged\n");
        save_all(argv[2]);
        return 1;
    }
    printf("verified\n");

    if (!update_install(name, &manifest)) {
        printf("install failed\n");
        save_all(argv[2]);
        return 1;
    }

    update_discard(target);
    printf("installed\n");
    save_all(argv[2]);
    return 0;
}
