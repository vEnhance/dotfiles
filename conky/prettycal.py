import functools
import json
import locale
import subprocess
from collections import defaultdict
from datetime import date, datetime, timedelta
from enum import IntEnum
from itertools import chain
from pathlib import Path
from socket import gethostname
from typing import Dict, List, Optional

from dateutil.parser import isoparse

try:
    locale.setlocale(locale.LC_ALL, "ko_KR.utf8")
except locale.Error:
    pass

NUM_ROWS = 15
HOSTNAME = gethostname()
if HOSTNAME in ("ArchScythe", "ArchSapphire"):
    NUM_COL = 2
elif HOSTNAME in ("ArchMajestic", "ArchBootes"):
    NUM_COL = 3
elif HOSTNAME in ("ArchDiamond",):
    NUM_COL = 5
else:
    NUM_COL = 2

if NUM_COL == 2:
    FONT_SIZE = 14
elif NUM_COL == 3:
    FONT_SIZE = 18
elif NUM_COL >= 4:
    FONT_SIZE = 20
else:
    FONT_SIZE = 18


class Type(IntEnum):
    NOW = 0
    CALENDAR = 1
    SCHEDULED = 2
    WAITING = 3
    DUE = 4


@functools.total_ordering
class CalItem:
    def __init__(self, text: str, when: datetime, t: Type, color: Optional[str] = None):
        self.text = text
        self.when = when
        self.type = t
        self.color = color

    def __str__(self):
        return self.text

    def __repr__(self):
        return self.text

    def __lt__(self, other):
        if self.when.date() < other.when.date():
            return True
        elif self.when.date() > other.when.date():
            return False
        elif self.type < other.type:
            return True
        elif self.type > other.type:
            return False
        elif self.when < other.when:
            return True
        elif self.when > other.when:
            return False
        return self.text < other.text

    def __eq__(self, other):
        return (
            self.when == other.when
            and self.type == other.type
            and self.text == other.text
        )

    def conky_repr(self, offset=None, needs_date=False, truncate=36):
        s = ""
        s += r"${font Noto Sans CJK KR:normal:size=%d}" % FONT_SIZE
        if self.type == Type.DUE:
            s += r"${color ffbbbb}[마감] "
        elif self.type == Type.SCHEDULED:
            s += r"${color ccccff}[예정]${offset 3} "
        elif self.type == Type.WAITING:
            s += r"${color bbffbb}[보류] "
        if self.type == Type.CALENDAR:
            s += r"${color ffffff}${font Noto Sans CJK KR:italic:size=%d}" % FONT_SIZE
            s += f"{self.when.hour:02d}:{self.when.minute:02d} "
        if offset is not None:
            s += r"${goto " + str(offset) + "}"
        if needs_date is True:
            if self.type == Type.CALENDAR:
                s += r"${color 00ff00}"
            elif self.type == Type.DUE:
                s += r"${color cc7777}"
            elif self.type == Type.NOW:
                s += r"${color eeeeee}"
            else:
                s += r"${color 99bb99}"
            s += r"${font Noto Sans CJK KR:size=%d}" % FONT_SIZE
            s += f"{self.when.date().strftime('%a %b%d일')} "
            if self.type == Type.CALENDAR or self.type == Type.NOW:
                s += r"${voffset 1}"
        s += r"${voffset -2}${font Noto Sans CJK KR:normal:size=%d}" % (
            int(0.9 * FONT_SIZE)
        )
        s += r"${color " + (self.color or "dddddd") + r"}"
        s += f"{self.text[:truncate]}"
        return s


all_items: Dict[Optional[date], List[CalItem]] = defaultdict(list)

