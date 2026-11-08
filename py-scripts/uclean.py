#!/usr/bin/python3

import argparse
import re
import sys
import urllib.parse

QUTE_PDFJS_PREFIX = "qute://pdfjs/web/viewer.html?filename="
AOPS_PREFIX_RE = re.compile(r"^https?://(?:www\.)?artofproblemsolving\.com/")
# e.g. c129h1387221p7718382 -> components c129, h1387221, p7718382
AOPS_COMMUNITY_RE = re.compile(r"^((?:[a-z]+\d+)+)(?=$|[/?#])")


def normalize_text(text: str) -> str:
    """
    >>> print(normalize_text("“Hi,” she said—‘wait’… pages 3–5"))
    "Hi," she said---'wait'... pages 3--5
    """
    return (
        text.replace("“", '"')
        .replace("”", '"')
        .replace("‘", "'")
        .replace("’", "'")
        .replace("…", "...")
        .replace("–", "--")
        .replace("—", "---")
    )


def clean_url(url: str) -> str:
    """
    >>> clean_url("https://artofproblemsolving.com/community/c129h1387221p7718382")
    'https://aops.com/community/p7718382'
    >>> clean_url("https://artofproblemsolving.com/community/c129h1387221")
    'https://aops.com/community/c129h1387221'
    >>> clean_url("https://www.artofproblemsolving.com/community/c6h123p456?foo=1#bar")
    'https://aops.com/community/p456?foo=1#bar'
    >>> clean_url("https://artofproblemsolving.com/wiki/index.php/2023_IMO_Problems")
    'https://aops.com/wiki/index.php/2023_IMO_Problems'
    >>> clean_url("qute://pdfjs/web/viewer.html?filename=tmp.pdf&file=&source=https%3A%2F%2Fexample.com%2Fa.pdf")
    'https://example.com/a.pdf'
    >>> clean_url("https://example.com/")
    'https://example.com/'
    """
    # qutebrowser's PDF viewer: recover the original PDF URL
    if url.startswith(QUTE_PDFJS_PREFIX) and "source=" in url:
        url = urllib.parse.unquote(url.split("source=", 1)[1])

    # AoPS: shorten domain, and reduce community links to just the post
    if AOPS_PREFIX_RE.match(url):
        url = AOPS_PREFIX_RE.sub("https://aops.com/", url)
        prefix = "https://aops.com/community/"
        if url.startswith(prefix):
            rest = url[len(prefix) :]
            if m := AOPS_COMMUNITY_RE.match(rest):
                components = re.findall(r"[a-z]+\d+", m.group(1))
                posts = [c for c in components if re.fullmatch(r"p\d+", c)]
                if posts:
                    url = prefix + posts[-1] + rest[m.end() :]
    return url


def clean(text: str) -> str:
    """
    >>> clean("  https://artofproblemsolving.com/community/c3p14\\n")
    'https://aops.com/community/p14'
    >>> clean("see https://artofproblemsolving.com/community/c3p14")
    'see https://artofproblemsolving.com/community/c3p14'
    >>> clean("“quoted”")
    '"quoted"'
    >>> clean("")
    ''
    """
    text = normalize_text(text).strip()
    # Only treat the input as a URL if it's a single token
    if text and not any(c.isspace() for c in text):
        text = clean_url(text)
    return text


def main():
    parser = argparse.ArgumentParser(
        description="Normalize curly punctuation and other symbols, and clean up URLs."
    )
    parser.add_argument("infile", nargs="?", help="Input file (default: stdin)")
    parser.add_argument("outfile", nargs="?", help="Output file (default: stdout)")
    parser.add_argument(
        "-w", "--write", action="store_true", help="Edit the input file in place"
    )

    args = parser.parse_args()

    if args.write and not args.infile:
        parser.error("In-place editing requires an input file.")

    if args.infile:
        with open(args.infile, "r", encoding="utf-8") as f:
            text = f.read()
    else:
        text = sys.stdin.read()

    cleaned = clean(text)

    if args.write:
        with open(args.infile, "w", encoding="utf-8") as f:
            print(cleaned, file=f)
    elif args.outfile:
        with open(args.outfile, "w", encoding="utf-8") as f:
            print(cleaned, file=f)
    else:
        print(cleaned)


if __name__ == "__main__":
    main()
