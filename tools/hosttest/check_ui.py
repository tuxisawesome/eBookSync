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
    (directory / "CSLIB.8xv").write_bytes(tifile.write(lib.NAME, index))


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

for failure in failures:
    print("  FAIL " + failure)
print(f"{checks - len(failures)}/{checks} reader UI checks pass")
sys.exit(1 if failures else 0)
