#!/usr/bin/env python3

## OSCAR (OLY SCORER)
# Takes score data in various formats and produces pretty LaTeX statistics

__version__ = "2025-04-25"

import argparse
import os
import sys
from pathlib import Path

from oscar.parsers import merge_contest_data, parse_file, parse_stdin
from oscar.render import render
from oscar.utils import clean_name


def main():
    parser = argparse.ArgumentParser(description="OSCAR - Oly Scorer")
    parser.add_argument(
        "files",
        nargs="*",
        default=None,
        help="Input file(s). Multiple files are merged as data for one contest.",
    )
    parser.add_argument(
        "-o",
        "--output",
        nargs="?",
        const="-",
        default=None,
        type=str,
        help="Output file (pass with no argument for stdout).",
    )
    parser.add_argument(
        "-f",
        "--full",
        action="store_true",
        help="Print the full breakdowns of all contestants.",
    )
    parser.add_argument(
        "-n",
        "--name",
        action="store",
        default=None,
        type=str,
        help="Name of competition for section headers.",
    )
    parser.add_argument(
        "-a",
        action="store",
        default=3,
        type=int,
        help="First stat is top A; by default A = 3.",
    )
    parser.add_argument(
        "-b",
        action="store",
        default=12,
        type=int,
        help="First stat is top B; by default B = 12.",
    )
    parser.add_argument(
        "-s",
        "--standalone",
        action="store_true",
        help="Output a complete LaTeX document instead of a fragment.",
    )
    args = parser.parse_args()

    filenames = args.files

    if not filenames:
        contest = parse_stdin()
        contest.name = args.name or "competition"
        outfile = (
            sys.stdout
            if args.output == "-"
            else (open(args.output, "w") if args.output else sys.stdout)
        )
        render(
            contest,
            outfile,
            full=args.full,
            a=args.a,
            b=args.b,
            standalone=args.standalone,
        )
    else:
        parts = [parse_file(Path(f)) for f in filenames]
        contest = merge_contest_data(parts)
        contest.name = (
            args.name or contest.name or clean_name(os.path.basename(filenames[0]))
        )

        if args.output == "-":
            outfile = sys.stdout
        elif args.output is not None:
            outfile = open(args.output, "w")
        else:
            base = os.path.splitext(filenames[0])[0]
            outfile = open(base + ".oscar.tex", "w")

        render(
            contest,
            outfile,
            full=args.full,
            a=args.a,
            b=args.b,
            standalone=args.standalone,
        )

        if outfile is not sys.stdout:
            outfile.close()


if __name__ == "__main__":
    main()
