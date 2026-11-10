#!/usr/bin/python3
"""
Watch a running OBS for dropped frames and raise a critical notification.

Started in the background by sh-scripts/obs.sh. Polls obs-websocket's GetStats
every few seconds and alerts when OBS's render-lag plus encoder-lag drops over
the last WINDOW_SECONDS reach DROP_THRESHOLD, then says when it recovers.
These counters are OBS's own count of dropped frames, more reliable than
GPU-busy % (on Intel, conky/gpu-load.sh can read 100% with headroom left).

Needs obs-websocket enabled (Tools -> WebSocket Server Settings). The port and
password come from OBS's own config, so no secret lives in these dotfiles.
Exits quietly once OBS closes the connection.
"""

import base64
import hashlib
import json
import subprocess
import sys
import time
import uuid
from collections import deque
from pathlib import Path

from websockets.exceptions import ConnectionClosed
from websockets.sync.client import connect

CONFIG = Path.home() / ".config/obs-studio/plugin_config/obs-websocket/config.json"
POLL_SECONDS = 2
# A stray dropped frame is normal; alert only once drops pile up. Render and
# encoder drops are added together and summed over a rolling window.
WINDOW_SECONDS = 10
DROP_THRESHOLD = 10  # frames per window; ~1.7% at 60 fps over 10 s
RECOVERED_TIMEOUT_MS = 10_000
CONNECT_TIMEOUT = 30  # OBS takes a few seconds to bring its server up


def notify(urgency: str, summary: str, body: str, timeout_ms: int = -1) -> None:
    """timeout_ms -1 means "use dunst's default for this urgency"."""
    subprocess.run(
        (
            "notify-send",
            "-u",
            urgency,
            "-t",
            str(timeout_ms),
            "-a",
            "OBS",
            # Same tag, so a newer alert replaces the old one instead of stacking.
            "-h",
            "string:x-dunst-stack-tag:obs-frames",
            summary,
            body,
        ),
        check=False,
    )


def auth_string(password: str, salt: str, challenge: str) -> str:
    secret = base64.b64encode(hashlib.sha256((password + salt).encode()).digest())
    return base64.b64encode(
        hashlib.sha256(secret + challenge.encode()).digest()
    ).decode()


def connect_with_retry(port: int):
    deadline = time.monotonic() + CONNECT_TIMEOUT
    while True:
        try:
            return connect(f"ws://localhost:{port}", open_timeout=5)
        except OSError:
            if time.monotonic() > deadline:
                return None
            time.sleep(1)


def identify(ws, password: str) -> None:
    hello = json.loads(ws.recv())
    assert hello["op"] == 0, hello
    payload: dict = {"rpcVersion": 1, "eventSubscriptions": 0}
    if auth := hello["d"].get("authentication"):
        payload["authentication"] = auth_string(
            password, auth["salt"], auth["challenge"]
        )
    ws.send(json.dumps({"op": 1, "d": payload}))
    identified = json.loads(ws.recv())  # a bad password closes the socket here
    assert identified["op"] == 2, identified


NOT_READY = 207  # obs-websocket's RequestStatus while OBS is still loading


def get_stats(ws) -> dict | None:
    """GetStats' responseData, or None if OBS hasn't finished starting up."""
    request_id = str(uuid.uuid4())
    ws.send(
        json.dumps({"op": 6, "d": {"requestType": "GetStats", "requestId": request_id}})
    )
    while True:
        msg = json.loads(ws.recv())
        if msg["op"] == 7 and msg["d"]["requestId"] == request_id:
            break
    status = msg["d"]["requestStatus"]
    if status["result"]:
        return msg["d"]["responseData"]
    if status["code"] == NOT_READY:
        return None
    raise RuntimeError(f"GetStats failed: {status}")


def ratio(stats: dict, kind: str) -> str:
    """e.g. "12/34567 (0.03%)" for kind "render" or "output"."""
    skipped, total = stats[f"{kind}SkippedFrames"], stats[f"{kind}TotalFrames"]
    pct = 100 * skipped / total if total else 0
    return f"{skipped}/{total} ({pct:.2f}%)"


def main() -> int:
    try:
        config = json.loads(CONFIG.read_text())
    except OSError, ValueError:
        config = {}
    if not config.get("server_enabled"):
        notify(
            "normal",
            "OBS frame watcher off",
            "Enable obs-websocket in Tools > WebSocket Server Settings",
        )
        return 0

    ws = connect_with_retry(int(config.get("server_port", 4455)))
    if ws is None:
        notify("normal", "OBS frame watcher off", "Couldn't reach obs-websocket")
        return 1

    debug = "--debug" in sys.argv
    prev = None
    alerting = False
    # (render, encoder) drops per poll, covering the last WINDOW_SECONDS
    window: deque[tuple[int, int]] = deque(maxlen=WINDOW_SECONDS // POLL_SECONDS)
    with ws:
        try:
            identify(ws, config.get("server_password", ""))
        except ConnectionClosed as e:
            notify("normal", "OBS frame watcher off", f"obs-websocket refused us: {e}")
            return 1
        try:
            while True:
                stats = get_stats(ws)
                if stats is None:
                    if debug:
                        print("OBS not ready yet", flush=True)
                    time.sleep(POLL_SECONDS)
                    continue
                cur = (stats["renderSkippedFrames"], stats["outputSkippedFrames"])
                if debug:
                    print(cur, f"{stats['activeFps']:.1f} fps", flush=True)
                if prev is not None:
                    window.append((cur[0] - prev[0], cur[1] - prev[1]))
                    render = sum(r for r, _ in window)
                    output = sum(o for _, o in window)
                    totals = (
                        f"Missed: Render {ratio(stats, 'render')}\n"
                        f"Missed: Encoder {ratio(stats, 'output')}\n"
                        f"Frame render time: "
                        f"{stats['averageFrameRenderTime']:.1f} ms "
                        f"at {stats['activeFps']:.1f} fps\n"
                        f"In last {WINDOW_SECONDS}s: "
                        f"{render} render-lag, {output} encoder-lag"
                    )
                    # Re-sent every poll while over threshold; the stack tag
                    # makes each one replace the last with fresh numbers.
                    if render + output >= DROP_THRESHOLD:
                        alerting = True
                        notify("critical", "OBS dropping frames", totals)
                    elif alerting:
                        # Back under threshold: swap the sticky critical alert
                        # for one that expires by itself.
                        alerting = False
                        notify(
                            "normal",
                            "OBS recovered",
                            totals,
                            timeout_ms=RECOVERED_TIMEOUT_MS,
                        )
                prev = cur
                time.sleep(POLL_SECONDS)
        except ConnectionClosed:
            return 0  # OBS exited


if __name__ == "__main__":
    sys.exit(main())
