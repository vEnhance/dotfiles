#!/usr/bin/python3
"""Dictation on X11 with hyprwhspr: speech collects in a box, then goes in.

    dictate.py send     Super+V  start dictating, or put the box's text in now
    dictate.py undo     Super+U  drop the last piece from the box (repeatable),
                                 or stop dictating if the box is empty
    dictate.py stop              stop dictating
    dictate.py hook              hyprwhspr's post_transcription_hook

hyprwhspr (continuous mode) transcribes each stretch of speech up to a pause
into a piece. Pieces collect in a box under the text cursor, and go into the
focused window after FLUSH_AFTER_SECONDS without a new one, on "new line" /
"new paragraph", on Super+V, or on stop, pasted with Shift+Insert. A box
shorter than MIN_CHARS (usually noise) is dropped instead, unless it's sent
with Super+V or "new line". Terminals and gvim get them wrapped with mango.py
first. Every piece is also logged to
~/.local/state/hyprwhspr/history.txt.
"""

import contextlib
import fcntl
import json
import math
import os
import re
import signal
import subprocess
import sys
import time
from pathlib import Path

import mango  # sibling script in py-scripts/

HOOK_CONSUMED = 77  # tells hyprwhspr the transcript was handled, so it won't type it

RUNTIME_DIR = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp"))
# Pieces in the box, and when it last changed
BUFFER_FILE = RUNTIME_DIR / "dictate.buffer.json"
# Where text last went in and the line it left off, for wrapping what's next
STATE_FILE = RUNTIME_DIR / "dictate.state.json"
LOCK_FILE = RUNTIME_DIR / "dictate.lock"  # around the box: hook, undo, flushes
OVERLAY_PID_FILE = RUNTIME_DIR / "dictate.overlay.pid"
WAS_MUTED_FILE = RUNTIME_DIR / "dictate.was-muted"  # re-mute the mic on stop
RECORDING_STATUS = RUNTIME_DIR / "hyprwhspr" / "recording_status"
AUDIO_LEVEL = RUNTIME_DIR / "hyprwhspr" / "audio_level"  # 0-1, while recording
STATE_DIR = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state"))
HISTORY_FILE = STATE_DIR / "hyprwhspr" / "history.txt"
CHVOL = Path(__file__).resolve().parent.parent / "sh-scripts" / "chvol.sh"

FLUSH_AFTER_SECONDS = 6  # quiet time (no new piece) before the box goes in
MIN_CHARS = 25  # shorter boxes are dropped, unless sent explicitly
MODIFIER_WAIT_SECONDS = 2  # e.g. a held Super, before sending keys

# "new line" / "new paragraph" become ¶ / ¶¶ through hyprwhspr's word_overrides
# (config/hyprwhspr/config.json): unlike a real newline, ¶ survives hyprwhspr
# trimming each chunk's edges. Also takes the punctuation the model gives them.
BREAK_RE = re.compile(r"\s*(¶)[.!?,;:]*\s*")
# The model sometimes punctuates after punctuation it already gave ("and?.")
PUNCTUATION_RUN_RE = re.compile(r"([.!?,;:])[.!?,;:]+")

# WM_CLASS (lowercased) of apps whose text gets hard-wrapped
WRAP_APPS = {
    "xfce4-terminal",
    "com.mitchellh.ghostty",
    "ghostty",
    "kitty",
    "alacritty",
    "org.wezfurlong.wezterm",
    "xterm",
    "urxvt",
    "gvim",
}

# Overlay look
OVERLAY_FONT = ("Noto Sans", 14)
OVERLAY_SMALL_FONT = ("Noto Sans", 12)
OVERLAY_COUNT_FONT = ("Noto Sans", 12, "bold")
OVERLAY_BG = "#00cca7"  # stands out against dark terminals
OVERLAY_FG = "#111111"
OVERLAY_DIM = "#1d5e53"
OVERLAY_DROP = "#a3002e"  # countdown when the box will be dropped
OVERLAY_METER = "#111111"
OVERLAY_BORDER = "#111111"  # so the box reads on light backgrounds too
OVERLAY_BORDER_PX = 2
OVERLAY_METER_PX = 6
OVERLAY_MIN_WIDTH_PX = 250  # so the meter is readable under "듣는 중…"
OVERLAY_WIDTH_PX = 600  # text wraps here
OVERLAY_PREVIEW_CHARS = 500  # show the tail of long text
OVERLAY_PLAN_LINES = 4  # near the bottom, go above the cursor if this won't fit
OVERLAY_CURSOR_GAP = 4  # between the text cursor and the overlay
OVERLAY_POLL_MS = 50  # box contents, countdown, cursor, recording state
# End the session once hyprwhspr hasn't been recording for this long. Covers
# startup (it takes ~1s to begin) and hyprwhspr stopping by itself (tray, silent
# mic).
OVERLAY_IDLE_EXIT_SECONDS = 3


