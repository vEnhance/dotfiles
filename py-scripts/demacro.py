import os
import subprocess
import sys
from pathlib import Path

TMP = "/tmp/demacro"
os.makedirs(TMP, exist_ok=True)

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
with open("%s.tex" % file_root_name) as f, open("%s/source.tex" % TMP, "w") as g:
    print(f.readline().strip(), file=g)  # print \documentclass
    for line in f:
        if line.strip() == r"\begin{document}":
            doc_started = True
            print(r"\usepackage{demacro-private}", file=g)
            print(r"\def\blue{\bgroup\color{blue}}", file=g)
            print(r"\def\endblue{\egroup}", file=g)
            print(r"\def\red{\bgroup\color{red}}", file=g)
            print(r"\def\endred{\egroup}", file=g)
            print(r"\def\green{\bgroup\color{green}}", file=g)
            print(r"\def\endgreen{\egroup}", file=g)
            print(r"", file=g)
            print(line.strip(), file=g)  # begin document
        elif not doc_started:
            preamble += line
            if r"newcommand" not in line:
                print(line.strip(), file=g)
        elif doc_started:
            print(line.strip(), file=g)
subprocess.run("cp -f *.tex " + TMP, shell=True, check=True)
subprocess.run(["cp", "-f", Path("~/dotfiles/py-scripts/demacro-private.sty").expanduser(), TMP], check=True)
with open("%s/demacro-private.sty" % TMP, "a") as f:
    print("\n" + preamble, file=f)
os.chdir(TMP)
subprocess.run([Path("~/dotfiles/py-scripts/de-macro").expanduser(), "source.tex"], check=True)
subprocess.run(["python3", Path("~/dotfiles/py-scripts/latex2wp.py").expanduser(), "source-clean.tex"], check=True)
os.chdir(current_dir)
subprocess.run(["cp", "-f", "%s/source-clean.html" % TMP, "%s.html" % file_root_name], check=True)
subprocess.run(["cp", "-f", "%s/source-clean.tex" % TMP, "%s.clean" % file_root_name], check=True)
