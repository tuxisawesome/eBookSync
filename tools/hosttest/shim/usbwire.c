/*
 * A model of the calculator's USB endpoints, faithful about packets.
 *
 * calc/src/usb.c is compiled against this instead of the real driver, and the
 * computer end -- the actual web/js/usb.js -- drives it over a pipe. Packets
 * arrive on stdin and replies go out on stdout, each framed as a 16-bit length
 * followed by its bytes.
 *
 * The rules that matter, and that the real hardware enforces silently:
 *
 *   - a bulk transfer moves whole packets of at most 64 bytes;
 *   - a receive finishes when its buffer fills or a short packet arrives;
 *   - a receive posted shorter than the packet arriving into it keeps what fits
 *     and *loses the rest*.
 *
 * That last rule is the one that broke sync twice. Here it is counted, and the
 * tests fail on any occurrence.
 */

#include "usbdrvce.h"

#include <stdlib.h>
#include <string.h>

#define MAX_PACKETS 8192

typedef struct {
    uint8_t data[USB_PACKET_SIZE];
    size_t length;
} packet_t;

static packet_t queued[MAX_PACKETS];
static int queue_head;
static int queue_tail;
static int overflows;
static int misaligned;
static bool input_ended;

static usb_event_callback_t event_handler;
static bool announced;

/* A scheduled receive waiting for a packet. */
static struct {
    bool active;
    usb_endpoint_t endpoint;
    uint8_t *buffer;
    size_t length;
    usb_transfer_callback_t handler;
    void *data;
} scheduled;

void wire_reset(void) {
    queue_head = queue_tail = 0;
    overflows = 0;
    misaligned = 0;
    input_ended = false;
    announced = false;
    scheduled.active = false;
}

int wire_overflows(void) { return overflows + misaligned; }

bool wire_out_drained(void) { return queue_head == queue_tail && input_ended; }

void wire_push_out(const void *data, size_t length) {
    if (length > USB_PACKET_SIZE || queue_tail >= MAX_PACKETS) {
        fprintf(stderr, "wire: bad packet\n");
        exit(1);
    }
    memcpy(queued[queue_tail].data, data, length);
    queued[queue_tail].length = length;
    queue_tail++;
}

/* Pull one framed packet off stdin. Returns false at end of input. */
static bool refill(void) {
    if (input_ended) return false;

    uint8_t header[2];
    if (fread(header, 1, 2, stdin) != 2) {
        input_ended = true;
        return false;
    }
    size_t length = (size_t)header[0] | ((size_t)header[1] << 8);
    if (length > USB_PACKET_SIZE) {
        fprintf(stderr, "wire: oversized packet %zu\n", length);
        exit(1);
    }

    uint8_t body[USB_PACKET_SIZE];
    if (length && fread(body, 1, length, stdin) != length) {
        input_ended = true;
        return false;
    }
    wire_push_out(body, length);
    return true;
}

static void emit(const uint8_t *data, size_t length) {
    uint8_t header[2] = { (uint8_t)length, (uint8_t)(length >> 8) };
    fwrite(header, 1, 2, stdout);
    if (length) fwrite(data, 1, length, stdout);
    fflush(stdout);
}

int wire_pop_in(void *data, size_t max) {
    (void)data;
    (void)max;
    return -1;      /* replies go straight out; nothing buffers them here */
}

static bool endpoint_is_in(usb_endpoint_t endpoint) {
    return ((uintptr_t)endpoint & 0x80) != 0;
}

/* Receive into `buffer`, obeying the packet rules above. */
static usb_error_t receive(uint8_t *buffer, size_t length, size_t *transferred) {
    size_t filled = 0;

    /*
     * A receive shorter than the endpoint's maximum packet does not work on the
     * hardware -- srldrvce, the toolchain's own device-mode driver, always posts
     * a full 64 bytes. Posting 8 bytes for an 8-byte header looks reasonable and
     * silently never completes.
     */
    if (length % USB_PACKET_SIZE) {
        misaligned++;
        fprintf(stderr, "wire: MISALIGNED -- %zu byte receive posted on a %d byte "
                        "endpoint\n", length, USB_PACKET_SIZE);
    }

    while (filled < length) {
        if (queue_head == queue_tail && !refill()) break;
        if (queue_head == queue_tail) break;

        packet_t *packet = &queued[queue_head++];
        size_t room = length - filled;

        if (packet->length > room) {
            /* The posted receive is smaller than the packet: keep what fits,
             * lose the rest. This is the failure mode being guarded against. */
            memcpy(buffer + filled, packet->data, room);
            filled += room;
            overflows++;
            fprintf(stderr, "wire: OVERFLOW -- %zu byte packet into %zu bytes of room\n",
                    packet->length, room);
            break;
        }

        memcpy(buffer + filled, packet->data, packet->length);
        filled += packet->length;
        if (packet->length < USB_PACKET_SIZE) break;   /* short packet ends it */
    }

    *transferred = filled;
    if (!filled) return USB_ERROR_TIMEOUT;
    return USB_SUCCESS;
}

