/*
 * Installing a new build of eOS, pushed over the sync link.
 *
 * A CE program runs in place inside its own variable, so it cannot overwrite
 * itself: deleting the variable would delete the code doing the deleting. eOS
 * gets round that with two programs that install each other.
 *
 *   EOS    the reader. Installs EOSUP, which is not running while it does.
 *   EOSUP  the updater. Installs EOS, which is not running while it does.
 *
 * So an updater update is invisible -- the reader applies it during the sync
 * that brings it down -- and only a reader update needs the user to quit and
 * run prgmEOSUP once. It also means EOSUP can be created from nothing, so the
 * only file that ever has to be installed by hand is EOS.8xp.
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

#define UPDATE_MANIFEST     "EOSUPD"
#define UPDATE_MAGIC        "EUP1"
#define UPDATE_MANIFEST_SIZE 20

/* Room for 256 KB, which is far more than a CE program can ever be. */
#define UPDATE_MAX_CHUNKS   16
#define UPDATE_CHUNK_SIZE   16384

/* Which program an update is for. Each is installed by the other one. */
typedef enum {
    UPDATE_TARGET_READER  = 0,   /* EOS,   installed by EOSUP */
    UPDATE_TARGET_UPDATER = 1,   /* EOSUP, installed by EOS */
} update_target_t;

#define UPDATE_READER_NAME  "EOS"
#define UPDATE_UPDATER_NAME "EOSUP"

typedef struct {
    uint8_t target;      /* update_target_t */
    uint16_t build;
    uint32_t bytes;
    uint16_t chunks;
    uint32_t crc;
} update_manifest_t;

/* The appvar holding one chunk: EOSU<index>, hex. */
void update_chunk_name(char *name, uint8_t index);

/* Delete the manifest and every chunk. Safe to call when there is nothing. */
void update_discard(void);

/*
 * CRC every chunk where it lies in flash and compare against the manifest.
 *
 * Nothing is copied: the chunks are archived, so ti_GetDataPtr hands back a
 * flash address and the checksum runs straight over it.
 */
bool update_verify(const update_manifest_t *manifest);

/* Record a verified update, so it survives until something installs it. */
bool update_arm(const update_manifest_t *manifest);

/* The armed update, if there is one. */
bool update_pending(update_manifest_t *manifest);

/*
 * Replace `program` with the chunks, and archive it.
 *
 * The caller must not be running from `program`. Both callers satisfy that by
 * construction -- see the note at the top of this file -- and there is no way
 * to check it from here.
 */
bool update_install(const char *program, const update_manifest_t *manifest);

#endif /* UPDATE_H */
