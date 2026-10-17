"""soot: suitcase packing tracker.

Data lives in ~/.local/share/soot/:
    base.md          master packing list (## Category headings, - item bullets)
    trips/<name>.json  per-trip state
    current          name of the active trip

Usage:
    soot init [NAME] -d "2026-10-12 08:00"   start a new trip from base.md
    soot [pack [NAME]]                       open the packing TUI
    soot list                                list trips
    soot use NAME                            switch the active trip
    soot base                                edit base.md in $EDITOR
"""

import argparse
import curses
import datetime
import json
import os
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path

DATA_DIR = Path.home() / ".local" / "share" / "soot"
BASE_PATH = DATA_DIR / "base.md"
TRIPS_DIR = DATA_DIR / "trips"
CURRENT_PATH = DATA_DIR / "current"

DEFAULT_BASE = ""

TODO = "todo"
PACKED = "packed"
WAIT = "wait"
SKIP = "skip"


@dataclass
class Item:
    name: str
    category: str
    status: str = TODO
    wait_hours: float = 0.0
    note: str = ""


@dataclass
class Trip:
    name: str
    departure: datetime.datetime
    items: list[Item]

    @property
    def path(self) -> Path:
        return TRIPS_DIR / f"{self.name}.json"

    def save(self) -> None:
        TRIPS_DIR.mkdir(parents=True, exist_ok=True)
        data = {
            "name": self.name,
            "departure": self.departure.isoformat(timespec="minutes"),
            "items": [asdict(item) for item in self.items],
        }
        tmp = self.path.with_suffix(".json.tmp")
        tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
        tmp.replace(self.path)

    @classmethod
    def load(cls, name: str) -> Trip:
        path = TRIPS_DIR / f"{name}.json"
        if not path.exists():
            sys.exit(f"No trip named {name!r}. Try `soot list`.")
        data = json.loads(path.read_text())
        return cls(
            name=data["name"],
            departure=datetime.datetime.fromisoformat(data["departure"]),
            items=[Item(**d) for d in data["items"]],
        )

    def wait_due(self, item: Item) -> datetime.datetime:
        return self.departure - datetime.timedelta(hours=item.wait_hours)

    def categories(self) -> list[str]:
        """Categories in order of first appearance."""
        return list(dict.fromkeys(item.category for item in self.items))

    def sorted_items(self) -> list[Item]:
        order = {c: i for i, c in enumerate(self.categories())}
        return sorted(self.items, key=lambda item: order[item.category])  # stable


def ensure_base() -> None:
    if not BASE_PATH.exists():
        DATA_DIR.mkdir(parents=True, exist_ok=True)
        BASE_PATH.write_text(DEFAULT_BASE)


def parse_base(text: str) -> list[Item]:
    items: list[Item] = []
    category = "Uncategorized"
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("## "):
            category = stripped[3:].strip()
        elif stripped.startswith(("- ", "* ")):
            items.append(Item(name=stripped[2:].strip(), category=category))
    return items


