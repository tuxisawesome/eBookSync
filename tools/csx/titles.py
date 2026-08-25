"""Pre-rendering book and strip titles into 2bpp bitmaps.

The calculator has no CJK font and no text shaping, and titles come from folder
and file names that will usually be Chinese. Rather than ship a font and a
layout engine to an eZ80, the computer -- which already has both -- renders each
title once and sends pixels.

Two bits per pixel, not one: at 14px a Chinese glyph is a dense little tangle of
strokes, and four grey levels are the difference between legible and a smudge.
The levels are drawn through a four-entry palette ramp on the calculator, so the
same bitmap works on a normal and a selected row.

The browser does this with a canvas; this module exists so the desktop tools can
build a complete library without one.
"""

import struct

from PIL import Image, ImageDraw, ImageFont

# Row height in the reader's lists. The bitmap is this tall regardless of the
# glyphs in it, so rows line up. 16 gives 15 rows per screen and leaves room for
# descenders that a 14px box would clip.
TITLE_HEIGHT = 16
FONT_SIZE = 13

# Widths the reader lays out for: a book row uses the full list width, a strip
# row leaves space for the read tick and size.
BOOK_WIDTH = 300
STRIP_WIDTH = 272

ELLIPSIS = "\u2026"

# A stack, not a single font: the usual Linux CJK font (DroidSansFallback) has
# no Latin glyphs at all, so "001 - 标题" would come out as four tofu boxes
# followed by readable Chinese. Each character is rendered with the first font in
# the stack whose cmap actually covers it. The browser gets this behaviour for
# free from the CSS font stack; here we have to do it by hand.
FONT_CANDIDATES = (
    # Latin/digits first, so mixed titles keep proportional Latin.
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
    "C:/Windows/Fonts/arial.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    # then CJK coverage
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
    "/usr/share/fonts/truetype/droid/DroidSansFallbackFull.ttf",
    "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc",
    "/System/Library/Fonts/PingFang.ttc",
    "C:/Windows/Fonts/msyh.ttc",
    "C:/Windows/Fonts/simhei.ttf",
)


def _font_coverage(path):
    """Return the set of code points a TrueType/OpenType file maps.

    Pillow will not fall back per glyph and there is no cmap accessor on
    ImageFont, so we read the cmap table directly. Formats 4 and 12 cover
    every font we care about; a TrueType Collection (.ttc) is read through its
    first face, which is enough to answer "does this file have Chinese".
    """
    with open(path, "rb") as handle:
        data = handle.read()

    offset = 0
    if data[:4] == b"ttcf":
        (offset,) = struct.unpack_from(">I", data, 12)

    (num_tables,) = struct.unpack_from(">H", data, offset + 4)
    cmap_offset = None
    for i in range(num_tables):
        entry = offset + 12 + i * 16
        if data[entry:entry + 4] == b"cmap":
            (cmap_offset,) = struct.unpack_from(">I", data, entry + 8)
            break
    if cmap_offset is None:
        return set()

    (num_records,) = struct.unpack_from(">H", data, cmap_offset + 2)
    best = None
    for i in range(num_records):
        platform, encoding, sub = struct.unpack_from(">HHI", data, cmap_offset + 4 + i * 8)
        # Prefer a full-repertoire Unicode subtable, then a BMP one.
        rank = {(3, 10): 0, (0, 4): 0, (0, 6): 0, (3, 1): 1, (0, 3): 1, (0, 2): 2}.get(
            (platform, encoding), 3
        )
        if best is None or rank < best[0]:
            best = (rank, cmap_offset + sub)
    if best is None:
        return set()

    table = best[1]
    (fmt,) = struct.unpack_from(">H", data, table)
    covered = set()
    if fmt == 4:
        (seg_x2,) = struct.unpack_from(">H", data, table + 6)
        segs = seg_x2 // 2
        ends = struct.unpack_from(f">{segs}H", data, table + 14)
        starts = struct.unpack_from(f">{segs}H", data, table + 16 + seg_x2)
        deltas = struct.unpack_from(f">{segs}h", data, table + 16 + seg_x2 * 2)
        range_base = table + 16 + seg_x2 * 3
        range_offsets = struct.unpack_from(f">{segs}H", data, range_base)
        for i in range(segs):
            if starts[i] == 0xFFFF:
                continue
            for code in range(starts[i], min(ends[i], 0xFFFE) + 1):
                if range_offsets[i] == 0:
                    glyph = (code + deltas[i]) & 0xFFFF
                else:
                    index = range_base + i * 2 + range_offsets[i] + (code - starts[i]) * 2
                    if index + 2 > len(data):
                        continue
                    (glyph,) = struct.unpack_from(">H", data, index)
                    if glyph:
                        glyph = (glyph + deltas[i]) & 0xFFFF
                if glyph:
                    covered.add(code)
    elif fmt == 12:
        (num_groups,) = struct.unpack_from(">I", data, table + 12)
        for i in range(num_groups):
            start, end, _ = struct.unpack_from(">III", data, table + 16 + i * 12)
            if end - start > 0x20000:      # guard against absurd groups
                end = start + 0x20000
            covered.update(range(start, end + 1))
    return covered


