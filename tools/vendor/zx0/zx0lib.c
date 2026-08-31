/*
 * eBookSync wrapper around Einar Saukas' ZX0 compressor (BSD-3-Clause, see
 * LICENSE in this directory). Exposes a one-call API so tools/csx can drive it
 * through ctypes instead of shelling out per band.
 */
#include <stdlib.h>
#include <string.h>
#include "zx0.h"

void zx0_reset(void);

/*
 * Everything in this library is built with -fvisibility=hidden and only the two
 * entry points below are exported. That matters: ZX0's optimizer calls a
 * function named `compress`, and zlib -- already loaded inside CPython --
 * exports a global `compress` of its own. Without hidden visibility the dynamic
 * linker interposes zlib's symbol and our calls silently go to the wrong
 * function.
 */
#if defined(_WIN32)
#define ZX0_EXPORT __declspec(dllexport)
#elif defined(__GNUC__)
#define ZX0_EXPORT __attribute__((visibility("default")))
#else
#define ZX0_EXPORT
#endif

/*
 * Compress `input_size` bytes into a freshly malloc'd buffer.
 * `offset_limit` caps the match window (upstream default is 32640); smaller
 * windows compress much faster at a small cost in ratio.
 * Returns NULL on failure. Free the result with zx0_free().
 */
ZX0_EXPORT unsigned char *zx0_compress_block(const unsigned char *input_data, int input_size,
                                            int offset_limit, int *output_size) {
    unsigned char *copy;
    unsigned char *output;
    BLOCK *optimal;
    int delta = 0;

    if (input_size <= 0)
        return NULL;
    if (offset_limit <= 0)
        offset_limit = 32640;

    /* optimize() takes a non-const pointer but never writes to it */
    copy = (unsigned char *)malloc(input_size);
    if (!copy)
        return NULL;
    memcpy(copy, input_data, input_size);

    optimal = optimize(copy, input_size, 0, offset_limit);
    /* invert_mode = TRUE matches the default (non-"classic") ZX0 v2 stream that
       the CE toolchain's zx0_Decompress expects. */
    output = compress(optimal, copy, input_size, 0, 0 /* backwards */, 1 /* invert */,
                      output_size, &delta);

    free(copy);
    zx0_reset();
    return output;
}

ZX0_EXPORT void zx0_free(unsigned char *p) {
    free(p);
}
