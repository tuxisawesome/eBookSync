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
    "$dir/lib_probe.c" $common "$root/calc/src/library.c"

echo "built $dir/render_probe and $dir/lib_probe"