# ---------------------------------------------------------------- text


def chunk_text(chunk: str) -> str:
    """A transcribed chunk as text to insert: ¶ to newlines, no doubled punctuation."""
    text = ""
    for piece in BREAK_RE.split(PUNCTUATION_RUN_RE.sub(r"\1", chunk.strip())):
        if piece == "¶":
            text = text.rstrip(" ") + "\n"
        elif piece:
            if text and not text.endswith("\n"):
                text += " "
            text += piece
    return text


def wrap(text: str) -> str:
    """Hard-wrap text with mango's Markdown rules, keeping trailing newlines.

    A leading "x" line keeps mango from treating "Note: ..." as front matter.
    """
    body = text.rstrip("\n")
    out = mango.wrap_text("x\n" + body + "\n", mango.FileType.MARKDOWN)
    return out.removeprefix("x\n").removesuffix("\n") + text[len(body) :]


def join_pieces(pieces: list[str]) -> str:
    text = ""
    for piece in pieces:
        if text and not text.endswith("\n") and not piece.startswith("\n"):
            text += " "
        text += piece
    return text


def compose(text: str, line: str, *, wrapped: bool) -> tuple[str, str]:
    """What to insert after `line` (the current line so far), and the new line."""
    sep = " " if line and not text.startswith("\n") else ""
    insert = sep + text
    if wrapped:
        wrapped = wrap(line + insert)
        # mango may rewrap the part that's already in; then start a fresh line
        insert = wrapped[len(line) :] if wrapped.startswith(line) else "\n" + wrap(text)
    return insert, (line + insert).rpartition("\n")[2]


def log_history(text: str) -> None:
    """One line per piece; breaks are folded so entries stay one line."""
    HISTORY_FILE.parent.mkdir(parents=True, exist_ok=True)
    with HISTORY_FILE.open("a") as f:
        f.write(" ".join(text.split()) + "\n")


# ---------------------------------------------------------------- system


def run(*cmd: str | Path) -> str:
    return subprocess.run(cmd, capture_output=True, text=True, check=False).stdout


def complain(problem: str) -> None:
    run("notify-send", "-u", "critical", "받아쓰기를 시작하지 못했어요", problem)


def audio_level() -> float:
    try:
        return float(AUDIO_LEVEL.read_text())
    except FileNotFoundError, ValueError:
        return 0.0


def is_recording() -> bool:
    try:
        return RECORDING_STATUS.read_text().strip() == "true"
    except FileNotFoundError:
        return False


def active_window() -> str:
    return run("xdotool", "getactivewindow").strip()


def focused_window_middle() -> tuple[int, int]:
    geometry = dict(
        line.split("=", 1)
        for line in run(
            "xdotool", "getactivewindow", "getwindowgeometry", "--shell"
        ).split()
    )
    try:
        x, y, w, h = (int(geometry[k]) for k in ("X", "Y", "WIDTH", "HEIGHT"))
    except KeyError, ValueError:
        return 0, 0
    return x + w // 2, y + h // 2


def monitors() -> list[tuple[int, int, int, int]]:
    """(x, y, width, height) of each monitor."""
    return [
        (int(m[3]), int(m[4]), int(m[1]), int(m[2]))
        for m in re.finditer(
            r"(\d+)/\d+x(\d+)/\d+\+(\d+)\+(\d+)", run("xrandr", "--listmonitors")
        )
    ]


def gets_wrapped(window: str) -> bool:
    return run("xdotool", "getwindowclassname", window).strip().lower() in WRAP_APPS


