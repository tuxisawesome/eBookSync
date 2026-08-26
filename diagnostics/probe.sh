#!/bin/sh
#
# Speak the sync protocol to the calculator from the shell.
#
# The calculator is on its Sync screen (2nd from the book list, NOT alpha).
# This sends one HELLO and prints whatever comes back -- the same exchange the
# page makes on connect, with no browser involved.
#
#   diagnostics/probe.sh /dev/cu.usbmodem<whatever>
#
# Note /dev/cu.*, not /dev/tty.*. On macOS the tty.* device blocks on open
# waiting for carrier detect, which a USB serial gadget never asserts; cu.* is
# the call-out device and opens immediately. If you have been testing with
# tty.*, that alone could explain a hang.

port="$1"
if [ -z "$port" ]; then
    echo "usage: $0 /dev/cu.usbmodemXXXX" >&2
    echo >&2
    echo "available ports:" >&2
    ls /dev/cu.usbmodem* 2>/dev/null >&2 || echo "  none found" >&2
    exit 2
fi

# Raw mode, no echo, no flow control, and do not wait for carrier.
if [ "$(uname -s)" = "Darwin" ]; then
    stty -f "$port" raw -echo clocal 115200
else
    stty -F "$port" raw -echo clocal 115200
fi

echo "listening on $port..."
# Start reading before writing, so the reply cannot be missed.
( head -c 14 < "$port" | od -An -tx1 | tr -s ' ' ) &
reader=$!

sleep 1

# HELLO: cmd 0x01, seq 0x01, arg 0x0000, length 0x00000000
printf '\001\001\000\000\000\000\000\000' > "$port"
echo "sent HELLO (01 01 00 00 00 00 00 00)"

wait $reader
echo
echo "expected something like:"
echo " 01 01 00 00 06 00 00 00 01 xx xx xx 40 40"
echo "  |  |  |     |           |  \\_____/  |  \\_ chunk size / 256 = 0x40 = 16384"
echo "  |  |  |     |           |     |     \\_ max chunks"
echo "  |  |  |     |           |     \\_ free archive bytes"
echo "  |  |  |     |           \\_ protocol version 1"
echo "  |  |  |     \\_ payload length 6"
echo "  |  |  \\_ status 0 (ok)"
echo "  |  \\_ seq 1, echoed"
echo "  \\_ cmd 1 (HELLO)"
