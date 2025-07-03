#!/usr/bin/env python3

import argparse
import sys


def normalize_text(text):
    return (
        text.replace("“", '"')
        .replace("”", '"')
        .replace("‘", "'")
        .replace("’", "'")
        .replace("…", "...")
        .replace("–", "--")
        .replace("—", "---")
    )


def main():
    parser = argparse.ArgumentParser(
        description="Normalize curly punctuation and other symbols."
    )
    parser.add_argument("infile", nargs="?", help="Input file (default: stdin)")
    parser.add_argument("outfile", nargs="?", help="Output file (default: stdout)")
    parser.add_argument(
        "-w", "--write", action="store_true", help="Edit the input file in place"
    )

    args = parser.parse_args()

    # Handle input
    if args.write and not args.infile:
        parser.error("In-place editing requires an input file.")

    if args.infile:
        with open(args.infile, "r", encoding="utf-8") as f:
            text = f.read()
    else:
        text = sys.stdin.read()

    # Normalize
    normalized = normalize_text(text).strip()

    # Handle output
    if args.write:
        with open(args.infile, "w", encoding="utf-8") as f:
            print(normalized, file=f)
    elif args.outfile:
        with open(args.outfile, "w", encoding="utf-8") as f:
            print(normalized, file=f)
    else:
        print(normalized)


if __name__ == "__main__":
    main()
