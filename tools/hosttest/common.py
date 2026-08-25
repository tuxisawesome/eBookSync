"""Shared plumbing for the host tests: pick viewports, run the probe, diff frames."""

import subprocess
import sys

SCREEN_W, SCREEN_H = 320, 240

# What render.h clears the screen to before drawing a viewport.
UI_BG = 248


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


def expected_frame(layers, layer_index, vx, vy):
    """Render one viewport straight from the definition, as palette indices.

    Deliberately not sharing code with the encoder, so a mistake in the band
    maths cannot cancel out on both sides of the comparison.
    """
    layer = layers[layer_index]
    frame = bytearray([UI_BG]) * (SCREEN_W * SCREEN_H)

    x_off = 0
    if layer.width < SCREEN_W:
        x_off = (SCREEN_W - layer.width) // 2
        vx = 0

    pixels = layer.tobytes()
    for y in range(SCREEN_H):
        src_y = vy + y
        if src_y >= layer.height:
            break
        row = pixels[src_y * layer.width:(src_y + 1) * layer.width]
        for x in range(SCREEN_W):
            src_x = vx + x - x_off
            if 0 <= src_x < layer.width:
                frame[y * SCREEN_W + x] = row[src_x]
    return bytes(frame)


def compare_frames(here, chunk_dir, viewports, layers, slot=0):
    """Run render_probe over `viewports` and diff every frame. Returns an exit code."""
    probe = here / "render_probe"
    if not probe.exists():
        sys.exit(f"{probe} is missing -- run tools/hosttest/build.sh first")

    cmd = [str(probe), str(chunk_dir), str(slot)] + [f"{l},{x},{y}" for l, x, y in viewports]
    run = subprocess.run(cmd, capture_output=True)
    if run.returncode != 0:
        sys.exit(run.stderr.decode() or f"render_probe exited {run.returncode}")
    print(run.stderr.decode().rstrip())

    frame_size = SCREEN_W * SCREEN_H
    if len(run.stdout) != frame_size * len(viewports):
        sys.exit(f"expected {len(viewports)} frames, got {len(run.stdout) / frame_size:.2f}")

    failures = 0
    for i, (layer_index, vx, vy) in enumerate(viewports):
        actual = run.stdout[i * frame_size:(i + 1) * frame_size]
        expect = expected_frame(layers, layer_index, vx, vy)
        if actual == expect:
            continue
        failures += 1
        bad = [j for j in range(frame_size) if actual[j] != expect[j]]
        first = bad[0]
        print(f"  MISMATCH layer={layer_index} vx={vx} vy={vy}: {len(bad)} pixels differ, "
              f"first at ({first % SCREEN_W},{first // SCREEN_W}) "
              f"got {actual[first]} want {expect[first]}")

    print(f"{len(viewports) - failures}/{len(viewports)} viewports match")
    return 1 if failures else 0
