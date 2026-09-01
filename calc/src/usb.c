/*
 * The calculator end of the sync protocol, over USB serial.
 *
 * The calculator presents a USB CDC serial port through srldrvce and the
 * computer talks to it with the Web Serial API. srldrvce sits on usbdrvce
 * underneath, and is the one device-mode path on this platform known to work --
 * the toolchain's srl_echo example demonstrates it, and this file is shaped
 * deliberately like srl_echo's main loop.
 *
 * Four rules came out of getting this wrong repeatedly, and the structure below
 * exists to keep them:
 *
 *   1. One usb_HandleEvents() per turn round the loop, at the top, always.
 *      Nothing nests another event pump inside itself.
 *
 *   2. Nothing blocks. srl_Read and srl_Write are non-blocking by contract --
 *      they push and pop a ring buffer -- so every state below does a bounded
 *      amount of work and returns. There are no inner loops waiting on the
 *      computer, so the keypad is always scanned and `clear` always works.
 *
 *   3. Operating-system calls happen in exactly one place, execute(), between
 *      finishing a read and starting a write -- never interleaved with USB
 *      traffic. Creating and archiving an appvar is a flash write; doing that
 *      while transfers are in flight is asking for trouble.
 *
 *   4. Nothing asks the OS an expensive question. Free archive space comes from
 *      os_ArcChk(), one call, whose answer the OS leaves in os_TempFreeArc.
 *      This used to binary-search ti_ArchiveHasRoom -- twenty-four calls, each
 *      one walking the VAT and flash, several of them asking whether eight
 *      megabytes would fit. That alone froze the calculator, with or without a
 *      cable attached, and it was the last of a long line of USB-shaped bugs
 *      that turned out not to be about USB at all.
 *
 * See docs/PROTOCOL.md.
 */

#include "proto.h"

#include "build.h"
#include "crc32.h"
#include "csx.h"
#include "library.h"
#include "update.h"
#include "wall.h"

#include <fileioc.h>
#include <srldrvce.h>
#include <stdlib.h>
#include <string.h>
#include <tice.h>
#include <usbdrvce.h>

/*
 * srldrvce's ring buffer. It wants at least 128 bytes and an even size, and
 * recommends 512; bigger is better here. The driver schedules 64-byte reads and
 * re-arms when we drain it, so a larger ring lets more accumulate between our
 * turns and makes throughput less sensitive to how often we get round to it.
 */
#define SERIAL_BUFFER 2048

/* Bytes moved per turn. There is no point asking for more than the ring holds. */
#define SLICE SERIAL_BUFFER

/*
 * Somewhere to throw away a payload that cannot be held.
 *
 * Emphatically not serial_buffer: that belongs to srldrvce and it is using it.
 */
static uint8_t discard_scratch[256];

/* ------------------------------------------------------------------- state */

static srl_device_t serial;
static uint8_t serial_buffer[SERIAL_BUFFER];
static bool serial_open;
static srl_error_t open_error;

static bool finished;
static bool closing;             /* BYE seen; stop once its reply is out */

/*
 * Where the link is up to. Each turn advances one state by at most one slice,
 * then returns to the loop.
 */
typedef enum {
    LINK_HEADER,      /* collecting the eight header bytes */
    LINK_PAYLOAD,     /* collecting the payload into `payload` */
    LINK_DISCARD,     /* throwing away a payload too big to hold */
    LINK_REPLY,       /* pushing the reply out */
} link_state_t;

static link_state_t link_state;

static uint8_t header[PROTO_HEADER_SIZE];
static uint8_t header_have;

static uint8_t command;
static uint8_t sequence;
static uint16_t argument;

static uint8_t *payload;         /* one whole chunk, allocated before usb_Init */
static uint32_t payload_want;
static uint32_t payload_have;

static uint8_t reply_header[PROTO_HEADER_SIZE];
static uint8_t reply_header_sent;
static uint8_t reply_small[16];  /* bodies that are a handful of bytes */

/*
 * A reply whose first bytes are not the ones in flash.
 *
 * INDEX_GET is the only user: the index is far too big to copy into RAM, but
 * its header has to be edited before it goes out, so the header is copied here
 * and the rest still streams straight from flash behind it.
 */
