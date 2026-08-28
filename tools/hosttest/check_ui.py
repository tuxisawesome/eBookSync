#!/usr/bin/env python3
"""Drive the reader's menu loop and check which keys do what.

This exists because of a bug that made the reader unusable: with nothing synced
yet -- every calculator, before its first sync -- pressing any key closed the
app. Worse, the sync screen is reached with 2nd from the book menu, so quitting
before showing that menu meant no comic could ever arrive.

tools/hosttest/ui_probe links the real calc/src/main.c, ui.c, input.c and
library.c against the shim and feeds them scripted keypresses, so "the app
closed" is observable without a calculator.

    tools/hosttest/check_ui.py
"""

import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from csx import library as lib, tifile   # noqa: E402

CLOSED = 0          # main() returned
RUNNING = 7         # still going when the script ran out; see shim/keys.h

failures = []
checks = 0


class StubRenderer:
    """Stands in for the title renderer so this needs no fonts."""

    def render(self, text, max_width):
        width = min(max_width, max(1, len(text) * 13))
        height = 16
        stride = (width + 3) // 4
        return width, height, bytes((i * 7 + len(text)) & 0xFF for i in range(stride * height))


def library_with_content(directory):
    books = [lib.Book("第一本书", [
        lib.Strip("001 - 标题", 0, 9, 140_000),
        lib.Strip("002 - 标题", 1, 9, 141_000),
    ])]
    index = lib.build(books, renderer=StubRenderer())
    (directory / f"{lib.NAME}.8xv").write_bytes(tifile.write(lib.NAME, index))


def run(keys, directory=None):
    command = [str(HERE / "ui_probe")]
    if directory:
        command += ["--lib", str(directory)]
    command += keys
    result = subprocess.run(command, capture_output=True, text=True)
    return result.returncode, result.stdout


def check(label, keys, expect_status, expect_output=None, directory=None):
    global checks
    checks += 1
    status, output = run(keys, directory)

    problems = []
    if status != expect_status:
        problems.append(
            f"exit {status} ({describe(status)}), expected {expect_status} ({describe(expect_status)})"
        )
    if expect_output and expect_output not in output:
        problems.append(f'output missing "{expect_output}" (got {output.strip()!r})')
    if problems:
        failures.append(f"{label}: " + "; ".join(problems))


def describe(status):
    return {CLOSED: "app closed", RUNNING: "still running"}.get(status, "error")


# A press the reader can see needs the key to go down after a quiet moment:
# input_reset() deliberately treats whatever is held at startup as already down,
# so the enter that launched the program is not read as a fresh press.
def press(key, frames=20):
    return [f"{key}:{frames}", f"idle:{frames}"]


LEAD = ["idle:5"]

# --- the reported bug: an empty calculator must survive a keypress ----------
for key in ("down", "up", "enter", "left", "right", "del", "add", "sub", "mode"):
    check(f"empty library, {key} does not close the app",
          LEAD + press(key), RUNNING)

check("empty library, several keys in a row do not close the app",
      LEAD + press("down") + press("enter") + press("up") + press("del"), RUNNING)

# --- but the deliberate ways out still work --------------------------------
check("empty library, clear closes the app", LEAD + press("clear"), CLOSED)

check("empty library, 2nd still reaches the sync screen",
      LEAD + press("2nd"), RUNNING, expect_output="sync")

# --- the key that launched the program is not a press ----------------------
# enter is held from the very first frame, as it is when the program starts from
# the homescreen. It must not count as pressing enter on the book list.
check("enter held at launch does not act",
      ["enter:40", "idle:40"], RUNNING)

check("enter held at launch, then a real press, does act",
      ["enter:40"] + ["idle:20"] + press("clear"), CLOSED)

# --- with a library, the menus work ----------------------------------------
with tempfile.TemporaryDirectory() as tmp:
    directory = Path(tmp)
    library_with_content(directory)

    check("library, enter opens a book and a strip",
          LEAD + press("enter") + press("enter"), RUNNING,
          expect_output="viewer 0", directory=directory)

    check("library, down then enter opens the second strip",
          LEAD + press("enter") + press("down") + press("enter"), RUNNING,
          expect_output="viewer 1", directory=directory)

    check("library, clear backs out of a book and then closes the app",
          LEAD + press("enter") + press("clear") + press("clear"), CLOSED,
          directory=directory)

    check("library, 2nd reaches the sync screen",
          LEAD + press("2nd"), RUNNING, expect_output="sync", directory=directory)

    # y= opens chat. With nothing synced it says so rather than closing, which
    # is the same bug class as the empty book list this file exists for.
    check("library, y= opens chat and clear comes back",
          LEAD + press("yequ") + press("clear"), RUNNING, directory=directory)

check("empty library, y= opens chat without closing the app",
      LEAD + press("yequ"), RUNNING)

