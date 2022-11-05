import datetime
import json
import sys

json_data = json.load(sys.stdin)
if 'error' not in json_data:
	with open(sys.argv[1], 'w') as f:
		for data in json_data:
			summary = data['summary'].replace(r'#', r'\#')
			start_date = datetime.date.fromisoformat(data['start_date'])
			start_time = data['start_time']
			if start_date == datetime.date.today():
				print(f"{start_time}\t{summary}", file=f)
			else:
				print(f"{start_date.strftime('%a%_d')}\t{start_time} {summary}", file=f)
else:
	print("No data")