static uint8_t reply_prefix[LIB_HEADER_SIZE];
static uint16_t reply_prefix_len;
static uint16_t reply_prefix_sent;

static const uint8_t *reply_body;
static uint32_t reply_body_len;
static uint32_t reply_body_sent;

/*
 * Answers gathered once, before USB starts, and served from memory afterwards.
 * See rule 3: none of the read-only commands may call the OS.
 */
static uint24_t cached_archive_free;
static uint8_t cached_flags;

/*
 * Which build is armed and waiting for prgmCSUP, or 0.
 *
 * The flag alone is not enough for the page to reason with. A reader update is
 * armed, not installed, so HELLO keeps reporting the build that is *running* --
 * and a page that only knows "something is armed" cannot tell an update it has
 * just sent from one that is now out of date itself.
 */
static uint16_t cached_armed_build;

static const uint8_t *cached_index;
static uint16_t cached_index_size;

/* Counters the sync screen displays; the only view into a stall. */
static uint16_t requests_handled;
static uint8_t last_command;
static uint16_t link_errors;
static uint24_t loop_count;
static uint24_t bytes_moved;
static uint8_t library_state;

uint16_t proto_requests(void) { return requests_handled; }
uint8_t proto_last_command(void) { return last_command; }
uint16_t proto_errors(void) { return link_errors; }
uint8_t proto_open_error(void) { return (uint8_t)open_error; }
uint24_t proto_loops(void) { return loop_count; }
uint24_t proto_bytes(void) { return bytes_moved; }
uint8_t proto_library_state(void) { return library_state; }

/* ----------------------------------------------------------------- helpers */