check("empty library, y= then clear returns to the book list",
      LEAD + press("yequ") + press("clear") + press("clear"), CLOSED)

# --- the chat screens, with something queued -------------------------------
# A message typed on the calculator sits in the outbox until a sync carries it
# away. The reader has to draw it in the meantime, so it is worth checking that
# the screens survive that state rather than only the empty one.
def seed_chat(directory, queued=()):
    """Drive chat_probe to lay out the appvars, then wrap them as .8xv."""
    table = directory / "table.bin"
    table.write_bytes(pack_table([(3, "Study group"), (9, "sam")]))

    command = [str(HERE / "chat_probe"), str(directory), "table", str(table)]
    for conversation, body in queued:
        command += ["send", str(conversation), body]
    command += ["save"]
    subprocess.run(command, capture_output=True, check=True)

    for name in ("EOSCHT", "EOSOUT"):
        raw = directory / f"{name}.bin"
        if raw.exists():
            (directory / f"{name}.8xv").write_bytes(tifile.write(name, raw.read_bytes()))


def pack_table(conversations):
    """The conversation table, as web/js/chatwire.js writes it."""
    import struct
    out = bytearray(b"ECH1" + bytes([1, len(conversations)]) + bytes(6))
    for identifier, name in conversations:
        out += struct.pack("<HIH", identifier, 0, 0)
        out += name.encode()[:16].ljust(16, b"\0")
    return bytes(out)


with tempfile.TemporaryDirectory() as tmp:
    directory = Path(tmp)
    library_with_content(directory)
    seed_chat(directory, queued=[(3, "typed on the calculator")])

    check("chat opens with a message waiting",
          LEAD + press("yequ"), RUNNING, directory=directory)

    check("and the conversation can be opened and left",
          LEAD + press("yequ") + press("enter") + press("clear") + press("clear"),
          RUNNING, directory=directory)

    check("scrolling a thread with a queued message does not close the app",
          LEAD + press("yequ") + press("enter") + press("up") + press("down"),
          RUNNING, directory=directory)

    check("and clear all the way out still quits",
          LEAD + press("yequ") + press("enter") + press("clear") + press("clear")
          + press("clear"), CLOSED, directory=directory)

# --- the lock screen -------------------------------------------------------
# The password is in the library index (see docs/FORMAT.md), so a locked
# calculator is one whose index has a device block filled in. Three wrong
# answers close the reader; the right one gets through to the book list.
def locked_library(directory, password, failures_so_far=0):
    books = [lib.Book("第一本书", [lib.Strip("001 - 标题", 0, 9, 140_000)])]
    index = lib.build(books, renderer=StubRenderer())
    index = lib.set_password(index, password, failures=failures_so_far)
    (directory / f"{lib.NAME}.8xv").write_bytes(tifile.write(lib.NAME, index))


# keyin.c reads the letters printed on the keys, so a numeric password is typed
# with the digit keys and needs no mode changes.
def type_password(digits):
    keys = []
    for digit in digits:
        keys += press(digit)
    return keys + press("enter")


with tempfile.TemporaryDirectory() as tmp:
    directory = Path(tmp)
    locked_library(directory, "1234")

    check("locked, the right password gets in",
          LEAD + type_password("1234"), RUNNING, directory=directory)

    check("locked, one wrong password does not close the app",
          LEAD + type_password("9999") + press("enter"), RUNNING, directory=directory)

    # Three wrong answers, each followed by the keypress that dismisses the
    # "wrong password" message.
    wrong = list(LEAD)   # a copy: += on a list mutates it in place
    for _ in range(3):
        wrong += type_password("9999") + press("enter")
    check("locked, three wrong passwords close the app", wrong, CLOSED, directory=directory)

    check("locked, clear at the prompt closes the app",
          LEAD + press("clear"), CLOSED, directory=directory)

    check("locked, the book list is not reachable without the password",
          LEAD + press("2nd") + press("2nd"), RUNNING,
          directory=directory)

    # Nothing typed before the password is right must reach the menus: the sync
    # screen in particular, since that is a way to move comics off the device.
    status, output = run(LEAD + press("2nd") + press("2nd"), directory)
    checks += 1
    if "sync" in output:
        failures.append("locked: 2nd reached the sync screen before the password")

with tempfile.TemporaryDirectory() as tmp:
    directory = Path(tmp)
    locked_library(directory, "1234", failures_so_far=4)

    # A previous failed attempt is reported to whoever does get in -- that is
    # what the counter is for, since it cannot rate-limit anything.
    check("locked, a good password after earlier failures still gets in",
          LEAD + type_password("1234") + press("enter"), RUNNING, directory=directory)

for failure in failures:
    print("  FAIL " + failure)
print(f"{checks - len(failures)}/{checks} reader UI checks pass")
sys.exit(1 if failures else 0)
