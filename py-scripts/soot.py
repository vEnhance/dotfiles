"""soot: suitcase packing tracker.

Data lives in ~/.local/share/soot/ (override with --dir):
    base.md          master packing list (## Category headings, - item bullets)
    trips/<name>.json  per-trip state
    current          name of the active trip

Usage:
    soot init [NAME] -d 2026-10-12   start a new trip from base.md
    soot dupe [NAME] -d 2026-10-19   start a new trip from the active trip's items
    soot [pack [NAME]]               open the packing TUI
    soot list                        list trips
    soot use NAME                    switch the active trip
    soot base                        edit base.md in $EDITOR
"""

import argparse
import curses
import datetime
import json
import os
import subprocess
import sys
from dataclasses import asdict, dataclass, replace
from itertools import groupby
from pathlib import Path

DATA_DIR = Path.home() / ".local" / "share" / "soot"
BASE_PATH = DATA_DIR / "base.md"
TRIPS_DIR = DATA_DIR / "trips"
CURRENT_PATH = DATA_DIR / "current"


def set_data_dir(path: Path) -> None:
    global DATA_DIR, BASE_PATH, TRIPS_DIR, CURRENT_PATH
    DATA_DIR = path
    BASE_PATH = DATA_DIR / "base.md"
    TRIPS_DIR = DATA_DIR / "trips"
    CURRENT_PATH = DATA_DIR / "current"


TODO = "todo"
PACKED = "packed"
WAIT = "wait"
SKIP = "skip"


@dataclass
class Item:
    name: str
    category: str
    status: str = TODO
    note: str = ""


@dataclass
class Trip:
    name: str
    departure: datetime.date
    items: list[Item]

    @property
    def path(self) -> Path:
        return TRIPS_DIR / f"{self.name}.json"

    def save(self) -> None:
        TRIPS_DIR.mkdir(parents=True, exist_ok=True)
        data = {
            "name": self.name,
            "departure": self.departure.isoformat(),
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
            departure=datetime.date.fromisoformat(data["departure"]),
            items=[Item(**d) for d in data["items"]],
        )

    def categories(self) -> list[str]:
        """Categories in order of first appearance."""
        return list(dict.fromkeys(item.category for item in self.items))

    def sorted_items(self) -> list[Item]:
        order = {c: i for i, c in enumerate(self.categories())}
        return sorted(self.items, key=lambda item: order[item.category])  # stable


def ensure_base() -> None:
    if not BASE_PATH.exists():
        DATA_DIR.mkdir(parents=True, exist_ok=True)
        BASE_PATH.touch()


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


