/*
 * Drives the real library index parser on the host.
 *
 * Loads EOSLIB.8xv, parses it through calc/src/library.c, and prints every book
 * and strip record plus a checksum of each expanded title bitmap.
 * tools/hosttest/check_library.py compares that with what tools/csx/library.py
 * put in.
 *
 *   lib_probe <dir-with-EOSLIB.8xv> [save <strip> <flags> <pos> <layer>]
 */

#include "library.h"

#include <stdlib.h>
#include <string.h>

uint8_t *read_appvar(const char *path, char *name, size_t *size);

static void dump(void) {
    printf("books %u strips %u\n", lib_book_count(), lib_strip_count());

    for (uint16_t i = 0; i < lib_book_count(); i++) {
        lib_book_t book;
        lib_get_book(i, &book);

        uint16_t width;
        uint8_t height;
        const uint8_t *bitmap = lib_title(book.title, &width, &height);
        unsigned long sum = 0;
        if (bitmap) {
            size_t bytes = (size_t)((width + 3) / 4) * height;
            for (size_t j = 0; j < bytes; j++)
                sum = sum * 31 + bitmap[j];
        }
        printf("book %u first %u count %u read %u title %ux%u sum %lu\n",
               i, book.strip_first, book.strip_count, lib_book_read_count(&book),
               width, height, bitmap ? sum : 0UL);
    }

    for (uint16_t i = 0; i < lib_strip_count(); i++) {
        lib_strip_t strip;
        lib_get_strip(i, &strip);

        uint16_t width;
        uint8_t height;
        const uint8_t *bitmap = lib_title(strip.title, &width, &height);
        unsigned long sum = 0;
        if (bitmap) {
            size_t bytes = (size_t)((width + 3) / 4) * height;
            for (size_t j = 0; j < bytes; j++)
                sum = sum * 31 + bitmap[j];
        }
        printf("strip %u slot %u chunks %u bytes %u flags %u readat %u pos %u "
               "layer %u title %ux%u sum %lu\n",
               i, strip.slot, strip.chunk_count, (unsigned)strip.bytes, strip.flags,
               (unsigned)strip.read_at, (unsigned)strip.pos, strip.layer,
               width, height, bitmap ? sum : 0UL);
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: lib_probe <dir> [save <strip> <flags> <pos> <layer>]\n"
                        "       lib_probe <dir> password <text>...\n");
        return 2;
    }

    char path[4096];
    snprintf(path, sizeof path, "%s/" LIB_NAME ".8xv", argv[1]);

    char name[9];
    size_t size;
    uint8_t *data = read_appvar(path, name, &size);
    if (!data) {
        fprintf(stderr, "cannot read %s\n", path);
        return 1;
    }
    shim_add_var(name, data, size);
    free(data);

    if (!lib_open()) {
        fprintf(stderr, "lib_open failed\n");
        return 1;
    }

    /*
     * password <text> ...: try each in turn and say whether the reader accepts
     * it, then write the index back so the failure counter can be inspected.
     *
     * The password never leaves the calculator in real life, so there is no
     * browser implementation to check this against -- tools/csx/library.py is
     * the independent one, and it built the index this is reading.
     */
    if (argc >= 3 && strcmp(argv[2], "password") == 0) {
        printf("set %d\n", lib_password_set() ? 1 : 0);
        for (int i = 3; i < argc; i++) {
            bool ok = lib_password_check(argv[i]);
            /* Verdict first: the text may be empty, and a trailing empty field
             * is not something a whitespace split can see. */
            printf("check %d %s\n", ok ? 1 : 0, argv[i]);
            if (ok)
                lib_password_clear_failures();
            else
                lib_password_note_failure();
        }
        printf("failures %u\n", lib_password_failures());

        const uint8_t *saved = shim_var_data(LIB_NAME, &size);
        char out[4096];
        snprintf(out, sizeof out, "%s/" LIB_NAME ".saved", argv[1]);
        FILE *file = fopen(out, "wb");
        fwrite(saved, 1, size, file);
        fclose(file);
        return 0;
    }

    if (argc >= 7 && strcmp(argv[2], "save") == 0) {
        uint16_t index = (uint16_t)atoi(argv[3]);
        lib_strip_t strip;
        lib_get_strip(index, &strip);
        strip.flags = (uint8_t)atoi(argv[4]);
        strip.pos = (uint24_t)strtoul(argv[5], NULL, 10);
        strip.layer = (uint8_t)atoi(argv[6]);
        strip.read_at = 1756100000u;
        if (!lib_save_strip(index, &strip)) {
            fprintf(stderr, "lib_save_strip failed\n");
            return 1;
        }
        /* Write the modified index back out so the checker can re-read it. */
        const uint8_t *saved = shim_var_data(LIB_NAME, &size);
        char out[4096];
        snprintf(out, sizeof out, "%s/" LIB_NAME ".saved", argv[1]);
        FILE *file = fopen(out, "wb");
        fwrite(saved, 1, size, file);
        fclose(file);
    }

    dump();
    return 0;
}
