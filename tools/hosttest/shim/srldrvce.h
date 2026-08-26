/* Enough of srldrvce to compile calc/src/usb.c on the host. */

#ifndef SRLDRVCE_H
#define SRLDRVCE_H

#include "usbdrvce.h"

typedef enum {
    SRL_SUCCESS = 0,
    SRL_ERROR_INVALID_DEVICE,
    SRL_ERROR_INVALID_INTERFACE,
    SRL_ERROR_NO_MEMORY,
    SRL_ERROR_NOT_SUPPORTED,
    SRL_ERROR_USB_FAILED,
} srl_error_t;

typedef struct { uint8_t reserved[16]; } srl_device_t;

#define SRL_INTERFACE_ANY 0xFF

srl_error_t srl_Open(srl_device_t *srl, usb_device_t dev, void *buffer, size_t size,
                     uint8_t interface, uint24_t rate);
int srl_Read(srl_device_t *srl, void *data, size_t length);
int srl_Write(srl_device_t *srl, const void *data, size_t length);
usb_error_t srl_UsbEventCallback(usb_event_t event, void *event_data,
                                 usb_callback_data_t *callback_data);
const usb_standard_descriptors_t *srl_GetCDCStandardDescriptors(void);

#endif
