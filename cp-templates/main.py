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
parser.add_argument("input", nargs="?", type=argparse.FileType("r"), default="-")

opts = parser.parse_args()
stream = opts.input  # input stream


def debug(*args: Any):
    if opts.debug is True:
        print(*args, file=sys.stderr)
