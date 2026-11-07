#!/usr/bin/python3
"""
Raise lower bounds in pyproject.toml to match the versions locked in uv.lock.

Meant to be run *after* something like ``uv sync --upgrade``; this script never
invokes uv itself.  It only reads uv.lock and rewrites requirement strings in
pyproject.toml, and only ever moves a lower bound upward:

- ``>=X``  becomes ``>=locked``
- ``>X``   becomes ``>=locked``
- ``~=X.Y`` becomes ``~=locked`` truncated to the same number of components,
  so the implied upper bound only moves as far as the lower bound does

Anything else (``==``, ``<``, ``<=``, ``!=``, ``===``, URLs, markers) is left
untouched.  Formatting of pyproject.toml is preserved, since only the quoted
requirement strings are substituted.

Run the doctests with ``python -m doctest -v uv-nudge.py``.
"""

import argparse
import os
import re
import sys
import tomllib
from collections.abc import Iterator
from pathlib import Path

from packaging.requirements import InvalidRequirement, Requirement
from packaging.specifiers import SpecifierSet
from packaging.utils import canonicalize_name
from packaging.version import InvalidVersion, Version

# A lower-bound clause: operator followed by a version.  ``>=`` is listed
# before ``>`` so it wins; ``>(?!=)`` keeps us from matching the ``>`` of
# ``>=`` twice, and ``===`` / ``==`` / ``<=`` / ``!=`` never match at all.
LOWER_BOUND_RE = re.compile(r"(?P<op>~=|>=|>(?!=))(?P<ws>\s*)(?P<ver>[^\s,;()]+)")


def _format_release(epoch: int, release: tuple[int, ...]) -> str:
    """
    >>> _format_release(0, (1, 2, 3))
    '1.2.3'
    >>> _format_release(2, (1, 0))
    '2!1.0'
    """
    s = ".".join(str(n) for n in release)
    return f"{epoch}!{s}" if epoch else s


def nudge_clause(op: str, old: str, locked: Version) -> tuple[str, str] | None:
    """
    Return the new (operator, version) for one lower-bound clause, or None
    if the bound is already at least as high as the locked version.

    >>> nudge_clause(">=", "6.0.3", Version("6.0.10"))
    ('>=', '6.0.10')
    >>> nudge_clause(">=", "6.0.10", Version("6.0.10")) is None
    True
    >>> nudge_clause(">=", "6.0", Version("6.0.0")) is None
    True
    >>> nudge_clause(">", "1.0", Version("1.2"))
    ('>=', '1.2')

    Compatible-release pins keep their precision:

    >>> nudge_clause("~=", "23.1", Version("23.2"))
    ('~=', '23.2')
    >>> nudge_clause("~=", "23.1", Version("23.2.5"))
    ('~=', '23.2')
    >>> nudge_clause("~=", "1.4.2", Version("1.5"))
    ('~=', '1.5.0')
    >>> nudge_clause("~=", "23.1", Version("23.1.9")) is None
    True

    Local version labels are not allowed in ordered comparisons, so drop them:

    >>> nudge_clause(">=", "2.0", Version("2.3.1+cu121"))
    ('>=', '2.3.1')

    Unparsable versions are left alone:

    >>> nudge_clause(">=", "banana", Version("1.0")) is None
    True
    """
    try:
        old_v = Version(old)
    except InvalidVersion:
        return None

    if op == "~=":
        n = len(old_v.release)
        release = (locked.release + (0,) * n)[:n]
        new = _format_release(locked.epoch, release)
    else:
        new = locked.public
        op = ">="

    if Version(new) <= old_v:
        return None
    return op, new


