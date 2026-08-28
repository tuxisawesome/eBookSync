#!/bin/sh
# Runs every host test. Needs a C compiler, Python with Pillow and Flask, and node.
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
echo "== reader menus: which keys do what =="
python3 "$dir/check_ui.py"

echo
echo "== library editing, and order reaching the calculator =="
"$node" "$dir/check_library_edit.mjs"

echo
echo "== usb protocol: browser and calculator over a modelled wire =="
"$node" "$dir/check_usb.mjs"

echo
echo "== self-update: what prgmEOSUP does =="
"$node" "$dir/check_update.mjs"

echo
echo "== the web pages: what is hidden stays hidden =="
"$node" "$dir/check_page.mjs"

echo
echo "== chat records: browser packer -> calculator store =="
"$node" "$dir/check_chat.mjs"

echo
echo "== chat relay: the api, the admin panel and who can see what =="
python3 -m unittest discover -s "$root/server/tests" -t "$root"

echo
echo "== the browser chat client against the real relay =="
"$node" "$dir/check_relay.mjs"

echo
echo "== sync planner =="
"$node" "$dir/check_planner.mjs"

echo
echo "all host tests passed"
