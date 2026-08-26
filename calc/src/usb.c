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

#include "csx.h"
#include "library.h"

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
static const uint8_t *reply_body;
static uint32_t reply_body_len;
static uint32_t reply_body_sent;

/*
 * Answers gathered once, before USB starts, and served from memory afterwards.
 * See rule 3: none of the read-only commands may call the OS.
 */
static uint24_t cached_archive_free;
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

/* Queue a reply. `body` may be NULL, and may point into flash. */
static void answer(uint16_t status, const uint8_t *body, uint32_t length) {
    reply_header[0] = command;
    reply_header[1] = sequence;
    put16(reply_header + 2, status);
    reply_header[4] = (uint8_t)length;
    reply_header[5] = (uint8_t)(length >> 8);
    reply_header[6] = (uint8_t)(length >> 16);
    reply_header[7] = (uint8_t)(length >> 24);

    reply_header_sent = 0;
    reply_body = body;
    reply_body_len = body ? length : 0;
    reply_body_sent = 0;
    link_state = LINK_REPLY;
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

    const uint8_t *here = lib_id();
    if (here) {
        which = (payload_want >= LIB_ID_SIZE
                 && memcmp(here, payload, LIB_ID_SIZE) == 0)
            ? PROTO_LIBRARY_SAME
            : PROTO_LIBRARY_DIFFERENT;
    }
    library_state = (uint8_t)which;

    reply_small[0] = PROTO_VERSION;
    put24(reply_small + 1, cached_archive_free);
    reply_small[4] = CSX_MAX_CHUNKS;
    reply_small[5] = CSX_CHUNK_SIZE / 256;
    reply_small[6] = (uint8_t)which;
    answer(PROTO_OK, reply_small, 7);
}

static void do_reset(void) {
    uint16_t removed = lib_reset();
    library_state = PROTO_LIBRARY_EMPTY;

    cached_index = NULL;
    cached_index_size = 0;

    put16(reply_small, removed);
    answer(PROTO_OK, reply_small, 2);
}

static void do_space(void) {
    put24(reply_small, cached_archive_free);
    answer(PROTO_OK, reply_small, 3);
}

#define LIST_RECORD 14

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
        record[0] = strip.slot;
        record[1] = strip.chunk_count;
        put24(record + 2, strip.bytes);
        record[5] = strip.flags;
        record[6] = (uint8_t)strip.read_at;
        record[7] = (uint8_t)(strip.read_at >> 8);
        record[8] = (uint8_t)(strip.read_at >> 16);
        record[9] = (uint8_t)(strip.read_at >> 24);
        put24(record + 10, strip.pos);
        record[13] = strip.layer;
    }

    answer(PROTO_OK, payload, needed);
}

static void do_index_get(void) {
    if (!cached_index || !cached_index_size) {
        answer(PROTO_OK, NULL, 0);
        return;
    }
    answer(PROTO_OK, cached_index, cached_index_size);
}

/* Create one appvar from what is already in `payload`, and archive it. */
static bool store(const char *name, uint32_t length) {
    ti_Delete(name);

    uint8_t handle = ti_Open(name, "w");
    if (!handle)
        return false;

    bool ok = ti_Write(payload, (size_t)length, 1, handle) == 1;

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

static void do_put_chunk(void) {
    char name[9];
    csx_chunk_name(name, (uint8_t)argument, (uint8_t)(argument >> 8));
    answer(store(name, payload_want) ? PROTO_OK : PROTO_NO_ROOM, NULL, 0);
}

static void do_index_put(void) {
    bool ok = store(LIB_NAME, payload_want);
    if (ok) {
        /* Every pointer into the old index is stale now. */
        lib_open();
        cached_index = NULL;
        cached_index_size = 0;

        uint8_t handle = ti_Open(LIB_NAME, "r");
        if (handle) {
            cached_index_size = (uint16_t)ti_GetSize(handle);
            cached_index = ti_GetDataPtr(handle);
            ti_Close(handle);
        }
    }
    answer(ok ? PROTO_OK : PROTO_WRITE_FAIL, NULL, 0);
}

static void do_delete(void) {
    uint8_t removed = csx_delete((uint8_t)argument);
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
            } else if (payload_want > CSX_CHUNK_SIZE || !payload) {
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
static void gather_state(void) {
    os_ArcChk();
    cached_archive_free = os_TempFreeArc;

    cached_index = NULL;
    cached_index_size = 0;

    uint8_t handle = ti_Open(LIB_NAME, "r");
    if (handle) {
        cached_index_size = (uint16_t)ti_GetSize(handle);
        cached_index = ti_GetDataPtr(handle);
        ti_Close(handle);
    }
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

    gather_state();

    /* The band cache has been handed back by now, so there is room. */
    payload = malloc(CSX_CHUNK_SIZE);

    if (usb_Init(handle_event, NULL, srl_GetCDCStandardDescriptors(),
                 USB_DEFAULT_INIT_FLAGS) != USB_SUCCESS) {
        usb_Cleanup();
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
    free(payload);
    payload = NULL;
    return true;
}
