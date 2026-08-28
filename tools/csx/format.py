"""The .csx container: layout constants, writer and reader.

See docs/FORMAT.md for the byte-level specification. Everything is
little-endian, matching the eZ80.
"""

import struct

MAGIC = b"CSX1"

# Rows per band. Bands are the unit of random access: the reader decompresses a
# whole band to draw any part of it, so smaller bands mean less wasted work when
# scrolling but a bigger band table and slightly worse compression.
BAND_HEIGHT = 32

# Pixels per column. A layer wider than this is split into several columns so
# that a horizontal pan never forces the reader to decompress pixels far outside
# the 320px viewport.
COL_WIDTH = 320

# Payload bytes per appvar chunk. Chunks are created in RAM before being
# archived, so this has to stay comfortably inside the calculator's free RAM.
CHUNK_SIZE = 16384

HEADER_FMT = "<4sBBHHHBBBB"          # 16 bytes
HEADER_SIZE = struct.calcsize(HEADER_FMT)
LAYER_FMT = "<HHBBHHH"               # 12 bytes: width, height(u24), pad, cols, bands, pad
LAYER_SIZE = struct.calcsize(LAYER_FMT)
BAND_FMT = "<BHH"                    # 5 bytes
BAND_SIZE = struct.calcsize(BAND_FMT)

assert HEADER_SIZE == 16 and LAYER_SIZE == 12 and BAND_SIZE == 5


class Layer:
    """One zoom level: a full-resolution rendering of the strip at `width`."""

    __slots__ = ("width", "height", "cols", "bands_per_col")

    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.cols = (width + COL_WIDTH - 1) // COL_WIDTH
        self.bands_per_col = (height + BAND_HEIGHT - 1) // BAND_HEIGHT

    @property
    def band_count(self):
        return self.cols * self.bands_per_col

    def col_width(self, col):
        return min(COL_WIDTH, self.width - col * COL_WIDTH)

    def band_rows(self, band):
        return min(BAND_HEIGHT, self.height - band * BAND_HEIGHT)

    def stride(self, col):
        """Packed 4bpp bytes per row for a column."""
        return (self.col_width(col) + 1) // 2


def rgb_to_1555(r, g, b):
    """Pack a colour the way graphx's gfx_RGBTo1555 does."""
    return ((r >> 3) << 10) | ((g >> 3) << 5) | (b >> 3)


def pack_chunks(layers, palette, bands):
    """Lay a strip out into fixed-size chunks.

    `bands` is a flat list of compressed band payloads in band-index order
    (layer, then column, then band). Bands are bin-packed with first-fit
    decreasing so that no band straddles a chunk boundary -- that is what lets
    the calculator decompress straight from a flash pointer with no staging
    copy. Chunk 0 starts with the header, palette, layer table and band table.

    Returns (chunks, band_entries) where chunks is a list of bytearrays and
    band_entries is a list of (chunk, offset, length).
    """
    table_size = (HEADER_SIZE + len(palette) * 2
                  + len(layers) * LAYER_SIZE + len(bands) * BAND_SIZE)
    if table_size > CHUNK_SIZE:
        raise ValueError(
            f"band table needs {table_size} bytes but a chunk holds {CHUNK_SIZE}; "
            "use a taller BAND_HEIGHT or a larger CHUNK_SIZE"
        )

    # free[i] = bytes still available in chunk i. Chunk 0 is pre-charged with
    # the header so the packer never places a band on top of it.
    free = [CHUNK_SIZE - table_size]
    fill = [table_size]
    entries = [None] * len(bands)

    for idx in sorted(range(len(bands)), key=lambda i: -len(bands[i])):
        payload = bands[idx]
        size = len(payload)
        if size > CHUNK_SIZE:
            raise ValueError(f"band {idx} is {size} bytes, larger than a chunk")
        for chunk in range(len(free)):
            if free[chunk] >= size:
                break
        else:
            free.append(CHUNK_SIZE)
            fill.append(0)
            chunk = len(free) - 1
        entries[idx] = (chunk, fill[chunk], size)
        fill[chunk] += size
        free[chunk] -= size

    chunks = [bytearray(n) for n in fill]
    for payload, (chunk, offset, size) in zip(bands, entries):
        chunks[chunk][offset:offset + size] = payload

    header = struct.pack(
        HEADER_FMT, MAGIC, len(layers), BAND_HEIGHT, COL_WIDTH,
        len(palette), len(bands), len(chunks), 0, 0, 0,
    )
    table = bytearray(header)
    for colour in palette:
        table += struct.pack("<H", colour)
    for layer in layers:
        table += struct.pack(
            LAYER_FMT, layer.width, layer.height & 0xFFFF, layer.height >> 16,
            0, layer.cols, layer.bands_per_col, 0,
        )
    for chunk, offset, size in entries:
        table += struct.pack(BAND_FMT, chunk, offset, size)
    assert len(table) == table_size, (len(table), table_size)
    chunks[0][0:table_size] = table

    return chunks, entries


class Strip:
    """A parsed .csx container, for verification and round-tripping."""

    def __init__(self, chunks):
        self.chunks = chunks
        blob = chunks[0]
        (magic, layer_count, band_height, col_width,
         palette_size, band_count, chunk_count, _, _, _) = struct.unpack_from(HEADER_FMT, blob, 0)
        if magic != MAGIC:
            raise ValueError(f"not a .csx container (magic {magic!r})")
        self.band_height = band_height
        self.col_width = col_width
        pos = HEADER_SIZE
        self.palette = list(struct.unpack_from(f"<{palette_size}H", blob, pos))
        pos += palette_size * 2
        self.layers = []
        for _ in range(layer_count):
            width, h_lo, h_hi, _, cols, bands_per_col, _ = struct.unpack_from(LAYER_FMT, blob, pos)
            pos += LAYER_SIZE
            layer = Layer(width, h_lo | (h_hi << 16))
            assert layer.cols == cols and layer.bands_per_col == bands_per_col
            self.layers.append(layer)
        self.bands = [struct.unpack_from(BAND_FMT, blob, pos + i * BAND_SIZE)
                      for i in range(band_count)]

    def band_index(self, layer_index, col, band):
        base = sum(l.band_count for l in self.layers[:layer_index])
        return base + col * self.layers[layer_index].bands_per_col + band

    def band_payload(self, index):
        chunk, offset, size = self.bands[index]
        return bytes(self.chunks[chunk][offset:offset + size])


def chunk_name(slot, chunk):
    """Appvar name for one chunk of a strip: EO<slot><chunk>, both hex."""
    if not 0 <= slot <= 0xFF:
        raise ValueError(f"strip slot {slot} out of range 0-255")
    if not 0 <= chunk <= 0xFF:
        raise ValueError(f"chunk index {chunk} out of range 0-255")
    return f"EO{slot:02X}{chunk:02X}"
