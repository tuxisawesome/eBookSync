/*
 * The calculator end of the sync protocol.
 *
 * usb_Init() with our own descriptors takes the port away from the TI OS and
 * makes the reader a plain vendor-specific device. The descriptors advertise
 * WebUSB and Microsoft OS 2.0, which is what lets Chrome open the device on
 * Windows without anyone installing a driver.
 *
 * See docs/PROTOCOL.md.
 */

#include "proto.h"

#include "csx.h"
#include "library.h"

#include <fileioc.h>
#include <string.h>
#include <tice.h>
#include <usbdrvce.h>


/*
 * Retries for the blocking transfers used *inside* a command, once its header
 * has arrived and the computer is committed to the exchange.
 */
#define TRANSFER_RETRIES 10

/*
 * Streaming buffer for chunk payloads. Small on purpose -- chunks are written
 * straight into the appvar as they arrive rather than staged whole in RAM --
 * and a multiple of the endpoint packet size, which is not optional: posting a
 * receive shorter than the packet the host sends overflows the endpoint and the
 * excess is silently dropped.
 */
#define STREAM_BUFFER 512

static usb_device_t host_device;
static usb_endpoint_t endpoint_in;
static usb_endpoint_t endpoint_out;
static bool configured;
static bool finished;

static uint8_t stream[STREAM_BUFFER];

/*
 * The idle wait for the next request is asynchronous, and has to be.
 *
 * usb_Transfer() blocks until the transfer completes, so waiting for a command
 * that way would sit inside the USB driver forever with the computer idle --
 * the keypad would never be scanned again and the reader would look hung, with
 * no way out but the reset button. Scheduling the receive instead lets
 * usb_HandleEvents() deliver it whenever it turns up, while the loop keeps
 * drawing and watching for the clear key.
 *
 * Once a header has arrived the computer is mid-exchange and committed to
 * sending the rest, so the payload and the reply can use blocking transfers.
 */
static uint16_t requests_handled;
static uint8_t last_command;
static uint16_t receive_errors;
static usb_error_t schedule_error;
static uint24_t loop_count;

/* A whole packet, not just the 8 header bytes: see read_exact. */
static uint8_t request_header[PROTO_PACKET_SIZE];
static volatile bool header_posted;
static volatile bool header_ready;
static volatile bool link_lost;


/* ------------------------------------------------------------- descriptors */

static const usb_device_descriptor_t device_descriptor = {
    .bLength = 18,
    .bDescriptorType = USB_DEVICE_DESCRIPTOR,
    /*
     * Plain USB 2.0, deliberately.
     *
     * Declaring 2.1 makes the host ask for a BOS descriptor, which is how a
     * device advertises WebUSB and asks Windows to bind WinUSB automatically.
     * Answering it means handling a control request by hand, and getting that
     * wrong wedges the control pipe the instant the host asks -- which is
     * exactly what happened. Answering it correctly needs
     * usb_ScheduleControlTransfer(), which takes the setup packet, and not
     * usb_ScheduleTransfer(), which does not.
     *
     * None of it is needed to talk to the device: Chrome will open any
     * vendor-class interface the user picks. It only buys automatic driver
     * binding on Windows, where Zadig is the fallback. Worth doing properly one
     * day; not worth a wedged calculator today.
     */
    .bcdUSB = 0x0200,
    .bDeviceClass = 0,
    .bDeviceSubClass = 0,
    .bDeviceProtocol = 0,
    .bMaxPacketSize0 = 64,
    .idVendor = PROTO_VENDOR_ID,
    .idProduct = PROTO_PRODUCT_ID,
    .bcdDevice = 0x0100,
    .iManufacturer = 1,
    .iProduct = 2,
    .iSerialNumber = 0,
    .bNumConfigurations = 1,
};

/* Configuration, one vendor-specific interface, one bulk pair. Written out as
 * bytes because that is how the spec reads and how it must reach the wire. */
