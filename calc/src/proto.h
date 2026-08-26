/*
 * The eBookSync USB protocol.
 *
 * The reader takes over the USB port and presents itself as a vendor-specific
 * device, so the sync page can claim it with WebUSB directly. Every message is
 * an 8-byte header and an optional payload; the computer sends a request and
 * the calculator answers with the same command and sequence number.
 *
 * All fields are little-endian. See docs/PROTOCOL.md, and keep this file in
 * step with web/js/usb.js.
 */

#ifndef PROTO_H
#define PROTO_H

#include <stdbool.h>
#include <stdint.h>

#define PROTO_VERSION       1

/*
 * The calculator is a USB CDC serial port, so the computer finds it by the
 * descriptors srldrvce presents. These are the shared V-USB CDC identifiers.
 */
#define PROTO_USB_VENDOR    0x16C0
#define PROTO_USB_PRODUCT   0x05E1

#define PROTO_HEADER_SIZE   8

typedef enum {
    PROTO_HELLO      = 0x01,   /* -> version, free archive space */
    PROTO_LIST       = 0x02,   /* -> the resident strips and their read state */
    PROTO_PUT_CHUNK  = 0x03,   /* <- one 16 KB chunk of a strip */
    PROTO_DEL        = 0x04,   /* <- delete every chunk of a strip */
    PROTO_INDEX_GET  = 0x05,   /* -> the CSLIB index */
    PROTO_INDEX_PUT  = 0x06,   /* <- replace the CSLIB index */
    PROTO_SPACE      = 0x07,   /* -> free archive space */
    PROTO_BYE        = 0x08,   /* <- leave sync mode */
} proto_cmd_t;

typedef enum {
    PROTO_OK          = 0,
    PROTO_BAD_CMD     = 1,
    PROTO_BAD_LENGTH  = 2,
    PROTO_NO_ROOM     = 3,     /* not enough archive space */
    PROTO_WRITE_FAIL  = 4,     /* could not create or archive the variable */
    PROTO_NOT_FOUND   = 5,
    PROTO_TRUNCATED   = 6,     /* the payload ended early */
} proto_status_t;

/*
 * Header: u8 cmd, u8 seq, u16 arg, u32 length.
 *
 * `arg` is a status in replies and a command argument in requests -- it is what
 * carries the slot and chunk index of a PUT_CHUNK. Keeping those out of the
 * payload matters more than it looks: USB is packet-based and the calculator
 * posts one receive for the header and another for the payload, so a few
 * argument bytes at the front of the payload would share a packet with the data
 * behind them and be impossible to read separately.
 */
typedef struct {
    uint8_t cmd;
    uint8_t seq;
    uint16_t arg;
    uint32_t length;
} proto_header_t;

/*
 * Run the sync session: take over USB, answer requests until the computer says
 * BYE or the user presses clear, then hand the port back to the OS.
 *
 * `progress` is called so the caller can draw a status screen; it returns false
 * to abort.
 */
typedef bool (*proto_progress_t)(const char *state, uint8_t slot, uint8_t chunk,
                                 uint8_t chunk_count);

/*
 * `echo_only` runs the link as a bare echo: bytes in, the same bytes straight
 * back out, with no protocol, no appvars and no library touched.
 *
 * It is a control experiment. If a sync stalls but echo does not, the fault is
 * in the protocol handling above the transport; if echo stalls too, the fault
 * is in the transport or below it, and nothing above will fix it. There is no
 * other way to make that split on hardware that cannot be stepped through.
 */
bool proto_run(proto_progress_t progress, bool echo_only);

/*
 * Counters the sync screen puts on display.
 *
 * Not decoration: when a sync stalls, the difference between "no request ever
 * arrived", "requests arrive but replies fail" and "the link dropped" is the
 * whole diagnosis, and there is no other way to see it on a calculator.
 */
uint16_t proto_requests(void);      /* requests handled */
uint8_t proto_last_command(void);   /* the most recent one */
uint16_t proto_errors(void);        /* failed receives on the idle wait */
uint8_t proto_open_error(void);      /* last srl_Open result */

/*
 * Times round the sync loop. Shown as a live counter, because a static screen
 * cannot tell you whether the loop is wedged or merely idle -- and those need
 * completely different fixes.
 */
uint24_t proto_loops(void);


#endif /* PROTO_H */
