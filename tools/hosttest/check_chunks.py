#!/usr/bin/env python3
"""Push chunks through the real usb.c, then open them with the real csx.c.

Nothing used to do both. tools/hosttest/usb_probe exercised the transfer and
linked csx.c only for the chunk names; render_probe read appvars laid out on
disk by the Python encoder and never saw the link. So the one question that
matters -- does a strip the calculator accepted actually open? -- had no test at
all, and a strip could be stored, indexed, listed in the reader's menu and
refused only when somebody picked it.

This drives the same probe web/js/link.js drives, over the same byte stream,
with an independent client so a mistake in link.js cannot cancel out a mistake
in usb.c. It covers:

  - a chunk arriving byte for byte,
  - a chunk whose CRC-32 does not match its bytes being refused and leaving
    nothing behind,
  - VERIFY answering for a complete strip, a strip with a chunk missing, and a
    slot with nothing in it.

    tools/hosttest/check_chunks.py
"""

import binascii
import struct
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from PIL import Image   # noqa: E402

from csx import format as fmt, image as img, zx0   # noqa: E402

PROTOCOL_VERSION = 5
HEADER = struct.Struct("<BBHI")

CMD_HELLO = 0x01
CMD_PUT_CHUNK = 0x03
CMD_VERIFY = 0x0E
CMD_WALLPAPER = 0x0F
CMD_UPDATE_BEGIN = 0x0A
CMD_UPDATE_CHUNK = 0x0B
CMD_UPDATE_END = 0x0C

TARGET_READER = 0
TARGET_LOCK = 2
UPDATE_CHUNK_SIZE = 16384
CMD_BYE = 0x08

WALLPAPER_SLOT = 0xFFFF

# CSLIB: the device block is the last 64 bytes of a 92-byte header, and the
# wallpaper claim is five bytes at offset 54 within it. See docs/FORMAT.md.
LIB_DEVICE_OFFSET = 28
DEV_WALL_FLAGS = LIB_DEVICE_OFFSET + 54
DEV_WALL_CRC = LIB_DEVICE_OFFSET + 55
BUSY = 0xFE

STATUS_OK = 0
STATUS_NOT_FOUND = 5
STATUS_BAD_CRC = 8

checks = 0
failures = 0


def check(label, actual, expected):
    global checks, failures
    checks += 1
    if actual != expected:
        failures += 1
        print(f"  FAIL {label}: got {actual!r}, want {expected!r}")


class Probe:
    """The calculator, as a subprocess speaking the protocol down a pipe."""

    def __init__(self, save_dir=None):
        args = [str(HERE / "usb_probe")]
        if save_dir:
            args += ["--save", str(save_dir)]
        self.proc = subprocess.Popen(args, stdin=subprocess.PIPE,
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE)
        self.seq = 0

    def request(self, cmd, payload=b"", arg=0):
        """Send one request and return (status, body), as the page does."""
        self.seq = (self.seq + 1) & 0xFF
        self.proc.stdin.write(HEADER.pack(cmd, self.seq, arg, len(payload)) + payload)
        self.proc.stdin.flush()

        while True:
            head = self.proc.stdout.read(HEADER.size)
            if len(head) < HEADER.size:
                raise RuntimeError(f"the probe stopped answering command {cmd:#04x}")
            reply_cmd, reply_seq, status, length = HEADER.unpack(head)

            # "Still alive, the OS is defragmenting" -- a notice, not a reply.
            if reply_cmd == BUSY:
                continue

            body = self.proc.stdout.read(length) if length else b""
            if reply_seq == self.seq:
                return status, body

    def hello(self):
        status, body = self.request(CMD_HELLO, b"\0" * 16)
        assert status == STATUS_OK, status
        return {
            "version": body[0],
            "max_chunks": body[4],
            "flags": body[9],
            "armed_build": body[10] | (body[11] << 8),
            "lock_build": body[12] | (body[13] << 8),
        }

    def push_update(self, target, build, image):
        """BEGIN, one CHUNK per 16 KB, then END -- what the page does."""
        chunks = [image[at:at + UPDATE_CHUNK_SIZE]
                  for at in range(0, len(image), UPDATE_CHUNK_SIZE)]
        crc = binascii.crc32(image) & 0xFFFFFFFF

        payload = struct.pack("<HIHI", build, len(image), len(chunks), crc)
        status = self.request(CMD_UPDATE_BEGIN, payload, target)[0]
        if status != STATUS_OK:
            return status

        for index, chunk in enumerate(chunks):
            status = self.request(CMD_UPDATE_CHUNK, chunk,
                                  target | (index << 8))[0]
            if status != STATUS_OK:
                return status

        return self.request(CMD_UPDATE_END, b"", target)[0]

    def put_chunk(self, slot, index, chunk, crc=None):
        if crc is None:
            crc = binascii.crc32(chunk) & 0xFFFFFFFF
        return self.request(CMD_PUT_CHUNK,
                            bytes([index]) + struct.pack("<I", crc) + chunk,
                            slot)[0]

    def verify(self, slot):
        status, body = self.request(CMD_VERIFY, b"", slot)
        return status, (body[0] if body else 0)

    def wallpaper(self, present):
        return self.request(CMD_WALLPAPER, b"", 1 if present else 0)[0]

    def close(self):
        try:
            self.request(CMD_BYE)
        except RuntimeError:
            pass
        self.proc.stdin.close()
        self.proc.wait(timeout=30)
        return self.proc.returncode


