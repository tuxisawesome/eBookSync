# Where things stand

Your last observation changed the picture. Holding `A` in `screen` made the
request counter tick up; a single tap did nothing. That is exactly right: `A`
held repeats the byte, and **eight bytes make a complete protocol header**,
which the reader then dispatched and replied to. One tap is one byte, which is
not a header.

So the reader **is** running the protocol correctly over `screen`. `srl_Read` is
documented and implemented as non-blocking -- it pops a ring buffer -- so the
loop was never stalled there either.

Which means the comparison that looked decisive was confounded: echo mode was
tested with `screen`, sync mode with Chrome. The variable was never echo versus
sync. **It is `screen` versus Chrome.**

## The first thing to check: cu, not tty

On macOS, `/dev/tty.usbmodem*` **blocks on open waiting for carrier detect**,
which a USB serial gadget never asserts. `/dev/cu.usbmodem*` is the call-out
device and opens immediately. They are the same hardware behind different open
semantics, and the tty one hanging on open would look exactly like a freeze.

Chrome picks the device itself, so this may not be what it is doing -- but if
any of your `screen` testing used `tty.*`, that alone muddies the results.

## Test: the protocol, without a browser

```sh
diagnostics/probe.sh /dev/cu.usbmodem<whatever>
```

Calculator on the **Sync** screen (`2nd`, not `alpha`). This sends one `HELLO`
and prints the reply -- the same exchange the page makes on connect, with no
browser in the way.

**It replies** (14 bytes starting `01 01 00 00 06 00 00 00 01`) -- the calculator
and the protocol are both fine end to end, and the fault is in the page: either
`web/js/link.js` or how Chrome drives the port. That is code I can test here,
which would be a first.

**It hangs or the calculator freezes** -- the fault is on the calculator after
all, and it is provoked by real protocol traffic rather than by stray keystrokes.
The `cmd` counter on screen will say which command was in flight.

## Also worth noting

If `probe.sh` works, try the page again straight afterwards **without
re-running the program**. If the page then works too, something about the
first connection after a fresh start is the trigger -- which would point at the
`gather_state()` call that now runs before `usb_Init()`.
