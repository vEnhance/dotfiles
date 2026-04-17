#!/usr/bin/env python3

"""
Interactive sed via the silver searcher (ag).
Takes ag results and puts them in a temporary output file in Vim.
After editing, updates the corresponding line numbers
Allows the -C switch in ag.

Example usage: viag -C5 keyword .
"""

import re
import subprocess
import sys
import tempfile
from collections import defaultdict

GREPPRG = ["ag", "--numbers"]
EDITOR = ["vim", "-c", "set filetype=silversearch"]

# Get GREPPRG output for Vim to read
with tempfile.NamedTemporaryFile() as tf:
    subprocess.run(GREPPRG + sys.argv[1:], stdout=tf)
    subprocess.call(EDITOR + [tf.name])
    tf.seek(0)
    directives = tf.read().decode("utf-8")
if not directives.strip():
    print("Aborting due to empty directives file.")
    sys.exit(1)

# Make the dictionary of changes
RE_HIT = re.compile(r"(?P<filename>[^:]+):(?P<lineno>[0-9]+)[:-](?P<content>.*)")
all_changes: defaultdict[str, dict[int, str]] = defaultdict(dict)
for line in directives.splitlines():
    if line == "--":
        continue
    assert (m := RE_HIT.match(line)) is not None
    all_changes[m.group("filename")][int(m.group("lineno"))] = m.group("content") + "\n"

# Write the changes
for filename, changes in all_changes.items():
    with open(filename, "r") as f:
        orig_lines = f.readlines()
    with open(filename, "w") as f:
        for n, line in enumerate(orig_lines):
            f.write(changes.get(n + 1, line))
