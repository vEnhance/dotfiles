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
preamble = ""
doc_started = False
with open("%s.tex" %file_root_name) as f, open("/tmp/source.tex", "w") as g:
	print >>g, f.readline().strip() # print \documentclass
	for line in f:
		if line.strip() == r'\begin{document}':
			doc_started = True
			print >>g, r'\usepackage{demacro-private}'
			print >>g, r'\def\blue{\bgroup\color{blue}}'
			print >>g, r'\def\endblue{\egroup}'
			print >>g, r'\def\red{\bgroup\color{red}}'
			print >>g, r'\def\endred{\egroup}'
			print >>g, r'\def\green{\bgroup\color{green}}'
			print >>g, r'\def\endgreen{\egroup}'
			print >>g, r''
			print >>g, line.strip() # begin document
		elif not doc_started:
			preamble += line
			if not r"newcommand" in line:
				print >>g, line.strip()
		elif doc_started:
			print >>g, line.strip()

os.system("cp -f ~/dotfiles/py-scripts/demacro-private.sty /tmp")
with open("/tmp/demacro-private.sty", "a") as f:
	print >>f, "\n" + preamble
os.chdir("/tmp")
os.system("de-macro source.tex")
os.system("python2 ~/dotfiles/py-scripts/latex2wp.py source-clean.tex")
os.chdir(current_dir)
os.system("cp -f /tmp/source-clean.html %s.html" %file_root_name)
os.system("cp -f /tmp/source-clean.tex %s.clean" %file_root_name)
