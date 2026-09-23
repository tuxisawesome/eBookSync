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

import os
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


def run(keys, directory=None, env=None):
    command = [str(HERE / "ui_probe")]
    if directory:
        command += ["--lib", str(directory)]
    command += keys
    result = subprocess.run(command, capture_output=True, text=True,
                            env=dict(os.environ, **(env or {})))
    return result.returncode, result.stdout


def check(label, keys, expect_status, expect_output=None, directory=None, env=None):
    global checks
    checks += 1
    status, output = run(keys, directory, env)

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

check("empty library, sync is still reachable under mode",
      LEAD + press("mode") + press("enter"), RUNNING, expect_output="sync")

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

    check("library, sync is reachable under mode",
          LEAD + press("mode") + press("enter"), RUNNING, expect_output="sync",
          directory=directory)



# --- continue, bookmarks, and where a book opens ---------------------------
def reading_library(directory, strips, last_slot=None):
    """One book of `strips`, each (read, bookmarked), in slots 0, 1, 2..."""
    books = [lib.Book("第一本书", [
        lib.Strip(f"{i + 1:03} - 标题", i, 9, 140_000, read=read, bookmarked=marked)
        for i, (read, marked) in enumerate(strips)
    ]), lib.Book("Another Book", [lib.Strip("01", len(strips), 9, 90_000)])]
    index = lib.build(books, renderer=StubRenderer())
    if last_slot is not None:
        index = lib.set_last_slot(index, last_slot)
    (directory / f"{lib.NAME}.8xv").write_bytes(tifile.write(lib.NAME, index))


TEXT = {"SHIM_TEXT": "1"}

with tempfile.TemporaryDirectory() as tmp:
    directory = Path(tmp)

    reading_library(directory, [(True, False), (True, False), (False, False)])
    check("a book opens on its first unread strip",
          LEAD + press("enter") + press("enter"), RUNNING,
          expect_output="viewer 2", directory=directory)

    reading_library(directory, [(False, False)] * 3)
    check("with no Continue or Bookmarks, the first row is still the first book",
          LEAD + press("enter") + press("enter"), RUNNING,
          expect_output="viewer 0", directory=directory)

    check("pressing on past the end of a strip opens the next one",
          LEAD + press("enter") + press("enter"), RUNNING,
          expect_output="viewer 0\nviewer 1\nviewer 2", directory=directory,
          env={"PROBE_VIEW_NEXT": "2"})

    reading_library(directory, [(False, False)] * 3, last_slot=1)
    check("Continue is the first row and opens the strip last read",
          LEAD + press("enter"), RUNNING, expect_output="viewer 1", directory=directory)
    check("Continue is labelled", LEAD, RUNNING, expect_output="Continue",
          directory=directory, env=TEXT)
    check("and the books follow it",
          LEAD + press("down") + press("enter") + press("enter"), RUNNING,
          expect_output="viewer 0", directory=directory)

    # Finished is finished: once the last-read strip is read, no Continue.
    reading_library(directory, [(False, False), (True, False), (False, False)], last_slot=1)
    status, output = run(LEAD, directory, TEXT)
    checks += 1
    if "Continue" in output:
        failures.append("a last-read strip that has been read still offered Continue")

    # del on Continue dismisses it: the first row is the first book again.
    reading_library(directory, [(False, False)] * 3, last_slot=1)
    check("del on Continue dismisses it",
          LEAD + press("del") + press("enter") + press("enter"), RUNNING,
          expect_output="viewer 0", directory=directory)
    status, output = run(LEAD + press("del") + press("clear") + ["idle:5"], directory, TEXT)
    checks += 1
    if output.count("Continue") != 1:
        failures.append(f"Continue was drawn {output.count('Continue')} times; want once, before del")

    reading_library(directory, [(False, False)] * 3, last_slot=40)
    status, output = run(LEAD, directory, TEXT)
    checks += 1
    if "Continue" in output:
        failures.append("a last-read slot that is not on the calculator still offered Continue")

    reading_library(directory, [(False, False), (False, True), (False, True)])
    check("Bookmarks is listed with its count",
          LEAD, RUNNING, expect_output="Bookmarks (2)", directory=directory, env=TEXT)
    check("Bookmarks lists the bookmarked strips",
          LEAD + press("enter") + press("down") + press("enter"), RUNNING,
          expect_output="viewer 2", directory=directory)

    # Once the list closes, Bookmarks is gone from the book list, so the row
    # the user was on is now the first book.
    check("alpha in Bookmarks takes one off, and the list closes when empty",
          LEAD + press("enter") + press("alpha") + press("alpha")
          + press("enter") + press("enter"),
          RUNNING, expect_output="viewer 0", directory=directory)

    reading_library(directory, [(False, False)] * 3)
    check("alpha on a strip bookmarks it, and Bookmarks appears",
          LEAD + press("enter") + press("down") + press("alpha") + press("clear")
          + press("enter") + press("enter"),
          RUNNING, expect_output="viewer 1", directory=directory)

    reading_library(directory, [(False, True), (False, False), (False, False)])
    check("marking a whole book read keeps its bookmarks",
          LEAD + press("down") + press("del") + press("up") + press("enter")
          + press("enter"),
          RUNNING, expect_output="viewer 0", directory=directory)

    # The header: battery gauge and free archive, from the shim's archive.
    check("the book list shows the free archive", LEAD, RUNNING,
          expect_output="M free", directory=directory, env=TEXT)