static const uint8_t configuration[] = {
    /* configuration */
    9, USB_CONFIGURATION_DESCRIPTOR, 32, 0, 1, 1, 0, 0x80, 250 / 2,
    /* interface: class 0xFF, vendor specific */
    9, USB_INTERFACE_DESCRIPTOR, 0, 0, 2, 0xFF, 0x00, 0x00, 0,
    /* bulk OUT */
    7, USB_ENDPOINT_DESCRIPTOR, PROTO_EP_OUT, 0x02,
       PROTO_PACKET_SIZE & 0xFF, PROTO_PACKET_SIZE >> 8, 0,
    /* bulk IN */
    7, USB_ENDPOINT_DESCRIPTOR, PROTO_EP_IN, 0x02,
       PROTO_PACKET_SIZE & 0xFF, PROTO_PACKET_SIZE >> 8, 0,
};

static const usb_configuration_descriptor_t *const configurations[] = {
    (const usb_configuration_descriptor_t *)configuration,
};

static const uint8_t langids[] = { 4, USB_STRING_DESCRIPTOR, 0x09, 0x04 };

static const uint8_t string_manufacturer[] = {
    18, USB_STRING_DESCRIPTOR,
    'e',0, 'B',0, 'o',0, 'o',0, 'k',0, 'S',0, 'y',0, 'n',0,
};
static const uint8_t string_product[] = {
    28, USB_STRING_DESCRIPTOR,
    'C',0, 'o',0, 'm',0, 'i',0, 'c',0, ' ',0, 'R',0, 'e',0,
    'a',0, 'd',0, 'e',0, 'r',0, ' ',0,
};

static const usb_string_descriptor_t *const strings[] = {
    (const usb_string_descriptor_t *)string_manufacturer,
    (const usb_string_descriptor_t *)string_product,
};

static const usb_standard_descriptors_t descriptors = {
    .device = &device_descriptor,
    .configurations = configurations,
    .langids = (const usb_string_descriptor_t *)langids,
    .numStrings = 2,
    .strings = strings,
};

/* ---------------------------------------------------------------- transport */

/*
 * Receive exactly `length` bytes.
 *
 * The posted length is capped at STREAM_BUFFER rather than chopped into small
 * reads: a receive shorter than the packet the host is sending overflows the
 * endpoint and loses the remainder. Callers never ask for more than they can
 * hold, so the cap only matters as a guard.
 */
/*
 * Look the endpoint up afresh for every transfer.
 *
 * srldrvce -- the one driver in the toolchain that acts as a device -- does
 * exactly this rather than caching the handle, and it is cheap. A handle kept
 * across a reconfiguration is not obviously still valid.
 */
static usb_endpoint_t endpoint(uint8_t address) {
    usb_device_t device = usb_FindDevice(NULL, NULL, USB_SKIP_HUBS);
    return device ? usb_GetDeviceEndpoint(device, address) : NULL;
}

/*
 * Receive exactly `length` bytes.
 *
 * Every posted receive is a whole number of packets. That is not an
 * optimisation: the endpoint moves whole packets, and a receive posted shorter
 * than the endpoint's maximum simply does not work -- srldrvce always posts a
 * full 64 bytes for the same reason. Short packets still end a transfer early,
 * so asking for more than is coming is safe and `got` says what really arrived.
 *
 * Callers always read into `stream`, so rounding up can never overrun.
 */
static bool read_exact(void *buffer, size_t length) {
    uint8_t *out = buffer;

    while (length) {
        size_t want = length;
        if (want > STREAM_BUFFER)
            want = STREAM_BUFFER;
        want = (want + PROTO_PACKET_SIZE - 1) / PROTO_PACKET_SIZE * PROTO_PACKET_SIZE;
        if (want > STREAM_BUFFER)
            want = STREAM_BUFFER;

        usb_endpoint_t out_ep = endpoint(PROTO_EP_OUT);
        if (!out_ep)
            return false;

        size_t got = 0;
        if (usb_Transfer(out_ep, out, want, TRANSFER_RETRIES, &got) != USB_SUCCESS)
            return false;
        if (!got || got > length)
            return false;
        out += got;
        length -= got;
    }
    return true;
}

