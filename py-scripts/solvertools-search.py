#!/usr/bin/python3

import argparse
import pprint

from solvertools.all import search

parser = argparse.ArgumentParser(description="Wrapper for search from solvertools")
parser.add_argument("pattern", nargs="?", type=str)
parser.add_argument("-l", "--length", nargs="?", type=int)
parser.add_argument("-c", "--clue", nargs="?", type=str)
parser.add_argument("-n", "--number", type=int, default=20)
args = parser.parse_args()

pprint.pprint(
    search(
        pattern=args.pattern,
        length=args.length,
        clue=args.clue,
        count=args.number,
    ),
)
