# Two control experiments

The reader now enumerates correctly — `/dev/tty.usbmodem*` appears on the Mac,
which means `srldrvce` and the CDC descriptors work. It freezes when the port is
**opened**, inside `usb_HandleEvents()`, before a single protocol byte moves.

Opening a CDC port is when the host sends its class control requests:
`SET_LINE_CODING`, `GET_LINE_CODING` and `SET_CONTROL_LINE_STATE`. Those are
handled by `srldrvce`, not by any code in this repo — which is worth knowing,
because it means the fault may not be in the reader at all.

Notably, `srldrvce`'s handler covers `SET_LINE_CODING` (`0x21`/`0x20`) and
`GET_LINE_CODING` (`0xA1`/`0x21`), but **not** `SET_CONTROL_LINE_STATE`
(`0x21`/`0x22`), which macOS sends on every open. If that is the problem, it
affects every program built on `srldrvce` equally — including the toolchain's
own example.

These two tests separate the possibilities. Together they take about five
minutes and are worth far more than another guess.

## Test 1: the toolchain's own example

`SRLECHO.8xp` is `srl_echo` from `CEdev/examples/library_examples/srldrvce`,
built unmodified. It uses `srldrvce` exactly as this reader now does, but shares
no other code: no graphx, no appvars, no protocol.

1. Send `SRLECHO.8xp` to the calculator and run it. It prints `usb init`.
2. Plug into the Mac. Check `ls /dev/tty.usb*`.
3. Open it and type — it should echo back:

   ```sh
   screen /dev/tty.usbmodem<whatever>     # ctrl-a k to quit
   ```

## Test 2: the reader's own echo mode

The reader now has the same test built in, so the *only* difference from a
normal sync is the protocol on top.

1. Run `COMICS`. On the book list press **alpha** (not `2nd`).
2. The screen says `eBookSync - ECHO TEST`.
3. Plug in, `screen /dev/tty.usbmodem…`, and type.

It echoes every byte straight back and touches nothing else — no appvars, no
library, no protocol.

## What the outcomes mean

| Test 1 | Test 2 | Where the fault is |
|---|---|---|
| echoes | echoes | The transport is fine. The fault is in my protocol handling, and the difference is now a small amount of code I can bisect. |
| echoes | freezes | `srldrvce` is fine, and something else in the reader — its heap, its use of graphx before sync, its open appvars — is breaking it. Also bisectable, and I would start by stripping the reader back to nothing but the sync screen. |
| freezes | freezes | The fault is below anything I control: `srldrvce`, `usbdrvce`, this OS version, or this calculator. No change to the reader will fix it, and the answer is to raise it with the toolchain authors — with these two results as the report. |

The third row is a real possibility and worth naming plainly. Seven fixes went
into the hand-written USB device before it was abandoned, and the failure never
moved. If `srl_echo` freezes on your machine too, that was never my bug to find.
