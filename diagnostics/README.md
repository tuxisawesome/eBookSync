# Where things stand

`srl_echo` works on this Mac; the reader's own echo mode freezes on port open.
That was the decisive pair:

- **srldrvce and the CDC transport are fine.** Enumeration, control requests,
  the lot.
- **The protocol is innocent.** Echo mode runs none of it and still froze.
- The fault is something else in the reader's environment that `srl_echo` does
  not have.

## What changed as a result

The sync loop now matches `srl_echo` as closely as it can. Three differences
were removed:

1. **`srl_Open` is called from inside the USB event handler**, the way
   `srl_echo` does it, rather than deferred to the main loop. srldrvce's header
   says not to; its own working example does it anyway. When the documentation
   and the only working example disagree, follow the example.
2. **`kb_Scan()` again**, instead of continuous keypad mode. `kb_Scan()`
   disables interrupts, which looked like a hazard next to an interrupt-driven
   USB driver -- but `srl_echo` calls it in its loop and works, and continuous
   mode did not help.
3. **No more framebuffer writes in the loop.** The phase marker painted pixels
   straight into video memory every iteration, which nothing else here does. It
   had already told us what it needed to (red: inside `usb_HandleEvents`).

## Test it in this order

**1. Echo mode.** Run `COMICS`, press **alpha** on the book list, plug in,
`screen /dev/tty.usbmodem…` and type. It should echo.

**2. If echo works, sync.** Press `2nd` instead and sync from the page.

## If echo still freezes

Then it is none of those three, and what is left is the reader's memory layout:
it allocates around 60 KB for the band cache at startup and frees it before
sync, and `usbdrvce` places its own structures at `0xD10000` -- the same region
a CE program's heap grows into. `USB_USE_C_HEAP` in `usbdrvce.h` carries the
warning "do not use this unless you changed your program's bss/heap to end at
0xD10000", which says the two areas do overlap by default.

The next step would be to stop the reader from ever growing its heap that far:
allocate the band cache from a fixed static buffer instead of `malloc`. That is
a contained change, and it is where I would go next.
