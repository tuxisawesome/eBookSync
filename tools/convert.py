#!/usr/bin/env python3
"""Convert comic JPEGs into .csx containers and TI-84 Plus CE appvars.

Examples:

    # Report what a strip costs at each detail level
    tools/convert.py assets/strip1.jpg --measure

    # Convert and write appvars ready for CEmu / TI Connect CE
    tools/convert.py assets/strip1.jpg -o out/ --slot 0

    # Convert and verify the container round-trips, saving a preview PNG
    tools/convert.py assets/strip1.jpg -o out/ --verify --preview out/preview.png
"""

import argparse
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from csx import format as fmt, image, strip as strip_mod, tifile, zx0


def human(n):
    return f"{n / 1024:.1f} KB" if n < 1024 * 1024 else f"{n / 1024 / 1024:.2f} MB"


def cmd_measure(args):
    src = image.load(args.source)
    print(f"{args.source}: {src.width}x{src.height}")
    print(f"{'preset':10} {'layers':16} {'raw':>10} {'packed':>10} {'ratio':>7} "
          f"{'chunks':>7} {'/3MB':>5}")
    for preset in image.LAYER_PRESETS:
        result = strip_mod.convert(
            args.source, preset=preset, colors=args.colors,
            denoise=0 if args.no_denoise else args.despeckle, dither=args.dither,
            offset_limit=args.offset_limit, jobs=args.jobs,
        )
        widths = "+".join(str(w) for w in image.LAYER_PRESETS[preset])
        fits = (3 * 1024 * 1024) // result.total_bytes
        print(f"{preset:10} {widths:16} {human(result.raw_bytes):>10} "
              f"{human(result.total_bytes):>10} {result.ratio:6.2f}x "
              f"{len(result.chunks):7} {fits:5}")


def cmd_convert(args):
    started = time.time()
    result = strip_mod.convert(
        args.source, preset=args.preset, colors=args.colors,
        denoise=0 if args.no_denoise else args.despeckle, dither=args.dither,
        offset_limit=args.offset_limit, jobs=args.jobs,
    )
    elapsed = time.time() - started

    layers = ", ".join(f"{l.width}x{l.height}" for l in result.layers)
    print(f"{args.source}: {layers}")
    print(f"  {human(result.raw_bytes)} raw -> {human(result.total_bytes)} in "
          f"{len(result.chunks)} chunks ({result.ratio:.2f}x) in {elapsed:.1f}s")

    if args.verify:
        decoded = strip_mod.decode(result.chunks)
        for original, layer in zip(decoded, result.layers):
            assert (original.width, original.height) == (layer.width, layer.height)
        print(f"  round-trip OK: {len(decoded)} layers decoded from the container")

    if args.preview:
        decoded = strip_mod.decode(result.chunks)
        preview = decoded[0].convert("RGB")
        Path(args.preview).parent.mkdir(parents=True, exist_ok=True)
        preview.save(args.preview)
        print(f"  wrote {args.preview} ({preview.width}x{preview.height})")

    if args.out:
        out = Path(args.out)
        out.mkdir(parents=True, exist_ok=True)
        for index, chunk in enumerate(result.chunks):
            name = fmt.chunk_name(args.slot, index)
            (out / f"{name}.8xv").write_bytes(tifile.write(name, chunk))
        print(f"  wrote {len(result.chunks)} appvars to {out}/ "
              f"({fmt.chunk_name(args.slot, 0)}..{fmt.chunk_name(args.slot, len(result.chunks) - 1)})")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("source", help="comic JPEG to convert")
    parser.add_argument("-o", "--out", help="directory to write .8xv appvars into")
    parser.add_argument("--slot", type=int, default=0,
                        help="strip slot 0-255, decides the appvar names (default 0)")
    parser.add_argument("--preset", default=image.DEFAULT_PRESET,
                        choices=sorted(image.LAYER_PRESETS),
                        help=f"zoom ladder (default {image.DEFAULT_PRESET})")
    parser.add_argument("--colors", type=int, default=16, choices=(16,),
                        help="palette size (only 16 is supported by the 4bpp format)")
    parser.add_argument("--no-denoise", action="store_true",
                        help="skip despeckling (larger output, more JPEG artefacts)")
    parser.add_argument("--despeckle", type=int, default=image.DEFAULT_DESPECKLE,
                        help=f"edge-preserving despeckle threshold, 0 disables "
                             f"(default {image.DEFAULT_DESPECKLE}; above ~48 text starts thinning)")
    parser.add_argument("--dither", action="store_true",
                        help="Floyd-Steinberg dithering (smoother gradients, larger output)")
    parser.add_argument("--offset-limit", type=int, default=zx0.DEFAULT_OFFSET_LIMIT,
                        help=f"ZX0 match window (default {zx0.DEFAULT_OFFSET_LIMIT})")
    parser.add_argument("--jobs", type=int, default=None,
                        help="parallel compression workers (default: cpu count, max 8)")
    parser.add_argument("--verify", action="store_true",
                        help="decode the container back and check it round-trips")
    parser.add_argument("--preview", help="write the fit-width layer to this PNG")
    parser.add_argument("--measure", action="store_true",
                        help="report size at every preset instead of converting")
    args = parser.parse_args(argv)

    if args.measure:
        cmd_measure(args)
    else:
        cmd_convert(args)


if __name__ == "__main__":
    main()
