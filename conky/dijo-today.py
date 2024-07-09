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
    if habit["type"] == "Bit":
        status = int(habit["stats"].get(today, False))
        goal = 1
    elif habit["type"] == "Count":
        status = habit["stats"].get(today, 0)
        goal = habit["goal"]
    else:
        continue
    if status < goal:
        print(f"[{goal-status}]  {habit["name"]}")
