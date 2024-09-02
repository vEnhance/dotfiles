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
    if today not in habit["stats"]:
        goal = int(habit.get("goal", 1))
        print(f"[{goal}]  {habit["name"]}")
