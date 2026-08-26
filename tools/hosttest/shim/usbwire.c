/*
 * A serial link over a pipe, standing in for srldrvce.
 *
 * calc/src/usb.c is compiled against this instead of the real driver, and the
 * computer end -- the actual web/js/link.js -- drives it from the other side.
 * Bytes in on stdin, bytes out on stdout.
 *
 * This used to model USB bulk endpoints packet by packet, because the reader
 * spoke to them directly and the packet rules were where the bugs lived. A CDC
 * serial port is a byte stream, so all of that is gone -- which was rather the
 * point of moving to it.
 */

#include "srldrvce.h"

#include <stdlib.h>
#include <string.h>

static usb_event_callback_t event_handler;
static bool announced;
static bool input_ended;
static bool port_open;

void wire_reset(void) {
    announced = false;
    input_ended = false;
    port_open = false;
}

int wire_overflows(void) { return 0; }

bool wire_out_drained(void) { return input_ended; }

/* --------------------------------------------------------------- usbdrvce */

usb_error_t usb_Init(usb_event_callback_t handler, usb_callback_data_t *data,
                     const usb_standard_descriptors_t *descriptors, unsigned flags) {
    (void)data;
    (void)flags;
    if (!descriptors) return USB_ERROR_INVALID_PARAM;
    event_handler = handler;
    /* Everything from here on is "while the link is up". */
    shim_reset_os_calls();
    return USB_SUCCESS;
}

void usb_Cleanup(void) {
    event_handler = NULL;
    port_open = false;
}

usb_error_t usb_HandleEvents(void) {
    if (!announced && event_handler) {
        announced = true;
        event_handler(USB_HOST_CONFIGURE_EVENT, NULL, NULL);
    }
    return USB_SUCCESS;
}

usb_device_t usb_FindDevice(usb_device_t root, usb_device_t from, usb_device_flags_t flags) {
    (void)root;
    (void)flags;
    return from ? NULL : (usb_device_t)(uintptr_t)1;
}

/* --------------------------------------------------------------- srldrvce */

static const usb_device_descriptor_t cdc_device = {
    .bLength = 18, .bDescriptorType = USB_DEVICE_DESCRIPTOR, .bcdUSB = 0x0200,
    .bDeviceClass = 0x02, .bMaxPacketSize0 = 64,
    .idVendor = 0x16C0, .idProduct = 0x05E1, .bcdDevice = 0x0220,
    .iManufacturer = 1, .iProduct = 2, .bNumConfigurations = 1,
};
static const uint8_t cdc_configuration[] = { 9, USB_CONFIGURATION_DESCRIPTOR, 9, 0, 1, 1, 0, 0xC0, 50 };
static const usb_configuration_descriptor_t *const cdc_configurations[] = {
    (const usb_configuration_descriptor_t *)cdc_configuration,
};
static const usb_standard_descriptors_t cdc_descriptors = {
    .device = &cdc_device, .configurations = cdc_configurations,
};

const usb_standard_descriptors_t *srl_GetCDCStandardDescriptors(void) {
    return &cdc_descriptors;
}

usb_error_t srl_UsbEventCallback(usb_event_t event, void *event_data,
                                 usb_callback_data_t *callback_data) {
    (void)event;
    (void)event_data;
    (void)callback_data;
    return USB_SUCCESS;
}

srl_error_t srl_Open(srl_device_t *srl, usb_device_t dev, void *buffer, size_t size,
                     uint8_t interface, uint24_t rate) {
    (void)srl;
    (void)rate;
    (void)interface;

    if (!dev) return SRL_ERROR_INVALID_DEVICE;
    /* The real driver documents these; hold it to them. */
    if (!buffer || size < 128 || size % 2) return SRL_ERROR_NO_MEMORY;

    port_open = true;
    return SRL_SUCCESS;
}

int srl_Read(srl_device_t *srl, void *data, size_t length) {
    (void)srl;
    if (!port_open) return -1;
    if (input_ended || !length) return 0;

    /* Blocks for the first byte, which is fine over a pipe: the loop only asks
     * when it is waiting for the computer anyway. */
    int first = fgetc(stdin);
    if (first == EOF) {
        input_ended = true;
        return 0;
    }

    uint8_t *out = data;
    out[0] = (uint8_t)first;
    size_t got = 1;

    /* Take whatever else is already buffered, as a real read would. */
    while (got < length) {
        int next = fgetc(stdin);
        if (next == EOF) {
            input_ended = true;
            break;
        }
        out[got++] = (uint8_t)next;
    }
    return (int)got;
}

int srl_Write(srl_device_t *srl, const void *data, size_t length) {
    (void)srl;
    if (!port_open) return -1;
    fwrite(data, 1, length, stdout);
    fflush(stdout);
    return (int)length;
}