# Get taskwarrior stuff
task_cmd_args = "task status:pending or status:waiting export".split(" ")
tasks_json = subprocess.run(task_cmd_args, capture_output=True).stdout.decode("utf-8")
tasks_dicts = json.loads(tasks_json)
for t in tasks_dicts:
    text = t["description"]
    if "scheduled" in t:
        calitem = CalItem(text, isoparse(t["scheduled"]), Type.SCHEDULED)
    elif "wait" in t:
        calitem = CalItem(text, isoparse(t["wait"]), Type.WAITING)
    elif "due" in t:
        calitem = CalItem(text, isoparse(t["due"]), Type.DUE)
    else:
        calitem = CalItem(text, datetime.now(), Type.NOW)
    all_items[calitem.when.date() if calitem.type != Type.NOW else None].append(calitem)

# Get google calendar stuff
agenda_text = Path("~/.cache/agenda.json").expanduser()
for d in json.loads(agenda_text.read_text()):
    when = isoparse(d["start_date"] + "T" + d["start_time"])
    calitem = CalItem(
        d["summary"], when, Type.CALENDAR, color=d["calendar_color"][1:]
    )  # remove hashtag
    all_items[when.date()].append(calitem)

ORDER = []
for i in range(NUM_COL):
    ORDER += [i, i + NUM_COL]

today = date.today()
table = [["" for _ in range(NUM_COL + 1)] for _ in range(NUM_ROWS * 2 + 2)]

HEADER_Y_FIRST = 0
HEADER_Y_SECOND = NUM_ROWS + 1


def offset(x):
    return 512 * x + 20


def offset_indented(x):
    return 512 * x + 93


def goto_offset(x):
    return r"${goto " + str(offset(x)) + "}"


for i in ORDER:
    current_day = today + timedelta(days=i)
    items = all_items.pop(current_day, [])
    items.sort()
    x = 1 + (i % NUM_COL)
    for n, item in enumerate(items[:NUM_ROWS]):
        y = (n + 1) + (1 + NUM_ROWS if i >= NUM_COL else 0)
        table[y][x] = item.conky_repr(needs_date=False, offset=offset_indented(x))

    y0 = HEADER_Y_FIRST if i < NUM_COL else HEADER_Y_SECOND
    table[y0][x] = current_day.strftime("%a %b%d일")

table[HEADER_Y_FIRST][0] = (
    r"${font Noto Sans CJK KR:size=%d:bold}${color 55ff99}Upcoming Events"
    % (FONT_SIZE + 3)
)
table[HEADER_Y_SECOND][0] = (
    r"${font Noto Sans CJK KR:size=%d:bold}${color ff5599}Other Tasks" % (FONT_SIZE + 3)
)
remaining = sorted(chain(*all_items.values()))


def criteria(item):
    return item.type == Type.CALENDAR or item.type == Type.NOW


remaining_calendar = [item for item in remaining if criteria(item)]
for n, item in enumerate(remaining_calendar[:NUM_ROWS]):
    table[n + 1][0] = item.conky_repr(
        needs_date=True, truncate=24, offset=offset_indented(0)
    )
remaining_tasks = [item for item in remaining if not criteria(item)]
remaining_tasks.sort(key=lambda item: item.when)
for n, item in enumerate(remaining_tasks[:NUM_ROWS]):
    table[HEADER_Y_SECOND + n + 1][0] = item.conky_repr(
        needs_date=True, truncate=24, offset=offset_indented(0)
    )

table[HEADER_Y_FIRST][1] = r"${color ddeeff}" + table[HEADER_Y_FIRST][1]
table[HEADER_Y_FIRST][2] = r"${color 66aaff}" + table[HEADER_Y_FIRST][2]
table[HEADER_Y_FIRST][-1] += r"${font Noto Sans CJK KR:size=%d}" % FONT_SIZE
table[HEADER_Y_SECOND - 1][-1] += "\n" + r"${goto 15}${color bbbbbb}${stippled_hr}"
table[HEADER_Y_SECOND][1] = r"${color 66aaff}" + table[HEADER_Y_SECOND][1]
table[HEADER_Y_SECOND][-1] += r"${font Noto Sans CJK KR:size=%d}" % FONT_SIZE

for row in table:
    print("".join(goto_offset(i) + row[i] for i in range(NUM_COL + 1)))
