# The `.csx` strip format

A `.csx` container holds one comic strip, preprocessed on the computer so the
calculator only has to unpack it. Everything is little-endian, matching the eZ80.

The reference encoder is `tools/csx/` (Python); the production encoder is
`web/js/convert.js` (browser). `calc/src/render.c` is the only decoder that
matters. Sizes quoted below are measured on `assets/strip1.jpg`, an 800x8243
webtoon episode.

## Why it looks like this

The calculator has a 320x240 8bpp screen, ~3 MB of flash archive, ~50 KB of free
RAM and a 48 MHz eZ80. That rules out decoding JPEG on-device and rules out
holding a whole strip in memory, so the format is built for **partial, random
access**: the reader decompresses only the few kilobytes covering the current
viewport.

Three decisions came out of measurement rather than taste:

**Bands, not tiles.** The unit of random access is a full-width horizontal band.
Compressing 64x64 tiles independently costs ~7% over compressing the image as a
whole; 320-wide bands cost 1-2%. Vertical scrolling dominates in a webtoon, so
bands also line up with how the image is actually read.

**16 colours at 4bpp.** 32 or 64 colours force 8bpp storage and cost +40% / +73%
for about 1 dB of PSNR. Nibble-packed 4bpp also unpacks cheaply on an eZ80.

**Edge-preserving despeckle.** JPEG ringing around line art destroys
compressibility. A plain 3x3 median removes it and shrinks output by 20%, but it
also wipes out the one-pixel strokes Chinese text is made of, rendering the strip
illegible. Instead the median is applied *only where it barely changes the
pixel*: flat areas get cleaned, edges and glyphs keep their original pixels. That
recovers 13% at no visible cost. See `image.despeckle`.

## Layers

A strip is rendered at several widths ("layers"), each a complete copy of the
strip at that zoom. The first is always 320px, the fit-width reading view.

| preset     | layers  | packed  | strips in 3 MB |
|------------|---------|---------|----------------|
| `fit`      | 320     | 137 KB  | 22 |
| `fit+1.5x` | 320+480 | 393 KB  | 7  |
| `fit+2x`   | 320+640 | 548 KB  | 5  |

All layers share one 16-entry palette, computed from the fit-width layer, so
zooming never shifts the colours. Palette *selection* is an encoder choice, not
part of the format -- the palette is stored explicitly, so the Python and JS
encoders are free to choose colours differently.

A layer wider than 320 is split into 320-pixel **columns** (480 becomes 320+160)
so a horizontal pan never decompresses pixels far outside the viewport. Each
column is cut into **bands** of 32 rows. The last column and last band are
short.

Band height trades three things off: 64-row bands compress ~2.7% smaller, but
double the RAM per cache slot and make scrolling lumpier (a 10 KB decompress
every 64 px instead of 5 KB every 32 px). 32 won.

## Compression

Each band is packed to 4bpp -- two pixels per byte, high nibble first, each row
padded to a whole byte -- and compressed independently with **ZX0** in its
default (non-"classic") forward mode, which is what the CE toolchain's
`zx0_Decompress` expects.

ZX0's optimal parse is O(size x offset_limit). Bands are ~5 KB where useful
matches sit within a few scanlines, so the match window is capped. Measured over
the 104 bands of the fit-width layer:

| offset limit | 256 | 512 | 1024 | 2048 | 5120 | 32640 |
|---|---|---|---|---|---|---|
| size | 129.1K | 126.5K | 124.9K | 123.8K | 123.4K | 123.4K |
| time | 1.7s | 3.0s | 5.4s | 9.5s | 15.7s | 15.7s |

The default of **1024** costs 1.2% over an unbounded window and runs three times
faster, which matters most in the browser. (For reference, ZX0 at 123.4K beats
zlib -9 at 124.4K on the same data.)

## Chunking