def noisy_container(height=128):
    """A container that needs more than one chunk.

    Noise, deliberately: a strip that compresses well is one chunk, and a
    single-chunk strip cannot have a hole in it below its own header.
    """
    seed = 12345

    def rand():
        nonlocal seed
        seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
        return (seed >> 16) & 0x0F

    indexed = Image.frombytes("P", (320, height),
                              bytes(rand() for _ in range(320 * height)))
    layer = fmt.Layer(320, height)
    bands = [zx0.compress(img.pack_band(indexed, layer, col, band))
             for col in range(layer.cols)
             for band in range(layer.bands_per_col)]
    palette = [fmt.rgb_to_1555(i * 16, i * 16, i * 16) for i in range(16)]
    chunks, _ = fmt.pack_chunks([layer], palette, bands)
    return [bytes(chunk) for chunk in chunks]


def main():
    print("== the link and the reader, end to end ==")

    # --- hello ------------------------------------------------------------
    probe = Probe()
    hello = probe.hello()
    check("hello reports this protocol", hello["version"], PROTOCOL_VERSION)
    check("hello reports the chunk ceiling", hello["max_chunks"], 64)
    check("hello session: probe used the link correctly", probe.close(), 0)

    # --- a chunk arrives whole -------------------------------------------
    with tempfile.TemporaryDirectory() as tmp:
        chunk = bytes((i * 37 + 11) & 0xFF for i in range(4096))
        probe = Probe(save_dir=tmp)
        probe.hello()
        check("a good chunk is accepted", probe.put_chunk(5, 2, chunk), STATUS_OK)
        code = probe.close()

        stored = Path(tmp) / f"{fmt.chunk_name(5, 2)}.bin"
        check("and lands under its own name", stored.exists(), True)
        check("byte for byte, with the index and CRC stripped",
              stored.read_bytes() if stored.exists() else None, chunk)
        check("good-chunk session: probe used the link correctly", code, 0)

    # --- a chunk that does not match its checksum -------------------------
    #
    # The calculator CRCs the appvar where it lies in flash, so this covers the
    # flash write and not only the wire. It has to leave nothing behind: half a
    # strip is worse than no strip, because it looks exactly like a whole one
    # until somebody opens it.
    with tempfile.TemporaryDirectory() as tmp:
        chunk = bytes((i * 5) & 0xFF for i in range(1024))
        probe = Probe(save_dir=tmp)
        probe.hello()

        wrong = (binascii.crc32(chunk) ^ 0xFFFF) & 0xFFFFFFFF
        check("a chunk whose CRC does not match is refused",
              probe.put_chunk(9, 0, chunk, crc=wrong), STATUS_BAD_CRC)
        check("a good chunk afterwards still works",
              probe.put_chunk(10, 0, chunk), STATUS_OK)
        code = probe.close()

        check("the refused chunk left nothing behind",
              (Path(tmp) / f"{fmt.chunk_name(9, 0)}.bin").exists(), False)
        check("the good one is there", 
              (Path(tmp) / f"{fmt.chunk_name(10, 0)}.bin").exists(), True)
        check("bad-crc session: probe used the link correctly", code, 0)

    # --- does the strip actually open? ------------------------------------
    #
    # The failure this whole command exists for. Every chunk that arrives is
    # stored and acknowledged, so a strip missing one of them reports as a
    # complete success and fails only at the reader, days later.
    chunks = noisy_container()
    check("the fixture needs more than one chunk", len(chunks) > 1, True)

    probe = Probe()
    probe.hello()
    for index, chunk in enumerate(chunks[:-1]):
        probe.put_chunk(30, index, chunk)

    check("a strip missing its last chunk does not open",
          probe.verify(30), (STATUS_NOT_FOUND, 0))

    probe.put_chunk(30, len(chunks) - 1, chunks[-1])
    check("the same strip opens once it is complete",
          probe.verify(30), (STATUS_OK, len(chunks)))
    check("a slot with nothing in it does not open",
          probe.verify(31), (STATUS_NOT_FOUND, 0))
    check("verify session: probe used the link correctly", probe.close(), 0)

    # --- the header alone is not enough -----------------------------------
    #
    # Chunk 0 carries the header, so a strip that is only chunk 0 parses and
    # then fails to find chunk 1. That is the shape of an interrupted transfer.
    probe = Probe()
    probe.hello()
    probe.put_chunk(32, 0, chunks[0])
    check("chunk 0 on its own does not open a multi-chunk strip",
          probe.verify(32), (STATUS_NOT_FOUND, 0))
    check("header-only session: probe used the link correctly", probe.close(), 0)

    # --- the wallpaper is claimed by the index ----------------------------
    #
    # It is an ordinary container in a reserved slot, so getting it there needs
    # nothing new. What is new is the claim: the calculator checksums what it
    # stored and writes that into the device block, which is the only thing
    # that can say those appvars are a wallpaper. Delete the index and they are
    # so many unreadable bytes -- which is the point, since deleting the index
    # is the one way past the password.
    screen = noisy_container(height=240)

    with tempfile.TemporaryDirectory() as tmp:
        probe = Probe(save_dir=tmp)
        probe.hello()
        for index, chunk in enumerate(screen):
            probe.put_chunk(WALLPAPER_SLOT, index, chunk)

        check("a screen-sized container opens like any other",
              probe.verify(WALLPAPER_SLOT), (STATUS_OK, len(screen)))
        check("the wallpaper is claimed", probe.wallpaper(True), STATUS_OK)
        code = probe.close()

        index_bytes = (Path(tmp) / "CSLIB.bin").read_bytes()
        expected = binascii.crc32(b"".join(screen)) & 0xFFFFFFFF
        check("the claim is recorded in the device block",
              index_bytes[DEV_WALL_FLAGS] & 1, 1)
        check("with the checksum of what was actually stored",
              struct.unpack_from("<I", index_bytes, DEV_WALL_CRC)[0], expected)
        check("wallpaper session: probe used the link correctly", code, 0)

    with tempfile.TemporaryDirectory() as tmp:
        probe = Probe(save_dir=tmp)
        probe.hello()
        for index, chunk in enumerate(screen):
            probe.put_chunk(WALLPAPER_SLOT, index, chunk)
        probe.wallpaper(True)
        check("and it can be given up again", probe.wallpaper(False), STATUS_OK)
        code = probe.close()

        index_bytes = (Path(tmp) / "CSLIB.bin").read_bytes()
        check("the claim is gone", index_bytes[DEV_WALL_FLAGS] & 1, 0)
        check("and so are the appvars",
              (Path(tmp) / f"{fmt.chunk_name(WALLPAPER_SLOT, 0)}.bin").exists(), False)
        check("forget session: probe used the link correctly", code, 0)

    # Claiming a slot with nothing in it must not leave a claim pointing at
    # wreckage -- that would be a wallpaper the reader tries to draw and cannot.
    with tempfile.TemporaryDirectory() as tmp:
        probe = Probe(save_dir=tmp)
        probe.hello()
        check("claiming an empty slot fails", probe.wallpaper(True), STATUS_NOT_FOUND)
        code = probe.close()

        # Refusing must not invent an index either: with nothing to clear there
        # is nothing to write, and an index rewrite is a flash write.
        written = Path(tmp) / "CSLIB.bin"
        claimed = bool(written.read_bytes()[DEV_WALL_FLAGS] & 1) if written.exists() else False
        check("and leaves no claim behind", claimed, False)
        check("empty-claim session: probe used the link correctly", code, 0)

    # --- two updates can be armed at once ---------------------------------
    #
    # The reader and the lock screen are separate images and prgmCSUP installs
    # both. They used to share one manifest and one set of chunk appvars, so a
    # sync carrying both would have had the second quietly sweep away the
    # first -- and the calculator would have reported an update as armed that
    # was no longer there.
    reader = bytes((i * 3 + 1) & 0xFF for i in range(600))
    lockscreen = bytes((i * 11 + 7) & 0xFF for i in range(400))

    with tempfile.TemporaryDirectory() as tmp:
        probe = Probe(save_dir=tmp)
        probe.hello()

        check("a reader update is accepted",
              probe.push_update(TARGET_READER, 41, reader), STATUS_OK)
        check("and a lock screen update alongside it",
              probe.push_update(TARGET_LOCK, 42, lockscreen), STATUS_OK)

        hello = probe.hello()
        check("hello reports the reader armed", hello["armed_build"], 41)
        check("and the lock screen armed", hello["lock_build"], 42)
        check("with both flags set", hello["flags"] & 0x06, 0x06)
        code = probe.close()

        # Separate manifests and separate chunks, or one would have eaten the
        # other. CSUPD0/CSU0xx is the reader, CSUPD2/CSU2xx the lock screen.
        for name in ("CSUPD0.bin", "CSU000.bin", "CSUPD2.bin", "CSU200.bin"):
            check(f"{name} is there", (Path(tmp) / name).exists(), True)
        check("the reader image is stored whole",
              (Path(tmp) / "CSU000.bin").read_bytes(), reader)
        check("and so is the lock screen's",
              (Path(tmp) / "CSU200.bin").read_bytes(), lockscreen)
        check("two-target session: probe used the link correctly", code, 0)

    print(f"{checks - failures}/{checks} link/reader checks pass")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
