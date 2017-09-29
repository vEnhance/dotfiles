#!/usr/bin/python3

import sys
text = ''
for line in sys.stdin:
	line = line.replace(r'“', r'"')
	line = line.replace(r'”', r'"')
	line = line.replace(r'’', r"'")
	text += line
print(text.strip())
