"""
OTIS Duplication Uniqueness System

Used to check which problems have been used multiple times or not at all.
"""

import argparse
import collections
import glob
import os
import re
from typing import DefaultDict, Dict, Tuple

import von.api
from von.model import VonCache, VonIndex
from von.view import printEntry

# Color names {{{
_TERM_COLOR = {}
_TERM_COLOR["NORMAL"] = ""
_TERM_COLOR["RESET"] = "\033[m"
_TERM_COLOR["BOLD"] = "\033[1m"
_TERM_COLOR["RED"] = "\033[31m"
_TERM_COLOR["GREEN"] = "\033[32m"
_TERM_COLOR["YELLOW"] = "\033[33m"
_TERM_COLOR["BLUE"] = "\033[34m"
_TERM_COLOR["MAGENTA"] = "\033[35m"
_TERM_COLOR["CYAN"] = "\033[36m"
_TERM_COLOR["BOLD_RED"] = "\033[1;31m"
_TERM_COLOR["BOLD_GREEN"] = "\033[1;32m"
_TERM_COLOR["BOLD_YELLOW"] = "\033[1;33m"
_TERM_COLOR["BOLD_BLUE"] = "\033[1;34m"
_TERM_COLOR["BOLD_MAGENTA"] = "\033[1;35m"
_TERM_COLOR["BOLD_CYAN"] = "\033[1;36m"
_TERM_COLOR["BG_RED"] = "\033[41m"
_TERM_COLOR["BG_GREEN"] = "\033[42m"
_TERM_COLOR["BG_YELLOW"] = "\033[43m"
_TERM_COLOR["BG_BLUE"] = "\033[44m"
_TERM_COLOR["BG_MAGENTA"] = "\033[45m"
_TERM_COLOR["BG_CYAN"] = "\033[46m"
# }}}


def APPLY_COLOR(color_name, s):
    return _TERM_COLOR[color_name] + s + _TERM_COLOR["RESET"]


parser = argparse.ArgumentParser(
    description="General purpose tool for OTIS problem management."
)
parser.add_argument(
    "-d", "--dup", action="store_true", help="Show only duplicated problems in report."
)
parser.add_argument(
    "-u", "--unique", action="store_true", help="Show only unique problems in report."
)
parser.add_argument(
    "-a",
    "--all",
    action="store_true",
    help="Only valid without files, uses the whole database rather than cache.",
)
parser.add_argument("files", nargs="*", help="List of files to scrape.")
args = parser.parse_args()
VON_RE = re.compile(r"^\\von([EMHZXI])(R?)(\[.*?\]|\*)?\{(.*?)\}")
PROB_RE = re.compile(r"^\\begin\{prob([EMHZXI])(R?)\}")
GOAL_RE = re.compile(r"^\\goals\{([0-9]+)\}\{([0-9]+)\}")

if len(args.files) == 0:
    path_tex = os.path.join(
        os.environ.get("HOME", ""), "Sync/OTIS/Materials/**/*.tex"
    )
    path_txt = os.path.join(
        os.environ.get("HOME", ""), "Sync/OTIS/Materials/**/*.txt"
    )
    files = glob.glob(path_tex, recursive=True) + glob.glob(path_txt, recursive=True)
    detect_missing = True
else:
    files = args.files
    detect_missing = False

repeat_count_dict: DefaultDict[str, int] = collections.defaultdict(int)
seen: DefaultDict[str, dict] = collections.defaultdict(
    dict
)  # only if detect_missing is False
seen_set = set()  # only if detect_missing is True
goals: Dict[str, Tuple[int, int]] = {}

hardness_chart = {
    "E": 2,
    "M": 3,
    "H": 5,
    "Z": 9,
    "X": 0,
    "I": 0,
}
for fn in files:
    with open(fn) as f:
        for n, line in enumerate(f):
            if (m := VON_RE.match(line)) is not None:
                d, r, _, source = m.groups()
                w = hardness_chart[d]
                if detect_missing is False:
                    assert (
                        fn not in seen[source] or w == 0
                    ), f"you dummy you duped {source} in {fn}"
                    seen[source][fn] = (w, r)
                elif detect_missing is True:
                    seen_set.add(source)
            elif (m := PROB_RE.match(line)) is not None and detect_missing is False:
                d, r = m.groups()
                w = hardness_chart[d]
                seen[f"ANONYMOUS {fn}:{n:03d}"][fn] = (w, r)
            elif (m := GOAL_RE.match(line)) is not None:
                a, b = m.groups()
                goals[fn] = (int(a), int(b))

if detect_missing is False:
    num_repeats = 0
    for source, data in seen.items():
        status_string = ""
        to_show = (
            (args.unique is True and len(data) == 1)
            or (args.dup is True and len(data) > 1)
            or (args.unique is False and args.dup is False)
        )
        if to_show:
            for fn in files:
                if fn in data:
                    if data[fn][1] == "R":
                        color = "BOLD_MAGENTA"
                    elif data[fn][0] == 0:
                        color = "NORMAL"
                    else:
                        color = "BOLD_CYAN"
                    status_string += APPLY_COLOR(color, str(data[fn][0]))
                else:
                    status_string += "."
            if source.startswith("ANONYMOUS"):
                src_display = source.replace("ANONYMOUS ", "").replace(".tex", "")
                desc = ""
            else:
                src_display = APPLY_COLOR("BOLD_GREEN", source)
                desc = von.api.get(source).desc
            print(f"{status_string} {src_display:28} {desc}")

        if len(data) > 1:
            for fn in data.keys():
                if data[fn][0] > 0:
                    repeat_count_dict[fn] += 1

    print(r"=" * 32)

    for fn in files:
        if "/" in fn:
            basename = fn[fn.rindex("/") + 1 :]
        else:
            basename = fn

        num_problems = sum(
            1 for data in seen.values() if fn in data and data[fn][0] > 0
        )
        num_points = sum(
            data[fn][0] for data in seen.values() if fn in data and data[fn][0] > 0
        )
        separator = "   "
        summary_output = (
            APPLY_COLOR("BOLD_RED", f"{repeat_count_dict[fn]:2}❗") + separator
        )
        summary_output += APPLY_COLOR("BOLD_GREEN", f"{num_problems:2}🧩") + separator
        summary_output += (
            f"♣[{num_points:3}; hi {goals[fn][1]:2}; min {goals[fn][0]:2}]" + " "
        )
        summary_output += APPLY_COLOR("CYAN", basename) + separator
        print(summary_output)

else:
    if args.all is True:
        index = VonIndex()
        entries = index.values()
    else:
        cache = VonCache()
        entries = cache

    for entry in entries:
        if (
            not entry.source in seen_set
            and not "waltz" in entry.tags
            and not "unowned" in entry.tags
            and not entry.secret
        ):
            printEntry(entry)
