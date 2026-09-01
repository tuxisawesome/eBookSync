#include "library.h"

#include "csx.h"
#include "sha256.h"

#include <compression.h>
#include <fileioc.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define HDR_MAGIC        0
#define HDR_VERSION      5
#define HDR_BOOK_COUNT   6
#define HDR_STRIP_COUNT  8
#define HDR_ID           12
#define HDR_DEVICE       LIB_DEVICE_OFFSET
#define HDR_SIZE         LIB_HEADER_SIZE

#define BOOK_SIZE        6
#define STRIP_SIZE       17

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

    if (!data || memcmp(data + HDR_MAGIC, LIB_MAGIC, 5) != 0 ||
        data[HDR_VERSION] != LIB_VERSION)
        return false;

    index_data = data;
    book_count = read16(data + HDR_BOOK_COUNT);
    strip_count = read16(data + HDR_STRIP_COUNT);
    return true;
}

const uint8_t *lib_id(void) {
    if (!index_data)
        return NULL;

    /* An emptied index carries zeros here, and so does the page when no library
     * folder has been chosen. Both mean "no identity", not "identity zero" --
     * answering DIFFERENT to either would refuse a calculator that is in fact
     * free to take anything. */
    const uint8_t *id = index_data + HDR_ID;
    for (uint8_t i = 0; i < LIB_ID_SIZE; i++) {
        if (id[i])
            return id;
    }
    return NULL;
}

const uint8_t *lib_device(void) {
    return index_data ? index_data + HDR_DEVICE : NULL;
}

/* Write the 92-byte header of a fresh, empty index. */
static void empty_header(uint8_t *header, const uint8_t *device) {
    memset(header, 0, HDR_SIZE);
    memcpy(header + HDR_MAGIC, LIB_MAGIC, 5);
    header[HDR_VERSION] = LIB_VERSION;
    if (device)
        memcpy(header + HDR_DEVICE, device, LIB_DEVICE_SIZE);
}

static bool write_empty(const uint8_t *device) {
    uint8_t header[HDR_SIZE];
    empty_header(header, device);

    ti_Delete(LIB_NAME);
    uint8_t handle = ti_Open(LIB_NAME, "w");
    if (!handle)
        return false;

    bool ok = ti_Write(header, sizeof header, 1, handle) == 1;
    ok = ti_SetArchiveStatus(true, handle) && ok;
    ti_Close(handle);
    if (!ok)
        ti_Delete(LIB_NAME);

    lib_open();
    return ok;
}

bool lib_ensure(void) {
    return lib_open() || write_empty(NULL);
}

/* Offsets within the device block. See docs/FORMAT.md. */
#define DEV_PW_FLAGS      0
#define DEV_PW_SALT       1
#define DEV_PW_HASH       17
#define DEV_PW_FAILURES   49
#define DEV_CLOCK_OFFSET  50
#define DEV_WALL_FLAGS    54
#define DEV_WALL_CRC      55

#define DEV_WALL_SET      0x01

#define DEV_PW_SET        0x01
#define DEV_SALT_SIZE     16
#define DEV_CLOCK_SIZE    4

/* Anything smaller is not worth an index rewrite. */
#define CLOCK_SLACK       60

uint32_t lib_now(void) {
    uint32_t raw = (uint32_t)time(NULL);

    const uint8_t *device = lib_device();
    if (!device)
        return raw;

    return raw + read32(device + DEV_CLOCK_OFFSET);
}

bool lib_set_clock(uint32_t unix_seconds) {
    uint32_t raw = (uint32_t)time(NULL);
    uint32_t wanted = unix_seconds - raw;

    const uint8_t *device = lib_device();
    if (device) {
        uint32_t current = read32(device + DEV_CLOCK_OFFSET);
        uint32_t drift = wanted - current;

        /* Unsigned, so a correction in either direction lands near 0 or near
         * 2^32; both ends are "close enough to leave alone". */
        if (drift < CLOCK_SLACK || drift > (uint32_t)0 - CLOCK_SLACK)
            return true;
    }

    uint8_t block[LIB_DEVICE_SIZE];
    if (device)
        memcpy(block, device, sizeof block);
    else
        memset(block, 0, sizeof block);

    block[DEV_CLOCK_OFFSET] = (uint8_t)wanted;
    block[DEV_CLOCK_OFFSET + 1] = (uint8_t)(wanted >> 8);
    block[DEV_CLOCK_OFFSET + 2] = (uint8_t)(wanted >> 16);
    block[DEV_CLOCK_OFFSET + 3] = (uint8_t)(wanted >> 24);
    return lib_set_device(block);
}

