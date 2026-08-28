# eOS

Read comics on a TI-84 Plus CE.

Two halves: a **reader** that runs on the calculator, and a **sync page** that
runs in your browser, converts your comics into something a 48 MHz eZ80 can
draw, and pushes them over USB.

- `calc/` — the reader. C for the CE toolchain.
- `calc/updater/` — `EOSUP`, the tiny program that installs a new reader.
- `web/` — the sync page. Plain HTML/CSS/ES modules, no build step, no server.
- `server/` — the chat relay. Flask, deployed separately; see `server/README.md`.
- `tools/` — a desktop converter and the host test harness.
- `docs/FORMAT.md` — the `.csx` strip format and the library index.
- `docs/PROTOCOL.md` — the link protocol.

eOS was called eBookSync. The rename went all the way down: the program is
`EOS.8xp`, the library index appvar is `EOSLIB`, strip chunks are `EO<slot><chunk>`
and the metadata file beside your comics is `eos.json`. An eBookSync library
already on a calculator cannot be read by eOS, so the first run offers to delete
it and reclaim the space; your files on the computer are untouched and syncing
again refills it. On the computer, `ebooksync.json` is read once and its library
identity carried into `eos.json`, so a library that has already been synced is
still recognised as the same one.

## What it does

The calculator lists your comics grouped by book, opens one, and lets you pan
around and zoom in. It remembers where you got to and marks a strip read when
you reach the end.

The sync page reads a folder of comics off your disk — one folder per book —
lets you arrange the library and tick which books and strips you want, converts
them, and sends them. It also carries chat and new builds of the reader itself
over the same cable. It reads back what you have finished, records that in a
metadata file beside your comics, and can clear read strips off the calculator
to make room for more.

The library is editable in the page: drag images in to add them, create, rename
and delete books and strips, and drag rows into the order you want to read them.
That order lives in `eos.json` next to your comics, and it is the order the
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

