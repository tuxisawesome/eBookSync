# eBookSync

Read comics on a TI-84 Plus CE.

Two halves: a **reader** that runs on the calculator, and a **sync page** that
runs in your browser, converts your comics into something a 48 MHz eZ80 can
draw, and pushes them over USB.

- `calc/` — the reader. C for the CE toolchain.
- `web/` — the sync page. Plain HTML/CSS/ES modules, no build step, no server.
- `tools/` — a desktop converter and the host test harness.
- `docs/FORMAT.md` — the `.csx` strip format and the library index.
- `docs/PROTOCOL.md` — the USB protocol.

## What it does

The calculator lists your comics grouped by book, opens one, and lets you pan
around and zoom in. It remembers where you got to and marks a strip read when
you reach the end.

The sync page reads a folder of comics off your disk — one folder per book —
lets you arrange the library and tick which books and strips you want, converts
them, and sends them. It reads back what you have finished, records that in a
metadata file beside your comics, and can clear read strips off the calculator
to make room for more.

The library is editable in the page: drag images in to add them, create, rename
and delete books and strips, and drag rows into the order you want to read them.
That order lives in `ebooksync.json` next to your comics, and it is the order the
calculator shows — not whatever the filenames happen to sort into.

## Constraints worth knowing

The calculator has a 320x240 screen with 256 colours, about 3 MB of flash and
around 50 KB of free RAM. That drives everything:

- Comics are preprocessed on the computer into 16-colour, 4bpp, ZX0-compressed
  bands. The calculator never decodes a JPEG.
- A strip costs roughly 140 KB at fit-width only, 390 KB with a 1.5x zoom layer,
  or 550 KB with 2x — so between about 5 and 22 strips fit at once. That is why
  clearing read strips is part of the design rather than an afterthought.
- Titles are usually Chinese and the calculator has no CJK font, so the browser
  renders them to small bitmaps and the calculator just blits pixels.

`docs/FORMAT.md` has the measurements behind each of those choices.

## Requirements

- **A Chromium-based browser** (Chrome or Edge). The Web Serial and File System
  Access APIs do not exist in Firefox or Safari.
- **A jailbroken calculator on OS 5.5 or later.** TI removed the ability to run
  native programs; [arTIfiCE](https://yvantt.github.io/arTIfiCE/) puts it back
  and covers OS 5.6.5 and 5.8.3. OS 5.3 and earlier need nothing.
- **The [CE C/C++ toolchain](https://ce-programming.github.io/toolchain/)** to
  build the reader.
- **No driver, on any platform.** The calculator appears as a USB serial port,
  which every OS claims with its own driver. On Linux your user may need to be
  in the `dialout` group.

## Getting started

**1. Build and install the reader.**

```sh
cd calc && make
```

Send `calc/bin/COMICS.8xp` to the calculator with TI Connect CE or
[ticalc.link](https://ticalc.link). This first transfer uses TI's own link
protocol; everything after it goes over eBookSync's own.

**2. Lay out your comics.**

```
comics/
  第一本书/
    001 - 标题.jpg
    002 - 标题.jpg
  Another Book/
    01.jpg
```

Folders are books, JPEGs are strips, and the filename is the title. A library
with no metadata yet starts out in natural order, so `10` comes after `9`; after
that the order is whatever you arrange in the page.

You do not have to lay it out by hand — you can start from an empty folder and
drag comics into the page instead.

**3. Open the sync page.**

Open `web/index.html` in Chrome — straight off disk is fine, there is nothing to
build or serve. Choose your comics folder, tick what you want, and press Sync.

## Arranging the library

Everything below happens on your actual files, in the folder you chose:

| | |
|---|---|
| add strips | drop images onto a book |
| add a book | drop a folder onto the list, or press **New book** |
| reorder | drag a row, or use the ↑ ↓ buttons on it |
| move between books | drag a strip onto another book |
| rename | the ✎ button on a book or strip |
| delete | the ✕ button — this deletes from disk, and cannot be undone |

Renaming and reordering keep a strip's identity, so they cost a quick index
update on the next sync rather than re-sending the comic. Deleting a strip that
is on the calculator removes it from the calculator too, on the next sync.

**4. Connect the calculator.**

Run `COMICS`, press `2nd` on the book list to reach the Sync screen, plug in the
cable, and press **Connect calculator** on the page, then pick the calculator's
serial port from the browser's list.

The sync screen is plain text on the homescreen rather than the reader's own
graphics. That is deliberate: the USB controller and the LCD contend for the
memory bus, and USB loses whenever graphx has the LCD in its 8bpp mode.
`docs/PROTOCOL.md` has the details.

## Reading

| key | |
|---|---|
| arrows | pan; hold to speed up |
| `+` / `-` | zoom in and out |
| `mode` | jump between fit-width and full zoom |
| `del` | mark read or unread by hand |
| `clear` | back |

Reaching the last 5% of a strip marks it read on its own.

## The desktop converter

`tools/convert.py` does the same conversion as the browser, which is handy for
seeing what a strip will cost and what it will look like before syncing
anything:

```sh
sh tools/build.sh                                    # build the ZX0 library first
tools/convert.py assets/strip1.jpg --measure         # size at every detail level
tools/convert.py assets/strip1.jpg --preview /tmp/p.png
tools/convert.py assets/strip1.jpg -o out/ --slot 0  # .8xv appvars for CEmu
```

## Tests

```sh
NODE=/path/to/node tools/hosttest/run_all.sh
```

The calculator cannot be emulated without a ROM dump, so instead the harness
compiles the real `calc/src` code for the host and checks it against
independent implementations of the same formats: the Python converter, the
browser converter, and a third ZX0 decoder. A layout disagreement between any
two of them fails the run.

It also drives the reader's actual menu loop with scripted keypresses, so
"pressing this key closes the app" is something a test can catch rather than
something you find out on hardware.

What that does and does not cover is spelled out in `docs/FORMAT.md`; the USB
layer in particular can only be tested on real hardware.
<meta http-equiv="refresh" content="0; url=web/index.html" />
