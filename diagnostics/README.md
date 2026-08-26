# Where things stand

`probe.sh` freezes the calculator exactly as Chrome does. That settles two
things:

- **Chrome and `web/js/link.js` are innocent.** A shell script sending eight
  bytes does it too.
- **The fault is on the calculator, and it is the reply that triggers it.**

Your keystroke experiment explains why that took so long to see. Holding `A`
sends `41 41 41 41 41 41 41 41`, which the reader parses as a header with a
payload length of `0x41414141` -- about a billion bytes. It then sits in
`drain()` consuming them and **never reaches the code that writes a reply**. So
every test with random keystrokes exercised the read path only. A real `HELLO`
has a payload length of zero, so it goes straight to writing.

Writing the reply is the one thing that had never actually been tested.

## This build says where it stops

The sync screen's status line now names the exact position, and it updates as
the command runs. When it freezes, whatever it last displayed is where it died:

| status | meaning |
|---|---|
| `1 header in` | the eight header bytes arrived and were dispatched |
| `2 in hello` | inside the HELLO handler, before anything is written |
| `w: events` | inside `usb_HandleEvents()`, called before each write |
| `w: srl_Write` | inside `srl_Write()` itself |
| `3 header sent` | the 8-byte reply header went out |
| `4 hello done` | the whole reply went out -- HELLO worked |
| `Connected` | back in the main loop, waiting for the next command |

## Run it

```sh
diagnostics/probe.sh /dev/cu.usbmodem<whatever>
```

Calculator on the Sync screen. Report the last status line shown.

`w: srl_Write` or `w: events` narrows this to a single function call, and one of
those two is almost certainly it. `4 hello done` would mean HELLO now works and
something later is at fault.