A TI variable's length field is 16 bit, and a variable is created in RAM before
being archived, so a strip cannot live in one appvar. It is split into 16 KB
chunks, each stored as its own appvar named `CS<slot><chunk>` -- the slot in
four hex digits and the chunk in two, which is the whole eight characters an
appvar name has -- so `CS000003` is chunk 3 of strip slot 0.

That name is what caps a slot at 65535. A slot belongs to the calculator, not
the library: a strip is given one when it is sent and gives it back when it is
removed, so the slot range bounds only what is resident at once, and the library
has no limit at all. (Slots used to be assigned when a strip joined the library
and kept for good, which capped a library at 256 strips, then at 65535.)

What actually bounds the calculator is the index. `INDEX_PUT` takes at most
16 392 bytes, and every resident strip costs a 17-byte row plus its compressed
title -- a few hundred strips in practice, and never more than 958 even with
empty titles. `LIST` has room for 1092. The page plans against both and leaves
anything past them on the computer.

16 KB keeps the create-then-archive step comfortably inside free RAM.

**A strip may have at most 64 chunks**, which is `CSX_MAX_CHUNKS` in
`calc/src/csx.h` and 1024 KB of container. `csx_open()` refuses anything
claiming more, so a bigger strip is not a slow strip or a clipped one -- it is a
strip that will not open at all. Nothing used to enforce this: the encoders grew
the chunk list without a cap and wrote the count into a single header byte, and
the calculator reported the ceiling in `HELLO` where the page parsed it and
never looked at it again. The result was strips that synced, listed, and drew in
the menu with their titles and sizes, and failed only when somebody picked one.
The page now refuses them, and says which detail level would fit.

At `fit+1.5x` that ceiling is around a 21,500-pixel-tall episode; at `fit+2x`,
around 15,400. It is a real limit rather than an arbitrary one: 1 MB is a third
of the whole archive, so a strip that large is not a thing the calculator can
usefully hold several of.

Bands are bin-packed into chunks with first-fit-decreasing and **never straddle a
chunk boundary**. That is what lets the reader hand `zx0_Decompress` a pointer
straight into flash from `ti_GetDataPtr()` with no staging copy. Packing waste is
under 1% in practice.

Chunk 0 begins with the header, palette, layer table and band table -- and the
part table, for a strip made from several images; the packer reserves that
space before placing any band.

## Byte layout

Concatenating every chunk in order gives the logical container:

```
Header (16 bytes)
  0   4   magic       "CSX1"
  4   1   layer_count
  5   1   band_height     rows per band (32)
  6   2   col_width       pixels per column (320)
  8   2   palette_size    entries (16)
  10  2   band_count      total bands across all layers
  12  1   chunk_count
  13  1   part_count      images stitched into this strip; 0 or 1 means one
  14  2   reserved

Palette (palette_size x 2 bytes)
  RGB1555, packed as gfx_RGBTo1555 does: 0RRRRRGGGGGBBBBB

Layer table (layer_count x 12 bytes)
  0   2   width
  2   3   height          u24
  5   1   reserved
  6   2   cols            ceil(width / col_width)
  8   2   bands_per_col   ceil(height / band_height)
  10  1   reserved

Band table (band_count x 5 bytes)
  0   1   chunk           which appvar holds this band
  1   2   offset          byte offset within that chunk
  3   2   length          compressed length

Part table (part_count x layer_count x 3 bytes, only when part_count > 1)
  u24 per part per layer: the row that part starts on in that layer

Band payloads
  ZX0 streams, placed by the bin packer.
```

Bands are indexed `base[layer] + col * bands_per_col[layer] + band`, where
`base[layer]` is the sum of `cols * bands_per_col` over the preceding layers.

A decompressed band is `stride * rows` bytes, where `stride = (col_width + 1) / 2`
and `rows` is 32 except in the final band of a column.

### Strips made of several images

A folder inside a book is one strip, made of the images directly inside it in
natural order -- 0-9, then A-Z, case-blind, and 10 after 9. It is **stitched
into one container**: each image is scaled to the layer width on its own, so
images of different shapes line up at the edges and simply differ in height,
and the results are stacked. Bands, columns, chunking, the 1 MB ceiling and the
saved scroll position all work exactly as for a single image.