static bool write_exact(const void *buffer, size_t length) {
    /* usb_Transfer wants a RAM buffer and does not modify it; the cast is safe
     * because everything we send already lives in RAM. */
    uint8_t *in = (uint8_t *)buffer;

    while (length) {
        usb_endpoint_t in_ep = endpoint(PROTO_EP_IN);
        if (!in_ep)
            return false;

        size_t sent = 0;
        if (usb_Transfer(in_ep, in, length, TRANSFER_RETRIES, &sent) != USB_SUCCESS)
            return false;
        if (!sent)
            return false;
        in += sent;
        length -= sent;
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
    uint24_t space = archive_free();
    uint8_t body[6];
    body[0] = PROTO_VERSION;
    body[1] = (uint8_t)space;
    body[2] = (uint8_t)(space >> 8);
    body[3] = (uint8_t)(space >> 16);
    body[4] = CSX_MAX_CHUNKS;
    body[5] = CSX_CHUNK_SIZE / 256;
    return send_header(PROTO_HELLO, seq, PROTO_OK, sizeof body)
        && write_exact(body, sizeof body);
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
     * payload: there they would share a USB packet with the chunk data behind
     * them, and could not be read separately from it. */
    uint8_t slot = (uint8_t)arg;
    uint8_t index = (uint8_t)(arg >> 8);
    uint32_t payload = length;

    if (!payload || payload > CSX_CHUNK_SIZE) {
        drain(length);
        return reply(PROTO_PUT_CHUNK, seq, PROTO_BAD_LENGTH);
    }

    char name[9];
    csx_chunk_name(name, slot, index);
    ti_Delete(name);

    uint8_t handle = ti_Open(name, "w");
    if (!handle) {
        drain(payload);
        return reply(PROTO_PUT_CHUNK, seq, PROTO_WRITE_FAIL);
    }

    /* Stream straight into the variable rather than staging the whole chunk:
     * 16 KB of RAM is more than the reader can spare. */
    bool ok = true;
    uint32_t left = payload;
    while (left) {
        size_t take = left > sizeof stream ? sizeof stream : (size_t)left;
        if (!read_exact(stream, take)) {
            ti_Close(handle);
            ti_Delete(name);
            return false;
        }
        if (ti_Write(stream, take, 1, handle) != 1)
            ok = false;
        left -= take;
    }

    /* Archive rather than pre-checking for room: the OS collects deleted
     * variables here if it has to, which a ti_ArchiveHasRoom test would have
     * refused without ever freeing anything. */
    bool archived = ok && ti_SetArchiveStatus(true, handle) != 0;
    ti_Close(handle);
    if (!archived)
        ti_Delete(name);

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
    uint8_t handle = ti_Open(LIB_NAME, "r");
    if (!handle)
        return send_header(PROTO_INDEX_GET, seq, PROTO_OK, 0);

    uint16_t size = (uint16_t)ti_GetSize(handle);
    const uint8_t *data = ti_GetDataPtr(handle);
    ti_Close(handle);

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
    uint24_t space = archive_free();
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
    (void)callback_data;
    (void)event_data;

    switch (event) {
        case USB_HOST_CONFIGURE_EVENT:
            host_device = usb_FindDevice(NULL, NULL, USB_SKIP_HUBS);
            if (host_device) {
                endpoint_out = usb_GetDeviceEndpoint(host_device, PROTO_EP_OUT);
                endpoint_in = usb_GetDeviceEndpoint(host_device, PROTO_EP_IN);
                configured = endpoint_in && endpoint_out;
            }
            break;


        case USB_DEVICE_DISCONNECTED_EVENT:
        case USB_DEVICE_SUSPENDED_EVENT:
        case USB_DEVICE_DISABLED_EVENT:
            configured = false;
            link_lost = true;
            break;

        default:
            break;
    }
    return USB_SUCCESS;
}

/* A scheduled idle receive finished: either a request header arrived, or the
 * link went away. Runs from usb_HandleEvents(), so it only sets flags. */
static usb_error_t request_arrived(usb_endpoint_t endpoint, usb_transfer_status_t status,
                                   size_t transferred, usb_transfer_data_t *data) {
    (void)endpoint;
    (void)data;

    header_posted = false;
    if (status == USB_TRANSFER_COMPLETED && transferred >= PROTO_HEADER_SIZE) {
        header_ready = true;
    } else if (status & (USB_TRANSFER_NO_DEVICE | USB_TRANSFER_CANCELLED)) {
        link_lost = true;
    } else {
        receive_errors++;
    }
    /* Anything else -- a stall, a bus error -- just means no request this time;
     * the loop posts another receive. */
    return USB_SUCCESS;
}

uint16_t proto_requests(void) { return requests_handled; }
uint8_t proto_last_command(void) { return last_command; }
uint16_t proto_errors(void) { return receive_errors; }
uint8_t proto_schedule_error(void) { return (uint8_t)schedule_error; }
uint24_t proto_loops(void) { return loop_count; }

/*
 * Written straight into video memory, in the OS's own 16bpp layout.
 *
 * graphx is shut down for the duration of a sync (see ui_sync_screen), so this
 * cannot go through it -- and going through nothing is the point anyway: it
 * appears immediately and survives the loop stopping dead, which is what it is
 * for.
 */
void proto_mark(uint8_t phase) {
    static const uint16_t colours[] = {
        0xF800,   /* red    -- inside usb_HandleEvents */
        0xFFE0,   /* yellow -- inside usb_ScheduleTransfer */
        0x07E0,   /* green  -- reading the keypad */
        0x001F,   /* blue   -- drawing */
    };
    if (phase >= sizeof colours / sizeof *colours)
        return;

    uint16_t *vram = (uint16_t *)0xD40000;
    for (uint8_t y = 0; y < 12; y++) {
        uint16_t *row = vram + (uint24_t)y * 320 + (320 - 14);
        for (uint8_t x = 0; x < 12; x++)
            row[x] = colours[phase];
    }
}

bool proto_run(proto_progress_t progress) {
    requests_handled = 0;
    last_command = 0;
    receive_errors = 0;
    schedule_error = USB_SUCCESS;
    loop_count = 0;

    host_device = NULL;
    endpoint_in = endpoint_out = NULL;
    configured = false;
    finished = false;
    header_posted = false;
    header_ready = false;
    link_lost = false;

    if (usb_Init(handle_event, NULL, &descriptors, USB_DEFAULT_INIT_FLAGS) != USB_SUCCESS) {
        usb_Cleanup();
        return false;
    }

    while (!finished) {
        loop_count++;

        proto_mark(PROTO_PHASE_EVENTS);
        usb_HandleEvents();

        if (link_lost) {
            link_lost = false;
            configured = false;
            header_posted = false;
            header_ready = false;
        }

        /* Keep exactly one idle receive outstanding. */
        if (configured && !header_posted && !header_ready) {
            proto_mark(PROTO_PHASE_SCHEDULE);
            usb_endpoint_t out_ep = endpoint(PROTO_EP_OUT);
            schedule_error = out_ep
                ? usb_ScheduleTransfer(out_ep, request_header, sizeof request_header,
                                       request_arrived, NULL)
                : USB_ERROR_NO_DEVICE;
            if (schedule_error == USB_SUCCESS)
                header_posted = true;
        }

        if (header_ready) {
            header_ready = false;
            if (!handle_request(progress))
                configured = false;
        }

        proto_mark(PROTO_PHASE_UI);
        if (progress && !progress(configured ? "Connected" : "Waiting for computer",
                                  0, 0, 0))
            break;
    }

    usb_Cleanup();
    return true;
}
