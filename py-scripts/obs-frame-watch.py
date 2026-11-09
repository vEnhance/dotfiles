#!/usr/bin/python3
"""
Watch a running OBS for dropped frames and raise a critical notification.

Started in the background by sh-scripts/obs.sh. Polls obs-websocket's GetStats
every few seconds and alerts when OBS's render-lag or encoder-lag counters go
up. These counters are OBS's own count of dropped frames, which is more reliable
than GPU-busy % (on Intel, conky/gpu-load.sh can read 100% with headroom left).

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
from pathlib import Path

from websockets.exceptions import ConnectionClosed
from websockets.sync.client import connect

CONFIG = Path.home() / ".config/obs-studio/plugin_config/obs-websocket/config.json"
POLL_SECONDS = 2
CONNECT_TIMEOUT = 30  # OBS takes a few seconds to bring its server up
COOLDOWN_SECONDS = 30


def notify(urgency: str, summary: str, body: str) -> None:
    subprocess.run(
        (
            "notify-send",
            "-u",
            urgency,
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


def get_stats(ws) -> dict:
    request_id = str(uuid.uuid4())
    ws.send(
        json.dumps({"op": 6, "d": {"requestType": "GetStats", "requestId": request_id}})
    )
    while True:
        msg = json.loads(ws.recv())
        if msg["op"] == 7 and msg["d"]["requestId"] == request_id:
            return msg["d"]["responseData"]


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
    last_alert = -COOLDOWN_SECONDS
    with ws:
        try:
            identify(ws, config.get("server_password", ""))
        except ConnectionClosed as e:
            notify("normal", "OBS frame watcher off", f"obs-websocket refused us: {e}")
            return 1
        try:
            while True:
                stats = get_stats(ws)
                cur = (stats["renderSkippedFrames"], stats["outputSkippedFrames"])
                if debug:
                    print(cur, f"{stats['activeFps']:.1f} fps", flush=True)
                if prev is not None:
                    render, output = cur[0] - prev[0], cur[1] - prev[1]
                    now = time.monotonic()
                    if (render > 0 or output > 0) and (
                        now - last_alert >= COOLDOWN_SECONDS
                    ):
                        last_alert = now
                        notify(
                            "critical",
                            "OBS dropping frames",
                            f"{render} render-lag, {output} encoder-lag "
                            f"in last {POLL_SECONDS}s",
                        )
                prev = cur
                time.sleep(POLL_SECONDS)
        except ConnectionClosed:
            return 0  # OBS exited


if __name__ == "__main__":
    sys.exit(main())