/* SHA-256(salt || password), which is what the device block holds. */
static void password_digest(const uint8_t *salt, const char *password,
                            uint8_t out[SHA256_SIZE]) {
    sha256_t ctx;
    sha256_init(&ctx);
    sha256_update(&ctx, salt, DEV_SALT_SIZE);
    sha256_update(&ctx, password, strlen(password));
    sha256_final(&ctx, out);
}

bool lib_password_set(void) {
    const uint8_t *device = lib_device();
    return device && (device[DEV_PW_FLAGS] & DEV_PW_SET);
}

uint8_t lib_password_failures(void) {
    const uint8_t *device = lib_device();
    return device ? device[DEV_PW_FAILURES] : 0;
}

bool lib_password_check(const char *password) {
    const uint8_t *device = lib_device();
    if (!device || !(device[DEV_PW_FLAGS] & DEV_PW_SET))
        return true;

    uint8_t digest[SHA256_SIZE];
    password_digest(device + DEV_PW_SALT, password, digest);

    /*
     * Compared without an early exit. Timing an answer out of a calculator you
     * are holding is not a realistic attack, but a comparison that stops at the
     * first wrong byte is the kind of thing that gets copied somewhere it does
     * matter.
     */
    uint8_t differing = 0;
    for (uint8_t i = 0; i < SHA256_SIZE; i++)
        differing |= digest[i] ^ device[DEV_PW_HASH + i];
    return differing == 0;
}

/* Read the device block into `block`, or zero it if there is no index yet. */
static void device_copy(uint8_t block[LIB_DEVICE_SIZE]) {
    const uint8_t *device = lib_device();
    if (device)
        memcpy(block, device, LIB_DEVICE_SIZE);
    else
        memset(block, 0, LIB_DEVICE_SIZE);
}

bool lib_password_store(const char *password) {
    uint8_t block[LIB_DEVICE_SIZE];
    device_copy(block);

    if (!password || !*password) {
        block[DEV_PW_FLAGS] &= (uint8_t)~DEV_PW_SET;
        memset(block + DEV_PW_SALT, 0, DEV_SALT_SIZE + SHA256_SIZE);
        block[DEV_PW_FAILURES] = 0;
        return lib_set_device(block);
    }

    /*
     * A fresh salt every time, seeded from the clock. Its job is only to stop
     * one precomputed table covering every eBookSync calculator; it is not a secret
     * and does not need to be unguessable.
     */
    srand((unsigned)time(NULL) ^ (unsigned)(uintptr_t)block);
    for (uint8_t i = 0; i < DEV_SALT_SIZE; i++)
        block[DEV_PW_SALT + i] = (uint8_t)rand();

    password_digest(block + DEV_PW_SALT, password, block + DEV_PW_HASH);
    block[DEV_PW_FLAGS] |= DEV_PW_SET;
    block[DEV_PW_FAILURES] = 0;
    return lib_set_device(block);
}

bool lib_password_note_failure(void) {
    uint8_t block[LIB_DEVICE_SIZE];
    device_copy(block);

    /* Saturates rather than wrapping round to nought, which would turn the
     * evidence into its opposite after 256 tries. */
    if (block[DEV_PW_FAILURES] < 0xFF)
        block[DEV_PW_FAILURES]++;
    return lib_set_device(block);
}

/*
 * The wallpaper claim.
 *
 * A checksum rather than a bare flag, so a wallpaper damaged in flash is
 * noticed rather than drawn as noise across the lock screen -- and so the claim
 * names a particular set of bytes rather than "whatever is in that slot".
 */
bool lib_wallpaper(uint32_t *crc) {
    const uint8_t *device = lib_device();
    if (!device || !(device[DEV_WALL_FLAGS] & DEV_WALL_SET))
        return false;

    *crc = read32(device + DEV_WALL_CRC);
    return true;
}

bool lib_set_wallpaper(const uint32_t *crc) {
    uint8_t block[LIB_DEVICE_SIZE];
    device_copy(block);

    if (!crc) {
        /* Nothing to clear, and an index rewrite is a flash write. */
        if (!(block[DEV_WALL_FLAGS] & DEV_WALL_SET))
            return true;

        block[DEV_WALL_FLAGS] &= (uint8_t)~DEV_WALL_SET;
        memset(block + DEV_WALL_CRC, 0, 4);
        return lib_set_device(block);
    }

    block[DEV_WALL_FLAGS] |= DEV_WALL_SET;
    block[DEV_WALL_CRC] = (uint8_t)*crc;
    block[DEV_WALL_CRC + 1] = (uint8_t)(*crc >> 8);
    block[DEV_WALL_CRC + 2] = (uint8_t)(*crc >> 16);
    block[DEV_WALL_CRC + 3] = (uint8_t)(*crc >> 24);
    return lib_set_device(block);
}

