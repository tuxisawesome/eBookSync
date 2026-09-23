#!/usr/bin/env python3
"""Drive the reader's real strip viewer over real strips.

tools/hosttest/viewer_probe links calc/src/viewer.c with the renderer and the
index and feeds it scripted keys; this checks what it saved and how it ended.
The strip under test is stitched from three images of different shapes, one of
them shorter than the screen -- the same folder check.py builds -- followed in
its book by an ordinary strip.

What has to hold:

  * holding down scrolls to the end of an image and stops there; only a fresh
    press goes on to the next one, and at the end of the last image it goes on
    to the next strip of the book
  * 2 and enter page down a screen at a time, 8 pages up, and up at the top of
    an image goes back to the bottom of the one before
  * alpha bookmarks the strip, and what the viewer saves carries the bookmark
    and records the strip as the one last read

    tools/hosttest/check_viewer.py
"""

import os
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
sys.path.insert(0, str(HERE))

from csx import format as fmt, library as lib, strip as strip_mod, tifile   # noqa: E402
from check import make_folder_strip   # noqa: E402

SCREEN_H = 240
PROMPT = 20          # the bar at the end of an image, scrolled past rather than over
PAGE = SCREEN_H - 32

failures = []
checks = 0


class StubRenderer:
    """Stands in for the title renderer so this needs no fonts."""

    def render(self, text, max_width):
        width = min(max_width, max(1, len(text) * 13))
        stride = (width + 3) // 4
        return width, 16, bytes((i * 7 + len(text)) & 0xFF for i in range(stride * 16))


def build_library(directory, source, pos=0, layer=0, bookmarked=False):
    folder = make_folder_strip(Path(source), directory / "episode")
    episode = strip_mod.convert(folder, preset="fit+1.5x")
    single = strip_mod.convert(Path(source), preset="fit")
    for slot, result in ((0, episode), (1, single)):
        for index, chunk in enumerate(result.chunks):
            name = fmt.chunk_name(slot, index)
            (directory / f"{name}.8xv").write_bytes(tifile.write(name, chunk))

    books = [lib.Book("第一本书", [
        lib.Strip("第1话", 0, len(episode.chunks), episode.total_bytes,
                  pos=pos, layer=layer, bookmarked=bookmarked),
        lib.Strip("第2话", 1, len(single.chunks), single.total_bytes),
    ])]
    index = lib.build(books, renderer=StubRenderer())
    (directory / f"{lib.NAME}.8xv").write_bytes(tifile.write(lib.NAME, index))
    return episode, single


def run(directory, strip, keys):
    env = dict(os.environ, SHIM_TEXT="1")
    result = subprocess.run([str(HERE / "viewer_probe"), "--lib", str(directory),
                             str(strip)] + keys, capture_output=True, text=True, env=env)
    if result.returncode != 0:
        sys.exit(result.stderr or f"viewer_probe exited {result.returncode}")

    out = {"text": []}
    for line in result.stdout.splitlines():
        if line.startswith("text "):
            out["text"].append(line.split(" ", 2)[2])
        elif line.startswith("result "):
            out["result"] = line.split()[1]
        elif line.startswith("saved "):
            words = line.split()
            out.update(pos=int(words[2]), layer=int(words[4]),
                       read=int(words[6]), bookmark=int(words[8]))
        elif line.startswith("last "):
            value = line.split()[1]
            out["last"] = None if value == "none" else int(value)
    return out


def check(label, got, **expect):
    global checks
    checks += 1
    wrong = {k: (got.get(k), v) for k, v in expect.items() if got.get(k) != v}
    if wrong:
        failures.append(f"{label}: " + ", ".join(f"{k}={g!r}, want {v!r}"
                                                 for k, (g, v) in wrong.items()))


def check_text(label, got, text, present=True):
    global checks
    checks += 1
    shown = any(text in line for line in got["text"])
    if shown != present:
        failures.append(f"{label}: \"{text}\" {'never' if present else 'was'} drawn")


# A fresh press needs the key to go down after a quiet frame or two.
def press(key, frames=3):
    return [f"{key}:{frames}", "idle:3"]


# Long enough to scroll the whole of any image here. A held arrow moves 26 rows
# every fourth frame once it is up to speed -- about 6.5 rows a frame -- and the
# longest image is some 3,300 rows.
HOLD_DOWN = ["down:700", "idle:3"]


