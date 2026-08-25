#!/usr/bin/env python3
"""Check the browser encoder produces containers the calculator can read.

web/js/convert.js and tools/csx are independent implementations of the same
format. This feeds both the same indexed pixels, has the JS side build the
container, then renders it through the real calc/src code and compares every
frame with the Python decoder -- so a layout disagreement anywhere between the
three cannot go unnoticed.

    tools/hosttest/check_js.py assets/strip1.jpg --node /path/to/node
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

from csx import format as fmt, image, strip as strip_mod, tifile   # noqa: E402

sys.path.insert(0, str(HERE))
from common import compare_frames, viewports_for   # noqa: E402


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("source", nargs="?", default="assets/strip1.jpg")
    parser.add_argument("--preset", default=image.DEFAULT_PRESET,
                        choices=sorted(image.LAYER_PRESETS))
    parser.add_argument("--node", default=shutil.which("node"),
                        help="node binary (default: whatever is on PATH)")
    args = parser.parse_args()

    if not args.node:
        sys.exit("node not found; pass --node /path/to/node")

    widths = image.LAYER_PRESETS[args.preset]
    print(f"rendering {args.source} at {widths}...")
    src = image.load(args.source)
    palette, indexed = image.build_layers(src, widths)

    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        spec = {"palette": palette, "layers": []}
        for layer in indexed:
            path = work / f"layer{layer.width}.idx"
            path.write_bytes(layer.tobytes())
            spec["layers"].append({"width": layer.width, "height": layer.height,
                                   "indices": str(path)})
        (work / "layers.json").write_text(json.dumps(spec))

        print("building the container with web/js/convert.js...")
        run = subprocess.run([args.node, str(HERE / "check_js.mjs"),
                              str(work / "layers.json"), str(work)],
                             capture_output=True, text=True)
        if run.returncode != 0:
            sys.exit(run.stderr or f"check_js.mjs exited {run.returncode}")
        print("  " + run.stderr.strip())

        # Read the JS container back with the Python parser and decode it, so
        # the comparison below is between two implementations that never shared
        # a line of code.
        chunks = []
        summary = json.loads((work / "js-summary.json").read_text())
        for index in range(summary["chunks"]):
            name = fmt.chunk_name(0, index)
            _, payload = tifile.read((work / f"{name}.8xv").read_bytes())
            chunks.append(bytearray(payload))

        layers = strip_mod.decode(chunks)
        print("  python decoded the js container: "
              + ", ".join(f"{l.width}x{l.height}" for l in layers))

        viewports = viewports_for(layers)
        return compare_frames(HERE, work, viewports, layers)


if __name__ == "__main__":
    sys.exit(main())
