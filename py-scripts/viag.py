#!/bin/python3

import collections
import os
import subprocess
import sys
import tempfile

EDITOR = os.environ.get("EDITOR", "vim")

with tempfile.NamedTemporaryFile() as tf:
    tf.write("".join(sys.stdin.readlines()).encode("utf-8"))
    tf.flush()
    subprocess.call([EDITOR, tf.name, "--not-a-term"], stdin=subprocess.DEVNULL)
    tf.seek(0)
    directives = tf.read().decode("utf-8")

DDTYPE = collections.defaultdict[str, dict[int, str]]
all_changes: DDTYPE = collections.defaultdict(dict)

for line in directives.splitlines(keepends=True):
    filename, lineno_str, content = line.split(":", maxsplit=2)
    lineno = int(lineno_str)
    all_changes[filename][lineno] = content

for filename, changes in all_changes.items():
    with open(filename, "r") as f:
        orig_lines = f.readlines()
    with open(filename, "w") as f:
        for n, line in enumerate(orig_lines):
            f.write(changes.get(n + 1, line))
