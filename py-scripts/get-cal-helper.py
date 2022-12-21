import json
import sys

json_data = json.load(sys.stdin)
if "error" not in json_data:
    with open(sys.argv[1], "w") as f:
        print(json.dumps(json_data), file=f)
else:
    print("No data")
