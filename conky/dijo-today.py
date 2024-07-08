import json
import sys
from datetime import date

today = date.today().strftime(r"%Y-%m-%d")

with open(sys.argv[1]) as f:
    data = json.load(f)
for habit in data:
    if habit["type"] == "Bit":
        status = habit["stats"].get(today, False)
        if status is False:
            print(f"*    {habit["name"]}")