bool lib_password_clear_failures(void) {
    uint8_t block[LIB_DEVICE_SIZE];
    device_copy(block);

    if (!block[DEV_PW_FAILURES])
        return true;

    block[DEV_PW_FAILURES] = 0;
    return lib_set_device(block);
}

bool lib_set_device(const uint8_t *block) {
    if (!lib_ensure())
        return false;

    uint8_t handle = ti_Open(LIB_NAME, "r+");
    if (!handle)
        return false;

    bool ok = ti_Seek(HDR_DEVICE, SEEK_SET, handle) != EOF
              && ti_Write(block, LIB_DEVICE_SIZE, 1, handle) == 1;
    ok = ti_SetArchiveStatus(true, handle) && ok;
    ti_Close(handle);

    /* The variable moved, so every cached pointer into it is stale. */
    lib_open();
    return ok;
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
    strip->slot = read16(entry);
    strip->chunk_count = entry[2];
    strip->bytes = (uint24_t)read16(entry + 3) | ((uint24_t)entry[5] << 16);
    strip->flags = entry[6];
    strip->read_at = read32(entry + 7);
    strip->pos = (uint24_t)read16(entry + 11) | ((uint24_t)entry[13] << 16);
    strip->layer = entry[14];
    strip->title = read16(entry + 15);
}

uint16_t lib_book_read_count(const lib_book_t *book) {
    uint16_t read = 0;
    for (uint16_t i = 0; i < book->strip_count; i++) {
        if (strip_entry(book->strip_first + i)[6] & LIB_FLAG_READ)
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
    if (ti_Seek(offset + 6, SEEK_SET, handle) == EOF) {
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
    uint32_t when = read ? lib_now() : 0;

    for (uint16_t i = 0; i < book->strip_count && ok; i++) {
        uint24_t offset = HDR_SIZE + (uint24_t)book_count * BOOK_SIZE
                          + (uint24_t)(book->strip_first + i) * STRIP_SIZE;
        if (ti_Seek(offset + 6, SEEK_SET, handle) == EOF) {
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
    /* Take a copy before anything is deleted: the block is in flash, and the
     * deletes below can move it. */
    uint8_t device[LIB_DEVICE_SIZE];
    const uint8_t *live = lib_device();
    if (live)
        memcpy(device, live, sizeof device);
    else
        memset(device, 0, sizeof device);

    uint16_t removed = 0;

    /* Delete the strips first: once the index is gone their slots are unknown. */
    for (uint16_t i = 0; i < strip_count; i++) {
        lib_strip_t strip;
        lib_get_strip(i, &strip);
        if (csx_delete(strip.slot))
            removed++;
    }

    /* Emptied, not deleted -- the device block goes back, so erasing the library
     * does not quietly clear the password with it. */
    write_empty(device);
    return removed;
}

/* ------------------------------------------------------------------ legacy */

/* The eBookSync naming's chunk names: the same layout, a different prefix. */
static void legacy_chunk_name(char *name, uint8_t slot, uint8_t chunk) {
    static const char hex[] = "0123456789ABCDEF";
    name[0] = 'E';
    name[1] = 'O';
    name[2] = hex[slot >> 4];
    name[3] = hex[slot & 0x0F];
    name[4] = hex[chunk >> 4];
    name[5] = hex[chunk & 0x0F];
    name[6] = '\0';
}

bool lib_has_legacy(void) {
    /* If these ever coincide, the sweep would offer to delete the live library.
     * Cheap to assert, and it has happened. */
    if (strcmp(LIB_LEGACY_NAME, LIB_NAME) == 0)
        return false;

    char name[7];
    legacy_chunk_name(name, 0, 0);

    uint8_t handle = ti_Open(LIB_LEGACY_NAME, "r");
    if (!handle)
        handle = ti_Open(name, "r");
    if (!handle)
        return false;

    ti_Close(handle);
    return true;
}

uint16_t lib_sweep_legacy(void) {
    uint16_t removed = 0;

    if (ti_Delete(LIB_LEGACY_NAME))
        removed++;

    /*
     * The old index is gone, so which slots existed is no longer knowable.
     * Probing each slot's first chunk and stopping at the first gap costs 256
     * lookups plus one per chunk actually there, rather than the 16384 a blind
     * sweep of the whole name space would.
     */
    for (uint16_t slot = 0; slot < 256; slot++) {
        for (uint16_t chunk = 0; chunk < CSX_MAX_CHUNKS; chunk++) {
            char name[7];
            legacy_chunk_name(name, (uint8_t)slot, (uint8_t)chunk);
            if (!ti_Delete(name))
                break;
            removed++;
        }
    }

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
