#include "wall.h"

#include "crc32.h"
#include "csx.h"
#include "library.h"
#include "render.h"

#include <fileioc.h>
#include <graphx.h>

/*
 * What the index says about the wallpaper, worked out once.
 *
 * Checking means opening the container and CRC-ing every chunk, which is tens
 * of kilobytes of flash. Once per run is plenty: nothing changes it except a
 * sync, and a sync is not running while the lock screen is up.
 */
typedef enum {
    WALL_UNKNOWN = 0,
    WALL_YES,
    WALL_NO,
} wall_state_t;

static wall_state_t state;

/*
 * One band's worth of room to decompress into.
 *
 * Static, and not malloc'd, which took a bug to learn. render_init() takes the
 * band cache by calling malloc until it fails, so by the time the reader is
 * showing a menu there is no heap left at all -- and a lock screen that asked
 * for five kilobytes got nothing, gave up, and painted a flat colour with the
 * clock on top of it. The cache adapts to what is left over; this cannot.
 */
static uint8_t scratch[CSX_BAND_MAX];

/* CRC-32 of every chunk of the reserved slot, in order. 0 if it will not open. */
static bool wall_checksum(uint32_t *out) {
    csx_strip_t strip;
    if (!csx_open(&strip, CSX_WALLPAPER_SLOT))
        return false;

    uint32_t crc = CRC32_INIT;
    for (uint8_t i = 0; i < strip.chunk_count; i++) {
        char name[9];
        csx_chunk_name(name, CSX_WALLPAPER_SLOT, i);

        uint8_t handle = ti_Open(name, "r");
        if (!handle)
            return false;

        uint16_t size = (uint16_t)ti_GetSize(handle);
        const uint8_t *data = ti_GetDataPtr(handle);
        ti_Close(handle);
        if (!data)
            return false;

        crc = crc32_update(crc, data, size);
    }

    *out = crc32_finish(crc);
    return true;
}

bool wall_present(void) {
    if (state != WALL_UNKNOWN)
        return state == WALL_YES;

    state = WALL_NO;

    uint32_t claimed;
    if (!lib_wallpaper(&claimed))
        return false;

    uint32_t actual;
    if (!wall_checksum(&actual) || actual != claimed)
        return false;

    state = WALL_YES;
    return true;
}

bool wall_draw(void) {
    if (!wall_present())
        return false;

    csx_strip_t strip;
    if (!csx_open(&strip, CSX_WALLPAPER_SLOT))
        return false;

    render_set_palette(&strip);
    return render_draw_full(&strip, scratch);
}

bool wall_adopt(void) {
    state = WALL_UNKNOWN;

    uint32_t crc;
    if (!wall_checksum(&crc)) {
        wall_forget();
        return false;
    }

    return lib_set_wallpaper(&crc);
}

void wall_forget(void) {
    state = WALL_NO;
    csx_delete(CSX_WALLPAPER_SLOT);
    lib_set_wallpaper(NULL);
}

void wall_sweep(void) {
    uint32_t claimed;
    if (lib_wallpaper(&claimed))
        return;

    /*
     * No claim, but the appvars are still here: either the index was deleted to
     * get past the password, or a sync died between storing the wallpaper and
     * saying so. Both end the same way -- there is nothing left that can say
     * what these bytes are, so they go.
     */
    csx_delete(CSX_WALLPAPER_SLOT);
}
