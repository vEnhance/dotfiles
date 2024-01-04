#!/bin/python

import datetime
import sys
from typing import Any, List

now = datetime.datetime.now()

hour = now.hour % 12
minute = now.minute
second = now.second

data: List[List[Any]] = [
    [52.5, 55, 57.5, 0, 2.5, 5, 7.5],
    [50, None, "E", "0", "1", None, 10],
    [47.5, "T", None, None, None, "2", 12.5],
    [45, "9", None, None, None, "3", 15],
    [42.5, "8", None, None, None, "4", 17.5],
    [40, None, "7", "6", "5", None, 20],
    [37.5, 35, 32.5, 30, 27.5, 25, 22.5],
]

if len(sys.argv) > 2:
    fontsize, offset = sys.argv[1], sys.argv[2]
else:
    fontsize, offset = "12", "230"

print(r"${font DejaVu Sans Mono:size=" + fontsize + "}")
for row in data:
    s = "${goto " + offset + "}"
    for x in row:
        if x is None:
            s += " "
        elif isinstance(x, str):
            if x == "T":
                h = 10
            elif x == "E":
                h = 11
            else:
                h = int(x)
            if hour >= h:
                s += r"${color #FFAAAA}"
                s += r"${font DejaVu Sans Mono:bold:size=" + fontsize + "}"
                s += x
                s += r"${font DejaVu Sans Mono:size=" + fontsize + "}"
            else:
                s += r"${color #999999}"
                s += x
        elif isinstance(x, float) or isinstance(x, int):
            if (minute + second / 60) >= x:
                s += r"${color #66DDDD}◘"
            else:
                s += r"${color #226666}◘"
        s += " "
    print(s)
