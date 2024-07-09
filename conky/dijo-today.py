import json
import sys
from datetime import date

today = date.today().strftime(r"%Y-%m-%d")

with open(sys.argv[1]) as f:
    data = json.load(f)
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
