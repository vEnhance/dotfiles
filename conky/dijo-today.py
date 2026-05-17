import json
from datetime import date
from pathlib import Path

today = date.today().strftime(r"%Y-%m-%d")
DIJO_DIR = Path("~/.local/share/dijo").expanduser()

with open(DIJO_DIR / "habit_record.json") as f:
    data = json.load(f)
with open(DIJO_DIR / "habit_record[auto].json") as f:
    data += json.load(f)

for habit in data:
    if habit["type"] == "Count":
        goal = habit.get("goal", 1)
        progress = habit["stats"].get(today, 0)
        if progress < goal:
            print(f"[{goal - progress}]  {habit['name']}")
    else:
        if today not in habit["stats"]:
            print(f"[*]  {habit['name']}")
