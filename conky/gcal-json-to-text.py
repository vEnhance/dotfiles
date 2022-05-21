import sys
import json
import datetime

json_data = json.load(sys.stdin)
if 'error' not in json_data:
	with open(sys.argv[1], 'w') as f:
		for data in json_data:
			start_date = datetime.date.fromisoformat(data['start_date'])
			if start_date == datetime.date.today():
				print(f"{data['start_time']}\t{data['summary']}", file=f)
			else:
				print(f"{start_date.strftime('%a%_d')}\t{data['start_time']} {data['summary']}", file=f)
else:
	print("No data")
