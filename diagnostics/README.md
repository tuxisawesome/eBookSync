# Where things stand

Echo mode works. Sync freezes. Between them that isolates the fault precisely:

- **The transport is fine.** `srl_echo` works, and so does the reader's own echo
  mode -- bytes in, bytes out, `req` climbing as you type.
- **The fault is in what the protocol *does***, not in the link it does it over.

## What the protocol does that echo does not

It calls the operating system. `HELLO`, the very first command and the one the
page sends on connect, called `ti_ArchiveHasRoom()` **twenty-four times** in a
binary search for the free archive size. That routine walks the VAT and the
flash. Doing that while a USB transfer may be in flight is the one thing echo
mode never does, and echo mode has never once failed.

## What changed

**The read-only commands no longer touch the OS at all.** Everything they answer
with -- free archive space, the library index and its size -- is gathered once
before `usb_Init()` and served from memory afterwards. `HELLO`, `LIST`,
`INDEX_GET`, `SPACE` and `BYE` now make no OS calls whatsoever.

**Chunks are taken into RAM before any of them is written.** `PUT_CHUNK` used to
interleave `ti_Write` calls between USB reads, which is the worst possible
pattern: OS work and USB traffic taking turns. Now the whole 16 KB transfer
finishes first and the OS work happens in one go with nothing USB-related in
between.

## What to watch

Connect from the page. It sends `HELLO`, then `LIST`, then `INDEX_GET` -- none
of which touch the OS any more. If the page shows the calculator's contents,
that is the connection working for the first time.

Then sync. That is where writes happen, and writes cannot be avoided. If it
freezes there, **the `cmd` number on the calculator's screen says which command
was in progress**:

| `cmd` | command | touches the OS |
|---|---|---|
| 1 | `HELLO` | no longer |
| 2 | `LIST` | no |
| 3 | `PUT_CHUNK` | yes -- creates and archives an appvar |
| 4 | `DEL` | yes -- deletes an appvar |
| 5 | `INDEX_GET` | no longer |
| 6 | `INDEX_PUT` | yes -- creates and archives an appvar |
| 7 | `SPACE` | no longer |

`cmd 3` or `cmd 6` would mean flash writes cannot happen while the link is up,
and the answer is to restructure so they happen between sessions rather than
during one. That is a bigger change, but a well-defined one.
