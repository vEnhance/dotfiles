import sys
import os

arg = sys.argv[1]
if ".tex" in arg:
	file_root_name = arg[0:-4]
elif arg[-1] == ".":
	file_root_name = arg[0:-1]
else:
	file_root_name = arg
	
current_dir = os.getcwd()
with open("%s.tex" %file_root_name) as f, open("/tmp/source.tex", "w") as g:
	for line in f:
		if line.strip() == r'\begin{document}':
			print >>g, r'\usepackage{demacro-private}'
		print >>g, line.strip()

os.system("cp -f ~/dotfiles/py-scripts/demacro-private.sty /tmp")
os.chdir("/tmp")
os.system("de-macro source.tex")
os.system("python2 ~/dotfiles/py-scripts/latex2wp.py source-clean.tex")
os.chdir(current_dir)
os.system("cp -f /tmp/source-clean.html %s.html" %file_root_name)
os.system("cp -f /tmp/source-clean.tex %s.clean.tex" %file_root_name)
