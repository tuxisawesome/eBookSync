"""End-to-end strip conversion: JPEG in, .csx chunks out."""

import os
from concurrent.futures import ProcessPoolExecutor

from . import format as fmt, image, zx0


class Converted:
    """The result of converting one strip."""

    def __init__(self, chunks, layers, palette, raw_bytes):
        self.chunks = chunks
        self.layers = layers
        self.palette = palette
        self.raw_bytes = raw_bytes

    @property
    def total_bytes(self):
        return sum(len(c) for c in self.chunks)

    @property
    def ratio(self):
        return self.raw_bytes / self.total_bytes


def _compress(args):
    payload, offset_limit = args
    return zx0.compress(payload, offset_limit=offset_limit)


def convert(path, preset=image.DEFAULT_PRESET, colors=16,
            denoise=image.DEFAULT_DESPECKLE,
            dither=False, offset_limit=zx0.DEFAULT_OFFSET_LIMIT, jobs=None,
            progress=None):
    """Convert a comic JPEG into the chunk list the calculator stores."""
    widths = image.LAYER_PRESETS[preset]
    img = image.load(path)
    palette, indexed = image.build_layers(
        img, widths, colors=colors, denoise=denoise, dither=dither
    )

    layers = [fmt.Layer(i.width, i.height) for i in indexed]
    raw = []
    for indexed_layer, layer in zip(indexed, layers):
        for col in range(layer.cols):
            for band in range(layer.bands_per_col):
                raw.append(image.pack_band(indexed_layer, layer, col, band))
        if progress:
            progress("pack", layer.width)

    jobs = jobs if jobs is not None else min(8, os.cpu_count() or 1)
    work = [(payload, offset_limit) for payload in raw]
    if jobs > 1 and len(work) > 1:
        with ProcessPoolExecutor(max_workers=jobs) as pool:
            compressed = list(pool.map(_compress, work, chunksize=8))
    else:
        compressed = [_compress(w) for w in work]
    if progress:
        progress("compress", sum(map(len, compressed)))

    chunks, _ = fmt.pack_chunks(layers, palette, compressed)
    return Converted(chunks, layers, palette, sum(map(len, raw)))


def decode(chunks):
    """Rebuild every layer as a PIL image. Used to eyeball what the calculator
    will actually show, and to prove the container round-trips."""
    from PIL import Image

    strip = fmt.Strip(chunks)
    palette = []
    for colour in strip.palette:
        palette += [((colour >> 10) & 31) << 3, ((colour >> 5) & 31) << 3, (colour & 31) << 3]
    palette += [0] * (768 - len(palette))

    out = []
    for li, layer in enumerate(strip.layers):
        canvas = Image.new("P", (layer.width, layer.height))
        canvas.putpalette(palette)
        for col in range(layer.cols):
            width = layer.col_width(col)
            for band in range(layer.bands_per_col):
                rows = layer.band_rows(band)
                data = zx0.decompress(strip.band_payload(strip.band_index(li, col, band)))
                pixels = image.unpack_band(data, layer, col, band)
                tile = Image.frombytes("P", (width, rows), pixels)
                canvas.paste(tile, (col * fmt.COL_WIDTH, band * fmt.BAND_HEIGHT))
        out.append(canvas)
    return out
