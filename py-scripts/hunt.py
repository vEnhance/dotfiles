# hunt.py
# Written by Evan Chen
#
# Usage:
# python hunt.py [file]
# If file is a filename, then hunt will open the first
# locate place, then output that directory to /tmp/hunt.user
# If there is more than one target, it will prompt the user to choose one.
# If file is a path to a file, then hunt will output
# the associated directory to /tmp/hunt.user.

import getpass
import re
import subprocess
import sys

REGEX_PTC = re.compile(r"\.ptc[0-9]+$")

target = sys.argv[1]

BAD_EXTS = [
    ".aux",
    ".bbl",
    ".bcf",
    ".blg",
    ".fdb_latexmk",
    ".fls",
    ".log",
    ".maf",
    ".mtc",
    ".mtc0",
    ".out",
    ".pre",
    ".pytxcode",
    ".pytxmcr",
    ".pytxpyg",
    ".run.xml",
    ".synctex.gz",
    ".toc",
    ".trashinfo",
    ".von",
]
BAD_SUBSTRINGS = [
    "/.stversions/",
    "/.local/share/Trash",
]
HUNT_OUT_PATH = "/tmp/hunt." + getpass.getuser()

if not target.strip():
    print("No target was specified!", file=sys.stderr)
    sys.exit(64)
elif not "/" in target:
    locate_out = subprocess.check_output(["locate", target])
    locations = locate_out.decode().strip().split("\n")
    locations = [
        x
        for x in locations
        if all(
            (
                not (x.endswith("~") and "/.vim/tmp/" in x),
                all(substr not in x for substr in BAD_SUBSTRINGS),
                all(ext in target or not x.endswith(ext) for ext in BAD_EXTS),
                REGEX_PTC.search(x) is None,
            )
        )
    ]
    tex_locations = [x for x in locations if x.endswith(".tex")]
    for t in tex_locations:
        n = 0
        while True:
            n += 1
            if (pdf_target := f"{t[:-4]}-{n}.pdf") in locations:
                locations.remove(pdf_target)
            if (asy_target := f"{t[:-4]}-{n}.asy") in locations:
                locations.remove(asy_target)
            else:
                break

    directories = set(x[: x.rfind("/")] for x in locations)
    if len(directories) > 1:
        for i, place in enumerate(locations):
            print(i, "\t" + place)
        try:
            user_input = input("Please enter an index: ")
        except (KeyboardInterrupt, EOFError):
            user_input = ""
            print("")
        if not user_input:
            with open(HUNT_OUT_PATH, "w") as f:
                print("", file=f)
                sys.exit(65)
        j = int(user_input)
    else:
        j = 0
    fileLocation = locations[j]

else:
    fileLocation = target

destination = fileLocation[: fileLocation.rfind("/")]
with open(HUNT_OUT_PATH, "w") as f:
    print(destination, file=f)

# os.system('cd %s' %destination)
