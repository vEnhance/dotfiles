#!/usr/bin/env python3
"""Audit and apply chaotic-aur package changes, separately from `pacman -Syu`.

/etc/pacman.conf declares the repo with a deliberately narrow usage:

    [chaotic-aur]
    Usage = Sync Search

Dropping Install and Upgrade means `pacman -Syu` never pulls a chaotic
package and `pacman -S foo` fails with "target not found" if foo only lives
there. The repo stays *registered*, so `pacman -Sl`, `paclist chaotic-aur`,
`pacman -Ss`, `pacman -Si` and `expac -S` keep working (pacsnap.sh and
aur-auto-vote-with-chaotic.py depend on that).

This script is the only way in. It re-grants `Usage = All` in a temporary
config generated from `pacman-conf`, but only after showing the upstream AUR
PKGBUILD diff for every package it is about to touch.

Recommended order, since chaotic packages often link against extra/ libs:

    sudo pacman -Syu    # official repos first
    chaotic             # then chaotic, with an audit prompt
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = "chaotic-aur"
AUR_GIT = "https://aur.archlinux.org/{}.git"
CACHE = (
    Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "chaotic" / "aur"
)

# How far back to walk a package's .SRCINFO history looking for the commit that
# built a given version. Matches are normally within a handful of commits; the
# cap just stops us walking a decade of history when chaotic and the AUR have
# diverged and no match exists.
MAX_LOG_SCAN = 200


# --------------------------------------------------------------------------
# plumbing
# --------------------------------------------------------------------------

COLOR = sys.stdout.isatty() and not os.environ.get("NO_COLOR")


def paint(code: str, text: str) -> str:
    return f"\033[{code}m{text}\033[0m" if COLOR else text


def bold(t: str) -> str:
    return paint("1", t)


def red(t: str) -> str:
    return paint("1;31", t)


def green(t: str) -> str:
    return paint("1;32", t)


def yellow(t: str) -> str:
    return paint("1;33", t)


def cyan(t: str) -> str:
    return paint("1;36", t)


def dim(t: str) -> str:
    return paint("2", t)


def out(cmd: list[str], check: bool = True) -> str:
    """Run cmd, return stdout. Raises on failure unless check=False."""
    p = subprocess.run(cmd, text=True, capture_output=True, check=False)
    if check and p.returncode != 0:
        die(f"{' '.join(cmd)} failed:\n{p.stderr.strip()}")
    return p.stdout


def die(msg: str) -> None:
    print(f"{red('error:')} {msg}", file=sys.stderr)
    sys.exit(1)


def vercmp(a: str, b: str) -> int:
    return int(out(["vercmp", a, b]).strip())


# --------------------------------------------------------------------------
# generated pacman configs
#
# We never edit /etc/pacman.conf at runtime. Instead we rebuild an equivalent
# config from `pacman-conf` output and override chaotic-aur's Usage to All.
# `pacman-conf` emits fully-resolved values (mirrorlists already expanded into
# Server lines), so the reconstruction stays correct if mirrors change.
# --------------------------------------------------------------------------


def options_block() -> str:
    lines: list[str] = []
    for line in out(["pacman-conf"]).splitlines():
        if line.startswith("["):
            # [options] is always first; the next header ends it.
            if lines:
                break
            continue
        lines.append(line)
    return "\n".join(lines)


def repo_block(repo: str, usage: str | None = None) -> str:
    lines = []
    for line in out(["pacman-conf", f"--repo={repo}"]).splitlines():
        if line.startswith("Usage") and usage is not None:
            continue
        lines.append(line)
    if usage is not None:
        lines.insert(0, f"Usage = {usage}")
    return f"[{repo}]\n" + "\n".join(lines)


def repo_list() -> list[str]:
    return out(["pacman-conf", "--repo-list"]).split()


def write_conf(chaotic_only: bool) -> Path:
    """Build a temp pacman.conf where chaotic-aur has full Usage.

    chaotic_only=True registers *just* chaotic-aur, so `pacman -Sy` refreshes
    chaotic-aur.db without also advancing core/extra/multilib. That keeps the
    invariant that official databases only move when you run `pacman -Syu`;
    otherwise this tool could set up a partial upgrade behind your back.
    """
    parts = ["[options]", options_block()]
    if chaotic_only:
        parts.append(repo_block(REPO, usage="All"))
    else:
        for r in repo_list():
            parts.append(repo_block(r, usage="All" if r == REPO else None))

    fd, path = tempfile.mkstemp(prefix="chaotic-", suffix=".conf", dir="/tmp")
    with os.fdopen(fd, "w") as f:
        f.write("\n\n".join(parts) + "\n")
    os.chmod(path, 0o644)  # readable by root under sudo
    return Path(path)


# --------------------------------------------------------------------------
# package state
# --------------------------------------------------------------------------


def chaotic_versions() -> dict[str, str]:
    """name -> version currently offered by chaotic-aur."""
    result = {}
    for line in out(["pacman", "-Sl", REPO]).splitlines():
        parts = line.split()
        if len(parts) >= 3:
            result[parts[1]] = parts[2]
    return result


def official_versions() -> dict[str, str]:
    repos = [r for r in repo_list() if r != REPO]
    result = {}
    for line in out(["pacman", "-Sl", *repos]).splitlines():
        parts = line.split()
        if len(parts) >= 3:
            # Earlier repos win, matching pacman's own precedence order.
            result.setdefault(parts[1], parts[2])
    return result


def installed_versions() -> dict[str, str]:
    result = {}
    for line in out(["pacman", "-Q"]).splitlines():
        name, _, ver = line.partition(" ")
        result[name] = ver
    return result


def ignored_packages() -> set[str]:
    return set(out(["pacman-conf", "IgnorePkg"], check=False).split())


def pkgbases(names: list[str]) -> dict[str, str]:
    """name -> pkgbase, read from the sync database via expac."""
    if not names:
        return {}
    result = {}
    for line in out(["expac", "-S", "%n %e", *names], check=False).splitlines():
        name, _, base = line.partition(" ")
        if name:
            result[name] = base.strip() or name
    return result


# --------------------------------------------------------------------------
# AUR PKGBUILD auditing
# --------------------------------------------------------------------------


def normalize(version: str) -> str:
    """Make a chaotic version comparable to an AUR .SRCINFO version.

    Chaotic rebuilds append a suffix to pkgrel (AUR i3lock-color 2.13.c.5-3
    ships as 2.13.c.5-3.3) and their epoch can differ from the AUR's (AUR
    uxplay is 1:1.73.6-1, chaotic ships 1.73.6-1). Strip both.
    """
    version = version.split(":", 1)[-1]
    if "-" in version:
        pkgver, _, pkgrel = version.rpartition("-")
        return f"{pkgver}-{pkgrel.split('.')[0]}"
    return version


def pkgver_only(version: str) -> str:
    return normalize(version).rpartition("-")[0] or normalize(version)


def git(repo: Path, *args: str, check: bool = True) -> str:
    return out(["git", "-C", str(repo), *args], check=check)


def sync_aur(pkgbase: str) -> Path | None:
    """Clone or fetch the AUR git repo for pkgbase. None if it has no AUR entry."""
    CACHE.mkdir(parents=True, exist_ok=True)
    repo = CACHE / pkgbase
    if repo.is_dir():
        p = subprocess.run(
            ["git", "-C", str(repo), "fetch", "--quiet", "origin"],
            text=True,
            capture_output=True,
            check=False,
        )
        if p.returncode != 0:
            print(f"  {yellow('warning:')} git fetch failed: {p.stderr.strip()}")
        return repo

    p = subprocess.run(
        ["git", "clone", "--quiet", AUR_GIT.format(pkgbase), str(repo)],
        text=True,
        capture_output=True,
        check=False,
    )
    if p.returncode != 0:
        shutil.rmtree(repo, ignore_errors=True)
        return None
    return repo


def srcinfo_version(repo: Path, sha: str) -> str | None:
    """epoch:pkgver-pkgrel recorded in .SRCINFO at the given commit."""
    text = git(repo, "show", f"{sha}:.SRCINFO", check=False)
    if not text:
        return None
    epoch = pkgver = pkgrel = None
    for line in text.splitlines():
        key, sep, value = line.partition("=")
        if not sep:
            continue
        key, value = key.strip(), value.strip()
        # First occurrence wins: these live in the pkgbase section, which
        # precedes any per-pkgname sections in a split package.
        if key == "pkgver" and pkgver is None:
            pkgver = value
        elif key == "pkgrel" and pkgrel is None:
            pkgrel = value
        elif key == "epoch" and epoch is None:
            epoch = value
    if not pkgver:
        return None
    version = f"{pkgver}-{pkgrel or '1'}"
    return f"{epoch}:{version}" if epoch else version


def find_commit(repo: Path, version: str) -> tuple[str | None, bool]:
    """Locate the commit that produced `version`.

    Returns (sha, exact). exact=False means we only matched on pkgver, because
    chaotic's pkgrel had drifted from the AUR's.
    """
    log = git(
        repo, "log", "--format=%H", f"-n{MAX_LOG_SCAN}", "origin/HEAD", "--", ".SRCINFO"
    ).split()
    target, target_pkgver = normalize(version), pkgver_only(version)
    loose = None
    for sha in log:
        found = srcinfo_version(repo, sha)
        if not found:
            continue
        if normalize(found) == target:
            return sha, True
        if loose is None and pkgver_only(found) == target_pkgver:
            loose = sha
    return loose, False


def delta(diff: str) -> str:
    """Run a plain (uncolored) diff through `delta` for syntax-aware coloring.

    --color-only leaves the diff structurally untouched (no side-by-side,
    no line-number gutter) and pulls colors from the terminal even though
    output is being captured rather than written to a tty.
    """
    p = subprocess.run(
        ["delta", "--color-only", "--paging=never"],
        input=diff,
        text=True,
        capture_output=True,
        check=False,
    )
    return p.stdout if p.returncode == 0 else diff


def audit(name: str, pkgbase: str, old: str | None, new: str) -> str:
    """Render the PKGBUILD audit for one package."""
    head = f"{bold(name)} {dim(old or '(not installed)')} {cyan('->')} {bold(new)}"
    if pkgbase != name:
        head += dim(f"  (pkgbase: {pkgbase})")
    lines = [head]

    repo = sync_aur(pkgbase)
    if repo is None:
        lines.append(
            f"  {yellow('no AUR entry')} - chaotic-native or dropped upstream; "
            "no PKGBUILD available to diff."
        )
        return "\n".join(lines)

    new_sha, new_exact = find_commit(repo, new)
    old_sha, old_exact = find_commit(repo, old) if old else (None, False)

    if new_sha is None:
        lines.append(
            f"  {yellow('note:')} no AUR commit matches {new}; "
            f"showing current AUR HEAD instead."
        )
        new_sha = git(repo, "rev-parse", "origin/HEAD").strip()
    elif not new_exact:
        lines.append(
            f"  {yellow('note:')} matched {new} on pkgver only (chaotic pkgrel differs)."
        )

    if old is None:
        lines.append(dim(f"  full PKGBUILD at {new_sha[:9]}:"))
        lines.append(git(repo, "show", f"{new_sha}:PKGBUILD", check=False))
        return "\n".join(lines)

    if old_sha is None:
        # Neither version is in AUR history. Usually means chaotic maintains
        # its own recipe for this package (chaotic-keyring, chaotic-mirrorlist)
        # and the AUR repo is a long-abandoned stub, so a commit log would be
        # actively misleading. Say what actually diverged instead.
        head_ver = srcinfo_version(repo, new_sha)
        if head_ver and pkgver_only(head_ver) != pkgver_only(new):
            lines.append(
                f"  {yellow('not tracked by the AUR:')} AUR is at {head_ver}, "
                f"chaotic ships {new}."
            )
            lines.append(
                "  Chaotic builds this from its own recipe; no upstream "
                "PKGBUILD to diff."
            )
        else:
            lines.append(
                f"  {yellow('note:')} no AUR commit matches installed {old}; "
                f"showing recent history instead of a diff."
            )
            lines.append(
                git(
                    repo, "log", "-n10", "--format=  %h %ad %s", "--date=short", new_sha
                )
            )
        return "\n".join(lines)

    if not old_exact:
        lines.append(f"  {yellow('note:')} matched installed {old} on pkgver only.")
    if old_sha == new_sha:
        lines.append(
            f"  {green('no PKGBUILD change')} - chaotic rebuilt the same recipe "
            f"(commit {old_sha[:9]})."
        )
        return "\n".join(lines)

    use_delta = COLOR and shutil.which("delta") is not None
    color = [] if use_delta else (["-c", "color.ui=always"] if COLOR else [])
    # .SRCINFO is generated from PKGBUILD, so its diff is pure duplication.
    diff = out(
        [
            "git",
            "-C",
            str(repo),
            *color,
            "diff",
            f"{old_sha}..{new_sha}",
            "--",
            ".",
            ":(exclude).SRCINFO",
        ],
        check=False,
    )
    if use_delta:
        diff = delta(diff)
    lines.append(dim(f"  {old_sha[:9]}..{new_sha[:9]}"))
    lines.append(
        diff.rstrip() if diff.strip() else f"  {green('no change outside .SRCINFO')}"
    )
    return "\n".join(lines)


def page(text: str) -> None:
    if not sys.stdout.isatty():
        print(text)
        return
    pager = os.environ.get("PAGER") or "less -R"
    try:
        p = subprocess.Popen(pager, shell=True, stdin=subprocess.PIPE, text=True)
        p.communicate(text)
    except OSError, BrokenPipeError:
        print(text)


# --------------------------------------------------------------------------
# commands
# --------------------------------------------------------------------------


def refresh() -> None:
    conf = write_conf(chaotic_only=True)
    try:
        print(f"{cyan('::')} Refreshing {REPO} database...")
        subprocess.run(["sudo", "pacman", "-Sy", "--config", str(conf)], check=True)
    finally:
        conf.unlink(missing_ok=True)


def pending_official() -> list[str]:
    """Upgrades `pacman -Syu` still owes, excluding chaotic packages."""
    chaotic = chaotic_versions()
    official = official_versions()
    result = []
    for line in out(["pacman", "-Qu"], check=False).splitlines():
        if "[ignored]" in line:
            continue
        name = line.split()[0]
        if name in official and name not in chaotic:
            result.append(name)
    return result


def resolve_updates(only: list[str]) -> tuple[list[tuple[str, str, str]], list[str]]:
    chaotic = chaotic_versions()
    official = official_versions()
    installed = installed_versions()
    ignored = ignored_packages()

    updates, skipped = [], []
    for name, new in sorted(chaotic.items()):
        if name not in installed:
            continue
        if only and name not in only:
            continue
        old = installed[name]
        if vercmp(new, old) <= 0:
            continue
        if name in ignored:
            skipped.append(f"{name} (IgnorePkg)")
            continue
        # If an official repo already offers this version or better, plain
        # `pacman -Syu` owns the upgrade and we should stay out of the way.
        if name in official and vercmp(official[name], new) >= 0:
            skipped.append(f"{name} (superseded by official repos)")
            continue
        updates.append((name, old, new))
    return updates, skipped


def confirm(prompt: str) -> bool:
    try:
        return input(f"{cyan('::')} {prompt} [y/N] ").strip().lower() in ("y", "yes")
    except EOFError, KeyboardInterrupt:
        print()
        return False


def install(names: list[str], noconfirm: bool) -> int:
    conf = write_conf(chaotic_only=False)
    try:
        cmd = ["sudo", "pacman", "-S", "--needed", "--config", str(conf)]
        if noconfirm:
            cmd.append("--noconfirm")
        return subprocess.run([*cmd, *names], check=False).returncode
    finally:
        conf.unlink(missing_ok=True)


def cmd_update(args: argparse.Namespace) -> int:
    if not args.no_refresh:
        refresh()

    updates, skipped = resolve_updates(args.packages)
    for note in skipped:
        print(f"{dim('skipping')} {note}")

    if not updates:
        print(f"{green('::')} Nothing to do; {REPO} packages are up to date.")
        return 0

    stale = pending_official()
    if stale:
        print(
            f"\n{yellow('warning:')} {len(stale)} official package(s) are still "
            f"pending ({', '.join(stale[:5])}"
            f"{', ...' if len(stale) > 5 else ''}).\n"
            f"          Run {bold('sudo pacman -Syu')} first to avoid a partial upgrade."
        )

    print(f"\n{cyan('::')} {len(updates)} {REPO} package(s) to upgrade:")
    for name, old, new in updates:
        print(f"    {name} {dim(old)} -> {new}")

    if not args.no_audit:
        bases = pkgbases([n for n, _, _ in updates])
        print(f"\n{cyan('::')} Fetching AUR PKGBUILDs for audit...")
        report = "\n\n".join(
            audit(name, bases.get(name, name), old, new) for name, old, new in updates
        )
        page(report)

    if not args.noconfirm and not confirm(f"Upgrade {len(updates)} package(s)?"):
        print("Aborted.")
        return 1
    return install([n for n, _, _ in updates], args.noconfirm)


def cmd_install(args: argparse.Namespace) -> int:
    if not args.no_refresh:
        refresh()

    chaotic = chaotic_versions()
    installed = installed_versions()
    missing = [n for n in args.packages if n not in chaotic]
    if missing:
        die(f"not in {REPO}: {', '.join(missing)}")

    if not args.no_audit:
        bases = pkgbases(args.packages)
        print(f"{cyan('::')} Fetching AUR PKGBUILDs for audit...")
        report = "\n\n".join(
            audit(n, bases.get(n, n), installed.get(n), chaotic[n])
            for n in args.packages
        )
        page(report)

    if not args.noconfirm and not confirm(f"Install {len(args.packages)} package(s)?"):
        print("Aborted.")
        return 1
    return install(args.packages, args.noconfirm)


def cmd_diff(args: argparse.Namespace) -> int:
    if not args.no_refresh:
        refresh()

    chaotic = chaotic_versions()
    installed = installed_versions()
    if args.packages:
        targets = []
        for n in args.packages:
            if n not in chaotic:
                die(f"not in {REPO}: {n}")
            targets.append((n, installed.get(n), chaotic[n]))
    else:
        targets = [(n, o, v) for n, o, v in resolve_updates([])[0]]
        if not targets:
            print(f"{green('::')} Nothing pending; {REPO} packages are up to date.")
            return 0

    bases = pkgbases([n for n, _, _ in targets])
    page("\n\n".join(audit(n, bases.get(n, n), old, new) for n, old, new in targets))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="chaotic",
        description="Audit and apply chaotic-aur changes, separately from pacman -Syu.",
    )
    sub = parser.add_subparsers(dest="command")

    def add_common(p: argparse.ArgumentParser) -> None:
        p.add_argument(
            "--no-refresh", action="store_true", help="skip refreshing chaotic-aur.db"
        )
        p.add_argument(
            "--no-audit", action="store_true", help="skip the PKGBUILD diff review"
        )
        p.add_argument("--noconfirm", action="store_true", help="do not prompt")

    p_update = sub.add_parser("update", help="upgrade installed chaotic packages")
    p_update.add_argument("packages", nargs="*", help="limit to these packages")
    add_common(p_update)
    p_update.set_defaults(func=cmd_update)

    p_install = sub.add_parser("install", help="install new packages from chaotic-aur")
    p_install.add_argument("packages", nargs="+")
    add_common(p_install)
    p_install.set_defaults(func=cmd_install)

    p_diff = sub.add_parser(
        "diff", help="show PKGBUILD diffs without changing anything"
    )
    p_diff.add_argument("packages", nargs="*", help="default: everything pending")
    p_diff.add_argument("--no-refresh", action="store_true")
    p_diff.set_defaults(func=cmd_diff)

    args = parser.parse_args()
    if args.command is None:
        args = parser.parse_args(["update"])
    return args.func(args)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(130)
