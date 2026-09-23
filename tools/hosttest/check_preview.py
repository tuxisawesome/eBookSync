#!/usr/bin/env python3
"""Check the page's preview shows what the calculator will.

web/js/preview.js decodes a converted strip and draws viewports of it, and it is
only worth anything if those are the calculator's pixels. This renders the same
viewports -- plain, at column edges, and clipped at the end of an image -- of a
single-image strip and of a three-image folder strip through both preview.js
and the real calc/src renderer, and compares them byte for byte.

    tools/hosttest/check_preview.py --node /path/to/node
"""

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
sys.path.insert(0, str(HERE))

from csx import format as fmt, strip as strip_mod, tifile   # noqa: E402
from check import make_folder_strip   # noqa: E402
from common import part_viewports, viewports_for   # noqa: E402

FRAME = 320 * 240


def compare(source, node, preset):
    result = strip_mod.convert(source, preset=preset)
    layers = strip_mod.decode(result.chunks)
    viewports = viewports_for(layers) + part_viewports(layers, result.parts)
    specs = [",".join(map(str, v)) for v in viewports]

    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        for index, chunk in enumerate(result.chunks):
            (work / f"{index}.bin").write_bytes(bytes(chunk))
            name = fmt.chunk_name(0, index)
            (work / f"{name}.8xv").write_bytes(tifile.write(name, chunk))

        calc = subprocess.run([str(HERE / "render_probe"), str(work), "0"] + specs,
                              capture_output=True)
        if calc.returncode != 0:
            sys.exit(calc.stderr.decode() or "render_probe failed")

        page = subprocess.run([node, str(HERE / "check_preview.mjs"), str(work),
                               str(len(result.chunks)), str(work / "frames.bin")] + specs,
                              capture_output=True, text=True)
        if page.returncode != 0:
            sys.exit(page.stderr or "check_preview.mjs failed")
        frames = (work / "frames.bin").read_bytes()
        parts = json.loads(page.stdout)

    failures = 0
    if parts != [list(p) for p in result.parts]:
        print(f"  MISMATCH part table: preview read {parts}, encoder wrote {result.parts}")
        failures += 1
    for i, spec in enumerate(specs):
        want = calc.stdout[i * FRAME:(i + 1) * FRAME]
        got = frames[i * FRAME:(i + 1) * FRAME]
        if want != got:
            bad = sum(1 for a, b in zip(want, got) if a != b)
            print(f"  MISMATCH viewport {spec}: {bad} pixels differ")
            failures += 1
    total = len(specs) + 1   # every viewport, and the part table
    print(f"  {source.name}: {total - failures}/{total} match")
    return failures, total


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("source", nargs="?", default="assets/strip1.jpg")
    parser.add_argument("--node", default=shutil.which("node"))
    args = parser.parse_args()
    if not args.node:
        sys.exit("node not found; pass --node /path/to/node")

    failures = total = 0
    f, t = compare(Path(args.source), args.node, "fit+1.5x")
    failures, total = failures + f, total + t
    with tempfile.TemporaryDirectory() as tmp:
        folder = make_folder_strip(Path(args.source), Path(tmp) / "episode")
        f, t = compare(folder, args.node, "fit+2x")
        failures, total = failures + f, total + t

    print(f"{total - failures}/{total} preview checks pass")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