def wait_for_modifiers() -> None:
    """Wait (a bit) until no modifiers are held, or our keys become shortcuts.

    Not xdotool's --clearmodifiers: it re-presses them afterwards, and if they were
    let go meanwhile, X is left thinking they're still down (Space then acts as
    Super+Space until Super is pressed again).
    """
    x11 = X11()
    deadline = time.monotonic() + MODIFIER_WAIT_SECONDS
    while x11.modifiers_held() and time.monotonic() < deadline:
        time.sleep(0.02)


def insert(text: str) -> None:
    """Paste text with Shift+Insert, from the primary selection.

    Not typed: typed newlines are Enter ((n)vim would autoindent or accept a
    completion, Claude Code / bash would submit), and fast typing drops keys in
    some apps (qutebrowser).
    """
    wait_for_modifiers()
    # Primary selection, so the clipboard is left alone. xclip stays alive to
    # own it; keep it off hyprwhspr's stdio pipes.
    subprocess.run(
        ["xclip", "-selection", "primary"],
        input=text,
        text=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    run("xdotool", "key", "shift+Insert")


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text())
    except FileNotFoundError, ValueError:
        return {}


@contextlib.contextmanager
def locked():
    """Hold the box: changes and flushes from hook, undo, overlay and stop.

    Not reentrant (a second flock on a new file description would deadlock).
    """
    with LOCK_FILE.open("w") as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        yield


def read_box() -> tuple[list[str], float]:
    box = load_json(BUFFER_FILE)
    return box.get("pieces", []), box.get("changed", 0.0)


def write_box(pieces: list[str]) -> None:
    BUFFER_FILE.write_text(json.dumps({"pieces": pieces, "changed": time.time()}))


def is_short(pieces: list[str]) -> bool:
    return len(join_pieces(pieces).strip()) < MIN_CHARS


def flush(*, short_too: bool = False) -> None:
    """Put the box's text into the focused window. Call while locked().

    A short box is just emptied, unless short_too.
    """
    pieces, _ = read_box()
    if not pieces:
        return
    if is_short(pieces) and not short_too:
        write_box([])
        return
    text = join_pieces(pieces)
    window = active_window()
    state = load_json(STATE_FILE)
    line = state.get("line", "") if state.get("window") == window else ""
    inserted, line = compose(text, line, wrapped=gets_wrapped(window))
    insert(inserted)
    write_box([])
    STATE_FILE.write_text(json.dumps({"window": window, "line": line}))


# ---------------------------------------------------------------- overlay


def overlay_pid() -> int | None:
    """PID of the running overlay, i.e. whether we're dictating."""
    try:
        pid = int(OVERLAY_PID_FILE.read_text())
        os.kill(pid, 0)
    except FileNotFoundError, ValueError, ProcessLookupError:
        return None
    return pid


class X11:
    """The bits of Xlib that Tk and xdotool don't offer, via ctypes."""

    # Shift, Control, Alt (Mod1), Super (Mod4), AltGr (Mod5)
    MODIFIERS = 1 | 1 << 2 | 1 << 3 | 1 << 6 | 1 << 7

    def __init__(self) -> None:
        import ctypes
        import ctypes.util

        c = self.c = ctypes
        ptr, ulong, uint, i = c.c_void_p, c.c_ulong, c.c_uint, c.c_int
        out = c.POINTER
        xlib = self.xlib = c.CDLL(c.util.find_library("X11"))
        xext = self.xext = c.CDLL(c.util.find_library("Xext"))
        xlib.XOpenDisplay.restype = ptr
        xlib.XDefaultRootWindow.restype = ulong
        xlib.XDefaultRootWindow.argtypes = [ptr]
        xlib.XQueryTree.argtypes = [
            ptr, ulong, out(ulong), out(ulong), out(ptr), out(uint),
        ]  # fmt: skip
        xlib.XQueryPointer.argtypes = [
            ptr, ulong, out(ulong), out(ulong), out(i), out(i), out(i), out(i),
            out(uint),
        ]  # fmt: skip
        xlib.XFree.argtypes = xlib.XFlush.argtypes = [ptr]
        xext.XShapeCombineRectangles.argtypes = [ptr, ulong, i, i, i, ptr, i, i, i]
        self.display = xlib.XOpenDisplay(None)
        self.root = xlib.XDefaultRootWindow(self.display)

    def toplevel(self, window: int) -> int:
        """Tk's ids are inner windows; walk up to the child of the root window."""
        c = self.c
        root, parent, children, n = c.c_ulong(), c.c_ulong(), c.c_void_p(), c.c_uint()
        while True:
            self.xlib.XQueryTree(
                self.display, window, *map(c.byref, (root, parent, children, n))
            )
            if children:
                self.xlib.XFree(children)
            if parent.value in (0, root.value):
                return window
            window = parent.value

    def click_through(self, window: int) -> None:
        """Empty input shape: clicks on the window fall through to what's below."""
        shape_input, shape_set, unsorted = 2, 0, 0
        self.xext.XShapeCombineRectangles(
            self.display, self.toplevel(window), shape_input, 0, 0, None, 0,
            shape_set, unsorted,
        )  # fmt: skip
        self.xlib.XFlush(self.display)

    def modifiers_held(self) -> bool:
        c = self.c
        win, i, mask = c.c_ulong(), c.c_int(), c.c_uint()
        self.xlib.XQueryPointer(
            self.display, self.root, *map(c.byref, (win, win, i, i, i, i, mask))
        )
        return bool(mask.value & self.MODIFIERS)


