# The eBookSync sync protocol

The calculator presents itself as a **USB CDC serial port** using `srldrvce`,
and the sync page talks to it with the **Web Serial API**. The calculator must
be running the reader and sitting on its Sync screen before you connect.

`calc/src/usb.c` and `web/js/link.js` are the two ends; `calc/src/proto.h` holds
the constants both must agree on.

## Why a serial port

The original design was a hand-written vendor-class WebUSB device: the reader
declared its own descriptors, answered control requests, looked up its own
endpoints and scheduled its own transfers. It never worked. Seven separate
defects were found and fixed in it -- blocking receives, control replies sent
with the wrong API, packet-illegal framing, receives shorter than the endpoint's
maximum -- and it still froze inside `usb_HandleEvents()` with no transfer ever
completing and no error ever reported.

`srldrvce` is the one device-mode path on this platform that is known to work;
the toolchain's own `srl_echo` example demonstrates it. Moving to it deletes
every line where those defects lived. What is left is a byte stream, which is
all this protocol ever needed.

The cost is that it is not WebUSB. Nothing else changed: the framing, the
commands and everything above them are identical.

**No driver is needed on any platform.** A CDC serial port is claimed by the
operating system's own driver, and Chrome talks through that -- no WinUSB, no
Zadig, no udev rule. On Linux your user may need to be in the `dialout` group.

## Framing

Every message is an 8-byte header, little-endian, optionally followed by a
payload:

```
0  1  cmd
1  1  seq      echoed in the reply
2  2  arg      a command argument in requests; a proto_status_t in replies
4  4  length   payload bytes that follow
```

The computer sends a request and waits for the reply carrying the same `cmd` and
`seq`. There is exactly one request in flight at a time -- the calculator has no
room to queue work, and a strict lockstep makes recovery after an unplug simple.

## The stream

A serial port is a byte stream, so the framing needs no care beyond reading the
right number of bytes: a header, then exactly `length` payload bytes. Requests
and replies both go out as a single write.

Arguments still ride in the header's `arg` field rather than at the front of the
payload -- `PUT_CHUNK` carries `slot | (index << 8)` there, `DEL` carries the
slot. That was forced by the old packet-based transport and kept because it is
simply tidier: the payload is the chunk and nothing else.

Neither end ever blocks. `srl_Read` returns what it has, so the reader pumps the
USB event loop and redraws between reads, and the user can always press `clear`.

## Speed

Two things set the pace, and only one of them is the wire.

**The link.** srldrvce schedules 64-byte reads and re-arms when the ring buffer
is drained, so throughput depends on how often the loop gets round to calling
`srl_Read`. Anything expensive per turn throttles the whole transfer. `kb_Scan()`
was the culprit: it disables interrupts and waits for a hardware scan, roughly a
millisecond, and it was being called every single turn. It now runs every 32
turns -- still far faster than a person can press a key -- and the ring buffer
is 2 KB rather than 512 bytes so more accumulates between turns.

Redrawing the status is several OS text calls, so it happens when a command
completes or every few thousand turns, not on every state change.

**The flash.** Each 16 KB chunk is created in RAM and then archived, and
archiving writes flash, which is slow and occasionally triggers a garbage
collect. That cost is inherent -- the data has to land somewhere permanent --
and it happens between chunks with the link idle.

The page reports a KB/s figure while sending, so this is measurable rather than
a matter of opinion.

## graphx has to be off

usbdrvce notes that a transfer fails with `USB_TRANSFER_BUS_ERROR` when
"non-default cpu speed or lcd parameters are in effect". `gfx_Begin()` puts the
LCD into 8bpp palettised mode, which is precisely such a parameter change: the
LCD and the USB controller contend for the memory bus, and in that mode USB
loses.

With graphx running, the sync loop froze **inside `usb_HandleEvents()`** with no
transfer ever completing and no error ever reported. `srl_echo`, the one
device-mode program in the toolchain that is known to work, makes no graphx
calls at all and runs on the homescreen.

So `ui_sync_screen()` calls `gfx_End()` before touching USB, draws its status on
the OS text display, and calls `gfx_Begin()` again afterwards. The phase marker
writes 16bpp pixels straight into video memory for the same reason.

## The keypad, of all things

`kb_Scan()` disables interrupts while it runs. Scanning once per frame in a menu
is fine; doing it in the sync loop, which spins as fast as it can, is not -- the
USB driver is interrupt-driven, and a loop that keeps switching interrupts off
starves it. Transfers stop completing, the computer times out waiting for a
reply, and the keypad looks dead too, so there is no way out but the reset
button.

The sync screen therefore puts the keypad in `MODE_3_CONTINUOUS` for the
duration: the controller scans by itself and the loop only reads `kb_Data`,
touching no interrupts. See `input_begin_continuous()`.

The screen also shows how many requests have been handled, the last command
byte, and how many receives failed. When a sync stalls, the difference between
"nothing ever arrived", "requests arrive but replies fail" and "the link
dropped" is the entire diagnosis, and there is nowhere else to see it.

## Commands

| cmd | name | payload | reply |
|-----|------|---------|-------|
| 0x01 | `HELLO` | - | `u8 protocol, u24 freeArchive, u8 maxChunks, u8 chunkSize/256` |
| 0x02 | `LIST` | - | `u16 count`, then `count` x 14-byte strip records |
| 0x03 | `PUT_CHUNK` | the chunk; `arg` = `slot \| (index << 8)` | status only |
| 0x04 | `DEL` | none; `arg` = slot | `u8 chunksRemoved` |
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

Vendor ID `0x16C0`, product ID `0x05E1` -- the shared V-USB CDC identifiers that
`srl_GetCDCStandardDescriptors()` presents. The sync page filters on them.

`srldrvce` owns the descriptors; the reader writes none of its own and answers
no control requests. That is the point of it.
