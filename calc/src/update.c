#include "update.h"

#include "crc32.h"

#include <fileioc.h>
#include <string.h>

#define MF_MAGIC     0
#define MF_VERSION   4
#define MF_TARGET    5
#define MF_BUILD     6
#define MF_BYTES     8
#define MF_CHUNKS    12
#define MF_CRC       14
#define MF_VERSION_1 1

static uint16_t read16(const uint8_t *p) {
    return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

static uint32_t read32(const uint8_t *p) {
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static void put16(uint8_t *p, uint16_t value) {
    p[0] = (uint8_t)value;
    p[1] = (uint8_t)(value >> 8);
}

static void put32(uint8_t *p, uint32_t value) {
    p[0] = (uint8_t)value;
    p[1] = (uint8_t)(value >> 8);
    p[2] = (uint8_t)(value >> 16);
    p[3] = (uint8_t)(value >> 24);
}

static const char HEX[] = "0123456789ABCDEF";

const char *update_target_name(uint8_t target) {
    switch (target) {
        case UPDATE_TARGET_READER:  return UPDATE_READER_NAME;
        case UPDATE_TARGET_UPDATER: return UPDATE_UPDATER_NAME;
        case UPDATE_TARGET_LOCK:    return UPDATE_LOCK_NAME;
        default:                    return NULL;
    }
}

void update_chunk_name(char *name, uint8_t target, uint8_t index) {
    name[0] = 'C';
    name[1] = 'S';
    name[2] = 'U';
    name[3] = HEX[target & 0x0F];
    name[4] = HEX[index >> 4];
    name[5] = HEX[index & 0x0F];
    name[6] = '\0';
}

void update_manifest_name(char *name, uint8_t target) {
    name[0] = 'C';
    name[1] = 'S';
    name[2] = 'U';
    name[3] = 'P';
    name[4] = 'D';
    name[5] = HEX[target & 0x0F];
    name[6] = '\0';
}

void update_discard(uint8_t target) {
    char name[7];

    update_manifest_name(name, target);
    ti_Delete(name);

    for (uint8_t i = 0; i < UPDATE_MAX_CHUNKS; i++) {
        update_chunk_name(name, target, i);
        ti_Delete(name);
    }
}

/*
 * Every target, plus the names used before there were targets.
 *
 * A calculator updating into this version can be holding a manifest and up to
 * sixteen chunks under the old names, which nothing will ever look at again.
 */
void update_sweep(void) {
    for (uint8_t target = 0; target < UPDATE_TARGET_COUNT; target++)
        update_discard(target);

    ti_Delete(UPDATE_MANIFEST_LEGACY);
    for (uint8_t i = 0; i < UPDATE_MAX_CHUNKS; i++) {
        char legacy[6];
        legacy[0] = 'C';
        legacy[1] = 'S';
        legacy[2] = 'U';
        legacy[3] = HEX[i >> 4];
        legacy[4] = HEX[i & 0x0F];
        legacy[5] = '\0';
        ti_Delete(legacy);
    }
}

/* Map one chunk and hand back its flash address; NULL if it is not there. */
static const uint8_t *chunk_data(uint8_t target, uint8_t index, uint16_t *size) {
    char name[7];
    update_chunk_name(name, target, index);

    uint8_t handle = ti_Open(name, "r");
    if (!handle)
        return NULL;

    *size = (uint16_t)ti_GetSize(handle);
    const uint8_t *data = ti_GetDataPtr(handle);
    ti_Close(handle);
    return data;
}

bool update_verify(const update_manifest_t *manifest) {
    if (!manifest->chunks || manifest->chunks > UPDATE_MAX_CHUNKS || !manifest->bytes)
        return false;

    uint32_t left = manifest->bytes;
    uint32_t crc = CRC32_INIT;

    for (uint16_t i = 0; i < manifest->chunks; i++) {
        uint16_t size;
        const uint8_t *data = chunk_data(manifest->target, (uint8_t)i, &size);
        if (!data)
            return false;

        /* Every chunk but the last must be full, or the image has a hole in it
         * that would otherwise only show up as a program that does not run. */
        uint32_t want = left > UPDATE_CHUNK_SIZE ? UPDATE_CHUNK_SIZE : left;
        if (size != want)
            return false;

        crc = crc32_update(crc, data, size);
        left -= want;
    }

    return left == 0 && crc32_finish(crc) == manifest->crc;
}

bool update_arm(const update_manifest_t *manifest) {
    uint8_t record[UPDATE_MANIFEST_SIZE];
    memset(record, 0, sizeof record);
    memcpy(record + MF_MAGIC, UPDATE_MAGIC, 4);
    record[MF_VERSION] = MF_VERSION_1;
    record[MF_TARGET] = manifest->target;
    put16(record + MF_BUILD, manifest->build);
    put32(record + MF_BYTES, manifest->bytes);
    put16(record + MF_CHUNKS, manifest->chunks);
    put32(record + MF_CRC, manifest->crc);

    char name[7];
    update_manifest_name(name, manifest->target);

    ti_Delete(name);
    uint8_t handle = ti_Open(name, "w");
    if (!handle)
        return false;

    bool ok = ti_Write(record, sizeof record, 1, handle) == 1;
    ok = ti_SetArchiveStatus(true, handle) && ok;
    ti_Close(handle);
    if (!ok)
        ti_Delete(name);
    return ok;
}

bool update_pending(uint8_t target, update_manifest_t *manifest) {
    char name[7];
    update_manifest_name(name, target);

    uint8_t handle = ti_Open(name, "r");
    if (!handle)
        return false;

    uint16_t size = (uint16_t)ti_GetSize(handle);
    const uint8_t *data = ti_GetDataPtr(handle);
    ti_Close(handle);

    if (!data || size < UPDATE_MANIFEST_SIZE ||
        memcmp(data + MF_MAGIC, UPDATE_MAGIC, 4) != 0 ||
        data[MF_VERSION] != MF_VERSION_1)
        return false;

    manifest->target = data[MF_TARGET];
    if (manifest->target != target)
        return false;
    manifest->build = read16(data + MF_BUILD);
    manifest->bytes = read32(data + MF_BYTES);
    manifest->chunks = read16(data + MF_CHUNKS);
    manifest->crc = read32(data + MF_CRC);
    return true;
}

bool update_install(const char *program, const update_manifest_t *manifest) {
    ti_DeleteVar(program, OS_TYPE_PRGM);

    uint8_t handle = ti_OpenVar(program, "w", OS_TYPE_PRGM);
    if (!handle)
        return false;

    /*
     * Written chunk by chunk straight out of flash. The whole image never
     * exists in one place, which is the only reason a 40 KB program can be
     * installed on a calculator with 50 KB of RAM.
     */
    bool ok = true;
    uint32_t left = manifest->bytes;
    for (uint16_t i = 0; i < manifest->chunks && ok; i++) {
        uint16_t size;
        const uint8_t *data = chunk_data(manifest->target, (uint8_t)i, &size);
        uint32_t want = left > UPDATE_CHUNK_SIZE ? UPDATE_CHUNK_SIZE : left;

        ok = data && size == want && ti_Write(data, (size_t)want, 1, handle) == 1;
        left -= want;
    }

    ok = ok && left == 0;
    ok = ti_SetArchiveStatus(true, handle) && ok;
    ti_Close(handle);

    /* A half-written program is worse than none: it would be in the menu and it
     * would crash. Take it away rather than leave it there. */
    if (!ok)
        ti_DeleteVar(program, OS_TYPE_PRGM);
    return ok;
}