def nudge_requirement(req_str: str, locked: Version) -> str:
    """
    Return ``req_str`` with every lower bound raised to ``locked`` where
    possible.  Returns ``req_str`` unchanged if nothing can move.

    The examples from the spec:

    >>> nudge_requirement("stripe==5.5.0", Version("5.5.0"))
    'stripe==5.5.0'
    >>> nudge_requirement("Django>=6.0.3,<6.1", Version("6.0.10"))
    'Django>=6.0.10,<6.1'
    >>> nudge_requirement("Django>=6.0.3", Version("6.1.1"))
    'Django>=6.1.1'
    >>> nudge_requirement("attrs~=23.1", Version("23.2"))
    'attrs~=23.2'

    Upper bounds, exclusions, and exact pins are never touched:

    >>> nudge_requirement("foo<3", Version("2.5"))
    'foo<3'
    >>> nudge_requirement("foo<=3,!=2.1", Version("2.5"))
    'foo<=3,!=2.1'
    >>> nudge_requirement("foo===1.0", Version("1.0"))
    'foo===1.0'
    >>> nudge_requirement("foo==2.*", Version("2.4"))
    'foo==2.*'
    >>> nudge_requirement("foo", Version("2.4"))
    'foo'

    Whitespace, extras, parenthesized specifiers, and markers are preserved,
    and comparisons inside the marker are not mistaken for bounds:

    >>> nudge_requirement("Django[argon2] >= 5.0 , < 7", Version("6.0.1"))
    'Django[argon2] >= 6.0.1 , < 7'
    >>> nudge_requirement('tomli>=1.1; python_version >= "3.8"', Version("2.0"))
    'tomli>=2.0; python_version >= "3.8"'
    >>> nudge_requirement("requests (>=2.0)", Version("2.32.3"))
    'requests (>=2.32.3)'

    Strict lower bounds become inclusive at the locked version:

    >>> nudge_requirement("foo>1.0,<2", Version("1.2"))
    'foo>=1.2,<2'

    If the locked version doesn't satisfy the existing pin (stale lock?),
    or would not satisfy the nudged one, nothing changes:

    >>> nudge_requirement("foo>=3.0", Version("2.0"))
    'foo>=3.0'
    >>> nudge_requirement("foo~=2.0", Version("2.1rc1"))
    'foo~=2.0'

    URL requirements are left alone:

    >>> nudge_requirement("foo @ https://example.com/foo-1.0.tar.gz", Version("1.0"))
    'foo @ https://example.com/foo-1.0.tar.gz'
    """
    req = Requirement(req_str)
    if req.url is not None:
        return req_str
    if not req.specifier.contains(locked, prereleases=True):
        return req_str

    head, sep, tail = req_str.partition(";")

    def repl(m: re.Match[str]) -> str:
        result = nudge_clause(m["op"], m["ver"], locked)
        if result is None:
            return m[0]
        op, ver = result
        return f"{op}{m['ws']}{ver}"

    new_str = LOWER_BOUND_RE.sub(repl, head) + sep + tail
    if new_str == req_str:
        return req_str

    # Sanity check: the result must still parse and still admit the
    # locked version, otherwise keep the original.
    try:
        new_req = Requirement(new_str)
    except InvalidRequirement:
        return req_str
    if not SpecifierSet(str(new_req.specifier)).contains(locked, prereleases=True):
        return req_str
    return new_str


def read_locked_versions(lock_text: str) -> dict[str, Version]:
    """
    Map canonical package name -> locked version.  If a package is locked at
    several versions (forked resolution), use the lowest, since a lower
    bound has to admit all of them.

    >>> lock = '''
    ... version = 1
    ... [[package]]
    ... name = "Django"
    ... version = "6.0.10"
    ... [[package]]
    ... name = "numpy"
    ... version = "2.1.0"
    ... [[package]]
    ... name = "numpy"
    ... version = "1.26.4"
    ... [[package]]
    ... name = "myproject"
    ... source = { virtual = "." }
    ... '''
    >>> sorted((k, str(v)) for k, v in read_locked_versions(lock).items())
    [('django', '6.0.10'), ('numpy', '1.26.4')]
    """
    data = tomllib.loads(lock_text)
    out: dict[str, Version] = {}
    for pkg in data.get("package", []):
        if "version" not in pkg:
            continue
        try:
            v = Version(pkg["version"])
        except InvalidVersion:
            continue
        name = canonicalize_name(pkg["name"])
        if name not in out or v < out[name]:
            out[name] = v
    return out