What the stitching would lose is where one image ends, and the part table keeps
it: the row each image starts on, in every layer. The reader confines the view
to one image at a time and draws nothing below its end -- a short image leaves
the rest of the screen empty rather than showing the next one underneath -- and
at the bottom a bar says what comes next. A fresh press of down goes there; a
held one stops, so holding the key to scroll cannot carry through into the next
image unseen.

The table sits after the band table, so the band table's offset does not move,
and it is absent when `part_count` is 0 or 1. Every container from before parts
existed is therefore a valid single-image container, and a reader from before
them shows a multi-image strip as one continuous strip rather than failing.
`csx_open()` refuses a table whose first top is not 0, whose tops do not
increase, or that runs past its layer.

## `CSLIB`: the library index

One appvar describing only what is actually resident on the calculator -- the
computer stays the source of truth for the whole library. It carries the
book/strip tree, per-strip read state and saved scroll position, and the
pre-rendered title bitmaps.

```
Header (92 bytes)
  0   5   magic       "CSLIB"
  5   1   version     3
  6   2   bookCount
  8   2   stripCount
  10  2   reserved
  12  16  libraryId       which library folder these comics came from
  28  64  device block    the calculator's, not the computer's -- see below

Book table (bookCount x 6 bytes)
  0   2   titleOffset     byte offset of the title record, from the start
  2   2   stripFirst      index into the strip table
  4   2   stripCount

Strip table (stripCount x 17 bytes)
  0   2   slot            names the CS<slot><chunk> appvars
  2   1   chunkCount
  3   3   bytes
  6   1   flags           bit 0: read, bit 1: bookmarked
  7   4   readAt          unix seconds, 0 if never
  11  3   pos             saved scroll position, in the saved layer's rows
  14  1   layer           saved zoom layer
  15  2   titleOffset

Title records (variable, referenced by offset)
  0   2   width
  2   1   height          always 16
  3   2   compressed length
  5   ..  ZX0 stream of the 2bpp rows, stride = (width + 3) / 4
```

### The device block

The last 64 bytes of the header belong to the calculator. The computer writes
zeros there and never reads anything back: `INDEX_PUT` splices the calculator's
live block over the incoming bytes before storing them, and `INDEX_GET` zeroes
it again in the reply.

```
  0   1   pwFlags         0 = no password set
  1   16  pwSalt
  17  32  pwHash          SHA-256(salt || password)
  49  1   pwFailures      consecutive wrong answers, kept across power cycles
  50  4   clockOffset     added to time() to get unix seconds
  54  1   wallFlags       0 = no lock screen wallpaper
  55  4   wallCrc         CRC-32 of the wallpaper container, chunk by chunk
  59  2   lastSlot        the strip last read, as slot + 1; 0 for none
  61  1   theme           0 = Dark, 1 = Light
  62  2   reserved
```

`lastSlot` is what the book list's Continue row opens. It is written in the same
index rewrite that saves the strip's position on the way out of the viewer, so
it costs no extra flash write, and it is kept by slot plus one so that the zeros
of an index that has never recorded one mean "nothing read yet" rather than
slot 0. A slot the index no longer lists simply has no Continue row.

`theme` is the Settings choice of colours. Zero is Dark, which is also what an
index that has never recorded one holds, so the default needs no write.

`wallCrc` is why the wallpaper is in here rather than standing on its own. The
image itself is an ordinary `.csx` container in slot `0xFFFF` -- a 320x240
picture is a very short strip -- so `CSFFFF00` would happily outlive `CSLIB`,
and the one way past the password is to delete `CSLIB`. A calculator whose table
of contents had been thrown away would still come up wearing its owner's
wallpaper. The claim lives here instead: no index, no claim, so the reader will
not draw it and deletes the appvars on the next run. It is a checksum rather
than a flag so that a wallpaper damaged in flash is noticed rather than smeared
across the lock screen.