class IBusCursor:
    """Screen rectangle of the focused app's text cursor, overheard on IBus's bus.

    Input contexts (one per app window/widget) tell IBus FocusIn / FocusOut and
    SetCursorLocation(x, y, w, h) in screen coordinates.
    """

    CONTEXT = "org.freedesktop.IBus.InputContext"

    def __init__(self) -> None:
        """Raises ConnectionError if IBus isn't running."""
        import gi

        gi.require_version("Gio", "2.0")
        from gi.repository import Gio, GLib

        try:
            address = run("ibus", "address").strip()
        except FileNotFoundError as e:
            raise ConnectionError("IBus가 설치되어 있지 않아요") from e
        try:
            flags = Gio.DBusConnectionFlags
            self.bus = Gio.DBusConnection.new_for_address_sync(
                address,
                flags.AUTHENTICATION_CLIENT | flags.MESSAGE_BUS_CONNECTION,
                None,
                None,
            )
            rule = f"eavesdrop='true',type='method_call',interface='{self.CONTEXT}'"
            self.bus.call_sync(
                "org.freedesktop.DBus", "/org/freedesktop/DBus",
                "org.freedesktop.DBus", "AddMatch", GLib.Variant("(s)", (rule,)),
                None, Gio.DBusCallFlags.NONE, 1000, None,
            )  # fmt: skip
        except GLib.Error as e:
            raise ConnectionError("IBus가 실행 중이 아니에요") from e
        self.focused: str | None = None
        self.rects: dict[str, tuple[int, int, int, int]] = {}
        self.bus.add_filter(self._overhear)  # runs on GDBus's own thread

    def _overhear(self, _bus, message, _incoming):
        if message.get_interface() == self.CONTEXT:
            member, path = message.get_member(), message.get_path()
            if member == "FocusIn":
                self.focused = path
            elif member == "FocusOut" and self.focused == path:
                self.focused = None
            elif member == "SetCursorLocation":
                x, y, w, h = message.get_body().unpack()
                if h > 0:
                    self.rects[path] = (x, y, w, h)
                    # Focused before we started listening
                    self.focused = self.focused or path
        return message

    def rect(self) -> tuple[int, int, int, int] | None:
        return self.rects.get(self.focused) if self.focused else None


