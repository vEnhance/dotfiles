#!/bin/python

from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import List, Tuple

import yaml

## DATA COLLECTION ##

OTIS_ROOT = Path("~/Sync/OTIS/queue/Root/").expanduser()
assert OTIS_ROOT.exists()

# Problem sets
pset_dir = OTIS_ROOT / "Problem sets"
pset_timestamps: List[str] = []
if pset_dir.exists():
    for pset_file in pset_dir.glob("*.venueQ.yaml"):
        with open(pset_file) as f:
            yaml_data = yaml.load(f, Loader=yaml.SafeLoader)
            pset_timestamps.append(yaml_data["upload__content"].split("/")[2])

# Inquiries
inquiry_timestamps = []
inquiries_path = OTIS_ROOT / "Inquiries.venueQ.yaml"
if inquiries_path.exists():
    with open(inquiries_path) as f:
        inquiries = yaml.load(f, Loader=yaml.SafeLoader)
        for inquiry in inquiries["inquiries"]:
            inquiry_timestamps.append(inquiry["created_at"])

# Suggestions
suggest_dir = OTIS_ROOT / "Suggestions"
suggestion_timestamps: List[str] = []
if suggest_dir.exists():
    for suggest_file in suggest_dir.glob("*.venueQ.yaml"):
        with open(suggest_file) as f:
            yaml_data = yaml.load(f, Loader=yaml.SafeLoader)
            suggestion_timestamps.append(yaml_data["updated_at"])

# Jobs
job_dir = OTIS_ROOT / "Jobs"
job_timestamps: List[str] = []
if job_dir.exists():
    for job_file in job_dir.glob("*.venueQ.yaml"):
        with open(job_file) as f:
            yaml_data = yaml.load(f, Loader=yaml.SafeLoader)
            job_timestamps.append(yaml_data["updated_at"])


def get_stats(x: List[str]) -> Tuple[timedelta, int]:
    n = len(x)
    if n == 0:
        return (timedelta(0), 0)
    else:
        m = min(x)  # earliest submission not yet covered
        if not "T" in m:
            # some crap like 2022-12-26-091745
            m = f"{m[:10]}T{m[11:13]}:{m[13:15]}:{m[15:17]}Z"
        m = m.rstrip("Z")  # take out the trailing Z
        m = m[:19] + "+00:00"  # set in UTC time
        return (datetime.now(timezone.utc) - datetime.fromisoformat(m), n)


def get_conky_presentation(s: str, x: List[str]) -> str:
    m, n = get_stats(x)
    hours = int(m.total_seconds() / 3600)
    if hours > 96:
        days = int(hours / 24)
        t = f"{days:3d}d"
    else:
        t = f"{hours:3d}h"
    return (r"${alignr}${color7}") + (s + t) + (r"${color8}" + f" [{n:2d}]")


# print(r'${alignr}${color4}OTIS Vital Signs')
print(get_conky_presentation("Inqr", inquiry_timestamps))
print(get_conky_presentation("PSet", pset_timestamps))
print(get_conky_presentation("Sugg", suggestion_timestamps))
print(get_conky_presentation("Jobs", job_timestamps))
