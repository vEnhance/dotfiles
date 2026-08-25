#!/usr/bin/env python3

from datetime import UTC, datetime, timedelta
from pathlib import Path

import yaml

## DATA COLLECTION ##

OTIS_ROOT = Path("/tmp/queue-for-otis/") / "Root"

# Problem sets
pset_dir = OTIS_ROOT / "Problem sets"
pset_timestamps: list[str] = []
if pset_dir.exists():
    for pset_file in pset_dir.glob("*.venueQ.yaml"):
        with open(pset_file) as f:
            yaml_data = yaml.load(f, Loader=yaml.SafeLoader)
            pset_timestamps.append(yaml_data["upload__content"].split("/")[2])

# Petitions
petition_timestamps = []
petitions_path = OTIS_ROOT / "Petitions.venueQ.yaml"
if petitions_path.exists():
    with open(petitions_path) as f:
        petitions = yaml.load(f, Loader=yaml.SafeLoader)
        for petition in petitions["petitions"]:
            petition_timestamps.append(petition["created_at"])


# Suggestions
suggest_dir = OTIS_ROOT / "Suggestions"
suggestion_timestamps: list[str] = []
if suggest_dir.exists():
    for suggest_file in suggest_dir.glob("*.venueQ.yaml"):
        with open(suggest_file) as f:
            yaml_data = yaml.load(f, Loader=yaml.SafeLoader)
            suggestion_timestamps.append(yaml_data["updated_at"])

# Jobs
job_dir = OTIS_ROOT / "Jobs"
job_timestamps: list[str] = []
if job_dir.exists():
    for job_file in job_dir.glob("*.venueQ.yaml"):
        with open(job_file) as f:
            yaml_data = yaml.load(f, Loader=yaml.SafeLoader)
            job_timestamps.append(yaml_data["updated_at"])

# Applications
app_dir = OTIS_ROOT / "Applications"
app_timestamps: list[str] = []
if app_dir.exists():
    for app_file in app_dir.glob("*.venueQ.yaml"):
        with open(app_file) as f:
            yaml_data = yaml.load(f, Loader=yaml.SafeLoader)
            app_timestamps.append(yaml_data["created_at"])

# Notifications
notifications_path = OTIS_ROOT / "Notifications.venueQ.yaml"
notification_timestamps: list[str] = []
if notifications_path.exists():
    with open(notifications_path) as f:
        notifications = yaml.load(f, Loader=yaml.SafeLoader)
        for notification in notifications["notifications"]:
            notification_timestamps.append(notification["updated_at"])


def get_stats(x: list[str]) -> tuple[timedelta, int]:
    n = len(x)
    if n == 0:
        return (timedelta(0), 0)
    else:
        m = min(x)  # earliest submission not yet covered
        if "T" not in m:
            # some crap like 2022-12-26-091745
            m = f"{m[:10]}T{m[11:13]}:{m[13:15]}:{m[15:17]}Z"
        m = m.rstrip("Z")  # take out the trailing Z
        m = m[:19] + "+00:00"  # set in UTC time
        return (datetime.now(UTC) - datetime.fromisoformat(m), n)


def get_conky_presentation(s: str, x: list[str]) -> str:
    m, n = get_stats(x)
    hours = int(m.total_seconds() / 3600)
    if hours > 96:
        days = int(hours / 24)
        t = f"{days:3d}d"
    else:
        t = f"{hours:3d}h"
    return (
        (r"${alignr}${color7}")
        + (s + t)
        + ((r"${color8}" if n > 0 else r"${color1}") + f" {n:2d}개" + r"${color1} 남음")
    )


# print(r'${alignr}${color4}OTIS Vital Signs')
print(get_conky_presentation("요청", petition_timestamps))
print(get_conky_presentation("숙제", pset_timestamps))
print(get_conky_presentation("제안", suggestion_timestamps))
print(get_conky_presentation("지원", app_timestamps))
print(get_conky_presentation("직업", job_timestamps))
print(get_conky_presentation("알림", notification_timestamps))
