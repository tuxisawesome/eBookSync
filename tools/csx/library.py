"""The CSLIB library index: what is on the calculator, and what it is called.

CSLIB is a single appvar describing only the content actually resident on the
calculator -- the computer stays the source of truth for the whole library. It
carries the book/strip tree, per-strip read state and saved scroll position, and
the pre-rendered title bitmaps.

Titles are ZX0-compressed. Uncompressed they would push the index past the 16 KB
an appvar can comfortably hold; compressed, a full library's worth of titles is
a couple of kilobytes, and the reader only ever expands the one row it is
drawing.

See docs/FORMAT.md for the byte layout.
"""

import struct

from . import titles as titles_mod, zx0

MAGIC = b"CSLIB"
VERSION = 2
NAME = "CSLIB"

HEADER_FMT = "<5sBHHH16s"   # 28 bytes, ending in the library id
BOOK_FMT = "<HHH"           # 6 bytes
STRIP_FMT = "<BBHBBIHBBH"   # 16 bytes

HEADER_SIZE = struct.calcsize(HEADER_FMT)
BOOK_SIZE = struct.calcsize(BOOK_FMT)
STRIP_SIZE = struct.calcsize(STRIP_FMT)
assert (HEADER_SIZE, BOOK_SIZE, STRIP_SIZE) == (28, 6, 16)

FLAG_READ = 0x01

# Biggest title bitmap the reader has to expand: the widest book row, 2bpp.
TITLE_MAX = ((titles_mod.BOOK_WIDTH + 3) // 4) * titles_mod.TITLE_HEIGHT


class Strip:
    def __init__(self, title, slot, chunk_count, size, read=False, read_at=0,
                 pos=0, layer=0):
        self.title = title
        self.slot = slot
        self.chunk_count = chunk_count
        self.size = size
        self.read = read
        self.read_at = read_at
        self.pos = pos
        self.layer = layer


class Book:
    def __init__(self, title, strips):
        self.title = title
        self.strips = strips


def build(books, renderer=None, library_id=b"\0" * 16):
    """Serialise the index. `books` is a list of Book, in reading order.

    `library_id` identifies the library folder these comics came from, so the
    calculator can tell when it is handed somebody else's.
    """
    renderer = renderer or titles_mod.TitleRenderer()

    strips = [strip for book in books for strip in book.strips]
    if len(books) > 0xFFFF or len(strips) > 0xFFFF:
        raise ValueError("too many books or strips for the index")

    # Every title is rendered once and deduplicated by its text and width, so a
    # repeated name costs nothing.
    blob = bytearray()
    offsets = {}
    title_base = HEADER_SIZE + len(books) * BOOK_SIZE + len(strips) * STRIP_SIZE

    def add_title(text, max_width):
        key = (text, max_width)
        if key not in offsets:
            width, height, packed = renderer.render(text, max_width)
            payload = zx0.compress(packed)
            offsets[key] = title_base + len(blob)
            blob.extend(struct.pack("<HBH", width, height, len(payload)))
            blob.extend(payload)
        return offsets[key]

    book_rows = bytearray()
    strip_rows = bytearray()
    first = 0
    for book in books:
        book_rows += struct.pack(
            BOOK_FMT, add_title(book.title, titles_mod.BOOK_WIDTH), first, len(book.strips)
        )
        first += len(book.strips)

    for strip in strips:
        strip_rows += struct.pack(
            STRIP_FMT,
            strip.slot,
            strip.chunk_count,
            strip.size & 0xFFFF, strip.size >> 16,
            FLAG_READ if strip.read else 0,
            strip.read_at,
            strip.pos & 0xFFFF, strip.pos >> 16,
            strip.layer,
            add_title(strip.title, titles_mod.STRIP_WIDTH),
        )

    header = struct.pack(HEADER_FMT, MAGIC, VERSION, len(books), len(strips), 0,
                         bytes(library_id)[:16].ljust(16, b"\0"))
    index = bytes(header) + bytes(book_rows) + bytes(strip_rows) + bytes(blob)
    assert len(header) + len(book_rows) + len(strip_rows) == title_base
    return index


def parse(data):
    """Read an index back, for verification and for merging calculator state."""
    magic, version, book_count, strip_count, _, library_id = struct.unpack_from(
        HEADER_FMT, data, 0)
    if magic != MAGIC:
        raise ValueError("not a CSLIB index")
    if version != VERSION:
        raise ValueError(f"unsupported CSLIB version {version}")

    def title_at(offset):
        width, height, length = struct.unpack_from("<HBH", data, offset)
        packed = zx0.decompress(data[offset + 5:offset + 5 + length])
        return width, height, packed

    strip_base = HEADER_SIZE + book_count * BOOK_SIZE
    strips = []
    for i in range(strip_count):
        (slot, chunks, size_lo, size_hi, flags, read_at,
         pos_lo, pos_hi, layer, title_ofs) = struct.unpack_from(
            STRIP_FMT, data, strip_base + i * STRIP_SIZE)
        strip = Strip("", slot, chunks, size_lo | (size_hi << 16),
                      bool(flags & FLAG_READ), read_at,
                      pos_lo | (pos_hi << 16), layer)
        strip.title_bitmap = title_at(title_ofs)
        strips.append(strip)

    books = []
    for i in range(book_count):
        title_ofs, first, count = struct.unpack_from(BOOK_FMT, data, HEADER_SIZE + i * BOOK_SIZE)
        book = Book("", strips[first:first + count])
        book.title_bitmap = title_at(title_ofs)
        books.append(book)

    for book in books:
        book.library_id = library_id
    return books
