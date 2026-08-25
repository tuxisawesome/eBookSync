#!/bin/sh
# Builds the ZX0 shared library used by tools/csx. Requires a C compiler.
set -e
dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
out="$dir/vendor/zx0/libzx0.so"
case "$(uname -s)" in
  Darwin) out="$dir/vendor/zx0/libzx0.dylib" ;;
  MINGW*|MSYS*|CYGWIN*) out="$dir/vendor/zx0/zx0.dll" ;;
esac
${CC:-cc} -O2 -fPIC -fvisibility=hidden -shared -o "$out" \
    "$dir/vendor/zx0/zx0lib.c" \
    "$dir/vendor/zx0/compress.c" \
    "$dir/vendor/zx0/optimize.c" \
    "$dir/vendor/zx0/memory.c"
echo "built $out"
