#!/bin/sh
# Builds the host test harness: the real calc/src code against tools/hosttest/shim.
set -e
dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$dir/../.." && pwd)

common="$dir/shim/shim.c $dir/appvar.c"
flags="-O1 -g -Wall -Wextra -std=c11 -I$dir/shim -I$root/calc/src -include $dir/shim/shim.h"

${CC:-cc} $flags -o "$dir/render_probe" \
    "$dir/render_probe.c" $common "$root/calc/src/csx.c" "$root/calc/src/render.c"

${CC:-cc} $flags -o "$dir/lib_probe" \
    "$dir/lib_probe.c" $common "$root/calc/src/library.c" "$root/calc/src/csx.c"

# calc/src/main.c owns `main`, and so does the probe. Rename the reader's, in a
# compile of its own so the define cannot leak into the probe.
${CC:-cc} $flags -Dmain=reader_main -c -o "$dir/reader_main.o" "$root/calc/src/main.c"
${CC:-cc} $flags -o "$dir/ui_probe" \
    "$dir/ui_probe.c" $common \
    "$root/calc/src/ui.c" "$root/calc/src/input.c" "$root/calc/src/library.c" \
    "$root/calc/src/render.c" "$root/calc/src/csx.c" \
    "$dir/reader_main.o"
rm -f "$dir/reader_main.o"

# usb.c against the wire model, driven over a pipe by the real web/js/usb.js.
${CC:-cc} $flags -o "$dir/usb_probe" \
    "$dir/usb_probe.c" $common "$dir/shim/usbwire.c" \
    "$root/calc/src/usb.c" "$root/calc/src/csx.c" "$root/calc/src/library.c"

echo "built $dir/render_probe, $dir/lib_probe, $dir/ui_probe and $dir/usb_probe"
