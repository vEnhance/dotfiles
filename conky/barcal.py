import json
from pathlib import Path

CACHE_DIR = Path("~/.cache").expanduser()
assert CACHE_DIR.exists()

with open(CACHE_DIR / "agenda.json") as f:
    events = json.load(f)

raise NotImplementedError("Need to actually write this script LOL")
