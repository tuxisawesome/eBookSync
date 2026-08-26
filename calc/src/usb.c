/*
 * The calculator end of the sync protocol, over USB serial.
 *
 * The calculator presents itself as a USB CDC serial port using srldrvce, and
 * the computer talks to it with the Web Serial API. srldrvce sits on the same
 * usbdrvce underneath, but it is the one device-mode path on this platform that
 * is known to work -- the toolchain's srl_echo example demonstrates it.
 *
 * A hand-written vendor-class WebUSB device was tried first and could not be
 * made to work: descriptors, control requests, endpoint lookup and transfer
 * scheduling all had to be right at once, and the failure mode was always the
 * same silent freeze inside usb_HandleEvents(). All of that is srldrvce's
 * problem now. What is left here is a byte stream, which is all the protocol
 * ever needed.
 *
 * See docs/PROTOCOL.md.
 */

#include "proto.h"

#include "csx.h"
#include "library.h"

#include <fileioc.h>
#include <stdlib.h>
#include <string.h>
#include <tice.h>
#include <srldrvce.h>
#include <usbdrvce.h>


/*
 * Staging buffer for chunk payloads. Small on purpose: chunks are written
 * straight into the appvar as they arrive rather than held whole in RAM.
 */
#define STREAM_BUFFER 512

static bool finished;

static uint8_t stream[STREAM_BUFFER];

/* Filled a few bytes at a time by the main loop until a whole header is in. */
static uint8_t request_header[PROTO_HEADER_SIZE];
static uint8_t header_filled;

/*
 * Counters the sync screen puts on display. When a sync stalls, the difference
 * between "nothing ever arrived", "requests arrive but replies fail" and "the
 * link dropped" is the whole diagnosis, and there is nowhere else to see it.
 */
static uint16_t requests_handled;
static uint8_t last_command;
static uint16_t receive_errors;
static uint24_t loop_count;


/* ------------------------------------------------------------------- state */

/*
 * srldrvce's working buffer. It wants at least 128 bytes, an even size, and
 * recommends 512.
 */
static uint8_t serial_buffer[512];

/*
 * Everything the read-only commands answer with, gathered before USB starts.
 *
 * Those answers come from the OS -- ti_ArchiveHasRoom walks the VAT and flash,
 * and HELLO used to call it two dozen times in a binary search. Running OS
 * routines like that while a USB transfer may be in flight is what froze the
 * link: the echo test, which touches nothing but srl_Read and srl_Write, has
 * never once failed. So the OS is asked once, up front, and the answers are
 * served from here.
 */
/*
 * A whole chunk is taken into RAM before any of it is written.
 *
 * Writing as it arrived meant ti_Write calls interleaved between USB reads --
 * OS work and USB traffic taking turns, which is the pattern most likely to
 * upset the driver. Now the transfer finishes first and the OS work happens in
 * one go with no USB in between. Allocated before usb_Init and freed after
 * usb_Cleanup, so the heap is never touched while the link is up.
 */
static uint8_t *chunk_buffer;

static uint24_t cached_archive_free;
static const uint8_t *cached_index;
static uint16_t cached_index_size;

static srl_device_t serial;
static bool serial_open;
static srl_error_t open_error;

/* Set while a command is being handled, so the stream helpers can keep the
 * screen alive and let the user give up. */
static proto_progress_t active_progress;

/*
 * Announce where we are, so a freeze leaves its last position on screen.
 *
 * The sync screen redraws whenever this string changes, so setting it is enough
 * to make it visible. A calculator that stops dead cannot be stepped through
 * and prints nothing; this is the substitute.
 */
static void step(const char *where) {
    if (active_progress)
        active_progress(where, 0, 0, 0);
}

/* ---------------------------------------------------------------- transport */

/*
 * Read exactly `length` bytes.
 *
 * srl_Read is non-blocking and returns what it has, so this pumps the USB event
 * loop and the progress callback while it waits. Nothing here ever blocks: a
 * computer that stops mid-message leaves the reader responsive and abortable
 * rather than wedged.
 */
static bool read_exact(void *buffer, size_t length) {
    uint8_t *out = buffer;

    while (length) {
        usb_HandleEvents();
        if (!serial_open)
            return false;

        int got = srl_Read(&serial, out, length);
        if (got < 0)
            return false;

        out += got;
        length -= (size_t)got;

        if (length && active_progress && !active_progress("Syncing", 0, 0, 0))
            return false;
    }
    return true;
}

