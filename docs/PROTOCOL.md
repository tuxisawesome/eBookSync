# The eBookSync link protocol

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
starves it.

The fix that worked was to scan far less often rather than to scan differently:
the loop calls `kb_Scan()` every 32 turns, which is still faster than a person
can press a key. Putting the keypad in `MODE_3_CONTINUOUS` was tried first and
did not help, so the sync loop matches `srl_echo`, the one device-mode program
in the toolchain known to work, and does nothing clever with the keypad at all.

The screen also shows how many requests have been handled, the last command
byte, and how many receives failed. When a sync stalls, the difference between
"nothing ever arrived", "requests arrive but replies fail" and "the link
dropped" is the entire diagnosis, and there is nowhere else to see it.

## Commands

| cmd | name | payload | reply |
|-----|------|---------|-------|
| 0x01 | `HELLO` | the 16-byte library id | `u8 protocol, u24 freeArchive, u8 maxChunks, u8 chunkSize/256, u8 library, u16 build, u8 flags, u16 armedBuild` |
| 0x02 | `LIST` | - | `u16 count`, then `count` x 14-byte strip records |
| 0x03 | `PUT_CHUNK` | the chunk; `arg` = `slot \| (index << 8)` | status only |
| 0x04 | `DEL` | none; `arg` = slot | `u8 chunksRemoved` |
| 0x05 | `INDEX_GET` | - | the CSLIB bytes, device block zeroed (empty if there is no index) |
| 0x06 | `INDEX_PUT` | the CSLIB bytes | status only |
| 0x07 | `SPACE` | - | `u24 freeArchive` |
| 0x08 | `BYE` | - | status only |
| 0x09 | `RESET` | - | `u16 stripsRemoved` |
| 0x0A | `UPDATE_BEGIN` | `u16 build, u32 bytes, u16 chunks, u32 crc32`; `arg` = target | status only |
| 0x0B | `UPDATE_CHUNK` | the chunk; `arg` = `target \| (index << 8)` | status only |
| 0x0C | `UPDATE_END` | -; `arg` = target | status only |
| 0x0D | `CLOCK_SET` | `u32 unix seconds` | status only |

`library` is `0` empty, `1` the same library as the computer's, `2` somebody
else's, `3` not compared -- see "Two libraries, one calculator" in the README.

An all-zero id means "no identity" at either end, and the two ends of that mean
different things. Sent *by the computer* it means no comics folder has been
chosen, so there is nothing to compare and the answer is `3`; connecting to
install an update alone is ordinary, and answering `2` there would have made the
page offer to erase a library on the strength of a comparison it never made.
Stored *on the calculator* it means the index has been emptied, so the
calculator is free to take anything and the answer is `0`.

`build` is the reader's build number, from `calc/BUILD`. It is what the page
compares against `web/comics/build.json` to decide whether it has something newer
to push.

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

## Version skew

`PROTO_VERSION` is 2. The page reports a mismatch rather than refusing to talk,
and that is deliberate: the update travels over this same link, so a page that
hung up on an out-of-date calculator would be unable to fix exactly the
calculators that need fixing.

Protocol 1 is eBookSync, which has no `UPDATE_*` commands at all, so there is
nothing the page can push it -- eBookSync has to be installed once by hand. From 2 on,
a calculator that is behind can always be brought forward over the link.

## Updating the reader over the link

A CE program runs in place inside its own variable, so it cannot overwrite
itself: deleting the variable would delete the code doing the deleting. eBookSync
gets round that with two programs that install each other.

| | |
|---|---|
| `COMICS` | the reader. Installs `CSUP`, which is not running while it does. |
| `CSUP` | the updater. Installs `COMICS`, which is not running while it does. |

So an updater update is invisible -- the reader applies it during the sync that
brings it down -- and only a reader update needs the user to quit and run
`prgmCSUP` once. It also means `CSUP` can be created from nothing, so the only
file that ever has to be installed by hand is `COMICS.8xp`.

The image arrives the way a comic does: `UPDATE_BEGIN`, then one `UPDATE_CHUNK`
per 16 KB, then `UPDATE_END`. It does not fit in RAM whole -- sync already holds
16 KB for the payload and 2 KB for the serial ring, out of about 50 KB -- and
chunks sitting in the archive can be checksummed and copied through pointers
without ever being staged. `target` is `0` for the reader and `1` for the
updater.

**This is the one thing here that is checksummed.** Nothing else in the protocol
is, deliberately: the wire is a USB byte stream with its own integrity, and a
comic that arrives damaged is a smeared page. A program that arrives damaged is
a calculator that will not start the reader, and whose only way back is a cable
and TI Connect. `UPDATE_END` CRC-32s every chunk where it lies in flash and
refuses the lot on a mismatch -- `PROTO_TRUNCATED` -- with nothing replaced and
nothing armed. `prgmCSUP` checks again before it deletes anything, because the
chunks have been sitting in the archive since the sync and that is the last
moment at which finding them damaged is free.

