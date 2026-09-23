#!/usr/bin/env python3
"""Compare the calculator's renderer against the Python decoder, pixel for pixel.

Converts a source image, writes the chunk appvars, runs tools/hosttest/render_probe
(the real calc/src/csx.c and render.c compiled for the host) over a set of
viewports, and checks every frame matches what tools/csx produces independently.

This is the only way to exercise the reader's clipping and 4bpp expansion
without a calculator: CEmu needs a ROM dump, so the code cannot be emulated.

It then does the same for a strip stitched from a folder of images of
different shapes -- one of them shorter than the screen -- and checks the part
table the calculator reads is the one the encoder wrote, and that nothing
past the end of an image is drawn while the reader is on it.

    tools/hosttest/check.py assets/strip1.jpg
"""

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from PIL import Image   # noqa: E402

from csx import format as fmt, image, strip as strip_mod, tifile   # noqa: E402

sys.path.insert(0, str(HERE))
from common import compare_frames, part_viewports, viewports_for   # noqa: E402

SCREEN_W, SCREEN_H = 320, 240


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("source", nargs="?", default="assets/strip1.jpg")
    parser.add_argument("--preset", default=image.DEFAULT_PRESET,
                        choices=sorted(image.LAYER_PRESETS))
    parser.add_argument("--keep", help="keep generated appvars in this directory")
    args = parser.parse_args()

    failures = check_source(args.source, args.preset, args.keep)

    with tempfile.TemporaryDirectory() as tmp:
        folder = make_folder_strip(Path(args.source), Path(tmp) / "episode")
        failures += check_source(folder, args.preset, None, expect_parts=3)
    return 1 if failures else 0


def make_folder_strip(source, folder):
    """A folder strip cut from `source`: three images of different shapes.

    Named 2, 10 and B so the natural order (2, 10, B) differs from a plain
    string sort (10, 2, B) -- a stitch in the wrong order has to show. The
    middle one is short and wide, so at fit width it is shorter than the screen.
    Mixed formats, because a folder is not obliged to be all JPEGs.
    """
    folder.mkdir(parents=True)
    img = image.load(source)
    w = img.width
    img.crop((0, 0, w, 1800)).save(folder / "2.jpg", quality=92)
    img.crop((0, 1800, w, 2100)).save(folder / "10.png")
    img.crop((w // 4, 2100, w - w // 4, 3900)).save(folder / "B.webp", quality=92)
    return folder


def check_source(source, preset, keep, expect_parts=None):
    print(f"converting {source} ({preset})...")
    result = strip_mod.convert(source, preset=preset)
    layers = strip_mod.decode(result.chunks)
    print(f"  {len(result.chunks)} chunks, layers "
          + ", ".join(f"{l.width}x{l.height}" for l in result.layers))

    failures = 0
    viewports = viewports_for(layers)
    if expect_parts:
        names = [p.name for p in image.part_paths(source)]
        if names != ["2.jpg", "10.png", "B.webp"]:
            print(f"  MISMATCH part order: {names}")
            failures += 1
        if len(result.parts) != expect_parts:
            print(f"  MISMATCH: expected {expect_parts} parts, got {len(result.parts)}")
            failures += 1
        # The stitched layer must be each part scaled on its own, stacked.
        for li, layer in enumerate(result.layers):
            heights = []
            for path in image.part_paths(source):
                with Image.open(path) as part:
                    heights.append(max(1, round(part.height * layer.width / part.width)))
            tops = [sum(heights[:i]) for i in range(len(heights))]
            if [part[li] for part in result.parts] != tops or layer.height != sum(heights):
                print(f"  MISMATCH layer {li}: tops {[p[li] for p in result.parts]}, want {tops}")
                failures += 1
        viewports += part_viewports(layers, result.parts)

    with tempfile.TemporaryDirectory() as tmp:
        outdir = Path(keep) if keep else Path(tmp)
        outdir.mkdir(parents=True, exist_ok=True)
        for index, chunk in enumerate(result.chunks):
            name = fmt.chunk_name(0, index)
            (outdir / f"{name}.8xv").write_bytes(tifile.write(name, chunk))
        failures += compare_frames(HERE, outdir, viewports, layers,
                                   parts=result.parts if expect_parts else None)
    return failures


if __name__ == "__main__":
    sys.exit(main())