static bool write_exact(const void *buffer, size_t length) {
    const uint8_t *in = buffer;

    while (length) {
        step("w: events");
        usb_HandleEvents();
        if (!serial_open)
            return false;

        step("w: srl_Write");
        int sent = srl_Write(&serial, in, length);
        if (sent < 0)
            return false;

        in += sent;
        length -= (size_t)sent;

        if (length && active_progress && !active_progress("Syncing", 0, 0, 0))
            return false;
    }
    return true;
}

static bool send_header(uint8_t cmd, uint8_t seq, uint16_t status, uint32_t length) {
    uint8_t header[PROTO_HEADER_SIZE];
    header[0] = cmd;
    header[1] = seq;
    header[2] = (uint8_t)status;
    header[3] = (uint8_t)(status >> 8);
    header[4] = (uint8_t)length;
    header[5] = (uint8_t)(length >> 8);
    header[6] = (uint8_t)(length >> 16);
    header[7] = (uint8_t)(length >> 24);
    return write_exact(header, sizeof header);
}

static bool reply(uint8_t cmd, uint8_t seq, uint16_t status) {
    return send_header(cmd, seq, status, 0);
}

/* Read and throw away a payload we cannot use, so the stream stays in step. */
static void drain(uint32_t length) {
    while (length) {
        size_t take = length > sizeof stream ? sizeof stream : (size_t)length;
        if (!read_exact(stream, take))
            return;
        length -= take;
    }
}

/* ----------------------------------------------------------------- commands */

static uint24_t archive_free(void) {
    /* ti_ArchiveHasRoom answers a yes/no question, so probe for the largest
     * size that still fits rather than guessing. */
    uint24_t low = 0;
    uint24_t high = 0xFFFFFF;
    while (low < high) {
        uint24_t mid = low + (high - low + 1) / 2;
        if (ti_ArchiveHasRoom(mid))
            low = mid;
        else
            high = mid - 1;
    }
    return low;
}

static bool cmd_hello(uint8_t seq) {
    step("2 in hello");
    uint24_t space = cached_archive_free;
    uint8_t body[6];
    body[0] = PROTO_VERSION;
    body[1] = (uint8_t)space;
    body[2] = (uint8_t)(space >> 8);
    body[3] = (uint8_t)(space >> 16);
    body[4] = CSX_MAX_CHUNKS;
    body[5] = CSX_CHUNK_SIZE / 256;
    if (!send_header(PROTO_HELLO, seq, PROTO_OK, sizeof body))
        return false;

    step("3 header sent");
    if (!write_exact(body, sizeof body))
        return false;

    step("4 hello done");
    return true;
}

#define LIST_RECORD 14

static bool cmd_list(uint8_t seq) {
    uint16_t count = lib_strip_count();

    if (!send_header(PROTO_LIST, seq, PROTO_OK, 2 + (uint32_t)count * LIST_RECORD))
        return false;

    /* Filled and flushed in whole bufferfuls rather than a record at a time:
     * every write is one USB transfer, and a 14-byte transfer is a short packet
     * that ends the computer's read early. */
    size_t used = 0;
    stream[used++] = (uint8_t)count;
    stream[used++] = (uint8_t)(count >> 8);

    for (uint16_t i = 0; i < count; i++) {
        if (used + LIST_RECORD > sizeof stream) {
            if (!write_exact(stream, used))
                return false;
            used = 0;
        }

        lib_strip_t strip;
        lib_get_strip(i, &strip);

        uint8_t *record = &stream[used];
        record[0] = strip.slot;
        record[1] = strip.chunk_count;
        record[2] = (uint8_t)strip.bytes;
        record[3] = (uint8_t)(strip.bytes >> 8);
        record[4] = (uint8_t)(strip.bytes >> 16);
        record[5] = strip.flags;
        record[6] = (uint8_t)strip.read_at;
        record[7] = (uint8_t)(strip.read_at >> 8);
        record[8] = (uint8_t)(strip.read_at >> 16);
        record[9] = (uint8_t)(strip.read_at >> 24);
        record[10] = (uint8_t)strip.pos;
        record[11] = (uint8_t)(strip.pos >> 8);
        record[12] = (uint8_t)(strip.pos >> 16);
        record[13] = strip.layer;
        used += LIST_RECORD;
    }

    return used ? write_exact(stream, used) : true;
}

