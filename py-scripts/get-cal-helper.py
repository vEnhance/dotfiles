import datetime
import json
import locale
import sys
from pathlib import Path

try:
    locale.setlocale(locale.LC_ALL, "ko_KR.utf8")
except locale.Error:
    pass


CACHE_DIR = Path("~/.cache").expanduser()

json_data = json.load(sys.stdin)
if "error" not in json_data:
    with open(CACHE_DIR / "agenda.json", "w") as f:
        print(json.dumps(json_data), file=f)

    with (
        open(CACHE_DIR / "agenda_today.txt", "w") as today_file,
        open(CACHE_DIR / "agenda_future.txt", "w") as future_file,
    ):
        for data in json_data:
            summary = data["summary"].replace(r"#", r"\#")
            start_date = datetime.date.fromisoformat(data["start_date"])
            start_time = data["start_time"]
            if start_date == datetime.date.today():
                if start_time == "00:00":
                    print(f"지금!  {summary}", file=today_file)
                else:
                    print(f"{start_time}  {summary}", file=today_file)
            elif start_time == "00:00":
                print(f"{start_date.strftime('%a%_d')}    {summary}", file=future_file)
            else:
                print(
                    f"{start_date.strftime('%a%_d')}  {start_time} {summary}",
                    file=future_file,
                )


else:
    print("No data")
    sys.exit(1)