def iter_requirement_strings(pyproject: dict) -> Iterator[tuple[str, str]]:
    """
    Yield (section label, requirement string) for every dependency list.

    >>> doc = tomllib.loads('''
    ... [project]
    ... dependencies = ["a>=1"]
    ... [project.optional-dependencies]
    ... fast = ["b>=2"]
    ... [dependency-groups]
    ... dev = ["c>=3", {include-group = "lint"}]
    ... lint = ["d>=4"]
    ... [tool.uv]
    ... dev-dependencies = ["e>=5"]
    ... ''')
    >>> for x in iter_requirement_strings(doc): print(*x)
    project.dependencies a>=1
    project.optional-dependencies.fast b>=2
    dependency-groups.dev c>=3
    dependency-groups.lint d>=4
    tool.uv.dev-dependencies e>=5
    """
    project = pyproject.get("project", {})
    for s in project.get("dependencies", []):
        yield "project.dependencies", s
    for extra, reqs in project.get("optional-dependencies", {}).items():
        for s in reqs:
            yield f"project.optional-dependencies.{extra}", s
    for group, reqs in pyproject.get("dependency-groups", {}).items():
        for s in reqs:
            if isinstance(s, str):
                yield f"dependency-groups.{group}", s
    for s in pyproject.get("tool", {}).get("uv", {}).get("dev-dependencies", []):
        yield "tool.uv.dev-dependencies", s


def compute_changes(
    pyproject: dict, locked: dict[str, Version]
) -> list[tuple[str, str, str]]:
    """
    Return a list of (section, old requirement, new requirement).

    >>> doc = tomllib.loads('''
    ... [project]
    ... dependencies = ["stripe==5.5.0", "Django>=6.0.3,<6.1", "attrs~=23.1",
    ...                 "not-in-lock>=1.0"]
    ... ''')
    >>> locked = {"stripe": Version("5.5.0"), "django": Version("6.0.10"),
    ...           "attrs": Version("23.2")}
    >>> for c in compute_changes(doc, locked): print(*c)
    project.dependencies Django>=6.0.3,<6.1 Django>=6.0.10,<6.1
    project.dependencies attrs~=23.1 attrs~=23.2
    """
    changes = []
    for section, req_str in iter_requirement_strings(pyproject):
        try:
            name = canonicalize_name(Requirement(req_str).name)
        except InvalidRequirement:
            print(f"warning: can't parse {req_str!r}, skipping", file=sys.stderr)
            continue
        if name not in locked:
            continue
        new = nudge_requirement(req_str, locked[name])
        if new != req_str:
            changes.append((section, req_str, new))
    return changes


def apply_changes(text: str, changes: list[tuple[str, str, str]]) -> str:
    """
    Substitute quoted requirement strings in the raw TOML text, leaving the
    rest of the file (comments, layout) alone.

    >>> text = 'dependencies = [\\n  "a>=1",  # hi\\n  \\'b~=2.0\\',\\n]\\n'
    >>> print(apply_changes(text, [("x", "a>=1", "a>=1.5"), ("x", "b~=2.0", "b~=2.3")]))
    dependencies = [
      "a>=1.5",  # hi
      'b~=2.3',
    ]
    <BLANKLINE>
    """
    for _, old, new in changes:
        for q in ('"', "'"):
            text = text.replace(f"{q}{old}{q}", f"{q}{new}{q}")
    return text


BOLD_RED = "\033[1;31m"
BOLD_GREEN = "\033[1;32m"
BOLD_BLUE = "\033[1;34m"
RESET = "\033[0m"