def parse_time(s: str) -> datetime.datetime:
    """Accept ISO-ish times, falling back to GNU `date -d` for things like 'fri 8am'."""
    try:
        return datetime.datetime.fromisoformat(s).replace(tzinfo=None)
    except ValueError:
        pass
    result = subprocess.run(
        ["date", "-d", s, "+%Y-%m-%dT%H:%M"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise ValueError(f"Can't parse time {s!r}")
    return datetime.datetime.fromisoformat(result.stdout.strip())


def fmt_delta(delta: datetime.timedelta) -> str:
    secs = int(delta.total_seconds())
    sign = "-" if secs < 0 else ""
    secs = abs(secs)
    days, secs = divmod(secs, 86400)
    hours, secs = divmod(secs, 3600)
    mins = secs // 60
    if days:
        return f"{sign}{days}d {hours}h"
    if hours:
        return f"{sign}{hours}h {mins}m"
    return f"{sign}{mins}m"


def fmt_hours(h: float) -> str:
    return f"{h:g}h"


def current_trip_name() -> str:
    if not CURRENT_PATH.exists():
        sys.exit("No active trip. Start one with `soot init -d TIME`.")
    return CURRENT_PATH.read_text().strip()


def set_current(name: str) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    CURRENT_PATH.write_text(name + "\n")


def counts(trip: Trip) -> dict[str, int]:
    out = {TODO: 0, PACKED: 0, WAIT: 0, SKIP: 0}
    for item in trip.items:
        out[item.status] += 1
    return out


C_HEADER, C_CATEGORY, C_PACKED, C_WAIT, C_DUE, C_SKIP, C_NOTE, C_TODO = range(1, 9)

HELP = [
    ("spc/p", "pack"),
    ("w", "wait"),
    ("x", "skip"),
    ("u", "unmark"),
    ("n", "note"),
    ("a/A", "add item/sect"),
    ("d/D", "del item/sect"),
    ("t", "departure"),
    ("q", "quit"),
]


class PackTUI:
    def __init__(self, stdscr: curses.window, trip: Trip) -> None:
        self.scr = stdscr
        self.trip = trip
        self.cursor = 0
        self.scroll = 0
        self.message = ""
        self.pending_section: int | None = None  # first digit of a 2-digit jump

    # Rows are either a category heading (str) or an Item.
    def rows(self) -> list[str | Item]:
        out: list[str | Item] = []
        last = None
        for item in self.trip.sorted_items():
            if item.category != last:
                out.append(item.category)
                last = item.category
            out.append(item)
        return out

    def selected(self) -> Item | None:
        items = self.trip.sorted_items()
        if not items:
            return None
        self.cursor = max(0, min(self.cursor, len(items) - 1))
        return items[self.cursor]

    @staticmethod
    def row_numbers(rows: list[str | Item]) -> list[str]:
        """Digit labels for each row: sections 0-9, items 0-9 within a section."""
        out: list[str] = []
        section = item = -1
        for row in rows:
            if isinstance(row, str):
                section, item = section + 1, -1
                out.append(str(section) if section <= 9 else " ")
            else:
                item += 1
                out.append(str(item) if section <= 9 and item <= 9 else " ")
        return out

    def jump_to_number(self, section: int, item: int = 0) -> None:
        cats = self.trip.categories()
        if section >= len(cats):
            return
        items = self.trip.sorted_items()
        in_section = [i for i, it in enumerate(items) if it.category == cats[section]]
        if item < len(in_section):
            self.cursor = in_section[item]

    def select(self, item: Item) -> None:
        self.cursor = self.trip.sorted_items().index(item)

    def run(self) -> None:
        curses.curs_set(0)
        curses.use_default_colors()
        curses.init_pair(C_HEADER, curses.COLOR_CYAN, -1)
        curses.init_pair(C_CATEGORY, curses.COLOR_MAGENTA, -1)
        curses.init_pair(C_PACKED, curses.COLOR_GREEN, -1)
        curses.init_pair(C_WAIT, curses.COLOR_BLUE, -1)
        curses.init_pair(C_DUE, curses.COLOR_RED, -1)
        curses.init_pair(C_SKIP, 8 if curses.COLORS > 8 else curses.COLOR_WHITE, -1)
        curses.init_pair(C_NOTE, curses.COLOR_YELLOW, -1)
        curses.init_pair(C_TODO, -1, -1)
        while True:
            self.draw()
            key = self.scr.get_wch()
            if key == curses.KEY_RESIZE:
                continue
            if not self.handle(key):
                break

    def draw(self) -> None:
        scr = self.scr
        scr.erase()
        height, width = scr.getmaxyx()
        now = datetime.datetime.now()
        trip = self.trip

        c = counts(trip)
        needed = len(trip.items) - c[SKIP]
        title = (
            f" {trip.name} · leaving {trip.departure:%a %b %d %H:%M}"
            f" (in {fmt_delta(trip.departure - now)})"
        )
        tally = f"{c[PACKED]}/{needed} packed · {c[WAIT]} waiting · {c[TODO]} todo "
        self.put(0, 0, title, curses.color_pair(C_HEADER) | curses.A_BOLD)
        self.put(0, max(len(title) + 2, width - len(tally)), tally, curses.A_DIM)

        rows = self.rows()
        sel = self.selected()
        sel_row = next((i for i, r in enumerate(rows) if r is sel), 0)
        body_top, body_height = 2, max(1, height - 4)
        if sel_row - 1 < self.scroll:  # keep the category heading visible
            self.scroll = max(0, sel_row - 1)
        elif sel_row >= self.scroll + body_height:
            self.scroll = sel_row - body_height + 1

        numbers = self.row_numbers(rows)
        for y, row in enumerate(rows[self.scroll : self.scroll + body_height]):
            num = numbers[self.scroll + y]
            if isinstance(row, str):
                attr = curses.color_pair(C_CATEGORY) | curses.A_BOLD
                self.put(body_top + y, 1, f"{num} {row}", attr)
            else:
                self.put(body_top + y, 3, num, curses.A_DIM)
                self.draw_item(body_top + y, row, now, selected=row is sel)

        self.put(height - 2, 0, self.message, curses.color_pair(C_NOTE))
        x = 0
        for key, desc in HELP:
            self.put(height - 1, x, key, curses.A_BOLD)
            x += len(key) + 1
            self.put(height - 1, x, desc, curses.A_DIM)
            x += len(desc) + 4
        scr.refresh()

    def draw_item(
        self, y: int, item: Item, now: datetime.datetime, *, selected: bool
    ) -> None:
        if item.status == PACKED:
            mark, tag, attr = "[✓]", "", curses.color_pair(C_PACKED)
        elif item.status == SKIP:
            mark, tag, attr = "[✗]", "", curses.color_pair(C_SKIP)
        elif item.status == WAIT:
            due = self.trip.wait_due(item)
            if now >= due:
                mark = "[!]"
                tag = f"PACK NOW (wait {fmt_hours(item.wait_hours)} before)"
                attr = curses.color_pair(C_DUE) | curses.A_BOLD
            else:
                mark = "[~]"
                tag = f"pack {due:%a %H:%M} (in {fmt_delta(due - now)})"
                attr = curses.color_pair(C_WAIT)
        else:
            mark, tag, attr = "[ ]", "", curses.color_pair(C_TODO)

        if selected:
            attr |= curses.A_REVERSE
        x = 5
        name_width = max(len(it.name) for it in self.trip.items)
        text = f"{mark} {item.name:<{name_width}}"
        self.put(y, x, text, attr)
        x += len(text) + 2
        if tag:
            self.put(y, x, tag, attr & ~curses.A_REVERSE | curses.A_ITALIC)
            x += len(tag) + 2
        if item.note:
            self.put(y, x, f"# {item.note}", curses.color_pair(C_NOTE))

    def put(self, y: int, x: int, text: str, attr: int = 0) -> None:
        height, width = self.scr.getmaxyx()
        if not (0 <= y < height) or x >= width:
            return
        text = text[: width - x - (1 if y == height - 1 else 0)]
        try:
            self.scr.addstr(y, x, text, attr)
        except curses.error:
            pass

    def prompt(self, label: str, initial: str = "") -> str | None:
        """Single-line input on the message row. Returns None on Esc."""
        height, width = self.scr.getmaxyx()
        buf = list(initial)
        pos = len(buf)
        curses.curs_set(1)
        try:
            while True:
                y = height - 2
                self.scr.move(y, 0)
                self.scr.clrtoeol()
                line = label + "".join(buf)
                self.put(y, 0, line, curses.A_BOLD)
                self.scr.move(y, min(len(label) + pos, width - 1))
                self.scr.refresh()
                key = self.scr.get_wch()
                if key in ("\n", "\r", curses.KEY_ENTER):
                    return "".join(buf).strip()
                if key == "\x1b":
                    return None
                if key in (curses.KEY_BACKSPACE, "\x7f", "\b"):
                    if pos > 0:
                        del buf[pos - 1]
                        pos -= 1
                elif key == curses.KEY_DC:
                    if pos < len(buf):
                        del buf[pos]
                elif key == curses.KEY_LEFT:
                    pos = max(0, pos - 1)
                elif key == curses.KEY_RIGHT:
                    pos = min(len(buf), pos + 1)
                elif key in (curses.KEY_HOME, "\x01"):
                    pos = 0
                elif key in (curses.KEY_END, "\x05"):
                    pos = len(buf)
                elif key == "\x15":  # ^U
                    del buf[:pos]
                    pos = 0
                elif isinstance(key, str) and key.isprintable():
                    buf.insert(pos, key)
                    pos += 1
        finally:
            curses.curs_set(0)

    def confirm(self, label: str) -> bool:
        answer = self.prompt(f"{label} [y/N] ")
        return answer is not None and answer.lower().startswith("y")

    def handle(self, key: str | int) -> bool:
        self.message = ""
        n = len(self.trip.items)
        item = self.selected()

        pending, self.pending_section = self.pending_section, None
        if isinstance(key, str) and key in "0123456789":
            if pending is None:
                self.jump_to_number(int(key))
                self.pending_section = int(key)
            else:
                self.jump_to_number(pending, int(key))
            return True

        if key in ("q", "Q"):
            return False
        if key in ("j", curses.KEY_DOWN):
            self.cursor = min(n - 1, self.cursor + 1)
        elif key in ("k", curses.KEY_UP):
            self.cursor = max(0, self.cursor - 1)
        elif key in ("g", curses.KEY_HOME):
            self.cursor = 0
        elif key in ("G", curses.KEY_END):
            self.cursor = n - 1
        elif key in ("J", curses.KEY_NPAGE, "\x06"):
            self.cursor = min(n - 1, self.cursor + 10)
        elif key in ("K", curses.KEY_PPAGE, "\x02"):
            self.cursor = max(0, self.cursor - 10)
        elif key in ("}", "]"):
            self.jump_category(+1)
        elif key in ("{", "["):
            self.jump_category(-1)
        elif key == "a":
            self.add_item()
        elif key == "A":
            self.add_section()
        elif key == "t":
            self.edit_departure()
        elif item is None:
            pass
        elif key in (" ", "p", "\n"):
            item.status = TODO if item.status == PACKED else PACKED
            self.advance_if(item.status == PACKED)
        elif key in ("x", "s"):
            item.status = TODO if item.status == SKIP else SKIP
            self.advance_if(item.status == SKIP)
        elif key == "u":
            item.status = TODO
        elif key == "w":
            initial = (
                fmt_hours(item.wait_hours).rstrip("h") if item.status == WAIT else ""
            )
            answer = self.prompt("Pack how many hours before leaving? ", initial)
            if answer:
                try:
                    hours = float(answer.rstrip("hH"))
                except ValueError:
                    self.message = f"Not a number: {answer!r}"
                else:
                    item.status = WAIT
                    item.wait_hours = hours
                    self.advance_if(True)
        elif key == "n":
            answer = self.prompt("Note: ", item.note)
            if answer is not None:
                item.note = answer
        elif key == "d":
            if self.confirm(f"Delete {item.name!r} from this trip?"):
                self.trip.items.remove(item)
        elif key == "D":
            self.delete_section(item.category)
        else:
            return True
        self.trip.save()
        return True

    def advance_if(self, cond: bool) -> None:
        if cond:
            self.cursor = min(len(self.trip.items) - 1, self.cursor + 1)

    def jump_category(self, direction: int) -> None:
        items = self.trip.sorted_items()
        if not items:
            return
        cats = self.trip.categories()
        cur = cats.index(items[self.cursor].category)
        target = cats[(cur + direction) % len(cats)]
        self.cursor = next(i for i, it in enumerate(items) if it.category == target)

    def add_item(self) -> None:
        name = self.prompt("New item: ")
        if not name:
            return
        sel = self.selected()
        item = Item(name=name, category=sel.category if sel else "Misc")
        self.trip.items.append(item)
        self.select(item)
        self.message = f"Added {name!r} to {item.category}"

    def add_section(self) -> None:
        """Add a section below the current one; it needs at least one item to exist."""
        category = self.prompt("New section: ")
        if not category:
            return
        if any(c.lower() == category.lower() for c in self.trip.categories()):
            self.message = f"Section {category!r} already exists"
            return
        # Normalize order so the new section can be spliced in after the current one.
        self.trip.items = self.trip.sorted_items()
        sel = self.selected()
        at = len(self.trip.items)
        if sel:
            at = 1 + max(
                i for i, it in enumerate(self.trip.items) if it.category == sel.category
            )
        added: list[Item] = []
        while name := self.prompt(f"Item in {category} (blank to finish): "):
            item = Item(name=name, category=category)
            self.trip.items.insert(at + len(added), item)
            added.append(item)
            self.select(item)
            self.draw()
        if added:
            self.message = f"Added section {category!r}"

    def delete_section(self, category: str) -> None:
        members = [it for it in self.trip.sorted_items() if it.category == category]
        if not self.confirm(
            f"Delete section {category!r} ({len(members)} items) from this trip?"
        ):
            return
        self.cursor = self.trip.sorted_items().index(members[0])
        self.trip.items = [it for it in self.trip.items if it.category != category]
        self.message = f"Deleted section {category!r}"

    def edit_departure(self) -> None:
        answer = self.prompt("Departure: ", f"{self.trip.departure:%Y-%m-%d %H:%M}")
        if not answer:
            return
        try:
            self.trip.departure = parse_time(answer)
        except ValueError as e:
            self.message = str(e)


def cmd_init(args: argparse.Namespace) -> None:
    ensure_base()
    try:
        departure = parse_time(args.departure)
    except ValueError as e:
        sys.exit(str(e))
    name = f"{departure:%Y-%m-%d}"
    if args.name:
        name += f"-{args.name}"
    trip = Trip(name=name, departure=departure, items=parse_base(BASE_PATH.read_text()))
    if trip.path.exists() and not args.force:
        sys.exit(f"Trip {name!r} already exists. Use --force to overwrite.")
    trip.save()
    set_current(name)
    print(
        f"Created trip {name!r} leaving {departure:%a %b %d %H:%M} with {len(trip.items)} items."
    )
    print("Run `soot pack` to start packing.")


def cmd_pack(args: argparse.Namespace) -> None:
    name = args.name or current_trip_name()
    trip = Trip.load(name)
    if args.name:
        set_current(name)
    os.environ.setdefault("ESCDELAY", "25")
    curses.wrapper(lambda scr: PackTUI(scr, trip).run())
    trip.save()


def cmd_list(_args: argparse.Namespace) -> None:
    current = CURRENT_PATH.read_text().strip() if CURRENT_PATH.exists() else None
    paths = sorted(TRIPS_DIR.glob("*.json")) if TRIPS_DIR.exists() else []
    if not paths:
        print("No trips yet.")
    for path in paths:
        trip = Trip.load(path.stem)
        c = counts(trip)
        star = "*" if trip.name == current else " "
        print(
            f"{star} {trip.name:20} {trip.departure:%Y-%m-%d %H:%M}  "
            f"{c[PACKED]}/{len(trip.items) - c[SKIP]} packed"
        )


def cmd_use(args: argparse.Namespace) -> None:
    Trip.load(args.name)  # validate
    set_current(args.name)
    print(f"Active trip is now {args.name!r}.")


def cmd_base(_args: argparse.Namespace) -> None:
    ensure_base()
    editor = os.environ.get("EDITOR", "vim")
    subprocess.run([editor, str(BASE_PATH)], check=False)


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(
        prog="soot", description="Suitcase packing tracker."
    )
    parser.set_defaults(func=cmd_pack, name=None)  # bare `soot` = `soot pack`
    sub = parser.add_subparsers(dest="command")

    p = sub.add_parser("init", help="start a new trip from base.md")
    p.add_argument(
        "name", nargs="?", help="trip name, prefixed with the departure date"
    )
    p.add_argument(
        "-d",
        "--departure",
        required=True,
        help="departure time, e.g. '2026-10-12 08:00' or 'fri 8am'",
    )
    p.add_argument("-f", "--force", action="store_true", help="overwrite existing trip")
    p.set_defaults(func=cmd_init)

    p = sub.add_parser("pack", help="open the packing TUI")
    p.add_argument("name", nargs="?", help="trip name (default: active trip)")
    p.set_defaults(func=cmd_pack)

    p = sub.add_parser("list", help="list trips")
    p.set_defaults(func=cmd_list)

    p = sub.add_parser("use", help="switch the active trip")
    p.add_argument("name")
    p.set_defaults(func=cmd_use)

    p = sub.add_parser("base", help="edit the master list in $EDITOR")
    p.set_defaults(func=cmd_base)

    args = parser.parse_args(argv)
    args.func(args)


if __name__ == "__main__":
    main()
