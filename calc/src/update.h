/*
 * Installing a new build of the reader, pushed over the sync link.
 *
 * A CE program runs in place inside its own variable, so it cannot overwrite
 * itself: deleting the variable would delete the code doing the deleting. eBookSync
 * gets round that with two programs that install each other.
 *
 *   COMICS  the reader. Installs CSUP, which is not running while it does.
 *   CSUP    the updater. Installs COMICS, which is not running while it does.
 *
 * So an updater update is invisible -- the reader applies it during the sync
 * that brings it down -- and only a reader update needs the user to quit and
 * run prgmCSUP once. It also means CSUP can be created from nothing, so the
 * only file that ever has to be installed by hand is COMICS.8xp.
 *
 * The image arrives the way a comic does: one archived appvar per 16 KB chunk.
 * It does not fit in RAM whole -- sync already holds 16 KB for the payload and
 * 2 KB for the serial ring, out of about 50 KB -- and chunks in flash can be
 * CRC'd and copied through pointers without ever being staged.
 */

#ifndef UPDATE_H
#define UPDATE_H

#include <stdbool.h>
#include <stdint.h>

/*
 * One armed update per target, so a sync that brings down a new reader and a
 * new lock screen together does not have the second sweep away the first.
 *
 * The manifest is CSUPD<target> and the chunks are CSU<target><index>, both in
 * hex. Before there were targets these were CSUPD and CSU<index>; update_sweep()
 * deletes those too, since a calculator updating into this version may be
 * holding one.
 */
#define UPDATE_MANIFEST_LEGACY "CSUPD"
#define UPDATE_MAGIC        "EUP1"
#define UPDATE_MANIFEST_SIZE 20

/* Room for 256 KB, which is far more than a CE program can ever be. */
#define UPDATE_MAX_CHUNKS   16
#define UPDATE_CHUNK_SIZE   16384

/* Which program an update is for. */
typedef enum {
    UPDATE_TARGET_READER  = 0,   /* COMICS,  installed by CSUP */
    UPDATE_TARGET_UPDATER = 1,   /* CSUP,    installed by COMICS */

    UPDATE_TARGET_COUNT   = 2,
} update_target_t;

#define UPDATE_READER_NAME  "COMICS"
#define UPDATE_UPDATER_NAME "CSUP"

/* The program one target names, or NULL if the target is not one. */
const char *update_target_name(uint8_t target);

typedef struct {
    uint8_t target;      /* update_target_t */
    uint16_t build;
    uint32_t bytes;
    uint16_t chunks;
    uint32_t crc;
} update_manifest_t;

/* The appvar holding one chunk: CSU<target><index>, hex. Needs 7 bytes. */
void update_chunk_name(char *name, uint8_t target, uint8_t index);

/* The appvar holding one target's manifest: CSUPD<target>. Needs 7 bytes. */
void update_manifest_name(char *name, uint8_t target);

/* Delete one target's manifest and chunks. Safe when there is nothing. */
void update_discard(uint8_t target);

/*
 * The same for every target, plus the names used before targets existed.
 *
 * Run once on the way in, so wreckage from an interrupted update -- or from the
 * version before this one -- does not sit in the archive for ever.
 */
void update_sweep(void);

/*
 * CRC every chunk where it lies in flash and compare against the manifest.
 *
 * Nothing is copied: the chunks are archived, so ti_GetDataPtr hands back a
 * flash address and the checksum runs straight over it.
 */
bool update_verify(const update_manifest_t *manifest);

/* Record a verified update, so it survives until something installs it. */
bool update_arm(const update_manifest_t *manifest);

/* The armed update for one target, if there is one. */
bool update_pending(uint8_t target, update_manifest_t *manifest);

/*
 * Replace `program` with the chunks, and archive it.
 *
 * The caller must not be running from `program`. Both callers satisfy that by
 * construction -- see the note at the top of this file -- and there is no way
 * to check it from here.
 */
bool update_install(const char *program, const update_manifest_t *manifest);

#endif /* UPDATE_H */
