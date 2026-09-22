#!/usr/bin/env python3

# Prints the [ Current Event ], [ Today ], and [ Upcoming ] sections of
# summary-bar.conf, reading the agenda cached by sh-scripts/get-cal.sh.

import datetime
import json
import locale
from pathlib import Path

AGENDA_JSON = Path("~/.cache/agenda.json").expanduser()

# how early an upcoming event starts showing up under [ Current Event ]
LEAD = datetime.timedelta(minutes=15)

# per-line colors; their length also caps how many lines each section shows
TODAY_COLORS = (9, 8, 4, 5, 6, 6, 6, 6, 6)
FUTURE_COLORS = (8, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6)

try:
    locale.setlocale(locale.LC_ALL, "ko_KR.utf8")
except locale.Error:
    pass


def header(title: str) -> str:
    return f"${{font1}}${{color1}}[ {title} ] ${{voffset 2}}${{hr 2}}${{font4}}"


def load_events() -> list[dict[str, str]]:
    try:
        with open(AGENDA_JSON) as f:
            json_data = json.load(f)
    except OSError, json.JSONDecodeError:
        return []
    if not isinstance(json_data, list):
        return []
    return json_data


def summary_of(data: dict[str, str]) -> str:
    summary = data["summary"].replace(r"#", r"\#").strip()
    return "바쁨" if summary == "NO_TITLE" else summary


def stamp(date_str: str, time_str: str) -> datetime.datetime:
    return datetime.datetime.fromisoformat(f"{date_str}T{time_str}")


def bullet(data: dict[str, str]) -> str:
    # conky retries a color with a "#" prepended, so bare hex is what we want
    # here: a literal "#" would start a comment and swallow the rest of the line
    color = data.get("calendar_color", "").lstrip("#").strip()
    return f"${{color {color}}}●" if color else "${color9}●"


now = datetime.datetime.now()
today = now.date()

current_lines: list[str] = []
today_lines: list[str] = []
future_lines: list[str] = []

for data in load_events():
    summary = summary_of(data)
    start_date = datetime.date.fromisoformat(data["start_date"])
    start_time = data["start_time"]
    all_day = start_time == "00:00"

    if not all_day:
        start = stamp(data["start_date"], start_time)
        end = stamp(data["end_date"], data["end_time"])
        if start - LEAD <= now < end:
            current_lines.append(
                f"{bullet(data)} ${{color9}}{start_time} - {data['end_time']}"
            )
            current_lines.append(f"${{color9}}   {summary}")
            continue  # no need to repeat it under [ Today ] as well

    if start_date == today:
        if all_day:
            today_lines.append(f"지금!  {summary}")
        else:
            today_lines.append(f"{start_time}  {summary}")
    elif all_day:
        future_lines.append(f"{start_date.strftime('%a%_d')}    {summary}")
    else:
        future_lines.append(f"{start_date.strftime('%a%_d')}  {start_time} {summary}")

out: list[str] = []

if current_lines:
    out.append(header("Current"))
    out += [f"${{font6}}{line}" for line in current_lines]
    out.append("${voffset 5}")

out.append(header("Today"))
out += [f"${{color{color}}}{line}" for color, line in zip(TODAY_COLORS, today_lines)]
out.append("${voffset 5}")

out.append(header("Upcoming"))
out += [f"${{color{color}}}{line}" for color, line in zip(FUTURE_COLORS, future_lines)]

print("\n".join(out))
