/*
 * Enough of usbdrvce to compile calc/src/usb.c on the host, backed by a model
 * of USB's packet semantics rather than real hardware.
 *
 * The point is the packet rules, because that is where the bugs were: a bulk
 * endpoint moves whole packets, a receive ends at a short packet or when its
 * buffer fills, and a receive posted shorter than the packet arriving into it
 * loses the remainder. That last one is silent on hardware and cost two rounds
 * of debugging; here it is counted and asserted on.
 */

#ifndef USBDRVCE_H
#define USBDRVCE_H

#include "shim.h"

#define USB_PACKET_SIZE 64

typedef enum usb_error {
  USB_SUCCESS,
  USB_IGNORE,
  USB_ERROR_SYSTEM,
  USB_ERROR_INVALID_PARAM,
  USB_ERROR_SCHEDULE_FULL,
  USB_ERROR_NO_DEVICE,
  USB_ERROR_NO_MEMORY,
  USB_ERROR_NOT_SUPPORTED,
  USB_ERROR_OVERFLOW,
  USB_ERROR_TIMEOUT,
  USB_ERROR_FAILED,
} usb_error_t;

typedef enum usb_event {
  USB_ROLE_CHANGED_EVENT,
  USB_DEVICE_DISCONNECTED_EVENT,
  USB_DEVICE_CONNECTED_EVENT,
  USB_DEVICE_DISABLED_EVENT,
  USB_DEVICE_ENABLED_EVENT,
  USB_DEVICE_RESUMED_EVENT,
  USB_DEVICE_SUSPENDED_EVENT,
  USB_DEFAULT_SETUP_EVENT,
  USB_HOST_CONFIGURE_EVENT,
} usb_event_t;

typedef enum usb_transfer_status {
  USB_TRANSFER_COMPLETED  = 0,
  USB_TRANSFER_STALLED    = 1 << 0,
  USB_TRANSFER_NO_DEVICE  = 1 << 1,
  USB_TRANSFER_HOST_ERROR = 1 << 2,
  USB_TRANSFER_ERROR      = 1 << 3,
  USB_TRANSFER_OVERFLOW   = 1 << 4,
  USB_TRANSFER_BUS_ERROR  = 1 << 5,
  USB_TRANSFER_FAILED     = 1 << 6,
  USB_TRANSFER_CANCELLED  = 1 << 7,
} usb_transfer_status_t;

enum {
  USB_DEVICE_DESCRIPTOR = 1,
  USB_CONFIGURATION_DESCRIPTOR,
  USB_STRING_DESCRIPTOR,
  USB_INTERFACE_DESCRIPTOR,
  USB_ENDPOINT_DESCRIPTOR,
};

enum { USB_SKIP_NONE = 0, USB_SKIP_HUBS = 1 };
enum { USB_RETRY_FOREVER = 0xFFFFFFu };
enum { USB_DEFAULT_INIT_FLAGS = 0 };

typedef struct usb_device *usb_device_t;
typedef struct usb_endpoint *usb_endpoint_t;
typedef unsigned usb_device_flags_t;

#ifndef usb_callback_data_t
#define usb_callback_data_t void
#endif
#ifndef usb_transfer_data_t
#define usb_transfer_data_t void
#endif

typedef struct usb_device_descriptor {
  uint8_t bLength, bDescriptorType;
  uint16_t bcdUSB;
  uint8_t bDeviceClass, bDeviceSubClass, bDeviceProtocol, bMaxPacketSize0;
  uint16_t idVendor, idProduct, bcdDevice;
  uint8_t iManufacturer, iProduct, iSerialNumber, bNumConfigurations;
} usb_device_descriptor_t;

typedef struct usb_configuration_descriptor {
  uint8_t bLength, bDescriptorType;
  uint16_t wTotalLength;
  uint8_t bNumInterfaces, bConfigurationValue, iConfiguration, bmAttributes, bMaxPower;
} usb_configuration_descriptor_t;

typedef struct usb_string_descriptor {
  uint8_t bLength, bDescriptorType;
  uint16_t bString[];
} usb_string_descriptor_t;

typedef struct usb_standard_descriptors {
  const usb_device_descriptor_t *device;
  const usb_configuration_descriptor_t *const *configurations;
  const usb_string_descriptor_t *langids;
  uint8_t numStrings;
  const usb_string_descriptor_t *const *strings;
} usb_standard_descriptors_t;

typedef struct usb_control_setup {
  uint8_t bmRequestType, bRequest;
  uint16_t wValue, wIndex, wLength;
} usb_control_setup_t;

typedef usb_error_t (*usb_event_callback_t)(usb_event_t event, void *event_data,
                                            usb_callback_data_t *callback_data);
typedef usb_error_t (*usb_transfer_callback_t)(usb_endpoint_t endpoint,
                                               usb_transfer_status_t status,
                                               size_t transferred,
                                               usb_transfer_data_t *data);

usb_error_t usb_Init(usb_event_callback_t handler, usb_callback_data_t *data,
                     const usb_standard_descriptors_t *descriptors, unsigned flags);
void usb_Cleanup(void);
usb_error_t usb_HandleEvents(void);
usb_device_t usb_FindDevice(usb_device_t root, usb_device_t from, usb_device_flags_t flags);

/* ------------------------------------------------------- the wire, for tests */

/* Always zero now that the link is a byte stream; kept so the probe's exit
 * status still means "the transport was used correctly". */
int wire_overflows(void);

/* True once every queued OUT packet has been consumed. */
bool wire_out_drained(void);

void wire_reset(void);

#endif /* USBDRVCE_H */
