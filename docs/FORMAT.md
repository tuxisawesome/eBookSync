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
chunks, each stored as its own appvar named `CS<slot><chunk>` with both fields in
hex -- `CS0003` is chunk 3 of strip slot 0. 16 KB keeps the create-then-archive
step comfortably inside free RAM.

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
