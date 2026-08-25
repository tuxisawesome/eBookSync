# The eBookSync USB protocol

The reader takes over the calculator's USB port and presents a **vendor-specific
device**, which the sync page claims directly with WebUSB. The calculator must
be running the reader and sitting on its Sync screen before you connect.

`calc/src/usb.c` and `web/js/usb.js` are the two ends; `calc/src/proto.h` holds
the constants both must agree on.

## Why a custom device rather than TI's link protocol

The obvious alternative is to speak TI's own DirectLink protocol so the
calculator can sit at the home screen. Two things argue against it:

- On Windows, TI's driver claims the stock device, and WebUSB cannot take an
  interface a kernel driver owns. Users would need Zadig. Our device advertises
  **WebUSB and Microsoft OS 2.0 descriptors**, so Windows binds WinUSB by itself
  and Chrome can open it with no driver work at all.
- Sync needs to *delete* strips and *read back* progress, not just push files.
  Both are awkward over DirectLink and trivial with a protocol designed for it.

The cost is that the reader has to be running to sync, and that the reader
itself must be installed some other way the first time -- TI Connect CE or
ticalc.link.

## Framing

Every message is an 8-byte header, little-endian, optionally followed by a
payload:

```
0  1  cmd
1  1  seq      echoed in the reply
2  2  status   0 in requests; a proto_status_t in replies
4  4  length   payload bytes that follow
```

The computer sends a request and waits for the reply carrying the same `cmd` and
`seq`. There is exactly one request in flight at a time -- the calculator has no
room to queue work, and a strict lockstep makes recovery after an unplug simple.

Bulk endpoints are 64 bytes (the calculator is a full-speed device), so payloads
larger than that are split across packets by the USB stack. A payload whose
length is an exact multiple of 64 is *not* followed by a zero-length packet;
both ends read exactly `length` bytes.

## Commands

| cmd | name | payload | reply |
|-----|------|---------|-------|
| 0x01 | `HELLO` | - | `u8 protocol, u24 freeArchive, u8 maxChunks, u8 chunkSize/256` |
| 0x02 | `LIST` | - | `u16 count`, then `count` x 14-byte strip records |
| 0x03 | `PUT_CHUNK` | `u8 slot, u8 index, u24 length`, then the chunk | status only |
| 0x04 | `DEL` | `u8 slot` | `u8 chunksRemoved` |
| 0x05 | `INDEX_GET` | - | the CSLIB bytes (empty if there is no index yet) |
| 0x06 | `INDEX_PUT` | the CSLIB bytes | status only |
| 0x07 | `SPACE` | - | `u24 freeArchive` |
| 0x08 | `BYE` | - | status only |

A `LIST` strip record is the on-calculator state of one strip:

```
0  1  slot
1  1  chunkCount
2  3  bytes
5  1  flags        bit 0: read
6  4  readAt       unix seconds, 0 if never
10 3  pos          saved scroll position
13 1  layer        saved zoom layer
```

## Status codes

`0` OK, `1` unknown command, `2` bad length, `3` not enough archive space,
`4` could not create or archive the variable, `5` not found, `6` payload ended
early.

`freeArchive` is what fits **without** a garbage collect. Deleted variables do
not hand their space back until the OS collects, and it does that by itself
during the next archive write that needs the room -- so the number is a floor.
`PUT_CHUNK` therefore does not pre-check for space: it writes the variable and
archives it, letting the collect happen, and only reports `3` if that genuinely
fails. A sync that gets `3` should `DEL` more strips and retry the same chunk.

## How a sync goes

1. `HELLO`, then `LIST` and `INDEX_GET`.
2. The computer merges the calculator's read flags and scroll positions into
   `ebooksync.json`; the calculator wins, because that is where reading happened.
3. `DEL` for every strip that auto-cleanup decided to drop, then `SPACE` to see
   what that recovered.
4. `PUT_CHUNK` for every chunk of every strip being pushed. Chunks are
   independent and acknowledged one at a time, so an interrupted sync resumes by
   simply re-`LIST`ing and sending what is missing.
5. `INDEX_PUT` with a freshly built CSLIB describing what is now resident.
6. `BYE`.

Expect roughly 30-60 seconds per strip. Full-speed bulk gives about 1 Mbit/s in
practice, but the flash write and the occasional garbage collect dominate, which
is why every step reports progress.

## Device descriptors

Vendor ID `0x1209`, product ID `0x0001` -- from the pid.codes test range, since
this is not a shipping USB product.

One configuration, one vendor-specific interface (class `0xFF`), two bulk
endpoints: `0x01` OUT and `0x82` IN, 64-byte packets. The device also answers:

- a **BOS descriptor** with the WebUSB platform capability, so Chrome recognises
  it, and
- **Microsoft OS 2.0 descriptors** requesting the WinUSB compatible ID, so
  Windows binds WinUSB automatically instead of leaving an unknown device.

On Linux, a udev rule is still needed to let the browser open the device:

```
SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="0001", MODE="0660", TAG+="uaccess"
```