The page sends the updater first. If the session dies between the two, what is
left is a calculator with a current updater and its old reader -- which still
works, and can still be updated next time. The other order would leave an armed
reader update and an updater too old to be trusted with it.

`HELLO`'s `build`, `flags` and `armedBuild` are what drive all of this. `flags`
bit 0 says `prgmCSUP` is installed, bit 1 says a reader update is armed and
waiting for it. All of it costs one OS call, gathered once before USB starts.

`build` is what the calculator is *running*. A reader update is armed rather
than installed, so that number does not move until `prgmCSUP` has been run --
which is why `armedBuild` exists. Without it a page comparing only `build`
against its own catalogue offers to send a build it has already sent, every
time, and the calculator reads as permanently one behind. An armed update
matching the catalogue means "done, waiting to be installed"; one that does not
match is from an earlier deploy and is genuinely replaced.

## Setting the clock

The CE has an RTC, but it is very often unset, and read timestamps depend on
it. `CLOCK_SET` carries the computer's unix time at the start of every
sync; the calculator stores the *difference* in the index's device block rather
than touching the RTC, so nothing depends on what epoch the clock counts from --
only on it running. The write happens only when the correction moves by more
than a minute, since it costs an unarchive and re-archive of the index.

## Defragmenting

The OS defragments the archive when it runs out of room, and it may decide to do
so on any archive write -- so, during a sync, on any `PUT_CHUNK`. Two things
follow, and both have teeth.

**It asks the user first.** The prompt waits for a keypress, so the operation
takes as long as it takes. A computer that gives up during it abandons a strip
half-written and the two ends stop agreeing about what is stored. So before the
collect starts, the calculator sends a header with cmd `0xFE`, `PROTO_BUSY`,
carrying the sequence number of the request in flight. It is a notice, not a
reply: the computer treats it as "still alive", stretches its patience to
fifteen minutes and keeps reading. `web/js/link.js` reads reply headers in a
loop for exactly this reason.

**It moves every archived variable.** Every pointer from `ti_GetDataPtr` is
meaningless afterwards -- the cached library index, and the chunk pointers a
strip is being read from. `ti_SetGCBehavior` installs a handler that maps them
all again, and re-reads the free space the collect just recovered. The menus
install their own pair as well, which also hands the LCD back to the OS so the
prompt can draw over graphx's 8bpp mode and restores it afterwards.

A late reply -- the answer to a request the computer already gave up on -- is
discarded rather than treated as a fault, so a link that does get out of step
recovers on its own instead of failing every command after it.

## Status codes

`0` OK, `1` unknown command, `2` bad length, `3` not enough archive space,
`4` could not create or archive the variable, `5` not found, `6` payload ended
early, `7` the command does not apply right now.

`freeArchive` is what fits **without** a garbage collect. Deleted variables do
not hand their space back until the OS collects, and it does that by itself
during the next archive write that needs the room -- so the number is a floor.
`PUT_CHUNK` therefore does not pre-check for space: it writes the variable and
archives it, letting the collect happen, and only reports `3` if that genuinely
fails. A sync that gets `3` should `DEL` more strips and retry the same chunk.

## How a sync goes

1. `HELLO`, then `CLOCK_SET`, then `LIST` and `INDEX_GET`.

   The update runs here too, and it does not wait on the library: `UPDATE_*` if
   the page has a newer build.
2. The computer merges the calculator's read flags and scroll positions into
   `ebooksync.json`; the calculator wins, because that is where reading happened.
3. `DEL` for every strip that auto-cleanup decided to drop, then `SPACE` to see
   what that recovered.
4. `PUT_CHUNK` for every chunk of every strip being pushed. Chunks are
   independent and acknowledged one at a time, so an interrupted sync resumes by
   simply re-`LIST`ing and sending what is missing.
5. `INDEX_PUT` with a freshly built CSLIB describing what is now resident. The
   calculator splices its own device block back into it -- see docs/FORMAT.md.
6. `BYE`.

Expect roughly 30-60 seconds per strip. Full-speed bulk gives about 1 Mbit/s in
practice, but the flash write and the occasional garbage collect dominate, which
is why every step reports progress.

## Device descriptors

Vendor ID `0x16C0`, product ID `0x05E1` -- the shared V-USB CDC identifiers that
`srl_GetCDCStandardDescriptors()` presents. The sync page filters on them.

`srldrvce` owns the descriptors; the reader writes none of its own and answers
no control requests. That is the point of it.