def main():
    with tempfile.TemporaryDirectory() as tmp:
        directory = Path(tmp)
        episode, _ = build_library(directory, "assets/strip1.jpg")
        tops = [part[0] for part in episode.parts]
        height = episode.layers[0].height
        bottoms = tops[1:] + [height]

        # The end of each image, as the viewer is allowed to scroll to it.
        def part_end(p):
            span = bottoms[p] + PROMPT - tops[p]
            return bottoms[p] + PROMPT - SCREEN_H if span > SCREEN_H else tops[p]

        print(f"episode: {len(tops)} images starting on rows {tops} of {height}; "
              f"ends at {[part_end(p) for p in range(len(tops))]}")
        if part_end(1) != tops[1]:
            sys.exit("the test strip's middle image should be shorter than the screen")

        got = run(directory, 0, HOLD_DOWN)
        check("holding down stops at the end of the first image", got,
              pos=part_end(0), result="back")
        check_text("the bar says what comes next", got, "Part 2 of 3")

        got = run(directory, 0, HOLD_DOWN + press("down"))
        check("a fresh press at the end goes on to the second image", got, pos=tops[1])

        got = run(directory, 0, ["down:700"] + ["down:40"])
        check("a key held through the end does not go on", got, pos=part_end(0))

        got = run(directory, 0, press("2"))
        check("2 pages down a screen", got, pos=PAGE)
        got = run(directory, 0, press("enter") + press("enter"))
        check("enter pages down too", got, pos=2 * PAGE)
        got = run(directory, 0, press("2") * 3)
        check("paging stops at the end of the image", got, pos=min(3 * PAGE, part_end(0)))
        got = run(directory, 0, press("2") * 4)
        check("and the next page goes on to the next image", got, pos=tops[1])
        got = run(directory, 0, press("2") * 2 + press("8"))
        check("8 pages up", got, pos=PAGE)

        got = run(directory, 0, HOLD_DOWN + press("down") + press("8"))
        check("8 at the top of an image goes back to the end of the last", got,
              pos=part_end(0))
        got = run(directory, 0, HOLD_DOWN + press("down") + press("up"))
        check("and so does up", got, pos=part_end(0))

        got = run(directory, 0, HOLD_DOWN + press("down"))
        check_text("a short image is already at its end, and says what is next",
                   got, "Part 3 of 3")

        through = HOLD_DOWN + press("down") + press("down") + HOLD_DOWN
        got = run(directory, 0, through)
        check("the last image ends at the end of the strip", got, pos=part_end(2))
        check_text("and offers the next strip", got, "Next:")

        got = run(directory, 0, through + press("down"))
        # Finished, so read -- and so nothing to Continue from until the next
        # strip is opened and records itself.
        check("pressing on past the last image opens the next strip", got,
              result="next", read=1, pos=0, last=None)

        got = run(directory, 1, ["down:1000", "idle:3"] + press("down"))
        check("the last strip of a book has nowhere to go", got, result="back", read=1)
        check_text("and says so", got, "End of book")

        got = run(directory, 0, press("alpha"))
        check("alpha bookmarks the strip", got, bookmark=1, last=0)
        got = run(directory, 0, press("alpha") + press("alpha"))
        check("and alpha again takes it off", got, bookmark=0)

        got = run(directory, 0, HOLD_DOWN + press("add"))
        check("zooming stays in the same image", got, layer=1)
        if got["pos"] > episode.parts[1][1] + PROMPT - SCREEN_H:
            failures.append(f"zoomed view left the first image: pos {got['pos']}")

    with tempfile.TemporaryDirectory() as tmp:
        directory = Path(tmp)
        episode, _ = build_library(directory, "assets/strip1.jpg",
                                   pos=episode.parts[1][0] + 60, bookmarked=True)
        got = run(directory, 0, [])
        check("a saved place inside a short image opens at its top", got,
              pos=episode.parts[1][0], bookmark=1)

    with tempfile.TemporaryDirectory() as tmp:
        directory = Path(tmp)
        build_library(directory, "assets/strip1.jpg", pos=1500)
        got = run(directory, 0, [])
        check("a saved place in the last image is kept", got, pos=1500)

    for failure in failures:
        print(f"FAIL {failure}")
    print(f"{checks - len(failures)}/{checks} viewer checks pass")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