Masking it on the way out does two jobs at once. It keeps the salt and hash off
the wire, where a computer that is not this library's could otherwise ask for
them. And it is what lets the page compare the index it holds against the one it
would build -- both have zeros there -- instead of finding the index stale on
every single sync.

The password is a random 16-byte salt and SHA-256(salt || password), so the
password itself is not stored and the same password on two calculators does not
produce the same bytes. `pwFailures` counts wrong answers since the last
successful unlock and is shown to whoever does get in -- it cannot rate-limit
anything, since pulling the batteries would defeat that and a permanent lockout
would cost the owner the library, so it is tamper evidence instead.

It lives in here, rather than in an appvar of its own, so that deleting it to
get past the password also destroys the table of contents: book grouping, the
title bitmaps, the slot-to-strip mapping, read state and chunk counts. What is
left is megabytes of `CS**` appvars with no way to tell what any of them is.
That is the whole of the deterrent -- not secrecy, but a bypass that costs the
library until you are back at the computer that can rebuild it. `lib_reset()`
empties the index rather than deleting it for the same reason: erasing the
library must not quietly clear the password with it.

**Both tables are in display order**, and the reader draws them in the order it
finds them. That is the entire mechanism by which the order arranged in the sync
page is the order you get on the calculator; nothing on the calculator sorts
anything.

Titles are rendered on the computer, **not** stored as text -- the calculator
has no CJK font and does no text shaping. Each is a 2bpp anti-aliased bitmap
16 px tall, already ellipsised by the renderer to the list column width (300 px
for books, 272 px for strips, leaving room for the read marker and size). The
four grey levels map to reserved graphx palette indices 240-243 on a normal row
and 244-247 on a selected one, leaving 0-15 for the artwork; level 0 is skipped
when drawing so the row colour shows through.

The bitmaps are ZX0-compressed. Uncompressed, a worst-case title is
300 x 16 x 2 / 8 = 1 200 bytes and a library's worth would not fit in one
appvar; compressed they come to a couple of kilobytes, and the reader expands
only the row it is currently drawing, into a single scratch buffer.

## The wallpaper

The lock screen wallpaper is not a format. It is a `.csx` container like any
other, holding one 320x240 layer -- eight bands, one column, usually a chunk or
two -- stored in slot **0xFFFF** and sent through `PUT_CHUNK` like a comic.
Strip slots are handed out upwards from 0 and stop at 0xFFFE, so the two can
never meet.

That is the whole design, and it is worth being explicit about what it buys:
no wallpaper format, no wallpaper decoder, no wallpaper transfer command, and
the per-chunk checksum and the `VERIFY` that follows it come along for free.
`web/js/worker/convert.js` crops the source to fill the screen and hands it to
the same encoder everything else goes through; `calc/src/render.c` draws it with
the same band loop, through one borrowed 5 KB buffer rather than the band cache,
because the lock screen has to be able to draw before `render_init()` has taken
its sixty kilobytes.

The claim that ties it to the index is in the device block, above.

## The library on disk, and `ebooksync.json`

Books are folders. Inside a book, a strip is either one image -- JPEG, PNG,
WebP, GIF (its first frame), BMP or AVIF -- or a folder of images, which is one
strip read image by image in natural order: 0-9, then A-Z, case-blind, and 10
after 9. A strip's title is its filename without the extension, or the folder's
name:

```
comics/
  ebooksync.json
  第一本书/
    001 - 标题.jpg
    002 - 标题.png
    第3话/            <- one strip, three images
      1.jpg
      2.jpg
      A.webp
  Another Book/
    01.jpg
```

Nothing is ever merged or rewritten on disk. A folder strip stays a folder of
the images it arrived as; they are stitched together only in memory, while
converting, and the container exists only on the calculator and in the
browser's conversion cache (IndexedDB) -- never in the library folder. A folder
with no images in it is not a strip, and folders inside a folder strip are not
looked into.

**Display order is metadata, not filenames.** `ebooksync.json` carries an
explicit `order` on every book and every strip, and that is what the sync page
shows and what is written into CSLIB. Nothing infers an order from names at sync
time.

