#!/usr/bin/python
from __future__ import print_function

from datetime import time
from zoneinfo import ZoneInfo

DEFAULT_TIME = time(22, 0, 0)  # Your wanted default time

local_zone = ZoneInfo('localtime')


def is_local_midnight(timestamp):
    return timestamp.astimezone(local_zone).time() == time(0, 0, 0)


def set_default_time(timestamp):
    return timestamp.astimezone(local_zone).replace(
        hour=DEFAULT_TIME.hour,
        minute=DEFAULT_TIME.minute,
        second=DEFAULT_TIME.second,
    )


def hook_default_time(task):
    if task['due'] and is_local_midnight(task['due']):
        task['due'] = set_default_time(task['due'])
        print(f"Default due time has been set to {task['due']}.")
