# A control experiment

`SRLECHO.8xp` is the CE toolchain's own `srl_echo` example, built unmodified
from `CEdev/examples/library_examples/srldrvce/srl_echo`. It is the one
device-mode USB program on this platform that is known to work.

It makes the calculator appear as a **USB serial port** and echoes back
everything it is sent. It uses `srldrvce`, which sits on top of the same
`usbdrvce` the reader uses, but it makes no graphx calls and hand-writes no
descriptors.

## Why run it

The reader's sync loop freezes inside `usb_HandleEvents()` with no transfer ever
completing and no error ever reported. That is either a bug in how the reader
drives `usbdrvce`, or something about this calculator, OS version or host that
stops device mode working at all. Seven rounds of reading documentation have not
separated those two, and this does, in about two minutes.

## Running it

1. Send `SRLECHO.8xp` to the calculator and run it (arTIfiCE first, as usual).
2. The screen says `usb init`, then waits.
3. Plug the calculator into the Mac.

Then, on the Mac:

```sh
ls /dev/tty.usb*          # before plugging in, and after
```

If a new device appears, open it and type:

```sh
screen /dev/tty.usbmodem<whatever>   # ctrl-a k to quit
```

Anything you type should come straight back.

## What the outcome means

**A serial port appears and echoes** — `usbdrvce` device mode works fine on your
hardware, and the fault is in the reader. The difference between the two
programs is then a short list, and I can bisect it.

**No serial port appears, or the calculator freezes** — device mode does not
work on this calculator/OS combination at all, and no amount of fixing the
reader will help. The transport has to change.

Either answer is worth far more than another guess.
