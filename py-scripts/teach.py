## WRAPPER SCRIPT FOR OTIS
## By Evan Chen

# Usage:
# $ teach ZCX rigid

import sys, os
if not os.path.exists("/tmp/teach/"):
	os.mkdir("/tmp/teach/")
if not os.path.exists("/tmp/teach/von"):
	os.mkdir("/tmp/teach/von/")

assert len(sys.argv) > 1, "No arguments given"

MATERIALS_PATH = os.path.expanduser("~/Dropbox/Documents/Teaching/Materials/")
tex_files = [os.path.join(dirpath, f) for dirpath, dirnames, files in os.walk(MATERIALS_PATH)
    for f in files if f.endswith('.tex')]

keywords = sys.argv[1:]

# get everything that has all keywords
locations = [f for f in tex_files if all(k in f for k in keywords)]

# copied from hunt.py
if len(locations) > 1:
	for i, place in enumerate(locations):
		print i, '\t' + os.path.relpath(place, MATERIALS_PATH)
	j = input("Please enter an index: ")
else:
	assert len(locations) != 0, "HALP no such lesson"
	j = 0
fname = locations[j]

with open(fname) as f:
	content = ''.join(f.readlines())
	lesson_name = os.path.basename(f.name)

content = content.replace(
		r'\usepackage{otis}',
		r'\usepackage[reveal]{otis}' \
		+ '\n' + r'\enablevonmargins')

target_path = os.path.join("/tmp/teach/", lesson_name)

with open(target_path, 'w') as g:
	print >>g, content

os.system("cd /tmp/teach/; latexmk -pv %s" %target_path)
