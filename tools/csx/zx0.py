"""ZX0 compression for the .csx pipeline.

Compression runs through the vendored ZX0 optimal parser (tools/vendor/zx0,
BSD-3-Clause, Einar Saukas) loaded with ctypes -- a pure-Python optimal parse
is far too slow for the ~350 bands in a single strip.

The decompressor here is pure Python and exists only to verify round-trips; the
calculator uses the CE toolchain's zx0_Decompress and the browser uses
web/js/zx0.js. All three speak the default (non-"classic") forward ZX0 v2
stream.
"""

import ctypes
import platform
from pathlib import Path

_VENDOR = Path(__file__).resolve().parent.parent / "vendor" / "zx0"
_LIBNAMES = {"Darwin": "libzx0.dylib", "Windows": "zx0.dll"}

# Match window cap handed to the optimal parser. ZX0's optimal parse is
# O(size * offset_limit), and bands are only a few KB of 4bpp image data where
# useful matches sit within a handful of scanlines -- so capping the window buys
# a large speedup for almost no ratio. Measured over the 104 bands of the
# fit-width layer of assets/strip1.jpg (515 KB raw):
#
#     limit    256     512    1024    2048    5120   32640 (upstream default)
#     size   129.1K  126.5K  124.9K  123.8K  123.4K  123.4K
#     time    1.7s    3.0s    5.4s    9.5s   15.7s   15.7s
#
# 1024 costs 1.2% over an unbounded window and runs three times faster, which
# matters most for the JS port that does this work in the browser.
DEFAULT_OFFSET_LIMIT = 1024

_lib = None


def _load():
    global _lib
    if _lib is not None:
        return _lib
    path = _VENDOR / _LIBNAMES.get(platform.system(), "libzx0.so")
    if not path.exists():
        raise RuntimeError(
            f"{path.name} is missing -- run tools/build.sh to build it (needs a C compiler)"
        )
    lib = ctypes.CDLL(str(path))
    lib.zx0_compress_block.restype = ctypes.POINTER(ctypes.c_ubyte)
    lib.zx0_compress_block.argtypes = [
        ctypes.c_char_p, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_int)
    ]
    lib.zx0_free.restype = None
    lib.zx0_free.argtypes = [ctypes.POINTER(ctypes.c_ubyte)]
    _lib = lib
    return lib


def compress(data, offset_limit=DEFAULT_OFFSET_LIMIT):
    """Compress bytes into a standalone ZX0 stream."""
    if not data:
        return b""
    lib = _load()
    out_size = ctypes.c_int(0)
    ptr = lib.zx0_compress_block(bytes(data), len(data), offset_limit, ctypes.byref(out_size))
    if not ptr:
        raise RuntimeError("zx0_compress_block failed")
    try:
        return bytes(bytearray(ptr[i] for i in range(out_size.value)))
    finally:
        lib.zx0_free(ptr)


class _BitReader:
    __slots__ = ("data", "pos", "mask", "value", "last_byte", "backtrack")

    def __init__(self, data):
        self.data = data
        self.pos = 0
        self.mask = 0
        self.value = 0
        self.last_byte = 0
        self.backtrack = False

    def byte(self):
        self.last_byte = self.data[self.pos]
        self.pos += 1
        return self.last_byte

    def bit(self):
        if self.backtrack:
            self.backtrack = False
            return self.last_byte & 1
        self.mask >>= 1
        if self.mask == 0:
            self.mask = 128
            self.value = self.byte()
        return 1 if self.value & self.mask else 0

    def gamma(self, inverted=False):
        value = 1
        while not self.bit():
            value = value << 1 | (self.bit() ^ (1 if inverted else 0))
        return value


def decompress(data):
    """Pure-Python reference decoder, mirroring dzx0.c in non-classic mode."""
    r = _BitReader(data)
    out = bytearray()
    last_offset = 1

    while True:
        # copy literals
        for _ in range(r.gamma()):
            out.append(r.byte())
        if not r.bit():
            # copy from last offset
            length = r.gamma()
            _copy(out, last_offset, length)
            if not r.bit():
                continue
        # copy from new offset
        while True:
            last_offset = r.gamma(inverted=True)
            if last_offset == 256:
                return bytes(out)
            last_offset = last_offset * 128 - (r.byte() >> 1)
            r.backtrack = True
            length = r.gamma() + 1
            _copy(out, last_offset, length)
            if not r.bit():
                break
    # unreachable


def _copy(out, offset, length):
    if offset > len(out):
        raise ValueError("invalid ZX0 stream: offset past start of output")
    for _ in range(length):
        out.append(out[-offset])