def parse_date(s: str) -> datetime.date:
    """Accept ISO dates, falling back to GNU `date -d` for things like 'fri'."""
    try:
        return datetime.date.fromisoformat(s)
    except ValueError:
        pass
    result = subprocess.run(
        ["date", "-d", s, "+%Y-%m-%d"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise ValueError(f"Can't parse date {s!r}")
    return datetime.date.fromisoformat(result.stdout.strip())


def fmt_days_until(date: datetime.date) -> str:
    days = (date - datetime.date.today()).days
    if days == 0:
        return "today"
    if days == 1:
        return "tomorrow"
    if days > 0:
        return f"in {days} days"
    return f"{-days} days ago"


def current_trip_name() -> str:
    if not CURRENT_PATH.exists():
        sys.exit("No active trip. Start one with `soot init -d DATE`.")
    return CURRENT_PATH.read_text().strip()


def set_current(name: str) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    CURRENT_PATH.write_text(name + "\n")


def counts(trip: Trip) -> dict[str, int]:
    out = {TODO: 0, PACKED: 0, WAIT: 0, SKIP: 0}
    for item in trip.items:
        out[item.status] += 1
    return out


JUMP_KEYS = "0123456789abcdef"

C_HEADER, C_CATEGORY, C_PACKED, C_WAIT, C_SKIP, C_NOTE, C_TODO = range(1, 8)

MARKS = {
    PACKED: ("[✓]", C_PACKED),
    SKIP: ("[✗]", C_SKIP),
    WAIT: ("[!]", C_WAIT),
    TODO: ("[ ]", C_TODO),
}

HELP = [
    ("spc/p", "pack"),
    ("w", "wait"),
    ("s", "skip"),
    ("u", "unmark"),
    ("n", "note"),
    ("o/O", "add item/sect"),
    ("x/X", "del item/sect"),
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
        self.pending_section: int | None = None  # first key of a 2-key jump

    # Rows are either a category heading (str) or an Item.
    def rows(self) -> list[str | Item]:
        out: list[str | Item] = []
        for category, items in groupby(
            self.trip.sorted_items(), lambda it: it.category
        ):
            out.append(category)
            out.extend(items)
        return out

    def selected(self) -> Item | None:
        items = self.trip.sorted_items()
        if not items:
            return None
        self.cursor = max(0, min(self.cursor, len(items) - 1))
        return items[self.cursor]

    @staticmethod
    def row_numbers(rows: list[str | Item]) -> list[str]:
        """Jump-key labels for each row: sections 0-f, items 0-f within a section."""
        out: list[str] = []
        section = item = -1
        n = len(JUMP_KEYS)
        for row in rows:
            if isinstance(row, str):
                section, item = section + 1, -1
                out.append(JUMP_KEYS[section] if section < n else " ")
            else:
                item += 1
                out.append(JUMP_KEYS[item] if section < n and item < n else " ")
        return out

    def section_indices(self, category: str) -> list[int]:
        """Cursor positions of the items in a section."""
        items = self.trip.sorted_items()
        return [i for i, it in enumerate(items) if it.category == category]

    def jump_to_number(self, section: int, item: int = 0) -> None:
        cats = self.trip.categories()
        if section >= len(cats):
            return
        in_section = self.section_indices(cats[section])
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
        trip = self.trip

        c = counts(trip)
        needed = len(trip.items) - c[SKIP]
        title = (
            f" {trip.name} · leaving {trip.departure:%a %b %d}"
            f" ({fmt_days_until(trip.departure)})"
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
                self.draw_item(body_top + y, row, selected=row is sel)

        self.put(height - 2, 0, self.message, curses.color_pair(C_NOTE))
        x = 0
        for key, desc in HELP:
            self.put(height - 1, x, key, curses.A_BOLD)
            x += len(key) + 1
            self.put(height - 1, x, desc, curses.A_DIM)
            x += len(desc) + 4
        scr.refresh()

    def draw_item(self, y: int, item: Item, *, selected: bool) -> None:
        mark, color = MARKS[item.status]
        attr = curses.color_pair(color)
        if selected:
            attr |= curses.A_REVERSE
        x = 5
        name_width = max(len(it.name) for it in self.trip.items)
        text = f"{mark} {item.name:<{name_width}}"
        self.put(y, x, text, attr)
        x += len(text) + 2
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
        if isinstance(key, str) and len(key) == 1 and key in JUMP_KEYS:
            num = JUMP_KEYS.index(key)
            if pending is None:
                self.jump_to_number(num)
                self.pending_section = num
            else:
                self.jump_to_number(pending, num)
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
        elif key == "o":
            self.add_item()
        elif key == "O":
            self.add_section()
        elif key == "t":
            self.edit_departure()
        elif item is None:
            pass
        elif key in (" ", "p", "\n"):
            self.toggle(item, PACKED)
        elif key == "s":
            self.toggle(item, SKIP)
        elif key == "w":
            self.toggle(item, WAIT)
        elif key == "u":
            item.status = TODO
        elif key == "n":
            answer = self.prompt("Note: ", item.note)
            if answer is not None:
                item.note = answer
        elif key == "x":
            if self.confirm(f"Delete {item.name!r} from this trip?"):
                self.trip.items.remove(item)
        elif key == "X":
            self.delete_section(item.category)
        else:
            return True
        self.trip.save()
        return True

    def toggle(self, item: Item, status: str) -> None:
        """Flip between `status` and todo, moving on to the next item when set."""
        if item.status == status:
            item.status = TODO
        else:
            item.status = status
            self.cursor = min(len(self.trip.items) - 1, self.cursor + 1)

    def jump_category(self, direction: int) -> None:
        sel = self.selected()
        if sel is None:
            return
        cats = self.trip.categories()
        target = cats[(cats.index(sel.category) + direction) % len(cats)]
        self.cursor = self.section_indices(target)[0]

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
        at = self.section_indices(sel.category)[-1] + 1 if sel else 0
        while name := self.prompt(f"Item in {category} (blank to finish): "):
            item = Item(name=name, category=category)
            self.trip.items.insert(at, item)
            at += 1
            self.select(item)
            self.draw()
        if category in self.trip.categories():
            self.message = f"Added section {category!r}"

    def delete_section(self, category: str) -> None:
        indices = self.section_indices(category)
        if not self.confirm(
            f"Delete section {category!r} ({len(indices)} items) from this trip?"
        ):
            return
        self.cursor = indices[0]
        self.trip.items = [it for it in self.trip.items if it.category != category]
        self.message = f"Deleted section {category!r}"

    def edit_departure(self) -> None:
        answer = self.prompt("Departure: ", self.trip.departure.isoformat())
        if not answer:
            return
        try:
            self.trip.departure = parse_date(answer)
        except ValueError as e:
            self.message = str(e)


def cmd_init(args: argparse.Namespace) -> None:
    ensure_base()
    create_trip(args, parse_base(BASE_PATH.read_text()))


def cmd_dupe(args: argparse.Namespace) -> None:
    """Start a trip (e.g. the return leg) from everything not skipped in another."""
    source = Trip.load(args.source or current_trip_name())
    items = [replace(it, status=TODO) for it in source.items if it.status != SKIP]
    create_trip(args, items)


def create_trip(args: argparse.Namespace, items: list[Item]) -> None:
    try:
        departure = parse_date(args.departure)
    except ValueError as e:
        sys.exit(str(e))
    name = f"{departure:%Y-%m-%d}"
    if args.name:
        name += f"-{args.name}"
    trip = Trip(name=name, departure=departure, items=items)
    if trip.path.exists() and not args.force:
        sys.exit(f"Trip {name!r} already exists. Use --force to overwrite.")
    trip.save()
    set_current(name)
    print(
        f"Created trip {name!r} leaving {departure:%a %b %d} with {len(trip.items)} items."
    )
    print("Run `soot pack` to start packing.")


def cmd_pack(args: argparse.Namespace) -> None:
    name = args.name or current_trip_name()
    trip = Trip.load(name)
    if args.name:
        set_current(name)
    os.environ.setdefault("ESCDELAY", "25")
    curses.wrapper(lambda scr: PackTUI(scr, trip).run())


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
            f"{star} {trip.name:20} {trip.departure}  "
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
    parser.add_argument(
        "--dir", type=Path, help=f"data directory (default: {DATA_DIR})"
    )
    sub = parser.add_subparsers(dest="command")

    new_trip = argparse.ArgumentParser(add_help=False)
    new_trip.add_argument(
        "name", nargs="?", help="trip name, prefixed with the departure date"
    )
    new_trip.add_argument(
        "-d",
        "--departure",
        required=True,
        help="departure date, e.g. '2026-10-12' or 'fri'",
    )
    new_trip.add_argument(
        "-f", "--force", action="store_true", help="overwrite existing trip"
    )

    p = sub.add_parser("init", parents=[new_trip], help="start a new trip from base.md")
    p.set_defaults(func=cmd_init)

    p = sub.add_parser(
        "dupe",
        parents=[new_trip],
        help="start a new trip from another trip's non-skipped items",
    )
    p.add_argument(
        "--from", dest="source", help="trip to copy from (default: active trip)"
    )
    p.set_defaults(func=cmd_dupe)

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
    if args.dir:
        set_data_dir(args.dir)
    args.func(args)


if __name__ == "__main__":
    main()
