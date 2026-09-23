"""Shared plumbing for the host tests: pick viewports, run the probe, diff frames."""

import subprocess
import sys

SCREEN_W, SCREEN_H = 320, 240

# What render.h clears the screen to before drawing a viewport.
UI_BG = 200


def viewports_for(layers):
    """Viewports worth checking: origins, band and column boundaries, and edges.

    The interesting cases are all about clipping -- a scroll position that lands
    inside a band, one that straddles two columns, and the last row and column
    where the final band and column are short.
    """
    out = []
    for index, layer in enumerate(layers):
        max_x = max(0, layer.width - SCREEN_W)
        max_y = max(0, layer.height - SCREEN_H)
        candidates = [
            (0, 0), (0, 17), (0, 32), (0, 33), (0, max_y // 2), (0, max_y),
            (max_x, 0), (max_x, max_y), (max_x // 2, 1000), (max_x // 3, 2049),
            (max_x, max_y // 3), (1 if max_x else 0, 31),
        ]
        for vx, vy in candidates:
            out.append((index, min(vx, max_x), min(vy, max_y)))
    return out


def part_viewports(layers, parts):
    """Viewports that stop at a part's end, the way the reader draws them.

    For each part in each layer: its top, the last position before its end, and
    one that sits past its end so the limit has to blank the rest of the screen
    -- which is what the reader shows under a short image.
    """
    out = []
    for li, layer in enumerate(layers):
        for p, tops in enumerate(parts):
            top = tops[li]
            bottom = parts[p + 1][li] if p + 1 < len(parts) else layer.height
            last = max(top, bottom - SCREEN_H)
            for vy in {top, last, max(top, bottom - SCREEN_H // 3)}:
                out.append((li, 0, min(vy, max(0, layer.height - 1)), bottom))
    return out


def parse_parts(stderr):
    """The part table render_probe reported: [[top per layer] per part]."""
    parts = []
    for line in stderr.splitlines():
        line = line.strip()
        if line.startswith("part ") and ":" in line:
            parts.append([int(v) for v in line.split(":", 1)[1].split()])
    return parts


def expected_frame(layers, layer_index, vx, vy, limit=None):
    """Render one viewport straight from the definition, as palette indices.

    Deliberately not sharing code with the encoder, so a mistake in the band
    maths cannot cancel out on both sides of the comparison. Rows at or past
    `limit` stay background, as render_view() leaves them.
    """
    layer = layers[layer_index]
    limit = layer.height if limit is None else min(limit, layer.height)
    frame = bytearray([UI_BG]) * (SCREEN_W * SCREEN_H)

    x_off = 0
    if layer.width < SCREEN_W:
        x_off = (SCREEN_W - layer.width) // 2
        vx = 0

    pixels = layer.tobytes()
    for y in range(SCREEN_H):
        src_y = vy + y
        if src_y >= limit:
            break
        row = pixels[src_y * layer.width:(src_y + 1) * layer.width]
        for x in range(SCREEN_W):
            src_x = vx + x - x_off
            if 0 <= src_x < layer.width:
                frame[y * SCREEN_W + x] = row[src_x]
    return bytes(frame)


def compare_frames(here, chunk_dir, viewports, layers, slot=0, parts=None):
    """Run render_probe over `viewports` and diff every frame. Returns an exit code.

    Viewports are (layer, vx, vy) or (layer, vx, vy, limit). With `parts`, the
    part table the calculator parsed must match it exactly too.
    """
    probe = here / "render_probe"
    if not probe.exists():
        sys.exit(f"{probe} is missing -- run tools/hosttest/build.sh first")

    cmd = [str(probe), str(chunk_dir), str(slot)] + [",".join(map(str, v)) for v in viewports]
    run = subprocess.run(cmd, capture_output=True)
    if run.returncode != 0:
        sys.exit(run.stderr.decode() or f"render_probe exited {run.returncode}")
    print(run.stderr.decode().rstrip())

    part_failures = 0
    if parts is not None:
        parsed = parse_parts(run.stderr.decode())
        if parsed != [list(p) for p in parts]:
            part_failures = 1
            print(f"  MISMATCH part table: calculator read {parsed}, encoder wrote {parts}")
        else:
            print(f"  part table matches: {len(parts)} parts")

    frame_size = SCREEN_W * SCREEN_H
    if len(run.stdout) != frame_size * len(viewports):
        sys.exit(f"expected {len(viewports)} frames, got {len(run.stdout) / frame_size:.2f}")

    failures = 0
    for i, viewport in enumerate(viewports):
        layer_index, vx, vy = viewport[:3]
        limit = viewport[3] if len(viewport) > 3 else None
        actual = run.stdout[i * frame_size:(i + 1) * frame_size]
        expect = expected_frame(layers, layer_index, vx, vy, limit)
        if actual == expect:
            continue
        failures += 1
        bad = [j for j in range(frame_size) if actual[j] != expect[j]]
        first = bad[0]
        print(f"  MISMATCH layer={layer_index} vx={vx} vy={vy} limit={limit}: "
              f"{len(bad)} pixels differ, "
              f"first at ({first % SCREEN_W},{first // SCREEN_W}) "
              f"got {actual[first]} want {expect[first]}")

    print(f"{len(viewports) - failures}/{len(viewports)} viewports match")
    return 1 if failures or part_failures else 0