static uint16_t read16(const uint8_t *p) {
    return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

static uint32_t read32(const uint8_t *p) {
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8)
         | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static void put16(uint8_t *p, uint16_t value) {
    p[0] = (uint8_t)value;
    p[1] = (uint8_t)(value >> 8);
}

static void put24(uint8_t *p, uint24_t value) {
    p[0] = (uint8_t)value;
    p[1] = (uint8_t)(value >> 8);
    p[2] = (uint8_t)(value >> 16);
}

/*
 * Queue a reply of `reply_prefix[0..prefix_len)` followed by `body`.
 *
 * `body` may be NULL, and may point into flash. The prefix exists for INDEX_GET
 * alone: the index is far too big to copy into RAM, but its header has to be
 * edited before it goes out, so the header is copied and the rest still streams
 * from flash behind it.
 */
static void answer_prefixed(uint16_t status, uint16_t prefix_len,
                            const uint8_t *body, uint32_t length) {
    uint32_t total = prefix_len + (body ? length : 0);

    reply_header[0] = command;
    reply_header[1] = sequence;
    put16(reply_header + 2, status);
    reply_header[4] = (uint8_t)total;
    reply_header[5] = (uint8_t)(total >> 8);
    reply_header[6] = (uint8_t)(total >> 16);
    reply_header[7] = (uint8_t)(total >> 24);

    reply_header_sent = 0;
    reply_prefix_len = prefix_len;
    reply_prefix_sent = 0;
    reply_body = body;
    reply_body_len = body ? length : 0;
    reply_body_sent = 0;
    link_state = LINK_REPLY;
}

static void answer(uint16_t status, const uint8_t *body, uint32_t length) {
    answer_prefixed(status, 0, body, length);
}

/* ---------------------------------------------------------------- commands */

/*
 * HELLO carries the computer's library identifier, and the answer says whether
 * it matches what is already here. Mixing two libraries would leave the
 * calculator holding comics the computer cannot account for, so it is worth
 * knowing before anything is sent.
 */
static void do_hello(void) {
    proto_library_t which = PROTO_LIBRARY_EMPTY;

    /* All zeros means the computer has no library to compare, not a library
     * whose identity happens to be zero. */
    bool told = false;
    if (payload_want >= LIB_ID_SIZE) {
        for (uint8_t i = 0; i < LIB_ID_SIZE; i++) {
            if (payload[i]) {
                told = true;
                break;
            }
        }
    }

    const uint8_t *here = lib_id();
    if (here) {
        which = !told
            ? PROTO_LIBRARY_UNKNOWN
            : (memcmp(here, payload, LIB_ID_SIZE) == 0
                ? PROTO_LIBRARY_SAME
                : PROTO_LIBRARY_DIFFERENT);
    }
    library_state = (uint8_t)which;

    reply_small[0] = PROTO_VERSION;
    put24(reply_small + 1, cached_archive_free);
    reply_small[4] = CSX_MAX_CHUNKS;
    reply_small[5] = CSX_CHUNK_SIZE / 256;
    reply_small[6] = (uint8_t)which;
    put16(reply_small + 7, COMICS_BUILD);
    reply_small[9] = cached_flags;
    put16(reply_small + 10, cached_armed_build);
    answer(PROTO_OK, reply_small, 12);
}

/* Re-map the index after anything that moved or replaced it. */
static void refresh_index_cache(void) {
    cached_index = NULL;
    cached_index_size = 0;

    uint8_t handle = ti_Open(LIB_NAME, "r");
    if (!handle)
        return;

    cached_index_size = (uint16_t)ti_GetSize(handle);
    cached_index = ti_GetDataPtr(handle);
    ti_Close(handle);
}

static void do_reset(void) {
    uint16_t removed = lib_reset();
    library_state = PROTO_LIBRARY_EMPTY;

    /* lib_reset empties the index rather than deleting it -- the device block
     * is in there -- so there is still something to point at. */
    refresh_index_cache();

    put16(reply_small, removed);
    answer(PROTO_OK, reply_small, 2);
}

static void do_space(void) {
    put24(reply_small, cached_archive_free);
    answer(PROTO_OK, reply_small, 3);
}

#define LIST_RECORD 15

static void do_list(void) {
    uint16_t count = lib_strip_count();

    /* Built into the payload buffer, which is idle while a reply is going out
     * and far larger than any list can be. */
    uint32_t needed = 2 + (uint32_t)count * LIST_RECORD;
    if (!payload || needed > CSX_CHUNK_SIZE) {
        answer(PROTO_WRITE_FAIL, NULL, 0);
        return;
    }

    put16(payload, count);
    for (uint16_t i = 0; i < count; i++) {
        lib_strip_t strip;
        lib_get_strip(i, &strip);

        uint8_t *record = payload + 2 + (uint24_t)i * LIST_RECORD;
        put16(record, strip.slot);
        record[2] = strip.chunk_count;
        put24(record + 3, strip.bytes);
        record[6] = strip.flags;
        record[7] = (uint8_t)strip.read_at;
        record[8] = (uint8_t)(strip.read_at >> 8);
        record[9] = (uint8_t)(strip.read_at >> 16);
        record[10] = (uint8_t)(strip.read_at >> 24);
        put24(record + 11, strip.pos);
        record[14] = strip.layer;
    }

    answer(PROTO_OK, payload, needed);
}

static void do_index_get(void) {
    if (!cached_index || cached_index_size < LIB_HEADER_SIZE) {
        answer(PROTO_OK, NULL, 0);
        return;
    }

    /*
     * The device block goes out as zeros. That keeps the password salt and hash
     * off the wire, where a computer that is not this library's could otherwise
     * ask for them -- and it is also what lets the page compare this against the
     * index it would build, which has zeros there. Sending the real block would
     * make the index look stale on every single sync.
     */
    memcpy(reply_prefix, cached_index, LIB_HEADER_SIZE);
    memset(reply_prefix + LIB_DEVICE_OFFSET, 0, LIB_DEVICE_SIZE);

    answer_prefixed(PROTO_OK, LIB_HEADER_SIZE,
                    cached_index + LIB_HEADER_SIZE,
                    cached_index_size - LIB_HEADER_SIZE);
}

/* Create one appvar from `data`, and archive it. */
static bool store_from(const char *name, const uint8_t *data, uint32_t length) {
    ti_Delete(name);

    uint8_t handle = ti_Open(name, "w");
    if (!handle)
        return false;

    bool ok = ti_Write(data, (size_t)length, 1, handle) == 1;

    /*
     * Archive rather than checking for room first: the OS collects deleted
     * variables here if it needs to, which a room test would have refused
     * without ever freeing anything.
     */
    bool archived = ok && ti_SetArchiveStatus(true, handle) != 0;
    ti_Close(handle);
    if (!archived)
        ti_Delete(name);
    return archived;
}

/* The same, from the start of the payload buffer. */
static bool store(const char *name, uint32_t length) {
    return store_from(name, payload, length);
}

/*
 * Read an appvar back and check it against a CRC.
 *
 * ti_GetDataPtr on an archived variable points straight into flash, so this
 * checks the bytes that were really written rather than the copy still sitting
 * in the payload buffer. That is the whole point of doing it here rather than
 * on the computer: it covers the flash write, not just the wire.
 */
static bool stored_matches(const char *name, uint32_t want, uint32_t length) {
    uint8_t handle = ti_Open(name, "r");
    if (!handle)
        return false;

    uint32_t size = (uint32_t)ti_GetSize(handle);
    const uint8_t *data = ti_GetDataPtr(handle);
    ti_Close(handle);

    if (!data || size != length)
        return false;

    return crc32_finish(crc32_update(CRC32_INIT, data, (size_t)length)) == want;
}

/*
 * One chunk of a strip.
 *
 * `arg` is the slot, which needs all sixteen bits of it now that a library may
 * hold more than 256 strips -- so the chunk index moves to the front of the
 * payload, and from protocol 4 the chunk's CRC-32 goes in behind it. That used
 * to be impossible: the old packet-based transport would have put those bytes
 * in the same packet as the data behind them, with no way to read them
 * separately. A byte stream has no such problem, and the whole payload is
 * already in one buffer before this runs.
 */
static void do_put_chunk(void) {
    /* u8 chunk index, u32 CRC-32, and at least one byte of chunk. */
    if (payload_want < 6) {
        answer(PROTO_BAD_LENGTH, NULL, 0);
        return;
    }

    uint8_t index = payload[0];
    uint32_t want = read32(payload + 1);
    uint32_t length = payload_want - 5;

    char name[9];
    csx_chunk_name(name, argument, index);

    if (!store_from(name, payload + 5, length)) {
        answer(PROTO_NO_ROOM, NULL, 0);
        return;
    }

    if (!stored_matches(name, want, length)) {
        /*
         * Take it away rather than leave it where csx_open() would find it and
         * refuse the whole strip months later. The computer sends it again; if
         * it keeps failing, the sync says so while somebody is still watching.
         */
        ti_Delete(name);
        answer(PROTO_BAD_CRC, NULL, 0);
        return;
    }

    answer(PROTO_OK, NULL, 0);
}

/*
 * Does this strip open?
 *
 * The same call the reader makes when a strip is picked, so a "yes" here means
 * the same thing it will mean then: every chunk is present, the header parses,
 * and the geometry is one this build can draw. A per-chunk CRC cannot answer
 * this -- it only ever sees the chunks that turned up.
 */
static void do_verify(void) {
    csx_strip_t strip;

    if (!csx_open(&strip, argument)) {
        answer(PROTO_NOT_FOUND, NULL, 0);
        return;
    }

    reply_small[0] = strip.chunk_count;
    answer(PROTO_OK, reply_small, 1);
}

static void do_index_put(void) {
    /* Anything shorter has no header, so storing it would lose the device block
     * and leave nothing that lib_open would accept. */
    if (payload_want < LIB_HEADER_SIZE) {
        answer(PROTO_BAD_LENGTH, NULL, 0);
        return;
    }

    /*
     * The computer replaces this variable whole and has no idea the device block
     * is in it -- it sends zeros there. Carry the live block across first, or
     * every index push would quietly clear the password.
     */
    const uint8_t *device = lib_device();
    if (device)
        memcpy(payload + LIB_DEVICE_OFFSET, device, LIB_DEVICE_SIZE);
    else
        memset(payload + LIB_DEVICE_OFFSET, 0, LIB_DEVICE_SIZE);

    bool ok = store(LIB_NAME, payload_want);
    if (ok) {
        /* Every pointer into the old index is stale now. */
        lib_open();
        refresh_index_cache();
    }
    answer(ok ? PROTO_OK : PROTO_WRITE_FAIL, NULL, 0);
}

/* ----------------------------------------------------------------- update */

/*
 * The update in flight, if any. Held only for the length of a session: an
 * update that is interrupted leaves chunks behind but no manifest, and the next
 * UPDATE_BEGIN sweeps them.
 */
static update_manifest_t incoming;
static bool receiving_update;

static void do_update_begin(void) {
    if (payload_want < 12) {
        answer(PROTO_BAD_LENGTH, NULL, 0);
        return;
    }

    incoming.target = (uint8_t)argument;
    incoming.build = read16(payload);
    incoming.bytes = read32(payload + 2);
    incoming.chunks = read16(payload + 6);
    incoming.crc = read32(payload + 8);

    if (incoming.target >= UPDATE_TARGET_COUNT || !incoming.bytes ||
        !incoming.chunks || incoming.chunks > UPDATE_MAX_CHUNKS ||
        incoming.bytes > (uint32_t)incoming.chunks * UPDATE_CHUNK_SIZE) {
        receiving_update = false;
        answer(PROTO_BAD_LENGTH, NULL, 0);
        return;
    }

    /* Anything already here for this target is a different update, or the
     * wreckage of one that was interrupted. Either way it is in the way --
     * and only this target's, so a reader update and a lock screen update can
     * both be in flight in one sync. */
    update_discard(incoming.target);
    receiving_update = true;
    answer(PROTO_OK, NULL, 0);
}

static void do_update_chunk(void) {
    if (!receiving_update) {
        answer(PROTO_BAD_STATE, NULL, 0);
        return;
    }

    uint8_t index = (uint8_t)(argument >> 8);
    if (index >= incoming.chunks) {
        answer(PROTO_BAD_LENGTH, NULL, 0);
        return;
    }

    char name[7];
    update_chunk_name(name, incoming.target, index);
    answer(store(name, payload_want) ? PROTO_OK : PROTO_NO_ROOM, NULL, 0);
}

static void do_update_end(void) {
    if (!receiving_update) {
        answer(PROTO_BAD_STATE, NULL, 0);
        return;
    }
    receiving_update = false;

    if (!update_verify(&incoming)) {
        /* Nothing was replaced, so there is nothing to roll back -- just take
         * the damaged image away so it cannot be installed later. */
        update_discard(incoming.target);
        answer(PROTO_TRUNCATED, NULL, 0);
        return;
    }

    /*
     * An updater update is applied here and now. CSUP is not running, so this
     * program can replace it, and doing it immediately means the user never
     * sees it. A reader update cannot be applied by the reader, so it is armed
     * and CSUP installs it later.
     */
    if (incoming.target == UPDATE_TARGET_UPDATER) {
        bool ok = update_install(UPDATE_UPDATER_NAME, &incoming);
        update_discard(incoming.target);
        if (ok)
            cached_flags |= PROTO_FLAG_UPDATER;
        answer(ok ? PROTO_OK : PROTO_WRITE_FAIL, NULL, 0);
        return;
    }

    bool ok = update_arm(&incoming);
    if (ok) {
        cached_flags |= PROTO_FLAG_ARMED;
        cached_armed_build = incoming.build;
    }
    answer(ok ? PROTO_OK : PROTO_WRITE_FAIL, NULL, 0);
}

/*
 * The computer's idea of the time.
 *
 * Sent at the start of every sync. The calculator keeps the difference rather
 * than touching the RTC, so nothing here depends on what epoch the clock counts
 * from -- only on it running. See lib_set_clock().
 */
static void do_clock_set(void) {
    if (payload_want < 4) {
        answer(PROTO_BAD_LENGTH, NULL, 0);
        return;
    }

    bool ok = lib_set_clock(read32(payload));

    /*
     * Writing the device block unarchives and re-archives the index, so the
     * pointer cached before USB started is stale. That matters more than it
     * looks: CLOCK_SET is the second command of every sync and INDEX_GET is the
     * fourth, so the reply to INDEX_GET would be read from wherever the index
     * used to be.
     */
    refresh_index_cache();
    answer(ok ? PROTO_OK : PROTO_WRITE_FAIL, NULL, 0);
}

/*
 * The lock screen wallpaper has just been stored, or is being removed.
 *
 * `arg` is 1 to adopt what is in the reserved slot and 0 to be rid of it.
 * Adopting checksums the container and writes the claim into the device block,
 * which is what ties the wallpaper to the index -- see calc/src/wall.h.
 */
static void do_wallpaper(void) {
    bool ok;
    if (argument) {
        ok = wall_adopt();
    } else {
        wall_forget();
        ok = true;
    }

    /* Same as above: the claim lives in the index, and writing it moved it. */
    refresh_index_cache();
    answer(ok ? PROTO_OK : PROTO_NOT_FOUND, NULL, 0);
}

/* ---------------------------------------------------------------- the rest */

static void do_delete(void) {
    uint8_t removed = csx_delete(argument);
    reply_small[0] = removed;
    answer(removed ? PROTO_OK : PROTO_NOT_FOUND, reply_small, 1);
}

/*
 * Run the command. This is the only place that talks to the OS, and it runs
 * with the whole request already in memory and nothing being transferred.
 */
static void execute(void) {
    requests_handled++;
    last_command = command;

    switch (command) {
        case PROTO_HELLO:     do_hello(); break;
        case PROTO_LIST:      do_list(); break;
        case PROTO_PUT_CHUNK: do_put_chunk(); break;
        case PROTO_DEL:       do_delete(); break;
        case PROTO_INDEX_GET: do_index_get(); break;
        case PROTO_INDEX_PUT: do_index_put(); break;
        case PROTO_SPACE:     do_space(); break;
        case PROTO_RESET:     do_reset(); break;

        case PROTO_UPDATE_BEGIN: do_update_begin(); break;
        case PROTO_UPDATE_CHUNK: do_update_chunk(); break;
        case PROTO_UPDATE_END:   do_update_end(); break;

        case PROTO_CLOCK_SET:    do_clock_set(); break;
        case PROTO_VERIFY:       do_verify(); break;
        case PROTO_WALLPAPER:    do_wallpaper(); break;
        case PROTO_BYE:       closing = true; answer(PROTO_OK, NULL, 0); break;
        default:              answer(PROTO_BAD_CMD, NULL, 0); break;
    }
}

/* ------------------------------------------------------------------- pump */

static void fail(void) {
    link_errors++;
    serial_open = false;
    link_state = LINK_HEADER;
    header_have = 0;
}

/* Advance the link by at most one slice. Never loops, never blocks. */
static void pump(void) {
    switch (link_state) {
        case LINK_HEADER: {
            int got = srl_Read(&serial, header + header_have,
                               PROTO_HEADER_SIZE - header_have);
            if (got < 0) {
                fail();
                return;
            }
            header_have += (uint8_t)got;
            if (header_have < PROTO_HEADER_SIZE)
                return;

            header_have = 0;
            command = header[0];
            sequence = header[1];
            argument = read16(header + 2);
            payload_want = read32(header + 4);
            payload_have = 0;

            if (!payload_want) {
                execute();
            } else if (payload_want > CSX_CHUNK_SIZE + PROTO_ARG_BYTES || !payload) {
                /* Nothing here can hold it; swallow it and say so. */
                link_state = LINK_DISCARD;
            } else {
                link_state = LINK_PAYLOAD;
            }
            return;
        }

        case LINK_PAYLOAD: {
            uint32_t left = payload_want - payload_have;
            size_t take = left > SLICE ? SLICE : (size_t)left;

            int got = srl_Read(&serial, payload + payload_have, take);
            if (got < 0) {
                fail();
                return;
            }
            payload_have += (uint32_t)got;
            bytes_moved += (uint24_t)got;
            if (payload_have >= payload_want)
                execute();
            return;
        }

        case LINK_DISCARD: {
            uint32_t left = payload_want - payload_have;
            size_t take = left > sizeof discard_scratch
                ? sizeof discard_scratch : (size_t)left;

            int got = srl_Read(&serial, discard_scratch, take);
            if (got < 0) {
                fail();
                return;
            }
            payload_have += (uint32_t)got;
            if (payload_have >= payload_want) {
                requests_handled++;
                last_command = command;
                answer(PROTO_BAD_LENGTH, NULL, 0);
            }
            return;
        }

        case LINK_REPLY: {
            if (reply_header_sent < PROTO_HEADER_SIZE) {
                int sent = srl_Write(&serial, reply_header + reply_header_sent,
                                     PROTO_HEADER_SIZE - reply_header_sent);
                if (sent < 0) {
                    fail();
                    return;
                }
                reply_header_sent += (uint8_t)sent;
                return;
            }

            if (reply_prefix_sent < reply_prefix_len) {
                int sent = srl_Write(&serial, reply_prefix + reply_prefix_sent,
                                     reply_prefix_len - reply_prefix_sent);
                if (sent < 0) {
                    fail();
                    return;
                }
                reply_prefix_sent += (uint16_t)sent;
                bytes_moved += (uint24_t)sent;
                return;
            }

            if (reply_body_sent < reply_body_len) {
                uint32_t left = reply_body_len - reply_body_sent;
                size_t take = left > SLICE ? SLICE : (size_t)left;

                int sent = srl_Write(&serial, reply_body + reply_body_sent, take);
                if (sent < 0) {
                    fail();
                    return;
                }
                reply_body_sent += (uint32_t)sent;
                bytes_moved += (uint24_t)sent;
                return;
            }

            link_state = LINK_HEADER;
            if (closing)
                finished = true;
            return;
        }
    }
}

/* --------------------------------------------------------- garbage collect */

/*
 * The OS defragments the archive when it runs out of room, and it asks the user
 * first -- so this takes as long as it takes, and there is no upper bound on
 * it. Left alone, the computer would decide the calculator had died, give up
 * part-way through sending a strip, and leave the two disagreeing about what is
 * stored.
 *
 * So: say so before it starts, and repair the damage afterwards.
 */

static uint8_t gc_count;

uint8_t proto_collections(void) { return gc_count; }

/*
 * Push a few bytes out with a hard cap on effort, since this runs at a moment
 * when nothing else can.
 *
 * It has to pump USB itself -- srl_Write only moves bytes when the driver gets
 * a turn, and the loop that would normally give it one is several frames away
 * inside an OS flash operation. That is a deliberate exception to rule 1 above,
 * and the only one.
 *
 * It must be all or nothing. The protocol is a byte stream with no framing to
 * resynchronise on, so half an eight-byte header slides every reply after it by
 * the missing number of bytes, and the computer spends the rest of the session
 * reading garbage out of correctly-delivered data. If the whole notice cannot
 * be got out, the link is declared dead instead: the computer sees a timeout,
 * which is recoverable, rather than a stream that lies.
 */
static void send_now(const uint8_t *bytes, size_t length) {
    size_t left = length;

    for (unsigned attempts = 0; attempts < 4096 && left; attempts++) {
        usb_HandleEvents();

        int sent = srl_Write(&serial, bytes, left);
        if (sent < 0)
            break;
        bytes += sent;
        left -= (size_t)sent;
    }

    if (!left)
        return;

    /* Nothing went out, so nothing is out of step; the computer just waits on
     * its ordinary timeout. */
    if (left == length)
        return;

    fail();
}

static void gc_before(void) {
    gc_count++;

    if (!serial_open)
        return;

    /* Same shape as a reply header, so the computer's reader can recognise it
     * without any special framing. */
    uint8_t notice[PROTO_HEADER_SIZE];
    notice[0] = PROTO_BUSY;
    notice[1] = sequence;
    put16(notice + 2, PROTO_OK);
    notice[4] = notice[5] = notice[6] = notice[7] = 0;
    send_now(notice, sizeof notice);
}

static void gc_after(void) {
    /*
     * Every pointer from ti_GetDataPtr is meaningless now -- the collect moved
     * the variables it was pointing into. Fetch them again.
     */
    lib_open();

    refresh_index_cache();

    /* And the free space it just recovered is different. */
    os_ArcChk();
    cached_archive_free = os_TempFreeArc;
}

/* ------------------------------------------------------------------ events */

static usb_error_t handle_event(usb_event_t event, void *event_data,
                                usb_callback_data_t *callback_data) {
    /* srldrvce does the real work and needs to see every event first. */
    usb_error_t error = srl_UsbEventCallback(event, event_data, callback_data);
    if (error != USB_SUCCESS)
        return error;

    switch (event) {
        case USB_HOST_CONFIGURE_EVENT: {
            /*
             * Opened here rather than from the loop. srldrvce's header says not
             * to call srl_Open from an event handler; its own example does
             * exactly this, and the example is what works.
             */
            if (serial_open)
                break;

            usb_device_t device = usb_FindDevice(NULL, NULL, USB_SKIP_HUBS);
            if (!device)
                break;

            open_error = srl_Open(&serial, device, serial_buffer,
                                  sizeof serial_buffer, SRL_INTERFACE_ANY, 9600);
            serial_open = open_error == SRL_SUCCESS;
            break;
        }

        case USB_DEVICE_DISCONNECTED_EVENT:
        case USB_DEVICE_SUSPENDED_EVENT:
        case USB_DEVICE_DISABLED_EVENT:
            serial_open = false;
            link_state = LINK_HEADER;
            header_have = 0;
            break;

        default:
            break;
    }
    return USB_SUCCESS;
}

/* --------------------------------------------------------------------- run */

/*
 * Ask the OS everything the link will need, once, while nothing is in flight.
 *
 * os_ArcChk() is a single call and leaves its answer in os_TempFreeArc.
 */
/* Is prgmCSUP installed, and is a reader update waiting for it? */
static uint8_t gather_update_flags(void) {
    uint8_t flags = 0;
    cached_armed_build = 0;

    uint8_t handle = ti_OpenVar(UPDATE_UPDATER_NAME, "r", OS_TYPE_PRGM);
    if (handle) {
        ti_Close(handle);
        flags |= PROTO_FLAG_UPDATER;
    }

    update_manifest_t armed;
    if (update_pending(UPDATE_TARGET_READER, &armed)) {
        flags |= PROTO_FLAG_ARMED;
        cached_armed_build = armed.build;
    }

    return flags;
}

static void gather_state(void) {
    os_ArcChk();
    cached_archive_free = os_TempFreeArc;
    cached_flags = gather_update_flags();

    refresh_index_cache();
}

static const char *status_text(void) {
    if (!serial_open)
        return "Waiting for computer";

    switch (link_state) {
        case LINK_PAYLOAD: return "Receiving";
        case LINK_DISCARD: return "Skipping";
        case LINK_REPLY:   return "Replying";
        default:           return "Connected";
    }
}

bool proto_run(proto_progress_t progress, bool echo_only) {
    serial_open = false;
    open_error = SRL_SUCCESS;
    finished = false;
    closing = false;
    link_state = LINK_HEADER;
    header_have = 0;
    requests_handled = 0;
    last_command = 0;
    link_errors = 0;
    loop_count = 0;
    bytes_moved = 0;
    library_state = PROTO_LIBRARY_EMPTY;
    receiving_update = false;

    gather_state();
    gc_count = 0;
    ti_SetGCBehavior(gc_before, gc_after);

    /* The band cache has been handed back by now, so there is room. */
    payload = malloc(CSX_CHUNK_SIZE + PROTO_ARG_BYTES);

    if (usb_Init(handle_event, NULL, srl_GetCDCStandardDescriptors(),
                 USB_DEFAULT_INIT_FLAGS) != USB_SUCCESS) {
        usb_Cleanup();
        ti_SetGCBehavior(NULL, NULL);
        free(payload);
        payload = NULL;
        return false;
    }

    while (!finished) {
        loop_count++;
        usb_HandleEvents();

        if (serial_open) {
            if (echo_only) {
                /* Bytes in, the same bytes out, and nothing else at all. */
                int got = srl_Read(&serial, discard_scratch, sizeof discard_scratch);
                if (got < 0) {
                    fail();
                } else if (got > 0) {
                    requests_handled++;
                    last_command = discard_scratch[0];
                    if (srl_Write(&serial, discard_scratch, (size_t)got) < 0)
                        fail();
                }
            } else {
                pump();
            }
        }

        if (progress && !progress(echo_only ? "Echo" : status_text(), 0, 0, 0))
            break;
    }

    usb_Cleanup();
    ti_SetGCBehavior(NULL, NULL);
    free(payload);
    payload = NULL;
    return true;
}
