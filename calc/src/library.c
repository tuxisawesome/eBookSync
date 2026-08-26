#include "library.h"

#include "csx.h"

#include <compression.h>
#include <fileioc.h>
#include <string.h>
#include <time.h>

#define HDR_MAGIC        0
#define HDR_VERSION      5
#define HDR_BOOK_COUNT   6
#define HDR_STRIP_COUNT  8
#define HDR_ID           12
#define HDR_SIZE         28

#define BOOK_SIZE        6
#define STRIP_SIZE       16

static const uint8_t *index_data;
static uint16_t book_count;
static uint16_t strip_count;
static uint8_t title_scratch[LIB_TITLE_MAX];

static uint16_t read16(const uint8_t *p) {
    return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

static uint32_t read32(const uint8_t *p) {
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static const uint8_t *book_entry(uint16_t index) {
    return index_data + HDR_SIZE + (uint24_t)index * BOOK_SIZE;
}

static const uint8_t *strip_entry(uint16_t index) {
    return index_data + HDR_SIZE + (uint24_t)book_count * BOOK_SIZE
           + (uint24_t)index * STRIP_SIZE;
}

bool lib_open(void) {
    index_data = NULL;
    book_count = strip_count = 0;

    uint8_t handle = ti_Open(LIB_NAME, "r");
    if (!handle)
        return false;

    const uint8_t *data = ti_GetDataPtr(handle);
    ti_Close(handle);

    if (!data || memcmp(data + HDR_MAGIC, "CSLIB", 5) != 0 ||
        data[HDR_VERSION] != LIB_VERSION)
        return false;

    index_data = data;
    book_count = read16(data + HDR_BOOK_COUNT);
    strip_count = read16(data + HDR_STRIP_COUNT);
    return true;
}

const uint8_t *lib_id(void) {
    return index_data ? index_data + HDR_ID : NULL;
}

uint16_t lib_book_count(void) { return book_count; }
uint16_t lib_strip_count(void) { return strip_count; }

void lib_get_book(uint16_t index, lib_book_t *book) {
    const uint8_t *entry = book_entry(index);
    book->title = read16(entry);
    book->strip_first = read16(entry + 2);
    book->strip_count = read16(entry + 4);
}

void lib_get_strip(uint16_t index, lib_strip_t *strip) {
    const uint8_t *entry = strip_entry(index);
    strip->slot = entry[0];
    strip->chunk_count = entry[1];
    strip->bytes = (uint24_t)read16(entry + 2) | ((uint24_t)entry[4] << 16);
    strip->flags = entry[5];
    strip->read_at = read32(entry + 6);
    strip->pos = (uint24_t)read16(entry + 10) | ((uint24_t)entry[12] << 16);
    strip->layer = entry[13];
    strip->title = read16(entry + 14);
}

uint16_t lib_book_read_count(const lib_book_t *book) {
    uint16_t read = 0;
    for (uint16_t i = 0; i < book->strip_count; i++) {
        if (strip_entry(book->strip_first + i)[5] & LIB_FLAG_READ)
            read++;
    }
    return read;
}

bool lib_save_strip(uint16_t index, const lib_strip_t *strip) {
    /* "r+" pulls the index out of the archive into RAM so it can be written. */
    uint8_t handle = ti_Open(LIB_NAME, "r+");
    if (!handle)
        return false;

    uint24_t offset = HDR_SIZE + (uint24_t)book_count * BOOK_SIZE
                      + (uint24_t)index * STRIP_SIZE;
    if (ti_Seek(offset + 5, SEEK_SET, handle) == EOF) {
        ti_Close(handle);
        return false;
    }

    uint8_t record[9];
    record[0] = strip->flags;
    record[1] = (uint8_t)strip->read_at;
    record[2] = (uint8_t)(strip->read_at >> 8);
    record[3] = (uint8_t)(strip->read_at >> 16);
    record[4] = (uint8_t)(strip->read_at >> 24);
    record[5] = (uint8_t)strip->pos;
    record[6] = (uint8_t)(strip->pos >> 8);
    record[7] = (uint8_t)(strip->pos >> 16);
    record[8] = strip->layer;

    bool ok = ti_Write(record, sizeof record, 1, handle) == 1;
    /* Put it back in the archive; RAM is needed for the band cache. */
    ok = ti_SetArchiveStatus(true, handle) && ok;
    ti_Close(handle);

    /* The variable moved, so every cached pointer into it is stale. */
    lib_open();
    return ok;
}

/*
 * Rewrite a run of strip records in one go.
 *
 * The index lives in the archive, so every save unarchives it, edits it and
 * archives it again. Marking a whole book read one strip at a time would do
 * that once per strip; this does it once.
 */
bool lib_set_book_read(const lib_book_t *book, bool read) {
    uint8_t handle = ti_Open(LIB_NAME, "r+");
    if (!handle)
        return false;

    bool ok = true;
    uint32_t when = read ? (uint32_t)time(NULL) : 0;

    for (uint16_t i = 0; i < book->strip_count && ok; i++) {
        uint24_t offset = HDR_SIZE + (uint24_t)book_count * BOOK_SIZE
                          + (uint24_t)(book->strip_first + i) * STRIP_SIZE;
        if (ti_Seek(offset + 5, SEEK_SET, handle) == EOF) {
            ok = false;
            break;
        }

        uint8_t record[5];
        record[0] = read ? LIB_FLAG_READ : 0;
        record[1] = (uint8_t)when;
        record[2] = (uint8_t)(when >> 8);
        record[3] = (uint8_t)(when >> 16);
        record[4] = (uint8_t)(when >> 24);
        ok = ti_Write(record, sizeof record, 1, handle) == 1;
    }

    ok = ti_SetArchiveStatus(true, handle) && ok;
    ti_Close(handle);

    lib_open();
    return ok;
}

uint16_t lib_reset(void) {
    uint16_t removed = 0;

    /* Delete the strips first: once the index is gone their slots are unknown. */
    for (uint16_t i = 0; i < strip_count; i++) {
        lib_strip_t strip;
        lib_get_strip(i, &strip);
        if (csx_delete(strip.slot))
            removed++;
    }

    ti_Delete(LIB_NAME);
    index_data = NULL;
    book_count = 0;
    strip_count = 0;
    return removed;
}

const uint8_t *lib_title(uint16_t offset, uint16_t *width, uint8_t *height) {
    if (!index_data || !offset)
        return NULL;

    const uint8_t *entry = index_data + offset;
    uint16_t bitmap_width = read16(entry);
    uint8_t bitmap_height = entry[2];

    uint24_t needed = (uint24_t)((bitmap_width + 3) / 4) * bitmap_height;
    if (needed == 0 || needed > sizeof title_scratch)
        return NULL;

    zx0_Decompress(title_scratch, entry + 5);
    *width = bitmap_width;
    *height = bitmap_height;
    return title_scratch;
}