static bool cmd_put_chunk(uint8_t seq, uint16_t arg, uint32_t length,
                          proto_progress_t progress) {
    /* Slot and chunk index ride in the header rather than at the front of the
     * payload, so the payload is nothing but chunk data. */
    uint8_t slot = (uint8_t)arg;
    uint8_t index = (uint8_t)(arg >> 8);

    if (!length || length > CSX_CHUNK_SIZE || !chunk_buffer) {
        drain(length);
        return reply(PROTO_PUT_CHUNK, seq, PROTO_BAD_LENGTH);
    }

    /* Take the whole thing off the link first: no OS calls until it is in. */
    if (!read_exact(chunk_buffer, (size_t)length))
        return false;

    char name[9];
    csx_chunk_name(name, slot, index);

    ti_Delete(name);

    bool ok = false;
    bool archived = false;
    uint8_t handle = ti_Open(name, "w");
    if (handle) {
        ok = ti_Write(chunk_buffer, (size_t)length, 1, handle) == 1;

        /* Archive rather than pre-checking for room: the OS collects deleted
         * variables here if it has to, which a ti_ArchiveHasRoom test would
         * have refused without ever freeing anything. */
        archived = ok && ti_SetArchiveStatus(true, handle) != 0;
        ti_Close(handle);
        if (!archived)
            ti_Delete(name);
    }

    if (progress)
        progress("Receiving", slot, index, 0);

    return reply(PROTO_PUT_CHUNK, seq,
                 archived ? PROTO_OK : (ok ? PROTO_NO_ROOM : PROTO_WRITE_FAIL));
}

static bool cmd_delete(uint8_t seq, uint16_t arg, uint32_t length) {
    drain(length);

    uint8_t removed = csx_delete((uint8_t)arg);
    return send_header(PROTO_DEL, seq, removed ? PROTO_OK : PROTO_NOT_FOUND, 1)
        && write_exact(&removed, 1);
}

static bool cmd_index_get(uint8_t seq) {
    uint16_t size = cached_index_size;
    const uint8_t *data = cached_index;

    if (!data || !size)
        return send_header(PROTO_INDEX_GET, seq, PROTO_OK, 0);

    if (!send_header(PROTO_INDEX_GET, seq, PROTO_OK, size))
        return false;

    /* The index lives in flash; usb_Transfer needs RAM, so page it out. */
    uint16_t left = size;
    while (left) {
        size_t take = left > sizeof stream ? sizeof stream : left;
        memcpy(stream, data, take);
        if (!write_exact(stream, take))
            return false;
        data += take;
        left -= (uint16_t)take;
    }
    return true;
}

static bool cmd_index_put(uint8_t seq, uint32_t length) {
    if (length > 0xFFFF) {
        drain(length);
        return reply(PROTO_INDEX_PUT, seq, PROTO_BAD_LENGTH);
    }

    ti_Delete(LIB_NAME);
    uint8_t handle = ti_Open(LIB_NAME, "w");
    if (!handle) {
        drain(length);
        return reply(PROTO_INDEX_PUT, seq, PROTO_WRITE_FAIL);
    }

    bool ok = true;
    uint32_t left = length;
    while (left) {
        size_t take = left > sizeof stream ? sizeof stream : (size_t)left;
        if (!read_exact(stream, take)) {
            ti_Close(handle);
            ti_Delete(LIB_NAME);
            return false;
        }
        if (ti_Write(stream, take, 1, handle) != 1)
            ok = false;
        left -= take;
    }

    if (ok)
        ok = ti_SetArchiveStatus(true, handle) != 0;
    ti_Close(handle);

    /* Every pointer the reader holds into the old index is now stale. */
    lib_open();
    return reply(PROTO_INDEX_PUT, seq, ok ? PROTO_OK : PROTO_WRITE_FAIL);
}

static bool cmd_space(uint8_t seq) {
    uint24_t space = cached_archive_free;
    uint8_t body[3] = { (uint8_t)space, (uint8_t)(space >> 8), (uint8_t)(space >> 16) };
    return send_header(PROTO_SPACE, seq, PROTO_OK, sizeof body)
        && write_exact(body, sizeof body);
}

