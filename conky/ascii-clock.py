#!/bin/python

import datetime
from typing import Any, List

now = datetime.datetime.now()

hour = now.hour % 12
minute = now.minute
second = now.second

data: List[List[Any]] = [
	[52.5, 55, 57.5, 0, 2.5, 5, 7.5],
	[50, None, 'E', '0', '1', None, 10],
	[47.5, 'T', None, None, None, '2', 12.5],
	[45, '9', None, None, None, '3', 15],
	[42.5, '8', None, None, None, '4', 17.5],
	[40, None, '7', '6', '5', None, 20],
	[37.5, 35, 32.5, 30, 27.5, 25, 22.5],
]

print('${font DejaVu Sans Mono:size=12}')
for row in data:
	s = '${goto 230}'
	for x in row:
		if x is None:
			s += ' '
		elif type(x) == str:
			if x == 'T':
				h = 10
			elif x == 'E':
				h = 11
			else:
				h = int(x)
			if hour >= h:
				s += r'${color #FFAAAA}'
				s += r'${font DejaVu Sans Mono:bold:size=12}'
				s += x
				s += r'${font DejaVu Sans Mono:size=12}'
			else:
				s += r'${color #999999}'
				s += x
		elif type(x) == float or type(x) == int:
			if (minute + second / 60) >= x:
				s += r'${color #66DDDD}◘'
			else:
				s += r'${color #226666}◘'
		s += ' '
	print(s)
