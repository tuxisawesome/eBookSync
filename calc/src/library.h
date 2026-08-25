/*
 * CSLIB: the index of what is actually on the calculator.
 *
 * Parsed in place from flash rather than copied into RAM -- the band cache
 * needs every byte it can get. Only the 16-byte strip record is ever written
 * back, and only when the reader leaves a strip.
 *
 * Titles are ZX0-compressed 2bpp bitmaps rendered by the sync app, because the
 * calculator has no CJK font. See docs/FORMAT.md.
 */

#ifndef LIBRARY_H
#define LIBRARY_H

#include <stdbool.h>
#include <stdint.h>

#define LIB_NAME        "CSLIB"
#define LIB_VERSION     1
#define LIB_FLAG_READ   0x01

/* Largest 2bpp title bitmap the reader has to expand, in bytes. */
#define LIB_TITLE_MAX   1200

typedef struct {
    uint8_t slot;
    uint8_t chunk_count;
    uint24_t bytes;
    uint8_t flags;
    uint32_t read_at;
    uint24_t pos;         /* saved scroll position, in the saved layer's rows */
    uint8_t layer;        /* zoom layer last used */
    uint16_t title;       /* offset of the title record within the index */
} lib_strip_t;

typedef struct {
    uint16_t title;
    uint16_t strip_first;
    uint16_t strip_count;
} lib_book_t;

/* Map the index. False when there is no library on the calculator yet. */
bool lib_open(void);

uint16_t lib_book_count(void);
uint16_t lib_strip_count(void);

void lib_get_book(uint16_t index, lib_book_t *book);
void lib_get_strip(uint16_t index, lib_strip_t *strip);

/* How many strips of a book are marked read. */
uint16_t lib_book_read_count(const lib_book_t *book);

/*
 * Persist one strip's read flag, scroll position and zoom layer.
 *
 * This rewrites the index appvar, which means unarchiving and re-archiving it,
 * so it is called when leaving a strip and never mid-scroll. Returns false if
 * the write failed, in which case the in-flash copy is unchanged.
 */
bool lib_save_strip(uint16_t index, const lib_strip_t *strip);

/*
 * Expand a title bitmap into the shared scratch buffer.
 *
 * Returns the pixel data, or NULL if the title is unreadable. Only one title is
 * live at a time, which is all the list drawing code needs.
 */
const uint8_t *lib_title(uint16_t offset, uint16_t *width, uint8_t *height);

#endif /* LIBRARY_H */
