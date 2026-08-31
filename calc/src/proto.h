/*
 * The eBookSync link protocol.
 *
 * The calculator presents itself as a USB CDC serial port through srldrvce and
 * the sync page drives it with the Web Serial API. Every message is an 8-byte
 * header and an optional payload; the computer sends a request and the
 * calculator answers with the same command and sequence number.
 *
 * All fields are little-endian. See docs/PROTOCOL.md, and keep this file in
 * step with web/js/link.js.
 */
#ifndef PROTO_H
#define PROTO_H

#include <stdbool.h>
#include <stdint.h>

#define PROTO_VERSION       2

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
    PROTO_RESET      = 0x09,   /* <- delete the whole library */

    /*
     * Pushing a new build of the reader. The image arrives the way a comic
     * does -- one archived appvar per chunk -- because it does not fit in RAM
     * whole: sync already holds 16 KB for the payload and 2 KB for the serial
     * ring, out of about 50 KB.
     */
    PROTO_UPDATE_BEGIN = 0x0A, /* <- u16 build, u32 bytes, u16 chunks, u32 crc */
    PROTO_UPDATE_CHUNK = 0x0B, /* <- one chunk; arg = target | (index << 8) */
    PROTO_UPDATE_END   = 0x0C, /* -> verify the CRC and arm the update */

    /* The CE's clock is often unset, and read timestamps depend on it. */
    PROTO_CLOCK_SET    = 0x0D, /* <- u32 unix seconds */

    /*
     * Not a command: an unprompted notice that the calculator is about to be
     * busy for an unknown length of time, because the OS has decided to
     * defragment the archive and is asking the user to confirm it. Sent with
     * the sequence number of the request in progress. The computer must treat
     * it as "still alive, keep waiting" rather than as the reply.
     */
    PROTO_BUSY       = 0xFE,
} proto_cmd_t;

/*
 * HELLO's flag byte.
 *
 * Both answers cost an OS call, so both are gathered once before USB starts --
 * see rule 4 in usb.c. Asking the operating system anything from inside a
 * command handler is what froze the calculator the last time.
 */
#define PROTO_FLAG_UPDATER   0x01   /* prgmCSUP is installed */
#define PROTO_FLAG_ARMED     0x02   /* a reader update is waiting for it */

/* What HELLO says about the library already on the calculator. */
typedef enum {
    PROTO_LIBRARY_EMPTY     = 0,   /* nothing here yet; anything may be sent */
    PROTO_LIBRARY_SAME      = 1,   /* same library as the computer's */
    PROTO_LIBRARY_DIFFERENT = 2,   /* someone else's comics are on here */

    /*
     * The computer did not say which library it has, so the question cannot be
     * answered. That happens when no comics folder has been chosen -- a
     * perfectly ordinary way to connect, since an update is not about comics.
     * It is not "different": nothing has been compared.
     */
    PROTO_LIBRARY_UNKNOWN   = 3,
} proto_library_t;

typedef enum {
    PROTO_OK          = 0,
    PROTO_BAD_CMD     = 1,
    PROTO_BAD_LENGTH  = 2,
    PROTO_NO_ROOM     = 3,     /* not enough archive space */
    PROTO_WRITE_FAIL  = 4,     /* could not create or archive the variable */
    PROTO_NOT_FOUND   = 5,
    PROTO_TRUNCATED   = 6,     /* the payload ended early */
    PROTO_BAD_STATE   = 7,     /* the command does not apply right now */
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
uint24_t proto_bytes(void);   /* payload bytes moved this session */
uint8_t proto_library_state(void);  /* proto_library_t, as of the last HELLO */
uint8_t proto_collections(void);    /* archive defragments during this session */


#endif /* PROTO_H */