Send `calc/bin/EOS.8xp` to the calculator with TI Connect CE or
[ticalc.link](https://ticalc.link). This first transfer uses TI's own link
protocol; everything after it goes over eOS's own — including later builds of
the reader itself, so this is the only time you need TI Connect.

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

Run `EOS`, unlock it if you have set a password, press `2nd` on the book list to
reach the Sync screen, plug in the
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

On the book list: `del` marks a whole book read or unread, `mode` opens
settings, `2nd` opens the sync screen, `y=` opens chat. On the strip list, `del` marks one strip.

Settings (`mode` from the book list) has four entries:

- **Password** — set, change or remove the lock. See below.
- **Erase the library** — deletes every comic on the calculator. Your files on
  the computer are untouched, and syncing again refills it.
- **Link echo test** — echoes bytes straight back to the computer, for working
  out why a sync will not start. `docs/PROTOCOL.md` explains what it is for.
  This used to be `alpha` from the book list; that key is chat now.
- **About** — the text of `about.txt`, scrollable with the arrow keys.

`about.txt` lives at the root of the repository and is baked into the program on
every build by `tools/make_about.sh`, since the calculator has no way to read
the repository for itself. Edit the file and rebuild; there is nothing to
regenerate by hand. It is drawn with the built-in font, so it is ASCII only and
lines longer than 40 characters run off the side.

## Chat

eOS carries messages as well as comics. Three places can read the same
conversations:

| | |
|---|---|
| the **relay** | a small Flask service that holds the history — `server/README.md` |
| the **PWA** | served by the relay, installable, what most people will use |
| the **sync page** | the Chat tab, next to your library |
| the **calculator** | `y=` from the book list |

The calculator has no network. Everything reaches it at sync time: messages you
have been sent come down, messages you typed on it go up, and the relay records
when that last happened so other people can see it. Someone messaging you sees
`calc · 14:02` beside your name, which is the difference between "has not
replied" and "has not plugged in since Tuesday".

**Setting it up.** Deploy the relay (`server/README.md`), open its admin panel,
add people and open conversations. Then in the sync page's **Chat** tab, put in
the relay's address and sign in. The sign-in is kept in your browser and
deliberately *not* in `eos.json` — that file sits beside your comics and travels
with the folder.

**Your account is one account.** The calculator is not a separate user; it is a
second terminal for yours. Anything typed on either is from you, and the history
syncs both ways.

**On the calculator**, `y=` opens the conversation list, `enter` opens one,
`2nd` writes a message, and `clear` goes back. What you write is queued and
leaves at the next sync — the screen says so.

Two limits worth knowing:

- **ASCII only.** The calculator has no CJK font — the same reason comic titles
  are pre-rendered bitmaps. The page folds messages down before sending them:
  accents are flattened, everything else becomes `?`.
- **Each conversation keeps about 8 KB on the calculator**, roughly two hundred
  messages, oldest dropped first. Flash is the comics' budget and chat is a
  guest in it. The relay keeps everything.

Nothing about chat is required to read comics, and a relay that is unreachable
never stops a sync — messages taken off the calculator are stored on the
computer first and go up whenever the relay comes back.

## The password

Set one in Settings and eOS asks for it on the way in. Three wrong answers close
the reader.

Typing uses the letters printed on the keys: `alpha` switches between digits and
letters, `2nd` switches case, `del` backspaces. There is no on-screen layout to
learn — the calculator is its own legend.

**Be clear about what this is.** It keeps a curious classmate out of your
comics. It is not security:

- Anyone with the cable and this page can read what is stored anyway.
- Relaunching gives three more tries, so the limit is a speed bump. What the
  calculator does instead is *count* failed attempts and tell you how many there
  have been the next time you unlock it. That is tamper evidence, which is the
  useful thing a calculator can actually offer.
- Deleting the library index gets past the prompt — but the password lives
  *inside* that index, along with the table of contents. Deleting it leaves
  megabytes of chunk appvars with nothing that can say what any of them is, and
  the only way back is the computer that holds your library. That cost is the
  point.

The password is stored as a random salt and SHA-256(salt + password), so it is
not on the calculator in readable form and two calculators with the same
password do not look alike.

## Updating the calculator over the cable

A CE program runs in place inside its own variable, so it cannot overwrite
itself. eOS therefore ships **two** programs that install each other:

| | |
|---|---|
| `EOS` | the reader. Installs `EOSUP`. |
| `EOSUP` | the updater. Installs `EOS`. |

The page keeps the latest of both next to itself, and offers them when the
calculator says it is behind. The updater is applied during the sync and you
never see it. A reader update is sent and *armed*: to install it, quit the
reader, run `prgmEOSUP` once, and run `EOS` again. The reader says so on the way
in, and the page says so when it has finished sending.

Nothing is replaced until you run `prgmEOSUP`, so an interrupted update costs
only the bytes it moved. The image is CRC-32 checked when it arrives and again
before anything is deleted — a damaged one is thrown away rather than installed.

A calculator with no `EOSUP` at all is given one on its first sync, which is why
`EOS.8xp` is the only file you ever have to install by hand.

To cut a build:

```sh
sh tools/stage_update.sh          # bumps calc/BUILD, builds both, copies to web/eos/
```

Commit what it puts in `web/eos/`; that is what the page serves.

## Two libraries, one calculator

Each library folder gets an identifier the first time it is used, stored in
`eos.json`, and the calculator keeps a copy alongside the comics. If you
connect a calculator holding a different library, the page says so and offers to
erase it rather than mixing the two -- the calculator would otherwise end up
with comics the library cannot account for. The calculator's own sync screen
shows the same warning.

## What the ticks mean

Connecting ticks everything already on the calculator. A tick means "I want
this on the calculator", not "send this now" -- so **unticking something is how
you ask for it to be removed** on the next sync.

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
sh tools/stage_update.sh --keep       # the update tests check the real build
NODE=/path/to/node tools/hosttest/run_all.sh
```

That needs a C compiler, Python with Pillow and Flask, and node.

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