def highlight_versions(
    old: str, new: str, old_color: str, new_color: str, reset: str
) -> tuple[str, str]:
    """
    Wrap only the version numbers of the clauses that changed in color codes.

    >>> highlight_versions("Django>=6.0.3,<6.1", "Django>=6.0.10,<6.1", "<", ">", "|")
    ('Django>=<6.0.3|,<6.1', 'Django>=>6.0.10|,<6.1')
    >>> highlight_versions("foo>1.0", "foo>=1.2", "<", ">", "|")
    ('foo><1.0|', 'foo>=>1.2|')
    >>> highlight_versions('t>=1; python_version >= "3"', 't>=2; python_version >= "3"',
    ...                    "<", ">", "|")
    ('t>=<1|; python_version >= "3"', 't>=>2|; python_version >= "3"')
    """
    old_head, old_sep, old_tail = old.partition(";")
    new_head, new_sep, new_tail = new.partition(";")
    old_matches = list(LOWER_BOUND_RE.finditer(old_head))
    new_matches = list(LOWER_BOUND_RE.finditer(new_head))

    def paint(head: str, spans: list[tuple[int, int]], color: str) -> str:
        for start, end in reversed(spans):
            head = head[:start] + color + head[start:end] + reset + head[end:]
        return head

    old_spans, new_spans = [], []
    for om, nm in zip(old_matches, new_matches, strict=True):
        if om[0] != nm[0]:
            old_spans.append(om.span("ver"))
            new_spans.append(nm.span("ver"))
    return (
        paint(old_head, old_spans, old_color) + old_sep + old_tail,
        paint(new_head, new_spans, new_color) + new_sep + new_tail,
    )


def use_color() -> bool:
    if os.environ.get("NO_COLOR"):
        return False
    if os.environ.get("FORCE_COLOR"):
        return True
    return sys.stdout.isatty()


def find_lockfile(start: Path) -> Path | None:
    for d in (start, *start.parents):
        if (d / "uv.lock").is_file():
            return d / "uv.lock"
    return None


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="uv-nudge",
        description="Raise lower bounds in pyproject.toml to the versions "
        "locked in uv.lock (run after `uv sync --upgrade` or similar).",
    )
    parser.add_argument(
        "pyproject",
        nargs="*",
        type=Path,
        default=[Path("pyproject.toml")],
        help="pyproject.toml file(s) to update (default: ./pyproject.toml)",
    )
    parser.add_argument(
        "-l",
        "--lock",
        type=Path,
        help="path to uv.lock (default: search upward from each pyproject.toml)",
    )
    parser.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
        help="print what would change without writing anything",
    )
    args = parser.parse_args()

    color = use_color()
    blue, reset = (BOLD_BLUE, RESET) if color else ("", "")

    any_changes = False
    for pyproject_path in args.pyproject:
        lock_path = args.lock or find_lockfile(pyproject_path.resolve().parent)
        if lock_path is None:
            print(f"error: no uv.lock found for {pyproject_path}", file=sys.stderr)
            return 1

        locked = read_locked_versions(lock_path.read_text())
        text = pyproject_path.read_text()
        changes = compute_changes(tomllib.loads(text), locked)
        if not changes:
            continue
        any_changes = True

        if len(args.pyproject) > 1:
            print(f"{pyproject_path}:")
        width = max(len(old) for _, old, _ in changes)
        current_section = None
        for section, old, new in changes:
            if section != current_section:
                if current_section is not None:
                    print()
                print(f"{blue}[{section}]{reset}")
                current_section = section
            padding = " " * (width - len(old))
            if color:
                old, new = highlight_versions(old, new, BOLD_RED, BOLD_GREEN, RESET)
            print(f"{old}{padding}  ->  {new}")

        if not args.dry_run:
            pyproject_path.write_text(apply_changes(text, changes))

    if not any_changes:
        print("Nothing to nudge.")
    elif args.dry_run:
        print("\n(dry run, nothing written)")
    else:
        print("\nYou should run `uv lock` now to update the lockfile as well.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
