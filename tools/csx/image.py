"""Turning a comic JPEG into packed 4bpp bands.

The pipeline, in order:

  resize -> median denoise -> palette quantise -> 4bpp pack -> band slicing

The despeckle step is not cosmetic: JPEG ringing around line art turns flat
regions into noise that compresses terribly. But it has to be edge-preserving.
A plain 3x3 median is 20% smaller still and completely illegible -- it wipes out
the one-pixel strokes that Chinese text is made of. So we take the median only
where it barely changes the pixel, which removes ringing from flat areas and
leaves every edge, and therefore every glyph, untouched.

The palette is computed once from the fit-width layer and reused for every other
layer, so a strip carries a single 16-entry palette and zooming never changes
the colours. Palette *selection* is an encoder choice, not part of the format --
the container stores the palette explicitly, so web/js may pick colours
differently without breaking anything.
"""

from PIL import Image, ImageChops, ImageFilter

from . import format as fmt

# Named zoom ladders offered by the sync UI. Values are layer widths in pixels;
# the first entry is always the fit-width reading view.
LAYER_PRESETS = {
    "fit": [320],
    "fit+1.5x": [320, 480],
    "fit+2x": [320, 640],
}
DEFAULT_PRESET = "fit+1.5x"

# How far a pixel may move before despeckle leaves it alone. Measured on the
# fit-width layer of assets/strip1.jpg (packed with ZX0, offset limit 1024):
#
#     off  median3   12      20      32      48
#   156.6K  124.9K  145.3K  139.3K  136.5K  128.9K
#
# median3 is the smallest and unusable. 32 saves 13% over doing nothing while
# leaving text visually identical; by 48 the strokes start thinning out.
DEFAULT_DESPECKLE = 32


def load(path):
    return Image.open(path).convert("RGB")


def resize_layer(img, width):
    """Downscale to `width`, halving repeatedly first for a cleaner result."""
    height = max(1, round(img.height * width / img.width))
    out = img
    while out.width >= width * 2 and out.height >= 2:
        out = out.resize((out.width // 2, max(1, out.height // 2)), Image.BOX)
    return out.resize((width, height), Image.LANCZOS)


def despeckle(img, threshold=DEFAULT_DESPECKLE):
    """Median-filter only the pixels the median barely moves.

    Flat, ringing-filled areas get cleaned up; edges and thin strokes keep their
    original pixels, because there the median differs sharply from the source.
    """
    median = img.filter(ImageFilter.MedianFilter(3))
    channels = ImageChops.difference(median, img).split()
    delta = ImageChops.lighter(ImageChops.lighter(channels[0], channels[1]), channels[2])
    safe = delta.point(lambda v: 255 if v <= threshold else 0)
    return Image.composite(median, img, safe)


def build_layers(img, widths, colors=16, denoise=DEFAULT_DESPECKLE, dither=False):
    """Render every zoom layer as an indexed image sharing one palette."""
    dither_mode = Image.Dither.FLOYDSTEINBERG if dither else Image.Dither.NONE

    rendered = []
    for width in widths:
        layer = resize_layer(img, width)
        if denoise:
            layer = despeckle(layer, denoise)
        rendered.append(layer)

    base = rendered[0].quantize(colors=colors, method=Image.MEDIANCUT, dither=dither_mode)
    indexed = [base] + [
        layer.quantize(palette=base, dither=dither_mode) for layer in rendered[1:]
    ]

    raw = base.getpalette()[: colors * 3]
    palette = [fmt.rgb_to_1555(*raw[i * 3:i * 3 + 3]) for i in range(colors)]
    return palette, indexed


def pack_band(indexed, layer, col, band):
    """Pack one band of one column into 4bpp, two pixels per byte."""
    x0 = col * fmt.COL_WIDTH
    y0 = band * fmt.BAND_HEIGHT
    width = layer.col_width(col)
    rows = layer.band_rows(band)
    stride = layer.stride(col)

    tile = indexed.crop((x0, y0, x0 + width, y0 + rows))
    src = tile.tobytes()
    out = bytearray(stride * rows)
    for y in range(rows):
        row = src[y * width:(y + 1) * width]
        base = y * stride
        for i in range(0, width - 1, 2):
            out[base + (i >> 1)] = (row[i] << 4) | row[i + 1]
        if width & 1:
            out[base + stride - 1] = row[width - 1] << 4
    return bytes(out)


def unpack_band(data, layer, col, band):
    """Inverse of pack_band, for verification."""
    width = layer.col_width(col)
    rows = layer.band_rows(band)
    stride = layer.stride(col)
    out = bytearray(width * rows)
    for y in range(rows):
        base = y * stride
        for x in range(width):
            byte = data[base + (x >> 1)]
            out[y * width + x] = (byte >> 4) if not (x & 1) else (byte & 0x0F)
    return bytes(out)
