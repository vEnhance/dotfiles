from pathlib import Path
from typing import List
import yaml

OTIS_ROOT = Path('~/ProGamer/OTIS/queue/Root/').expanduser()
assert OTIS_ROOT.exists()

# Problem sets
pset_dir = OTIS_ROOT / "Problem sets"
assert pset_dir.exists()
pset_timestamps: List[str] = []
for pset_file in pset_dir.glob('*.venueQ.yaml'):
	with open(pset_file) as f:
		yaml_data = yaml.load(f, Loader=yaml.SafeLoader)
		pset_timestamps.append(yaml_data['upload__content'].split('/')[2])

# Inquiries
with open(OTIS_ROOT / "Inquiries.venueQ.yaml") as f:
	inquiries = yaml.load(f, Loader=yaml.SafeLoader)['inquiries']

# Suggestions
suggest_dir = OTIS_ROOT / "Suggestions"
assert suggest_dir.exists()
suggestion_timestamps: List[str] = []
for suggest_file in suggest_dir.glob('*.venueQ.yaml'):
	with open(suggest_file) as f:
		yaml_data = yaml.load(f, Loader=yaml.SafeLoader)
		suggestion_timestamps.append(yaml_data['created_at'])

print(len(pset_timestamps))
print(min(pset_timestamps or [0]))
print(len(inquiries))
print(len(suggestion_timestamps))
print(min(suggestion_timestamps or [0]))
