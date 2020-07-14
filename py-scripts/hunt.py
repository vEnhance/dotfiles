# hunt.py
# Written by Evan Chen
#
# Usage:
# python hunt.py [file]
# If file is a filename, then hunt will open the first
# locate place, then output that directory to /tmp/hunt
# If there is more than one target, it will prompt the user to choose one.
# If file is a path to a file, then hunt will output
# the associated directory to /tmp/hunt.

import sys, os, subprocess
target = sys.argv[1]


if not '/' in target:
	locateOut = subprocess.check_output(["locate", target])
	locations = locateOut.decode().strip().split('\n')
	if len(locations) > 1:
		for i, place in enumerate(locations):
			print(i, '\t' + place)
		j = int(input("Please enter an index: "))
	else:
		j = 0
	fileLocation = locations[j]

else:
	fileLocation = target

destination = fileLocation[:fileLocation.rfind('/')]
with open("/tmp/hunt", "w") as f:
	print(destination, file=f)

#os.system('cd %s' %destination)
