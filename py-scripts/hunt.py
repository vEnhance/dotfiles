# hunt.py
# Written by Evan Chen
#
# Usage:
# python hunt.py [file]
# If file is a filename, then hunt will open the first
# locate place, then output that directory to /tmp/hunt-user
# If there is more than one target, it will prompt the user to choose one.
# If file is a path to a file, then hunt will output
# the associated directory to /tmp/hunt-user.

import getpass
import os
import subprocess
import sys

target = sys.argv[1]

BAD_EXTS = (
	'.aux',
	'.fdb_latexmk',
	'.fls',
	'.log',
	'.out',
	'.pre',
	'.pytxcode',
	'.pytxmcr',
	'.pytxpyg',
	'.synctex.gz',
	'.von',
)

if not '/' in target:
	locateOut = subprocess.check_output(["locate", target])
	locations = locateOut.decode().strip().split('\n')
	locations = [
		x for x in locations if not (x.endswith('~') and '.vim' in x) and
		all(ext in target or not x.endswith(ext) for ext in BAD_EXTS)
	]

	directories = set(x[:x.rfind('/')] for x in locations)
	if len(directories) > 1:
		for i, place in enumerate(locations):
			print(i, '\t' + place)
		j = int(input("Please enter an index: "))
	else:
		j = 0
	fileLocation = locations[j]

else:
	fileLocation = target

destination = fileLocation[:fileLocation.rfind('/')]
with open("/tmp/hunt." + getpass.getuser(), "w") as f:
	print(destination, file=f)

#os.system('cd %s' %destination)
