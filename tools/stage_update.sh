#!/bin/sh
#
# Build both programs and stage them where the sync page can fetch them.
#
# The page is static and served by GitHub Pages, so an update is just three
# files sitting next to it: the two .8xp builds and a manifest naming the build
# number. Nothing is generated at request time and there is no server involved.
#
# Bumps calc/BUILD unless --keep is given, because a build the page can push has
# to be distinguishable from the one already on the calculator -- HELLO reports
# a number, and two different programs claiming the same one is the one way this
# can silently do nothing.
#
#   tools/stage_update.sh [--keep]

set -e
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$here/.." && pwd)

keep=no
[ "$1" = "--keep" ] && keep=yes

build=$(tr -cd '0-9' < "$root/calc/BUILD")
: "${build:?calc/BUILD does not contain a number}"

if [ "$keep" = no ]; then
    build=$((build + 1))
    echo "$build" > "$root/calc/BUILD"
fi
echo "build $build"

make -C "$root/calc" >/dev/null
make -C "$root/calc/updater" >/dev/null

out="$root/web/eos"
mkdir -p "$out"
cp "$root/calc/bin/EOS.8xp" "$out/EOS.8xp"
cp "$root/calc/updater/bin/EOSUP.8xp" "$out/EOSUP.8xp"

# The manifest carries the sizes as a cheap sanity check on what was served;
# the authoritative integrity check is the CRC the calculator runs over what it
# actually stored, which is computed from the file rather than recorded here.
python3 - "$out" "$build" <<'PY'
import json, pathlib, sys

out = pathlib.Path(sys.argv[1])
build = int(sys.argv[2])

manifest = {
    "build": build,
    "eos": {"bytes": (out / "EOS.8xp").stat().st_size},
    "eosup": {"bytes": (out / "EOSUP.8xp").stat().st_size},
}
(out / "build.json").write_text(json.dumps(manifest, indent=2) + "\n")
PY

echo "staged $out/EOS.8xp, $out/EOSUP.8xp and $out/build.json"