class TitleRenderer:
    """Renders titles through a font stack with per-character fallback."""

    def __init__(self, height=TITLE_HEIGHT, size=FONT_SIZE, fonts=None):
        self.height = height
        self.size = size
        self.fonts = []
        for path in (fonts or FONT_CANDIDATES):
            try:
                font = ImageFont.truetype(path, size)
            except (OSError, ValueError):
                continue
            try:
                coverage = _font_coverage(path)
            except (OSError, ValueError, struct.error, IndexError):
                coverage = None      # unreadable cmap: treat as "covers anything"
            self.fonts.append((font, coverage))
        if not self.fonts:
            raise RuntimeError(
                "no usable font found; pass fonts= or install one of: "
                + ", ".join(FONT_CANDIDATES)
            )
        # Centre the glyphs vertically once, using the first font's metrics.
        ascent, descent = self.fonts[0][0].getmetrics()
        self.baseline = max(0, (height - (ascent + descent)) // 2)

    def font_for(self, char):
        for font, coverage in self.fonts:
            if coverage is None or ord(char) in coverage:
                return font
        return self.fonts[0][0]

    def runs(self, text):
        """Split text into (font, substring) runs of a single font."""
        out = []
        for char in text:
            font = self.font_for(char)
            if out and out[-1][0] is font:
                out[-1][1].append(char)
            else:
                out.append((font, [char]))
        return [(font, "".join(chars)) for font, chars in out]

    def measure(self, text):
        return int(round(sum(font.getlength(run) for font, run in self.runs(text))))

    def fit(self, text, max_width):
        """Trim `text` with an ellipsis until it fits `max_width` pixels."""
        if self.measure(text) <= max_width:
            return text
        low, high = 0, len(text)
        while low < high:
            mid = (low + high + 1) // 2
            if self.measure(text[:mid] + ELLIPSIS) <= max_width:
                low = mid
            else:
                high = mid - 1
        return text[:low] + ELLIPSIS if low else ELLIPSIS

    def render(self, text, max_width):
        """Render to (width, height, packed 2bpp rows).

        Level 0 is background, 3 is full-strength text; the calculator maps
        those onto a palette ramp.
        """
        text = self.fit(text, max_width)
        width = min(max(self.measure(text), 1), max_width)

        canvas = Image.new("L", (width, self.height), 0)
        draw = ImageDraw.Draw(canvas)
        pen = 0.0
        for font, run in self.runs(text):
            draw.text((pen, self.baseline), run, fill=255, font=font)
            pen += font.getlength(run)

        stride = (width + 3) // 4
        packed = bytearray(stride * self.height)
        pixels = canvas.load()
        for y in range(self.height):
            base = y * stride
            for x in range(width):
                level = pixels[x, y] >> 6           # 0..3
                if level:
                    packed[base + (x >> 2)] |= level << (6 - 2 * (x & 3))
        return width, self.height, bytes(packed)


def unpack(width, height, packed):
    """Inverse of render's packing, for verification and previews."""
    stride = (width + 3) // 4
    out = bytearray(width * height)
    for y in range(height):
        base = y * stride
        for x in range(width):
            out[y * width + x] = (packed[base + (x >> 2)] >> (6 - 2 * (x & 3))) & 3
    return bytes(out)