/* Act on the header that just arrived. Returns false if the link is gone. */
static bool handle_request(proto_progress_t progress) {
    const uint8_t *header = request_header;

    uint8_t cmd = header[0];
    uint8_t seq = header[1];
    uint16_t arg = (uint16_t)header[2] | ((uint16_t)header[3] << 8);

    requests_handled++;
    last_command = cmd;
    step("1 header in");
    uint32_t length = (uint32_t)header[4] | ((uint32_t)header[5] << 8)
                    | ((uint32_t)header[6] << 16) | ((uint32_t)header[7] << 24);

    switch (cmd) {
        case PROTO_HELLO:     drain(length); return cmd_hello(seq);
        case PROTO_LIST:      drain(length); return cmd_list(seq);
        case PROTO_PUT_CHUNK: return cmd_put_chunk(seq, arg, length, progress);
        case PROTO_DEL:       return cmd_delete(seq, arg, length);
        case PROTO_INDEX_GET: drain(length); return cmd_index_get(seq);
        case PROTO_INDEX_PUT: return cmd_index_put(seq, length);
        case PROTO_SPACE:     drain(length); return cmd_space(seq);
        case PROTO_BYE:
            drain(length);
            finished = true;
            return reply(PROTO_BYE, seq, PROTO_OK);
        default:
            drain(length);
            return reply(cmd, seq, PROTO_BAD_CMD);
    }
}

/* -------------------------------------------------------------------- events */

static usb_error_t handle_event(usb_event_t event, void *event_data,
                                usb_callback_data_t *callback_data) {
    /* srldrvce does the real work; it needs to see every event first. */
    usb_error_t error = srl_UsbEventCallback(event, event_data, callback_data);
    if (error != USB_SUCCESS)
        return error;

    switch (event) {
        case USB_HOST_CONFIGURE_EVENT: {
            /*
             * Opened here, inside the event, rather than noted and opened from
             * the loop.
             *
             * srldrvce's header says not to call srl_Open from an event
             * handler. Its own example, srl_echo, does exactly this -- and
             * srl_echo works on this hardware while deferring it did not. When
             * the documentation and the only working example disagree, follow
             * the example.
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
            header_filled = 0;
            break;

        default:
            break;
    }
    return USB_SUCCESS;
}

uint16_t proto_requests(void) { return requests_handled; }
uint8_t proto_last_command(void) { return last_command; }
uint16_t proto_errors(void) { return receive_errors; }
uint8_t proto_schedule_error(void) { return (uint8_t)open_error; }
uint24_t proto_loops(void) { return loop_count; }

/* Ask the OS everything the link will need, while it is still safe to ask. */
static void gather_state(void) {
    cached_archive_free = archive_free();

    cached_index = NULL;
    cached_index_size = 0;

    uint8_t handle = ti_Open(LIB_NAME, "r");
    if (handle) {
        cached_index_size = (uint16_t)ti_GetSize(handle);
        cached_index = ti_GetDataPtr(handle);
        ti_Close(handle);
    }
}

bool proto_run(proto_progress_t progress, bool echo_only) {
    requests_handled = 0;
    last_command = 0;
    receive_errors = 0;
    open_error = SRL_SUCCESS;
    loop_count = 0;
    finished = false;
    serial_open = false;
    header_filled = 0;
    active_progress = progress;

    gather_state();

    /* The band cache has been handed back by now, so there is room. */
    chunk_buffer = malloc(CSX_CHUNK_SIZE);

    if (usb_Init(handle_event, NULL, srl_GetCDCStandardDescriptors(),
                 USB_DEFAULT_INIT_FLAGS) != USB_SUCCESS) {
        usb_Cleanup();
        return false;
    }

    while (!finished) {
        loop_count++;

        usb_HandleEvents();

        if (echo_only) {
            /* Bytes in, the same bytes out. Nothing else. */
            if (serial_open) {
                int got = srl_Read(&serial, stream, sizeof stream);
                if (got < 0) {
                    serial_open = false;
                    receive_errors++;
                } else if (got > 0) {
                    requests_handled++;
                    last_command = stream[0];
                    if (!write_exact(stream, (size_t)got))
                        serial_open = false;
                }
            }

                if (progress && !progress(serial_open ? "Echo: connected" : "Echo: waiting",
                                      0, 0, 0))
                break;
            continue;
        }

        /* Collect a header a few bytes at a time; srl_Read never blocks. */
        if (serial_open && header_filled < PROTO_HEADER_SIZE) {
            int got = srl_Read(&serial, request_header + header_filled,
                               PROTO_HEADER_SIZE - header_filled);
            if (got < 0) {
                serial_open = false;
                receive_errors++;
            } else {
                header_filled += (uint8_t)got;
            }
        }

        if (header_filled == PROTO_HEADER_SIZE) {
            header_filled = 0;
            if (!handle_request(progress))
                serial_open = false;
        }

        if (progress && !progress(serial_open ? "Connected" : "Waiting for computer",
                                  0, 0, 0))
            break;
    }

    active_progress = NULL;
    usb_Cleanup();

    free(chunk_buffer);
    chunk_buffer = NULL;
    return true;
}
