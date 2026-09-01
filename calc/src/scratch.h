/*
 * One big buffer, shared by the two things that need one.
 *
 * The sync loop holds a whole chunk plus its arguments while a PUT_CHUNK is in
 * flight; the lock screen holds one decompressed band while it draws the
 * wallpaper. They are never both live -- the sync screen is the one place the
 * lock does nothing, deliberately -- so they are the same memory.
 *
 * Static rather than malloc'd, and that is the point. render_init() takes the
 * band cache by calling malloc until it is refused, so anything that asks the
 * heap for a large block afterwards gets nothing: the wallpaper used to, and
 * silently drew a flat colour instead. Reserving it up front costs the band
 * cache a couple of slots, which is a slower pan, and buys a sync that does not
 * run out of room to build a variable in -- which is a failed sync, reported as
 * "not enough archive space" on a calculator with megabytes free.
 */

#ifndef SCRATCH_H
#define SCRATCH_H

#include <stdint.h>

#include "csx.h"
#include "proto.h"

#define SCRATCH_SIZE (CSX_CHUNK_SIZE + PROTO_ARG_BYTES)

extern uint8_t scratch[SCRATCH_SIZE];

#endif /* SCRATCH_H */
