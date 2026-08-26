# The bug

The sync screen froze after showing "Starting", **with no cable attached**. That
ruled out USB entirely and pointed at the only thing that runs between drawing
that word and waiting for the computer: gathering the free archive size.

It did that by binary-searching `ti_ArchiveHasRoom` -- twenty-four calls, each
one walking the VAT and the flash, several of them asking whether eight
megabytes would fit in a three megabyte archive. That is what froze the
calculator.

The right way is one call:

```c
os_ArcChk();                      /* one OS routine */
free = os_TempFreeArc;            /* it leaves the answer here */
```

It also explains the whole trail backwards. `HELLO` called that binary search,
so every connection froze on the first command. Random keystrokes never did,
because eight bytes of `A` parse as a payload length of about a billion, so the
reader sat in `drain()` and never reached a command handler at all. Echo mode
never did either, because it runs no commands. Every "it must be USB" conclusion
came from a program that never once completed a command.

# What was rewritten

`calc/src/usb.c`, around four rules:

1. **One `usb_HandleEvents()` per turn round the loop**, at the top. Nothing
   nests another event pump inside itself.
2. **Nothing blocks.** `srl_Read` and `srl_Write` are non-blocking by contract,
   so the link is a state machine -- header, payload, execute, reply -- where
   each state moves at most 512 bytes and returns. No inner loop ever waits on
   the computer, so the keypad is always scanned and `clear` always works.
3. **OS calls happen in exactly one place**, `execute()`, with the whole request
   already in memory and nothing in flight.
4. **Nothing asks the OS an expensive question.**

# The test that would have caught it

The host suite reported 231 green checks through every one of these bugs,
because the shim answered `ti_ArchiveHasRoom` instantly. It now counts calls
into the operating system made while the link is up, and requires the read-only
commands to make none:

```
=== with the OS binary search back in HELLO ===
  FAIL hello/list/index/space make no OS calls: got 24, want 0
20/21 usb protocol checks pass

=== rewritten ===
21/21 usb protocol checks pass
```

# Testing this build

`SRLECHO.8xp` and `probe.sh` are still here and still useful.

1. `diagnostics/probe.sh /dev/cu.usbmodem<whatever>` -- calculator on the Sync
   screen. Expect 14 bytes back beginning `01 01 00 00 06 00 00 00 01`.
2. Then the page: connect, and it should show the calculator's contents.
3. Then a real sync.

Use `/dev/cu.*`, not `/dev/tty.*` -- on macOS the latter blocks on open waiting
for a carrier signal a USB gadget never asserts.
