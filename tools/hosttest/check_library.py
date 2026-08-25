#!/usr/bin/env python3
"""Check calc/src/library.c parses exactly what tools/csx/library.py builds.

Builds an index with Chinese titles, runs it through the real calculator parser
compiled for the host, and compares every field and every expanded title bitmap.
Then exercises the write-back path the reader uses when it leaves a strip.
"""

import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from csx import library as lib, tifile   # noqa: E402


def checksum(packed):
    total = 0
    for byte in packed:
        total = (total * 31 + byte) % (2 ** 64)
    return total


def sample_books():
    return [
        lib.Book("第一本书", [
            lib.Strip("001 - 标题很长的一集漫画故事名字会被截断掉的", 0, 25, 401_920,
                      read=True, read_at=1_756_000_001, pos=1234, layer=1),
            lib.Strip("002 - 第二集", 1, 25, 402_000, read=True, read_at=1_756_000_500),
            lib.Strip("003 - 第三集", 2, 24, 390_100),
        ]),
        lib.Book("Another Book 另一本", [
            lib.Strip("01 - Episode One", 10, 9, 140_000, pos=99, layer=0),
        ]),
        lib.Book("短", []),
    ]


def run_probe(directory, *extra):
    result = subprocess.run([str(HERE / "lib_probe"), str(directory), *extra],
                            capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(result.stderr or f"lib_probe exited {result.returncode}")
    return result.stdout


def parse_probe(text):
    books, strips, header = [], [], {}
    for line in text.splitlines():
        parts = line.split()
        if parts[0] == "books":
            header = {"books": int(parts[1]), "strips": int(parts[3])}
        elif parts[0] == "book":
            books.append({parts[i]: parts[i + 1] for i in range(2, len(parts) - 1, 2)})
        elif parts[0] == "strip":
            strips.append({parts[i]: parts[i + 1] for i in range(2, len(parts) - 1, 2)})
    return header, books, strips


def main():
    books = sample_books()
    index = lib.build(books)
    parsed = lib.parse(index)

    with tempfile.TemporaryDirectory() as tmp:
        directory = Path(tmp)
        (directory / "CSLIB.8xv").write_bytes(tifile.write(lib.NAME, index))

        header, probe_books, probe_strips = parse_probe(run_probe(directory))

        failures = []
        if header["books"] != len(books) or header["strips"] != sum(len(b.strips) for b in books):
            failures.append(f"counts: C says {header}, Python built "
                            f"{len(books)} books / {sum(len(b.strips) for b in books)} strips")

        first = 0
        for i, (book, probe) in enumerate(zip(books, probe_books)):
            want_read = sum(1 for s in book.strips if s.read)
            width, height, packed = parsed[i].title_bitmap
            checks = {
                "first": first, "count": len(book.strips), "read": want_read,
                "title": f"{width}x{height}", "sum": checksum(packed),
            }
            for key, want in checks.items():
                if str(probe.get(key)) != str(want):
                    failures.append(f"book {i} {key}: C {probe.get(key)} != Python {want}")
            first += len(book.strips)

        flat = [s for book in books for s in book.strips]
        flat_parsed = [s for book in parsed for s in book.strips]
        for i, (strip, want, probe) in enumerate(zip(flat, flat_parsed, probe_strips)):
            width, height, packed = want.title_bitmap
            checks = {
                "slot": strip.slot, "chunks": strip.chunk_count, "bytes": strip.size,
                "flags": lib.FLAG_READ if strip.read else 0, "readat": strip.read_at,
                "pos": strip.pos, "layer": strip.layer,
                "title": f"{width}x{height}", "sum": checksum(packed),
            }
            for key, expect in checks.items():
                if str(probe.get(key)) != str(expect):
                    failures.append(f"strip {i} {key}: C {probe.get(key)} != Python {expect}")

        # Now the write-back path: mark strip 2 read, at position 4321, layer 1.
        run_probe(directory, "save", "2", str(lib.FLAG_READ), "4321", "1")
        saved = lib.parse((directory / "CSLIB.saved").read_bytes())
        updated = [s for book in saved for s in book.strips][2]
        if not (updated.read and updated.pos == 4321 and updated.layer == 1
                and updated.read_at == 1_756_100_000):
            failures.append(f"write-back: read={updated.read} pos={updated.pos} "
                            f"layer={updated.layer} read_at={updated.read_at}")
        # ...and that it disturbed nothing else.
        untouched = [s for book in saved for s in book.strips][0]
        if untouched.pos != 1234 or untouched.slot != 0 or untouched.size != 401_920:
            failures.append("write-back corrupted a neighbouring record")

    for failure in failures:
        print("  FAIL " + failure)
    total = 1 + len(books) * 5 + len(flat) * 9 + 2
    print(f"{total - len(failures)}/{total} library checks pass")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