A file discovered on disk for the first time is appended to the end of its book
rather than slotted in where its name happens to sort -- dropping episode 15
into a library should put it after 14, not in the middle. A library with no
metadata yet takes its initial order from a natural sort, which is what it would
have had anyway.

```jsonc
{
  "version": 4,
  "libraryId": "8f3c…",
  "lastSync": "2026-08-25T17:40:00Z",
  "settings": { "detail": "fit+1.5x", "colors": 16, "dither": false,
                "selection": "manual", "autoDelete": true, "keepRead": 2,
                "maxDeviceBytes": 2900000 },
  "books": {
    "第一本书": {
      "order": 0,
      "detail": null,
      "strips": {
        "001 - 标题.jpg": {
          "id": 17, "order": 0, "selected": true,
          "read": true, "readAt": "2026-08-24T20:11:00Z", "pos": 3120, "layer": 1,
          "bookmarked": false,
          "srcHash": "…", "srcSize": 1962500, "srcStamp": "1962500:1756000000000",
          "onCalc": true, "chunkCount": 25, "deviceBytes": 401927
        }
      }
    }
  }
}
```

A book's `detail` is its own detail level, or `null` to use the library's.
Like the library setting it decides how strips are converted when they are
sent; a strip already on the calculator stays as it was sent until it is sent
again.

`srcHash` is what the conversion cache is keyed on: the image's contents, or for
a folder strip its images' names and contents in order. `srcStamp` is the sizes
and modification times of the files it was taken from, and a scan that finds a
different stamp drops the hash -- so replacing an image, or adding one to a
folder strip, is converted afresh rather than served a cached copy of what used
to be there.

`id` is the slot the strip occupies on the calculator, from 0 to 65534, or `null`
when it is not there. It is what names the `CS<slot><chunk>` appvars: it is taken
(lowest free first) when the strip is sent and cleared when the strip is removed
or a connection finds it gone, so a slot may be reused by a different strip
later. 65535 is not handed out: it belongs to the lock screen wallpaper.

`wallpaper` is `{ "srcHash": "...", "sentAt": "..." }` once one has been sent, or
absent. The hash is of `wallpaper.jpg` at the root of the library folder, and a
hash that no longer matches the file is what makes the next sync send it again.
The file lives at the root rather than in a book because the scanner only looks
inside directories, so nothing there can be mistaken for a comic. It survives renames and moves between
books, so renaming or reordering costs a fresh index on the next sync rather
than re-sending half a megabyte of chunks.

The calculator is authoritative for `read`, `readAt`, `pos`, `layer` and
`bookmarked` -- that is where reading happens -- and this file is authoritative
for everything else. A bookmark is set and cleared only on the calculator; the
page reads it back on every connection and writes it into every index it sends,
and clearing read strips to make room never takes a bookmarked one.
`onCalc` is rebuilt from what the calculator reports rather than from what the
page believes, so an interrupted sync corrects itself.

Version 1 of this file had no `order` fields. Anything missing one picks its
order up from the natural sort on the next scan, which is exactly the order a
version 1 library was displayed in.

Version 4 exists because this file has been renamed and renamed back. If
`ebooksync.json` is not there, `eos.json` is read instead and the `libraryId`
carried across, so a library that has already been synced is still recognised as
the same one. The old file is left on disk rather than deleted.

## Tools

```sh
tools/build.sh                                   # build the ZX0 shared library (needs cc)
tools/convert.py assets/strip1.jpg --measure     # size at every preset
tools/convert.py assets/strip1.jpg -o out/ --slot 0 --verify
tools/convert.py assets/strip1.jpg --preview /tmp/p.png   # see what the calculator shows
tools/convert.py comics/第一本书/第3话 --measure          # a folder strip works the same way
```

`--verify` decodes the container back through the pure-Python ZX0 decoder and
checks every layer reconstructs, which is the fastest way to catch a codec
regression without a calculator.
