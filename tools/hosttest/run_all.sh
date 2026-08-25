#!/bin/sh
# Runs every host test. Needs a C compiler, Python with Pillow, and node.
#
# The calculator itself cannot be emulated here -- CEmu needs a ROM dump -- so
# these compile the real calc/src code for the host and check it against
# independent implementations of the same formats.
set -e
dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$dir/../.." && pwd)
node=${NODE:-node}

echo "== building =="
sh "$root/tools/build.sh"
sh "$dir/build.sh"

echo
echo "== container: python encoder -> calculator renderer =="
python3 "$dir/check.py" "$@"

echo
echo "== library index: python builder -> calculator parser =="
python3 "$dir/check_library.py"

echo
echo "== container: browser encoder -> calculator renderer =="
python3 "$dir/check_js.py" --node "$node" "$@"

echo
echo "== library index: browser builder -> calculator parser =="
"$node" "$dir/check_js_library.mjs"

echo
echo "== library editing, and order reaching the calculator =="
"$node" "$dir/check_library_edit.mjs"

echo
echo "== sync planner =="
"$node" "$dir/check_planner.mjs"

echo
echo "all host tests passed"
