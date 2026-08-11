# vEnhance's cp Python template

import argparse
import sys
from typing import Any

parser = argparse.ArgumentParser()
parser.add_argument(
    "-d",
    "--debug",
    action="store_true",
    help="Show debugging statements (prints to stderr)",
)
parser.add_argument("input", nargs="?", default="-")

opts = parser.parse_args()
# Lives for the whole program; no point wrapping the entire solution in a `with`
stream = sys.stdin if opts.input == "-" else open(opts.input)  # noqa: SIM115


def debug(*args: Any):
    if opts.debug is True:
        print(*args, file=sys.stderr)
