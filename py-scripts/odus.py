# OTIS DUPES

import argparse
import collections
import re
import von.api

# Color names {{{
_TERM_COLOR = {}
_TERM_COLOR["NORMAL"]          = ""
_TERM_COLOR["RESET"]           = "\033[m"
_TERM_COLOR["BOLD"]            = "\033[1m"
_TERM_COLOR["RED"]             = "\033[31m"
_TERM_COLOR["GREEN"]           = "\033[32m"
_TERM_COLOR["YELLOW"]          = "\033[33m"
_TERM_COLOR["BLUE"]            = "\033[34m"
_TERM_COLOR["MAGENTA"]         = "\033[35m"
_TERM_COLOR["CYAN"]            = "\033[36m"
_TERM_COLOR["BOLD_RED"]        = "\033[1;31m"
_TERM_COLOR["BOLD_GREEN"]      = "\033[1;32m"
_TERM_COLOR["BOLD_YELLOW"]     = "\033[1;33m"
_TERM_COLOR["BOLD_BLUE"]       = "\033[1;34m"
_TERM_COLOR["BOLD_MAGENTA"]    = "\033[1;35m"
_TERM_COLOR["BOLD_CYAN"]       = "\033[1;36m"
_TERM_COLOR["BG_RED"]          = "\033[41m"
_TERM_COLOR["BG_GREEN"]        = "\033[42m"
_TERM_COLOR["BG_YELLOW"]       = "\033[43m"
_TERM_COLOR["BG_BLUE"]         = "\033[44m"
_TERM_COLOR["BG_MAGENTA"]      = "\033[45m"
_TERM_COLOR["BG_CYAN"]         = "\033[46m"
# }}}

def APPLY_COLOR(color_name, s):	
	return _TERM_COLOR[color_name] + s + _TERM_COLOR["RESET"]


parser = argparse.ArgumentParser(description="Scrape OTIS files for problems")
parser.add_argument('-d', '--dup', action='store_true',
		help='Show only duplicated problems in report.')
parser.add_argument('-u', '--unique', action='store_true',
		help='Show only unique problems in report.')
parser.add_argument('files', nargs='+',
		help='List of files to scrape')

args = parser.parse_args()

von_re = re.compile(r'^\\von([EMHZ])(R?).*?\{(.*?)\}')

repeat_count_dict = {}
seen = collections.defaultdict(dict)

hardness_chart = {'E':2,'M':3,'H':5,'Z':9}
for fn in args.files:
	repeat_count_dict[fn] = 0
	with open(fn) as f:
		for line in f:
			if (m := von_re.match(line)) is not None:
				d, r, source = m.groups()
				w = hardness_chart[d]
				assert fn not in seen[source], \
						f"you dummy you duped {source} in {fn}"
				seen[source][fn] = (w, r)

num_repeats = 0
for source, data in seen.items():
	status_string = ''
	to_show = (args.unique is True and len(data) == 1) \
		or (args.dup is True and len(data) > 1) \
		or (args.unique is False and args.dup is False)
	if to_show:
		for fn in args.files:
			if fn in data:
				color = "BOLD_MAGENTA" if data[fn][1] == 'R' else 'BOLD_CYAN'
				status_string += APPLY_COLOR(color, str(data[fn][0]))
			else:
				status_string += '.'
		print(f"{status_string} {APPLY_COLOR('BOLD_GREEN', source):28} "\
				+ f"{von.api.get(source).desc}")

	if len(data) > 1:
		for fn in data.keys():
			repeat_count_dict[fn] += 1

print(r'='*32)

for fn in args.files:
	if '/' in fn:
		basename = fn[fn.rindex('/')+1:]
	else:
		basename = fn

	num_problems = sum(1 for data in seen.values() if fn in data)
	num_points = sum(data[fn][0] for data in seen.values() if fn in data)
	print(APPLY_COLOR("BOLD_RED", f"{repeat_count_dict[fn]:2}❗") \
			+ " "*3
			+ APPLY_COLOR("BOLD_GREEN", f"{num_problems:2}🧩") \
			+ " "*3
			+ f"{num_points:3}♣"
			+ " "*3
			+ APPLY_COLOR("CYAN", basename)
			)