def run_overlay() -> None:
    import tkinter as tk
    import tkinter.font

    root = tk.Tk(className="dictation-overlay")
    root.overrideredirect(True)  # no WM decorations, i3 leaves it alone
    root.attributes("-topmost", True)
    root.configure(
        bg=OVERLAY_BG,
        highlightthickness=OVERLAY_BORDER_PX,
        highlightbackground=OVERLAY_BORDER,
        highlightcolor=OVERLAY_BORDER,
    )
    label = tk.Label(
        root, bg=OVERLAY_BG, wraplength=OVERLAY_WIDTH_PX, justify="left",
        anchor="nw", padx=8, pady=4,
    )  # fmt: skip
    label.pack(fill="x")
    status = tk.Frame(root, bg=OVERLAY_BG)  # packed only while the box has text
    count = tk.Label(status, bg=OVERLAY_BG, font=OVERLAY_COUNT_FONT, padx=0, pady=0)
    count.pack(side="left", anchor="n", padx=(8, 0))
    hints = tk.Label(
        status, bg=OVERLAY_BG, fg=OVERLAY_DIM, font=OVERLAY_SMALL_FONT,
        wraplength=OVERLAY_WIDTH_PX // 2, justify="left", anchor="w", padx=4, pady=0,
    )  # fmt: skip
    hints.pack(side="left", anchor="n")
    # The mic level, to tell whether speech is heard (a chunk comes after a
    # pause in it) when nothing has come through yet
    meter_track = tk.Frame(
        root, bg=OVERLAY_BG, height=OVERLAY_METER_PX, width=OVERLAY_MIN_WIDTH_PX
    )
    meter_track.pack(fill="x", padx=8, pady=(2, 6))
    meter = tk.Frame(meter_track, bg=OVERLAY_METER)

    cursor = IBusCursor()
    screens = monitors() or [
        (0, 0, root.winfo_screenwidth(), root.winfo_screenheight())
    ]
    window_middle: tuple[int, int] | None = None  # for before the cursor is known
    # Most dictation runs to a few lines: decide above/below for that size, so
    # the box doesn't jump over the cursor as it grows
    line_px = tk.font.Font(font=OVERLAY_FONT).metrics("linespace")
    small_px = tk.font.Font(font=OVERLAY_SMALL_FONT).metrics("linespace")
    planned_h = OVERLAY_PLAN_LINES * line_px + small_px + OVERLAY_METER_PX + 20
    last_pos: tuple[int, int] | None = None

    def place() -> None:
        """Sit under the text cursor (above it if it doesn't fit), on its monitor.

        Re-placed as the box grows, so it never runs off the monitor's edge.
        """
        nonlocal last_pos, window_middle
        w, h = root.winfo_reqwidth(), root.winfo_reqheight()
        if rect := cursor.rect():
            cx, cy, _, ch = rect
        else:  # nothing reported yet: middle of the focused window
            window_middle = window_middle or focused_window_middle()
            cx, cy, ch = window_middle[0] - w // 2, window_middle[1], 0
        mx, my, mw, mh = next(
            (
                m
                for m in screens
                if m[0] <= cx < m[0] + m[2] and m[1] <= cy < m[1] + m[3]
            ),
            screens[0],
        )
        x, y = cx, cy + ch + OVERLAY_CURSOR_GAP
        if y + max(h, planned_h) > my + mh:
            y = cy - OVERLAY_CURSOR_GAP - h
        pos = (max(mx, min(x, mx + mw - w)), max(my, min(y, my + mh - h)))
        if pos != last_pos:
            last_pos = pos
            root.geometry(f"+{pos[0]}+{pos[1]}")

    shown: tuple[str, str, str] | None = None
    last_recording = time.monotonic()
    started = False

    def show(pieces: list[str], left: float) -> None:
        nonlocal shown
        text = join_pieces(pieces).strip()
        short = is_short(pieces)
        seconds = max(1, math.ceil(left))
        if not text:
            when = note = ""
        elif short:
            when = f"{seconds}초 후 버림 (너무 짧음)"
            note = "· Win+V 입력 · Win+U 되돌리기"
        else:
            when = f"{seconds}초 후 입력"
            note = "· Win+V 지금 입력 · Win+U 되돌리기"
        if (text, when, note) == shown:
            return
        shown = (text, when, note)
        if text:
            if len(text) > OVERLAY_PREVIEW_CHARS:
                text = "…" + text[-OVERLAY_PREVIEW_CHARS:]
            fg = OVERLAY_DIM if short else OVERLAY_FG  # dim: will be dropped
            label.configure(text=text, font=OVERLAY_FONT, fg=fg)
            count.configure(text=when, fg=OVERLAY_DROP if short else OVERLAY_FG)
            hints.configure(text=note)
            status.pack(fill="x", before=meter_track)
        else:
            label.configure(
                text="듣는 중… · Win+U 종료", font=OVERLAY_SMALL_FONT, fg=OVERLAY_DIM
            )
            status.pack_forget()
        root.update_idletasks()  # recompute size before re-placing

    def poll() -> None:
        nonlocal last_recording, started
        if is_recording():
            last_recording = time.monotonic()
            started = True
        elif time.monotonic() - last_recording > OVERLAY_IDLE_EXIT_SECONDS:
            # hyprwhspr stopped by itself (tray, silent mic), or never started
            if not started:
                complain("hyprwhspr가 녹음을 시작하지 않았어요")
            with locked():
                flush()
            end_session()
            root.destroy()
            return
        with locked():
            pieces, changed = read_box()
            left = FLUSH_AFTER_SECONDS - (time.time() - changed)
            if any("\n" in piece for piece in pieces):
                flush(short_too=True)
                pieces = []
            elif pieces and left <= 0:
                flush()
                pieces = []
        show(pieces, left)
        level = min(1.0, audio_level()) ** 0.5  # so quiet sounds still show
        meter.place(relheight=1, relwidth=level)
        place()
        root.after(OVERLAY_POLL_MS, poll)

    root.update()  # map it so the X window exists
    X11().click_through(root.winfo_id())
    # An idle app has nothing to report until its cursor moves, but it reports
    # on gaining focus: take focus for a moment and give it back.
    if focused := active_window():
        run("xdotool", "windowfocus", str(root.winfo_id()))
        run("xdotool", "windowfocus", focused)
    poll()
    root.mainloop()


