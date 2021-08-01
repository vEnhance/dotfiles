import sys
import json
import datetime

for data in json.load(sys.stdin):
	start_date = datetime.date.fromisoformat(data['start_date'])
	if start_date == datetime.date.today():
		print(f"{data['start_time']}\t{data['summary']}")
	else:
		print(f" {start_date.strftime('%a')}\t" \
				f"{data['start_time']} {data['summary']}")
