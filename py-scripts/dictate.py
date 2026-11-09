#!/usr/bin/python3
"""Dictation on X11 with hyprwhspr: speech collects in a box, then goes in.

hyprwhspr (continuous mode) records and transcribes; this does everything else.

    dictate.py send     Super+V  not dictating: start (unmuting the mic if needed)
                                 dictating:     put the box's text in now
    dictate.py undo     Super+U  drop the last piece from the box (repeatable)
    dictate.py stop     Super+Z  stop (re-muting the mic)
    dictate.py hook              hyprwhspr's post_transcription_hook (chunk on stdin)

Each chunk hyprwhspr transcribes (what was said up to a short pause) is a
piece. Pieces collect in a small overlay box, which sits under the text cursor
in xfce4-terminal (found through the accessibility API, AT-SPI, which VTE
supports) or beside the mouse pointer elsewhere. A bar along its bottom drains
over FLUSH_AFTER_SECONDS; each new piece (or undo) refills it. When it runs
out, the box's text goes into the focused window. It also goes in at once when
a piece contains a break (saying "new line" / "new paragraph"), on Super+V,
and when dictation stops. The box never takes focus and clicks pass through it; it
running is what "dictating" means.

Breaks: hyprwhspr's word_overrides (config/hyprwhspr/config.json) turn "new
line" / "new paragraph" into ¶ / ¶¶, which unlike a real newline survives
hyprwhspr trimming each chunk's edges. Runs of punctuation are cut to their
first mark ("and?." -> "and?").

Going in:
  - Terminals (xfce4-terminal etc.) get it hard-wrapped with mango.py's rules,
    continuing the line the last text left off on (dictation is assumed to
    start at the start of a line), and pasted, through the primary selection
    with Shift+Insert. As a paste it's inserted as-is: nvim doesn't autoindent
    or accept completions on its newlines, and Claude Code / bash don't submit.
  - Elsewhere (chat, browser) it's typed with xdotool, unwrapped.

Every piece is also appended as one raw line to
~/.local/state/hyprwhspr/history.txt, for recovery.
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

# A ¶ from word_overrides, plus the punctuation the model gives the spoken command
BREAK_RE = re.compile(r"\s*(¶)[.!?,;:]*\s*")
# The model sometimes punctuates after punctuation it already gave ("and?.")
PUNCTUATION_RUN_RE = re.compile(r"([.!?,;:])[.!?,;:]+")

# WM_CLASS (lowercased) of terminals, which get wrapped, pasted text
TERMINALS = {
    "xfce4-terminal",
    "com.mitchellh.ghostty",
    "ghostty",
    "kitty",
    "alacritty",
    "org.wezfurlong.wezterm",
    "xterm",
    "urxvt",
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
OVERLAY_POINTER_OFFSET = (16, 16)  # gap between the pointer and the overlay
OVERLAY_CARET_GAP = 4  # gap between the terminal's text cursor and the overlay
OVERLAY_FOLLOW_MS = 16  # pointer tracking (~60 fps)
OVERLAY_CARET_MS = 150  # how often to ask the terminal where its cursor is
OVERLAY_POLL_MS = 50  # box contents, countdown, recording state
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


def compose(text: str, line: str, *, terminal: bool) -> tuple[str, str]:
    """What to insert after `line` (the current line so far), and the new line."""
    sep = " " if line and not text.startswith("\n") else ""
    insert = sep + text
    if terminal:
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


def is_recording() -> bool:
    try:
        return RECORDING_STATUS.read_text().strip() == "true"
    except FileNotFoundError:
        return False


def active_window() -> str:
    return run("xdotool", "getactivewindow").strip()


def is_terminal(window: str) -> bool:
    return run("xdotool", "getwindowclassname", window).strip().lower() in TERMINALS


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


def insert(text: str, *, terminal: bool) -> None:
    wait_for_modifiers()
    if terminal:
        # Primary selection, so the clipboard is left alone. xclip stays alive
        # to own it; keep it off hyprwhspr's stdio pipes.
        subprocess.run(
            ["xclip", "-selection", "primary"],
            input=text,
            text=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        run("xdotool", "key", "shift+Insert")
    else:
        run("xdotool", "type", "--delay", str(TYPE_DELAY_MS), "--", text)


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
    terminal = is_terminal(window)
    inserted, line = compose(text, line, terminal=terminal)
    insert(inserted, terminal=terminal)
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


class TerminalCaret:
    """Screen position of the focused xfce4-terminal's text cursor, via AT-SPI.

    VTE (the terminal widget) exposes its contents and cursor as accessible
    text, so this sees the cursor of whatever runs inside: shell, vim, nvim, ...
    """

    APP = "xfce4-terminal"

    def __init__(self) -> None:
        """Raises ImportError/ValueError (no bindings), ConnectionError (no a11y bus)."""
        import gi

        gi.require_version("Atspi", "2.0")
        from gi.repository import Atspi, Gio, GLib

        # libatspi aborts the process if it can't reach the accessibility bus,
        # so make sure it can first.
        try:
            address = os.environ.get("AT_SPI_BUS_ADDRESS")
            if not address:
                reply = Gio.bus_get_sync(Gio.BusType.SESSION).call_sync(
                    "org.a11y.Bus", "/org/a11y/bus", "org.a11y.Bus", "GetAddress",
                    None, None, Gio.DBusCallFlags.NONE, 1000,
                )  # fmt: skip
                address = reply.unpack()[0]
            flags = Gio.DBusConnectionFlags
            Gio.DBusConnection.new_for_address_sync(
                address,
                flags.AUTHENTICATION_CLIENT | flags.MESSAGE_BUS_CONNECTION,
            ).close_sync()
        except GLib.Error as e:
            raise ConnectionError(e.message) from e

        self.atspi = Atspi
        self.error = GLib.Error
        Atspi.set_timeout(200, 1000)  # ms; don't let a busy terminal freeze us

    def rect(self) -> tuple[int, int, int, int] | None:
        """(x, y, width, height) of the character cell under the cursor, if any."""
        try:
            terminal = self._focused_terminal()
            if terminal is None:
                return None
            text = terminal.get_text_iface()
            r = text.get_character_extents(
                text.get_caret_offset(), self.atspi.CoordType.SCREEN
            )
        except self.error:  # app went away, timed out, ...
            return None
        return (r.x, r.y, r.width, r.height) if r.height > 0 else None

    def _focused_terminal(self):
        Atspi = self.atspi
        desktop = Atspi.get_desktop(0)
        for i in range(desktop.get_child_count()):
            app = desktop.get_child_at_index(i)
            if app is None or app.get_name() != self.APP:
                continue
            for j in range(app.get_child_count()):
                frame = app.get_child_at_index(j)
                if frame and frame.get_state_set().contains(Atspi.StateType.ACTIVE):
                    return self._find_terminal(frame)
        return None

    def _find_terminal(self, node):
        """The focused terminal (i.e. the current tab) under node."""
        Atspi = self.atspi
        states = node.get_state_set()
        if not states.contains(Atspi.StateType.SHOWING):
            return None
        if node.get_role() == Atspi.Role.TERMINAL:
            return node if states.contains(Atspi.StateType.FOCUSED) else None
        for i in range(node.get_child_count()):
            child = node.get_child_at_index(i)
            if child and (found := self._find_terminal(child)):
                return found
        return None


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

    last_pos: tuple[int, int] | None = None
    caret_rect: tuple[int, int, int, int] | None = None

    def place() -> None:
        """Sit under the terminal's text cursor if known, else beside the pointer.

        Flips to the other side near screen edges.
        """
        nonlocal last_pos
        w, h = root.winfo_reqwidth(), root.winfo_reqheight()
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        if caret_rect:
            cx, cy, _, ch = caret_rect
            x = min(cx, sw - w)
            y = cy + ch + OVERLAY_CARET_GAP
            if y + h > sh:
                y = cy - OVERLAY_CARET_GAP - h
        else:
            px, py = root.winfo_pointerxy()
            dx, dy = OVERLAY_POINTER_OFFSET
            x = px + dx if px + dx + w <= sw else px - dx - w
            y = py + dy if py + dy + h <= sh else py - dy - h
        pos = (max(0, x), max(0, y))
        if pos != last_pos:
            last_pos = pos
            root.geometry(f"+{pos[0]}+{pos[1]}")

    def follow() -> None:
        place()
        root.after(OVERLAY_FOLLOW_MS, follow)

    try:
        caret = TerminalCaret()
    except ImportError, ValueError, ConnectionError:  # no bindings / a11y bus
        caret = None

    def track_caret() -> None:
        nonlocal caret_rect
        caret_rect = caret.rect()
        root.after(OVERLAY_CARET_MS, track_caret)

    shown: str | None = None
    last_recording = time.monotonic()

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
        place()

    def poll() -> None:
        nonlocal last_recording
        if is_recording():
            last_recording = time.monotonic()
        elif time.monotonic() - last_recording > OVERLAY_IDLE_EXIT_SECONDS:
            # hyprwhspr stopped by itself (tray, silent mic)
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
        root.after(OVERLAY_POLL_MS, poll)

    root.update()  # map it so the X window exists
    X11().click_through(root.winfo_id())
    poll()
    if caret:
        track_caret()
    follow()
    root.mainloop()


# ---------------------------------------------------------------- session


def start() -> None:
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


def send() -> None:
    if overlay_pid() is None:
        start()
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
