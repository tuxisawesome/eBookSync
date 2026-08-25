#!/usr/bin/env python3
"""Compare the calculator's renderer against the Python decoder, pixel for pixel.

Converts a source image, writes the chunk appvars, runs tools/hosttest/render_probe
(the real calc/src/csx.c and render.c compiled for the host) over a set of
viewports, and checks every frame matches what tools/csx produces independently.

This is the only way to exercise the reader's clipping and 4bpp expansion
without a calculator: CEmu needs a ROM dump, so the code cannot be emulated.

    tools/hosttest/check.py assets/strip1.jpg
"""

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from csx import format as fmt, image, strip as strip_mod, tifile   # noqa: E402

sys.path.insert(0, str(HERE))
from common import compare_frames, viewports_for   # noqa: E402

SCREEN_W, SCREEN_H = 320, 240


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("source", nargs="?", default="assets/strip1.jpg")
    parser.add_argument("--preset", default=image.DEFAULT_PRESET,
                        choices=sorted(image.LAYER_PRESETS))
    parser.add_argument("--keep", help="keep generated appvars in this directory")
    args = parser.parse_args()

    print(f"converting {args.source} ({args.preset})...")
    result = strip_mod.convert(args.source, preset=args.preset)
    layers = strip_mod.decode(result.chunks)
    print(f"  {len(result.chunks)} chunks, layers "
          + ", ".join(f"{l.width}x{l.height}" for l in result.layers))

    viewports = viewports_for(layers)

    with tempfile.TemporaryDirectory() as tmp:
        outdir = Path(args.keep) if args.keep else Path(tmp)
        outdir.mkdir(parents=True, exist_ok=True)
        for index, chunk in enumerate(result.chunks):
            name = fmt.chunk_name(0, index)
            (outdir / f"{name}.8xv").write_bytes(tifile.write(name, chunk))
        return compare_frames(HERE, outdir, viewports, layers)


if __name__ == "__main__":
    sys.exit(main())
