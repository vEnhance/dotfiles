import sys
import os

TMP = "/tmp/demacro"
os.system("mkdir -p %s" %TMP)

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
with open("%s.tex" %file_root_name) as f, open("%s/source.tex" %TMP, "w") as g:
	print(f.readline().strip(), file=g) # print \documentclass
	for line in f:
		if line.strip() == r'\begin{document}':
			doc_started = True
			print(r'\usepackage{demacro-private}', file=g)
			print(r'\def\blue{\bgroup\color{blue}}', file=g)
			print(r'\def\endblue{\egroup}', file=g)
			print(r'\def\red{\bgroup\color{red}}', file=g)
			print(r'\def\endred{\egroup}', file=g)
			print(r'\def\green{\bgroup\color{green}}', file=g)
			print(r'\def\endgreen{\egroup}', file=g)
			print(r'', file=g)
			print(line.strip(), file=g) # begin document
		elif not doc_started:
			preamble += line
			if not r"newcommand" in line:
				print(line.strip(), file=g)
		elif doc_started:
			print(line.strip(), file=g)
os.system("cp -f *.tex " + TMP)
os.system("cp -f ~/dotfiles/py-scripts/demacro-private.sty " + TMP)
with open("%s/demacro-private.sty" %TMP, "a") as f:
	print("\n" + preamble, file=f)
os.chdir(TMP)
os.system("~/dotfiles/py-scripts/de-macro source.tex")
os.system("python3 ~/dotfiles/py-scripts/latex2wp.py source-clean.tex")
os.chdir(current_dir)
os.system("cp -f %s/source-clean.html %s.html" %(TMP, file_root_name))
os.system("cp -f %s/source-clean.tex %s.clean" %(TMP, file_root_name))
