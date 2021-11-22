#!/bin/python

from pathlib import Path
from typing import List, Tuple
import yaml
from datetime import datetime, timedelta

## DATA COLLECTION ##

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
inquiry_timestamps = []
with open(OTIS_ROOT / "Inquiries.venueQ.yaml") as f:
	inquiries = yaml.load(f, Loader=yaml.SafeLoader)
	for inquiry in inquiries['inquiries']:
		inquiry_timestamps.append(inquiry['created_at'])

# Suggestions
suggest_dir = OTIS_ROOT / "Suggestions"
assert suggest_dir.exists()
suggestion_timestamps: List[str] = []
for suggest_file in suggest_dir.glob('*.venueQ.yaml'):
	with open(suggest_file) as f:
		yaml_data = yaml.load(f, Loader=yaml.SafeLoader)
		suggestion_timestamps.append(yaml_data['created_at'])


def get_stats(x: List[str]) -> Tuple[timedelta, int]:
	n = len(x)
	if n == 0:
		return (timedelta(0), 0)
	else:
		m = min(x)  # earliest submission not yet covered
		if not 'Z' in m:
			m = m[:10] + 'T' + m[11:13] + ':' + m[14:16]
		else:
			m = m[:19]
		return (datetime.now() - datetime.fromisoformat(m), n)


def get_conky_presentation(x: List[str]) -> str:
	m, n = get_stats(x)
	return (
		r'${alignr}${color7}' + str(int(m.total_seconds() / 3600)) +
		('hr' + r'${color8}' + f' [{n:2d}]')
	)


#print(r'${alignr}${color4}OTIS Vital Signs')
print(get_conky_presentation(pset_timestamps))
print(get_conky_presentation(inquiry_timestamps))
print(get_conky_presentation(suggestion_timestamps))