static void transmit(const uint8_t *buffer, size_t length) {
    size_t sent = 0;
    do {
        size_t take = length - sent;
        if (take > USB_PACKET_SIZE) take = USB_PACKET_SIZE;
        emit(buffer + sent, take);
        sent += take;
    } while (sent < length);
}

/* ------------------------------------------------------------------- driver */

usb_error_t usb_Init(usb_event_callback_t handler, usb_callback_data_t *data,
                     const usb_standard_descriptors_t *descriptors, unsigned flags) {
    (void)data;
    (void)flags;

    /* Sanity-check the descriptors the reader hands over, since a mistake there
     * is invisible until a real host rejects the device. */
    if (!descriptors || !descriptors->device || !descriptors->configurations) {
        return USB_ERROR_INVALID_PARAM;
    }
    if (descriptors->device->bLength != 18 ||
        descriptors->device->bDescriptorType != USB_DEVICE_DESCRIPTOR) {
        fprintf(stderr, "wire: bad device descriptor\n");
        return USB_ERROR_INVALID_PARAM;
    }

    const uint8_t *configuration = (const uint8_t *)descriptors->configurations[0];
    size_t total = (size_t)configuration[2] | ((size_t)configuration[3] << 8);
    size_t walked = 0;
    while (walked < total) {
        size_t length = configuration[walked];
        if (!length) {
            fprintf(stderr, "wire: zero-length descriptor at %zu\n", walked);
            return USB_ERROR_INVALID_PARAM;
        }
        walked += length;
    }
    if (walked != total) {
        fprintf(stderr, "wire: configuration wTotalLength %zu does not match %zu of "
                        "descriptors\n", total, walked);
        return USB_ERROR_INVALID_PARAM;
    }

    event_handler = handler;
    return USB_SUCCESS;
}

void usb_Cleanup(void) {
    scheduled.active = false;
    event_handler = NULL;
}

usb_device_t usb_FindDevice(usb_device_t root, usb_device_t from, usb_device_flags_t flags) {
    (void)root;
    (void)flags;
    return from ? NULL : (usb_device_t)(uintptr_t)1;
}

usb_endpoint_t usb_GetDeviceEndpoint(usb_device_t device, uint8_t address) {
    (void)device;
    return (usb_endpoint_t)(uintptr_t)(address ? address : 0x100);
}

usb_error_t usb_Transfer(usb_endpoint_t endpoint, void *buffer, size_t length,
                         unsigned retries, size_t *transferred) {
    (void)retries;

    size_t moved = 0;
    usb_error_t result = USB_SUCCESS;

    if (endpoint_is_in(endpoint)) {
        transmit(buffer, length);
        moved = length;
    } else {
        result = receive(buffer, length, &moved);
    }

    if (transferred) *transferred = moved;
    return result;
}

usb_error_t usb_ScheduleTransfer(usb_endpoint_t endpoint, void *buffer, size_t length,
                                 usb_transfer_callback_t handler, usb_transfer_data_t *data) {
    if (endpoint_is_in(endpoint)) {
        /* Control replies during enumeration: just send them. */
        transmit(buffer, length);
        if (handler) handler(endpoint, USB_TRANSFER_COMPLETED, length, data);
        return USB_SUCCESS;
    }

    if (scheduled.active) return USB_ERROR_SCHEDULE_FULL;
    scheduled.active = true;
    scheduled.endpoint = endpoint;
    scheduled.buffer = buffer;
    scheduled.length = length;
    scheduled.handler = handler;
    scheduled.data = data;
    return USB_SUCCESS;
}

usb_error_t usb_HandleEvents(void) {
    if (!announced && event_handler) {
        announced = true;
        event_handler(USB_HOST_CONFIGURE_EVENT, NULL, NULL);
        return USB_SUCCESS;
    }

    if (scheduled.active) {
        size_t moved = 0;
        usb_error_t result = receive(scheduled.buffer, scheduled.length, &moved);

        scheduled.active = false;
        if (scheduled.handler) {
            usb_transfer_status_t status = result == USB_SUCCESS
                ? USB_TRANSFER_COMPLETED
                : USB_TRANSFER_NO_DEVICE;
            scheduled.handler(scheduled.endpoint, status, moved, scheduled.data);
        }
    }
    return USB_SUCCESS;
}
