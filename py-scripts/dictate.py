#!/usr/bin/python3
"""Dictation on X11 with hyprwhspr: speech collects in a box, then goes in.

    dictate.py send     Super+V  start dictating, or put the box's text in now
    dictate.py undo     Super+U  drop the last piece from the box (repeatable)
    dictate.py stop     Super+Z  stop dictating
    dictate.py hook              hyprwhspr's post_transcription_hook

hyprwhspr (continuous mode) transcribes each stretch of speech up to a pause
into a piece. Pieces collect in a box under the text cursor, and go into the
focused window after FLUSH_AFTER_SECONDS without a new one, on "new line" /
"new paragraph", on Super+V, or on stop. Terminals and gvim get them wrapped
with mango.py and pasted; other apps get them typed. Every piece is also logged
to ~/.local/state/hyprwhspr/history.txt.
"""

import contextlib
import fcntl
import json
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
STATE_DIR = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state"))
HISTORY_FILE = STATE_DIR / "hyprwhspr" / "history.txt"
CHVOL = Path(__file__).resolve().parent.parent / "sh-scripts" / "chvol.sh"

FLUSH_AFTER_SECONDS = 2  # quiet time (no new piece) before the box goes in
MODIFIER_WAIT_SECONDS = 2  # e.g. a held Super, before sending keys
TYPE_DELAY_MS = 4  # between typed keys (xdotool's default of 12 is slow)

# "new line" / "new paragraph" become ¶ / ¶¶ through hyprwhspr's word_overrides
# (config/hyprwhspr/config.json): unlike a real newline, ¶ survives hyprwhspr
# trimming each chunk's edges. Also takes the punctuation the model gives them.
BREAK_RE = re.compile(r"\s*(¶)[.!?,;:]*\s*")
# The model sometimes punctuates after punctuation it already gave ("and?.")
PUNCTUATION_RUN_RE = re.compile(r"([.!?,;:])[.!?,;:]+")

# WM_CLASS (lowercased) of apps that get wrapped text, pasted from the primary
# selection with Shift+Insert. A paste goes in as-is, where typed newlines would
# be Enter: (n)vim would autoindent or accept a completion, Claude Code / bash
# would submit. Everything else gets it typed, unwrapped.
PASTE_APPS = {
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
OVERLAY_FONT = ("Noto Sans", 11)
OVERLAY_SMALL_FONT = ("Noto Sans", 9)
OVERLAY_BG = "#00cca7"  # stands out against dark terminals
OVERLAY_FG = "#111111"
OVERLAY_DIM = "#1d5e53"
OVERLAY_BAR = "#111111"
OVERLAY_BAR_PX = 4
OVERLAY_WIDTH_PX = 480  # text wraps here
OVERLAY_PREVIEW_CHARS = 500  # show the tail of long text
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
    run("notify-send", "-u", "critical", "Dictation didn't start", problem)


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


def gets_pasted(window: str) -> bool:
    return run("xdotool", "getwindowclassname", window).strip().lower() in PASTE_APPS


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


def insert(text: str, *, paste: bool) -> None:
    """Paste text with Shift+Insert (from the primary selection), or type it."""
    wait_for_modifiers()
    if not paste:
        run("xdotool", "type", "--delay", str(TYPE_DELAY_MS), "--", text)
        return
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


def flush() -> None:
    """Put the box's text into the focused window. Call while locked()."""
    pieces, _ = read_box()
    if not pieces:
        return
    text = join_pieces(pieces)
    window = active_window()
    state = load_json(STATE_FILE)
    line = state.get("line", "") if state.get("window") == window else ""
    paste = gets_pasted(window)
    inserted, line = compose(text, line, wrapped=paste)
    insert(inserted, paste=paste)
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
            raise ConnectionError("IBus isn't installed") from e
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
            raise ConnectionError("IBus isn't running") from e
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

    root = tk.Tk(className="dictation-overlay")
    root.overrideredirect(True)  # no WM decorations, i3 leaves it alone
    root.attributes("-topmost", True)
    root.configure(bg=OVERLAY_BG)
    label = tk.Label(
        root, bg=OVERLAY_BG, wraplength=OVERLAY_WIDTH_PX, justify="left",
        anchor="nw", padx=8, pady=4,
    )  # fmt: skip
    label.pack(fill="x")
    track = tk.Frame(root, bg=OVERLAY_BG, height=OVERLAY_BAR_PX)
    track.pack(fill="x")
    bar = tk.Frame(track, bg=OVERLAY_BAR)  # the countdown, drains to the left

    cursor = IBusCursor()
    last_pos: tuple[int, int] | None = None

    def place() -> None:
        """Sit under the text cursor (above it near the screen's bottom)."""
        nonlocal last_pos
        w, h = root.winfo_reqwidth(), root.winfo_reqheight()
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        if rect := cursor.rect():
            cx, cy, _, ch = rect
            x = cx
            y = cy + ch + OVERLAY_CURSOR_GAP
            if y + h > sh:
                y = cy - OVERLAY_CURSOR_GAP - h
        elif last_pos is None:  # nothing reported yet: middle of the focused window
            x, y = focused_window_middle()
            x -= w // 2
        else:
            return
        pos = (max(0, min(x, sw - w)), max(0, y))
        if pos != last_pos:
            last_pos = pos
            root.geometry(f"+{pos[0]}+{pos[1]}")

    shown: str | None = None
    last_recording = time.monotonic()
    started = False

    def show(text: str) -> None:
        nonlocal shown
        if text == shown:
            return
        shown = text
        if text:
            if len(text) > OVERLAY_PREVIEW_CHARS:
                text = "…" + text[-OVERLAY_PREVIEW_CHARS:]
            label.configure(text=text, font=OVERLAY_FONT, fg=OVERLAY_FG)
        else:
            label.configure(text="Listening…", font=OVERLAY_SMALL_FONT, fg=OVERLAY_DIM)
        root.update_idletasks()  # recompute size before re-placing

    def poll() -> None:
        nonlocal last_recording, started
        if is_recording():
            last_recording = time.monotonic()
            started = True
        elif time.monotonic() - last_recording > OVERLAY_IDLE_EXIT_SECONDS:
            # hyprwhspr stopped by itself (tray, silent mic), or never started
            if not started:
                complain("hyprwhspr didn't start recording")
            with locked():
                flush()
            end_session()
            root.destroy()
            return
        with locked():
            pieces, changed = read_box()
            left = FLUSH_AFTER_SECONDS - (time.time() - changed)
            if pieces and (left <= 0 or any("\n" in piece for piece in pieces)):
                flush()
                pieces = []
        show(join_pieces(pieces).strip())
        if pieces:
            bar.place(relheight=1, relwidth=max(0, left) / FLUSH_AFTER_SECONDS)
        else:
            bar.place_forget()
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
        complain("hyprwhspr isn't running")
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
            flush()


def hook() -> int:
    """Add a transcribed chunk to the box (or put it straight in, if stopped)."""
    if text := chunk_text(sys.stdin.read()):
        log_history(text)
        with locked():
            pieces, _ = read_box()
            write_box([*pieces, text])
            if overlay_pid() is None:
                flush()  # the last chunk, landing after Super+Z stopped
    return HOOK_CONSUMED


def undo() -> None:
    """Drop the last piece from the box, refilling the countdown."""
    with locked():
        pieces, _ = read_box()
        if pieces:
            write_box(pieces[:-1])


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
