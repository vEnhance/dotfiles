import sys, os

assert len(sys.argv) > 1, "start"
fname = sys.argv[1]

if fname[-1] == ".":
	fname += "tex"
elif "." not in fname:
	fname += ".tex"

with open(fname) as f:
	content = ''.join(f.readlines())
	lesson_name = os.path.basename(f.name)

content = content.replace(
		r'\usepackage{otis}',
		r'\usepackage[reveal]{otis}' + '\n' + '\enablevonmargins')

target_path = os.path.join("/tmp/", lesson_name)

with open(target_path, 'w') as g:
	print >>g, content

os.system("latexmk -pv %s" %target_path)