# --- the theme, and the sync screen ----------------------------------------
def screen_pixel(keys, directory, x, y):
    """The colour at (x, y) of the last frame shown, via the shim's screenshot."""
    with tempfile.TemporaryDirectory() as shots:
        path = Path(shots) / "frame.ppm"
        run(keys, directory, {"SHIM_SCREEN": str(path)})
        data = path.read_bytes()
        # "P6\n320 240\n255\n" then RGB.
        header = data.index(b"255\n") + 4
        at = header + (y * 320 + x) * 3
        return tuple(data[at:at + 3])


def themed_library(directory, theme):
    reading_library(directory, [(False, False)] * 3)
    index = bytearray(tifile.read((directory / f"{lib.NAME}.8xv").read_bytes())[1])
    index[lib.DEVICE_OFFSET + 61] = theme
    (directory / f"{lib.NAME}.8xv").write_bytes(tifile.write(lib.NAME, bytes(index)))


def near(colour, want, slack=8):
    return all(abs(a - b) <= slack for a, b in zip(colour, want))


with tempfile.TemporaryDirectory() as tmp:
    directory = Path(tmp)

    # An empty stretch of the book list, below the last row: the background.
    DARK_BG, LIGHT_BG = (0x16, 0x12, 0x1f), (0xf8, 0xf6, 0xfc)
    themed_library(directory, 0)
    checks += 1
    got = screen_pixel(LEAD, directory, 160, 190)
    if not near(got, DARK_BG):
        failures.append(f"an index with no theme recorded is Dark: background {got}")

    themed_library(directory, 1)
    checks += 1
    got = screen_pixel(LEAD, directory, 160, 190)
    if not near(got, LIGHT_BG):
        failures.append(f"an index saying Light opens Light: background {got}")

    check("Settings says which theme it is", LEAD + press("mode"), RUNNING,
          expect_output="Light", directory=directory, env=TEXT)

    themed_library(directory, 0)
    checks += 1
    got = screen_pixel(LEAD + press("mode") + press("down") + press("enter"), directory, 160, 225)
    status, output = run(LEAD + press("mode") + press("down") + press("enter"), directory, TEXT)
    if "Light" not in output:
        failures.append("enter on Theme did not switch to Light")
    if near(got, (0x24, 0x1d, 0x35)):
        failures.append(f"switching to Light did not repaint in it: footer {got}")

    # The sync screen is drawn, in the reader's own font, not typed on the
    # homescreen.
    check("the sync screen is drawn, with its own key hint", LEAD + press("mode") + press("enter"),
          RUNNING, expect_output="Stop syncing", directory=directory, env=TEXT)
    check("and says what to do next", LEAD + press("mode") + press("enter"),
          RUNNING, expect_output="Press Connect calculator on the sync page",
          directory=directory, env=TEXT)
    status, output = run(LEAD + press("mode") + press("enter"), directory, TEXT)
    checks += 1
    if "Different library" in output or "[clear] stop syncing" in output:
        failures.append("the sync screen still wrote homescreen text")


# --- the lock screen -------------------------------------------------------
# The password is in the library index (see docs/FORMAT.md), so a locked
# calculator is one whose index has a device block filled in. Three wrong
# answers close the reader; the right one gets through to the book list.
def locked_library(directory, password, failures_so_far=0):
    books = [lib.Book("第一本书", [lib.Strip("001 - 标题", 0, 9, 140_000)])]
    index = lib.build(books, renderer=StubRenderer())
    index = lib.set_password(index, password, failures=failures_so_far)
    (directory / f"{lib.NAME}.8xv").write_bytes(tifile.write(lib.NAME, index))


# The wallpaper and the clock come up first and any key brings up the prompt, so
# every password entry starts with a keypress that is spent on that. 2nd rather
# than clear: clear at the prompt means "give up".
WAKE = press("2nd")


# keyin.c reads the letters printed on the keys, so a numeric password is typed
# with the digit keys and needs no mode changes.
def type_password(digits):
    keys = list(WAKE)
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
          LEAD + WAKE + press("clear"), CLOSED, directory=directory)

    # And the key that brings the prompt up is spent doing that: it must not
    # also count as an answer, or the wake screen would burn a try.
    check("the key that dismisses the wallpaper is not an answer",
          LEAD + WAKE, RUNNING, directory=directory)

    check("locked, the book list is not reachable without the password",
          LEAD + WAKE + press("2nd") + press("2nd"), RUNNING,
          directory=directory)

    check("and neither is the sync screen",
          LEAD + WAKE + press("mode") + press("enter"), RUNNING,
          directory=directory)

    # Nothing typed before the password is right must reach the menus: the sync
    # screen in particular, since that is a way to move comics off the device.
    status, output = run(LEAD + WAKE + press("2nd") + press("2nd"), directory)
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

