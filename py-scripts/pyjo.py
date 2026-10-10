"""pyjo: list-view TUI for dijo habits.

Reads and writes ~/.local/share/dijo/habit_record.json in the same format as
dijo (keys sorted, like `jq -S`), so the dijo binary keeps working on it.

Layout: day columns, then the habit names. The view starts as the last week;
moving past its left edge widens it (as far as the terminal allows) and then
scrolls, and the view only scrolls back right once the cursor hits that edge.

Keys:
    j/k        move between habits          0-9, a-f   jump to row 0..15,
                                                       marking bits done
    h/l        move one day back/forward    t          jump back to today
    enter      toggle (bit) or +1 (count)   n / p      +1 / -1 (count)
    u          clear the cell entirely      q          quit
"""

import argparse
import curses
import datetime
import json
import locale
import os
import subprocess
import unicodedata
from pathlib import Path
from typing import Any

DATA_PATH = Path.home() / ".local" / "share" / "dijo" / "habit_record.json"
NOISEMAKER_SH = Path.home() / "dotfiles" / "sh-scripts" / "noisemaker" / "noisemaker.sh"

SHORTCUTS = "0123456789abcdef"
CELL = 6  # width of one day column
CELLS_X = 1
MIN_NAME_WIDTH = 30
DEFAULT_COLS = 7
HEADER_ROWS = 5

C_REACHED = 1
C_TODO = 2
C_TODAY = 3
C_DIM = 4
C_EDIT = 5

HELP = [
    ("hjkl", "move"),
    ("⏎", "toggle/+1"),
    ("n/p", "+1/-1"),
    ("u", "clear"),
    ("t", "today"),
    ("0-f", "jump"),
    ("q", "quit"),
]

Habit = dict[str, Any]


def iso(day: datetime.date) -> str:
    return day.isoformat()


def is_count(habit: Habit) -> bool:
    return habit["type"] == "Count"


def reached(habit: Habit, day: datetime.date) -> bool:
    value = habit["stats"].get(iso(day))
    if value is None:
        return False
    if is_count(habit):
        return value >= habit["goal"]
    return value is True


def text_width(s: str) -> int:
    return sum(2 if unicodedata.east_asian_width(c) in "WF" else 1 for c in s)


def truncate(s: str, width: int) -> str:
    out = []
    used = 0
    for c in s:
        w = text_width(c)
        if used + w > width:
            break
        out.append(c)
        used += w
    return "".join(out)


class Store:
    """The habit file, reloaded if something else (e.g. dijo) touched it."""

    def __init__(self, path: Path) -> None:
        self.path = path
        self.mtime = 0.0
        self.habits: list[Habit] = []
        self.load()

    def load(self) -> None:
        with self.path.open() as f:
            self.habits = json.load(f)
        self.mtime = self.path.stat().st_mtime

    def refresh(self) -> None:
        if self.path.stat().st_mtime != self.mtime:
            self.load()

    def save(self) -> None:
        text = json.dumps(self.habits, indent=2, sort_keys=True, ensure_ascii=False)
        tmp = self.path.with_name(self.path.name + ".pyjo-tmp")
        tmp.write_text(text + "\n")
        tmp.replace(self.path)
        self.mtime = self.path.stat().st_mtime


