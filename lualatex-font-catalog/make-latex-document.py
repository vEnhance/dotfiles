print(
	r'''\documentclass[11pt]{article}
\usepackage[landscape,margin=1in]{geometry}
\newcounter{tablenum}
\setcounter{tablenum}{0}
\newcommand{\s}[1]{\stepcounter{tablenum} {\fontspec{#1}\thetablenum} & {\fontspec{#1}#1} & {\fontspec{#1}Sphinx of black qwartz, judge my vow.}}
\usepackage{fontspec}
\usepackage{longtable}
\begin{document}
\begin{longtable}{rll}'''
)

banned_words = [
	'bold',
	'italic',
	'light',
	'oblique',
	'semi',
	'slanted',
	'braille',
	'icons',
	'symbol',
	'fontawesome',
	'fourierorns',
	'gfs',
	'keyboard',
	'ifinitialsregular',
	'ntxsups',
	'philokalia',
]
with open('languages.txt') as f:
	banned_words += [line.strip() for line in f]

with open('fontlist') as f:
	for i, line in enumerate(f):
		fontname = line.strip()
		if 'regular' in fontname and not any(bw in fontname for bw in banned_words):
			print(r'\s{' + fontname + r'} \\ %' + str(i + 1))

print(r'\end{longtable}')
print(r'\end{document}')