# --- 2nd+ON locks, wherever you are ----------------------------------------
#
# The lock is not the gate on the way in: it can be reached from anywhere in the
# reader, it blanks the screen the way the operating system's own power gesture
# does, and three wrong answers put it back to sleep still locked rather than
# closing the app. That last part is the difference between a lock and a speed
# bump, and it is the thing worth having a test for -- a lock that quietly let
# go after three tries would look identical from the outside.
with tempfile.TemporaryDirectory() as tmp:
    directory = Path(tmp)
    locked_library(directory, "1234")

    # Past the gate first, then lock from the book list. Waking needs ON, which
    # the script carries in the group the key matrix does not use.
    unlocked = LEAD + type_password("1234")

    check("2nd+ON from the book list locks, and the password gets back in",
          unlocked + press("2nd+on") + press("on") + type_password("1234"),
          RUNNING, directory=directory)

    # Not just a dark screen: the reader hands the power-down to the operating
    # system's own APD, which on hardware is a real suspend that resumes this
    # program. "apd 1" is the probe reporting that the flag was set.
    check("locking really asks the OS to power the calculator down",
          unlocked + press("2nd+on") + press("on") + type_password("1234"),
          RUNNING, expect_output="apd 1", directory=directory)

    check("and nothing else does",
          unlocked + press("mode"), RUNNING, expect_output="apd 0",
          directory=directory)

    check("the wrong password does not get back in",
          unlocked + press("2nd+on") + press("on") + type_password("9999"),
          RUNNING, directory=directory)

    # The whole point: out of tries, it sleeps again rather than closing. The
    # app is still running, and the script has run out with nobody let in.
    locked_out = list(unlocked) + press("2nd+on") + press("on")
    for _ in range(3):
        locked_out += type_password("9999") + press("enter")
    check("three wrong answers leave it locked rather than closing the app",
          locked_out, RUNNING, directory=directory)

    # And it must not be possible to walk away from the lock screen the way you
    # can walk away from the gate: clear closes the app at startup, and must not
    # here, because the screen behind it is the library.
    check("clear does not dismiss the lock",
          unlocked + press("2nd+on") + press("on") + WAKE + press("clear")
          + press("clear") + press("clear") + press("clear"),
          RUNNING, directory=directory)

    # The strip list and the viewer scan the keypad through their own loops, so
    # each is its own chance to have missed the hook.
    check("2nd+ON locks from inside a book too",
          unlocked + press("enter") + press("2nd+on") + press("on")
          + type_password("1234"),
          RUNNING, directory=directory)

with tempfile.TemporaryDirectory() as tmp:
    directory = Path(tmp)
    library_with_content(directory)

    # With no password there is nothing to ask for, so it is a screen blanker:
    # any key brings it back. The key that dismisses it is spent doing that --
    # so the first clear returns to the book list and the second closes the app,
    # which is also the proof that the reader is really back where it was.
    check("with no password set, 2nd+ON blanks and any key returns",
          LEAD + press("2nd+on") + press("on") + press("clear") + press("clear"),
          CLOSED, directory=directory)

    check("and the key that dismisses it does not also act",
          LEAD + press("2nd+on") + press("on") + press("clear"),
          RUNNING, directory=directory)

# --- the ON latch is handed back on the way out -----------------------------
#
# It has to be enabled before kb_On reports anything -- not doing that is why
# 2nd+ON could never fire -- but keypadc's header warns it persists between
# program runs. Enabling it and walking away leaves the operating system's own
# ON handling sitting underneath the reader's.
check("quitting hands the ON latch back", LEAD + press("clear"), CLOSED,
      expect_output="on latch released")


# --- the lock screen must not ask the heap for anything ---------------------
#
# render_init() takes the band cache by calling malloc until it is refused, so
# by the time a menu is on screen there is no heap left. wall_draw() used to ask
# for five kilobytes to decompress into, got nothing, gave up, and let the lock
# screen fall back to a flat fill -- which looks exactly like a wallpaper that
# is one colour, with a clock on top. It went unnoticed because the fallback is
# indistinguishable from success.
#
# Read from the source rather than measured, which is weaker than it sounds
# only because the honest behavioural version -- exhaust the heap, then draw --
# cannot be run on a host whose heap is not finite.
checks += 1
wall = (HERE.parent.parent / "calc" / "src" / "wall.c").read_text()
if "malloc(" in wall:
    failures.append("wall.c allocates; the band cache will have taken the heap first")

for failure in failures:
    print("  FAIL " + failure)
print(f"{checks - len(failures)}/{checks} reader UI checks pass")
sys.exit(1 if failures else 0)