class PyjoTUI:
    def __init__(self, scr: curses.window, store: Store) -> None:
        self.scr = scr
        self.store = store
        self.cursor = 0
        self.scroll = 0
        self.day = datetime.date.today()
        self.view_start = self.day - datetime.timedelta(days=DEFAULT_COLS - 1)
        self.message = ""
        # (habit name, day) pairs that went from not done to done this session
        self.completed: set[tuple[str, datetime.date]] = set()

    @property
    def habits(self) -> list[Habit]:
        return self.store.habits

    def run(self) -> bool:
        """Run until quit; returns whether anything completed is still done."""
        curses.curs_set(0)
        curses.use_default_colors()
        curses.init_pair(C_REACHED, curses.COLOR_GREEN, -1)
        curses.init_pair(C_TODO, curses.COLOR_RED, -1)
        curses.init_pair(C_TODAY, curses.COLOR_YELLOW, -1)
        curses.init_pair(C_DIM, curses.COLOR_BLUE, -1)
        curses.init_pair(C_EDIT, curses.COLOR_CYAN, -1)
        # Wake up once a minute so the view follows midnight rollover.
        self.scr.timeout(60_000)
        while True:
            self.draw()
            try:
                key = self.scr.get_wch()
            except curses.error:
                continue
            if not self.handle(key):
                return self.still_completed()

    def draw(self) -> None:
        scr = self.scr
        scr.erase()
        height, width = scr.getmaxyx()
        today = datetime.date.today()
        self.day = min(self.day, today)
        days = self.visible_days(today, width)
        name_x = CELLS_X + len(days) * CELL + 1

        title = f"pyjo  {self.day:%a %Y-%m-%d}"
        if self.day != today:
            title += f"  ({(today - self.day).days}d ago)"
        self.put(0, 0, title, curses.A_BOLD)

        for i, day in enumerate(days):
            x = CELLS_X + i * CELL
            if day == self.day:
                attr = curses.color_pair(C_EDIT)
            elif day == today:
                attr = curses.color_pair(C_TODAY)
            else:
                attr = 0
            if day == today:
                attr |= curses.A_BOLD
            self.put(2, x, f"{day:%a}".center(CELL - 1), attr)
            self.put(3, x, f"{day:%m-%d}".center(CELL - 1), attr)
        n_done = sum(reached(h, self.day) for h in self.habits)
        self.put(3, name_x, f"{n_done}/{len(self.habits)} done", curses.A_DIM)

        body_height = max(1, height - HEADER_ROWS - 2)
        if self.cursor < self.scroll:
            self.scroll = self.cursor
        elif self.cursor >= self.scroll + body_height:
            self.scroll = self.cursor - body_height + 1
        visible = self.habits[self.scroll : self.scroll + body_height]
        for row, habit in enumerate(visible, start=self.scroll):
            self.draw_habit(HEADER_ROWS + row - self.scroll, row, habit, days, name_x)

        self.put(height - 2, 0, self.message, curses.A_BOLD)
        x = 0
        for key, desc in HELP:
            self.put(height - 1, x, key, curses.A_BOLD)
            x += text_width(key) + 1
            self.put(height - 1, x, desc, curses.A_DIM)
            x += len(desc) + 3
        scr.refresh()

    def visible_days(self, today: datetime.date, width: int) -> list[datetime.date]:
        """Columns to show, adjusting the view so it contains self.day."""
        max_cols = max(1, (width - MIN_NAME_WIDTH) // CELL)
        self.view_start = min(self.view_start, self.day)

        def n_cols() -> int:
            span = (today - self.view_start).days + 1
            return min(max_cols, max(DEFAULT_COLS, span))

        end = self.view_start + datetime.timedelta(days=n_cols() - 1)
        if self.day > end:
            self.view_start += self.day - end
        return [self.view_start + datetime.timedelta(days=d) for d in range(n_cols())]

    def draw_habit(
        self,
        y: int,
        row: int,
        habit: Habit,
        days: list[datetime.date],
        name_x: int,
    ) -> None:
        selected = row == self.cursor
        for i, day in enumerate(days):
            text, attr = self.cell(habit, day)
            if day == self.day:
                attr |= curses.A_BOLD
                if selected:
                    attr |= curses.A_REVERSE
            self.put(y, CELLS_X + i * CELL, text.center(CELL - 1), attr)

        if row < len(SHORTCUTS):
            self.put(y, name_x, SHORTCUTS[row], curses.A_DIM)

        name = habit["name"]
        if reached(habit, self.day):
            attr = curses.color_pair(C_REACHED) | curses.A_DIM
        else:
            attr = curses.A_NORMAL
        if selected:
            attr |= curses.A_REVERSE
        self.put(y, name_x + 2, name, attr)

    @staticmethod
    def cell(habit: Habit, day: datetime.date) -> tuple[str, int]:
        value = habit["stats"].get(iso(day))
        if is_count(habit):
            text = "·" if value is None else str(value)
        else:
            text = {None: "·", True: "✔", False: "x"}[value]
        if value is None:
            return text, curses.color_pair(C_DIM)
        if reached(habit, day):
            return text, curses.color_pair(C_REACHED)
        return text, curses.color_pair(C_TODO)

    def put(self, y: int, x: int, text: str, attr: int = 0) -> None:
        height, width = self.scr.getmaxyx()
        if not (0 <= y < height) or x >= width:
            return
        text = truncate(text, width - x - (1 if y == height - 1 else 0))
        try:
            self.scr.addstr(y, x, text, attr)
        except curses.error:
            pass

    def handle(self, key: str | int) -> bool:
        self.message = ""
        n = len(self.habits)
        today = datetime.date.today()

        if key in ("q", "Q"):
            return False
        if isinstance(key, str) and key in SHORTCUTS:
            row = SHORTCUTS.index(key)
            if row < n:
                self.cursor = row
                self.edit("complete")
        elif key in ("j", curses.KEY_DOWN):
            self.cursor = min(n - 1, self.cursor + 1)
        elif key in ("k", curses.KEY_UP):
            self.cursor = max(0, self.cursor - 1)
        elif key in ("g", curses.KEY_HOME):
            self.cursor = 0
        elif key in ("G", curses.KEY_END):
            self.cursor = n - 1
        elif key in ("h", curses.KEY_LEFT):
            self.day -= datetime.timedelta(days=1)
        elif key in ("l", curses.KEY_RIGHT):
            self.day = min(today, self.day + datetime.timedelta(days=1))
        elif key == "t":
            self.day = today
            self.view_start = today - datetime.timedelta(days=DEFAULT_COLS - 1)
        elif key in ("\n", "\r", curses.KEY_ENTER, "n", "p", "u"):
            self.edit(key)
        return True

    def still_completed(self) -> bool:
        self.store.refresh()
        by_name = {h["name"]: h for h in self.habits}
        return any(
            name in by_name and reached(by_name[name], day)
            for name, day in self.completed
        )

    def edit(self, key: str | int) -> None:
        if not self.habits:
            return
        self.store.refresh()
        self.cursor = min(self.cursor, len(self.habits) - 1)
        habit = self.habits[self.cursor]
        stats = habit["stats"]
        date = iso(self.day)
        value = stats.get(date)
        was_reached = reached(habit, self.day)

        if key == "complete":  # row shortcut: bit habits get marked done
            if is_count(habit) or value is True:
                return
            stats[date] = True
        elif key == "u":
            if value is None:
                return
            del stats[date]
        elif is_count(habit):
            if key == "p":
                if not value:
                    return
                stats[date] = value - 1
            else:
                stats[date] = (value or 0) + 1
        elif key == "n" or key == "p":
            self.message = "n/p only apply to count habits; use enter to toggle"
            return
        else:
            stats[date] = value is not True
        self.store.save()
        if not was_reached and reached(habit, self.day):
            self.completed.add((habit["name"], self.day))


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(prog="pyjo", description=__doc__.split("\n")[0])
    parser.add_argument(
        "-f", "--file", type=Path, default=DATA_PATH, help="habit_record.json to edit"
    )
    args = parser.parse_args(argv)

    store = Store(args.file)
    locale.setlocale(locale.LC_ALL, "ko_KR.UTF-8")
    os.environ.setdefault("ESCDELAY", "25")
    still_done = curses.wrapper(lambda scr: PyjoTUI(scr, store).run())
    if still_done:
        # Own session, so the sound outlives the terminal closing behind us.
        subprocess.run([NOISEMAKER_SH, "5"], check=False, start_new_session=True)


if __name__ == "__main__":
    main()
