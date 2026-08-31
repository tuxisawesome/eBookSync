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

That name is what caps a slot at 65535. A slot is kept for the life of a strip,
so it bounds the *library* rather than the calculator: at one byte it stopped a
collection of comics at 256, however few of them were resident at a time.

16 KB keeps the create-then-archive step comfortably inside free RAM.

Bands are bin-packed into chunks with first-fit-decreasing and **never straddle a
chunk boundary**. That is what lets the reader hand `zx0_Decompress` a pointer
straight into flash from `ti_GetDataPtr()` with no staging copy. Packing waste is
under 1% in practice.

Chunk 0 begins with the header, palette, layer table and band table; the packer
reserves that space before placing any band.

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
  13  3   reserved

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

Band payloads
  ZX0 streams, placed by the bin packer.
```

Bands are indexed `base[layer] + col * bands_per_col[layer] + band`, where
`base[layer]` is the sum of `cols * bands_per_col` over the preceding layers.

A decompressed band is `stride * rows` bytes, where `stride = (col_width + 1) / 2`
and `rows` is 32 except in the final band of a column.

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
  6   1   flags           bit 0: read
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
  54  10  reserved
```

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

## The library on disk, and `ebooksync.json`

Books are folders, strips are the JPEGs inside them, and a strip's title is its
filename without the extension:

```
comics/
  ebooksync.json
  第一本书/
    001 - 标题.jpg
    002 - 标题.jpg
  Another Book/
    01.jpg
```

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
      "strips": {
        "001 - 标题.jpg": {
          "id": 17, "order": 0, "selected": true,
          "read": true, "readAt": "2026-08-24T20:11:00Z", "pos": 3120, "layer": 1,
          "srcHash": "…", "srcSize": 1962500,
          "onCalc": true, "chunkCount": 25, "deviceBytes": 401927
        }
      }
    }
  }
}
```

`id` is a stable 0-255 slot, assigned once and never reassigned; it is what
names the `CS<slot><chunk>` appvars. It survives renames and moves between
books, so renaming or reordering costs a fresh index on the next sync rather
than re-sending half a megabyte of chunks.

The calculator is authoritative for `read`, `readAt`, `pos` and `layer` -- that
is where reading happens -- and this file is authoritative for everything else.
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
```

`--verify` decodes the container back through the pure-Python ZX0 decoder and
checks every layer reconstructs, which is the fastest way to catch a codec
regression without a calculator.