# ---------------------------------------------------------------- session


def start() -> int:
    if run("systemctl", "--user", "is-active", "hyprwhspr").strip() != "active":
        complain("hyprwhspr가 실행 중이 아니에요")
        return 1
    try:
        IBusCursor()  # the overlay needs it to know where to sit
    except ConnectionError as e:
        complain(str(e))
        return 1
    # Unmute first, or hyprwhspr cancels on a silent mic
    if "MUTED" in run("wpctl", "get-volume", "@DEFAULT_SOURCE@"):
        run(CHVOL, "w")
        WAS_MUTED_FILE.touch()
    BUFFER_FILE.unlink(missing_ok=True)
    STATE_FILE.unlink(missing_ok=True)  # dictation starts at the start of a line
    proc = subprocess.Popen(
        [sys.executable, __file__, "overlay"],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    OVERLAY_PID_FILE.write_text(str(proc.pid))
    run("hyprwhspr", "record", "start")
    return 0


def end_session() -> None:
    """Cleanup once recording is over, whoever stopped it."""
    OVERLAY_PID_FILE.unlink(missing_ok=True)
    if WAS_MUTED_FILE.exists():
        run(CHVOL, "m")
        WAS_MUTED_FILE.unlink()


def stop() -> None:
    run("hyprwhspr", "record", "stop")  # its last chunk still comes through hook
    with locked():  # so the overlay isn't killed mid-flush
        if (pid := overlay_pid()) is not None:
            os.kill(pid, signal.SIGTERM)
        flush()
    end_session()


# ---------------------------------------------------------------- commands


def send() -> int:
    if overlay_pid() is None:
        return start()
    else:
        with locked():
            flush(short_too=True)


def hook() -> int:
    """Add a transcribed chunk to the box (or put it straight in, if stopped)."""
    if text := chunk_text(sys.stdin.read()):
        log_history(text)
        with locked():
            pieces, _ = read_box()
            write_box([*pieces, text])
            if overlay_pid() is None:
                flush()  # the last chunk, landing after stop
    return HOOK_CONSUMED


def undo() -> None:
    """Drop the last piece from the box, refilling the countdown, or stop."""
    with locked():
        pieces, _ = read_box()
        if pieces:
            write_box(pieces[:-1])
            return
    if overlay_pid() is not None:
        stop()


def main() -> int:
    commands = {
        "send": send,
        "undo": undo,
        "stop": stop,
        "hook": hook,
        "overlay": run_overlay,
    }
    if len(sys.argv) != 2 or sys.argv[1] not in commands:
        print(f"usage: {sys.argv[0]} {{send|undo|stop|hook}}", file=sys.stderr)
        return 2
    return commands[sys.argv[1]]() or 0


if __name__ == "__main__":
    sys.exit(main())
