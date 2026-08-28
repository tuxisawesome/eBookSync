"""Reading and writing TI-84 Plus CE appvar files (.8xv).

Used to get converted strips into CEmu or onto a calculator with TI Connect CE
without going through the WebUSB sync path -- handy while developing the reader.

Layout:
    0   8   "**TI83F*"
    8   3   1A 0A 00
    11  42  comment
    53  2   data section length
    55  ..  data section
    ..  2   checksum: sum of the data section bytes, mod 65536

Each data section entry:
    2   header length (always 13)
    2   variable data length
    1   type id (0x15 = appvar)
    8   name, NUL padded
    1   version
    1   archive flag (0x80 = archived)
    2   variable data length again
    ..  variable data: a 2-byte payload length followed by the payload
"""

import struct

SIGNATURE = b"**TI83F*\x1a\x0a\x00"
TYPE_APPVAR = 0x15
DEFAULT_COMMENT = b"eOS"

# A variable's length field is 16 bit, so no single appvar can exceed this.
MAX_VAR_SIZE = 0xFFFF - 2


def encode_name(name):
    raw = name.encode("ascii")
    if not 1 <= len(raw) <= 8:
        raise ValueError(f"appvar name {name!r} must be 1-8 characters")
    if not all(c in b"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" for c in raw):
        raise ValueError(f"appvar name {name!r} must be uppercase letters and digits")
    if raw[0:1].isdigit():
        raise ValueError(f"appvar name {name!r} must not start with a digit")
    return raw.ljust(8, b"\x00")


def write(name, payload, archived=True, comment=DEFAULT_COMMENT):
    """Build the bytes of a .8xv file holding `payload`."""
    if len(payload) > MAX_VAR_SIZE:
        raise ValueError(
            f"{len(payload)} bytes exceeds the {MAX_VAR_SIZE} byte appvar limit"
        )
    var_data = struct.pack("<H", len(payload)) + bytes(payload)
    entry = (struct.pack("<HH", 13, len(var_data))
             + bytes([TYPE_APPVAR])
             + encode_name(name)
             + bytes([0, 0x80 if archived else 0x00])
             + struct.pack("<H", len(var_data))
             + var_data)
    checksum = sum(entry) & 0xFFFF
    return (SIGNATURE
            + comment[:42].ljust(42, b"\x00")
            + struct.pack("<H", len(entry))
            + entry
            + struct.pack("<H", checksum))


def read(blob):
    """Parse a .8xv file, returning (name, payload). Raises on a bad checksum."""
    if not blob.startswith(SIGNATURE):
        raise ValueError("not a TI-83F variable file")
    (section_len,) = struct.unpack_from("<H", blob, 53)
    entry = blob[55:55 + section_len]
    (stored,) = struct.unpack_from("<H", blob, 55 + section_len)
    if stored != (sum(entry) & 0xFFFF):
        raise ValueError("checksum mismatch")
    header_len, data_len = struct.unpack_from("<HH", entry, 0)
    name = entry[5:13].rstrip(b"\x00").decode("ascii")
    var_data = entry[2 + header_len + 2:2 + header_len + 2 + data_len]
    (payload_len,) = struct.unpack_from("<H", var_data, 0)
    return name, var_data[2:2 + payload_len]
