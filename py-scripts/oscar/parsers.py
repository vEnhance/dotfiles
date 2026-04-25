from __future__ import annotations

import os
import sys
from pathlib import Path

from oscar.models import ContestData
from oscar.utils import clean_name, ssum


def detect_delimiter(filepath: Path) -> str:
    ext = filepath.suffix.lower()
    if ext == ".csv":
        return ","
    return "\t"


def detect_format(first_line: str, delimiter: str) -> str:
    """Returns 'per_student', 'per_problem_dist', or 'total_dist'."""
    tokens = first_line.strip().split(delimiter)
    # If all tokens are numeric (or '-' or empty), it's the old per-student format
    if all(t in ("", "-") or t.lstrip("-").isdigit() for t in tokens):
        return "per_student"
    # Has a header row
    if tokens[0].strip().lower() == "score":
        if len(tokens) == 2:
            return "total_dist"
        if len(tokens) > 2:
            return "per_problem_dist"
    raise ValueError(f"Cannot detect format from header: {first_line.strip()}")


def parse_per_student(lines: list[str], delimiter: str) -> ContestData:
    scores_raw: list[list[int | None]] = []

    for line in lines:
        if not line.strip():
            continue
        data = line.rstrip("\n\r").split(delimiter)
        pr_data = [int(x) if x in "01234567" and x else None for x in data[:-1]]
        total = ssum(pr_data)
        assert int(data[-1]) == total, f"Total mismatch: {data}"
        scores_raw.append(pr_data)

    scores_raw.sort(key=lambda s: (-ssum(s), tuple(-(x or 0) for x in s)))
    N = len(scores_raw)
    num_problems = len(scores_raw[0])
    max_total = 7 * num_problems

    # Derive problem_dist
    problem_dist: list[list[int]] = [[0] * 8 for _ in range(num_problems)]
    for student in scores_raw:
        for p, score in enumerate(student):
            problem_dist[p][score or 0] += 1

    # Derive total_dist
    total_dist = [0] * (max_total + 1)
    for student in scores_raw:
        total_dist[ssum(student)] += 1

    return ContestData(
        name="",
        num_problems=num_problems,
        n=N,
        problem_names=[f"P{i + 1}" for i in range(num_problems)],
        scores_raw=scores_raw,
        problem_dist=problem_dist,
        total_dist=total_dist,
    )


def parse_per_problem_dist(lines: list[str], delimiter: str) -> ContestData:
    header = lines[0].strip().split(delimiter)
    problem_names = [h.strip() for h in header[1:]]
    num_problems = len(problem_names)

    problem_dist: list[list[int]] = [[0] * 8 for _ in range(num_problems)]
    for line in lines[1:]:
        if not line.strip():
            continue
        tokens = line.strip().split(delimiter)
        score = int(tokens[0])
        for p, val in enumerate(tokens[1:]):
            problem_dist[p][score] = int(val)

    n = sum(problem_dist[0])
    # Validate all columns have same total
    for p in range(num_problems):
        col_total = sum(problem_dist[p])
        assert col_total == n, (
            f"Column {problem_names[p]} has {col_total} entries, expected {n}"
        )

    return ContestData(
        name="",
        num_problems=num_problems,
        n=n,
        problem_names=problem_names,
        problem_dist=problem_dist,
    )


def parse_total_dist(lines: list[str], delimiter: str) -> ContestData:
    total_dist: list[int] = []
    for line in lines[1:]:
        if not line.strip():
            continue
        tokens = line.strip().split(delimiter)
        score = int(tokens[0])
        count = int(tokens[1])
        # Extend if needed
        while len(total_dist) <= score:
            total_dist.append(0)
        total_dist[score] = count

    n = sum(total_dist)

    return ContestData(
        name="",
        n=n,
        total_dist=total_dist,
    )


def parse_file(filepath: Path) -> ContestData:
    delimiter = detect_delimiter(filepath)
    with open(filepath) as f:
        lines = f.readlines()

    fmt = detect_format(lines[0], delimiter)
    if fmt == "per_student":
        data = parse_per_student(lines, delimiter)
    elif fmt == "per_problem_dist":
        data = parse_per_problem_dist(lines, delimiter)
    elif fmt == "total_dist":
        data = parse_total_dist(lines, delimiter)
    else:
        raise ValueError(f"Unknown format: {fmt}")

    data.name = clean_name(os.path.basename(str(filepath)))
    return data


def parse_stdin(delimiter: str = "\t") -> ContestData:
    lines = sys.stdin.readlines()
    fmt = detect_format(lines[0], delimiter)
    if fmt == "per_student":
        data = parse_per_student(lines, delimiter)
    elif fmt == "per_problem_dist":
        data = parse_per_problem_dist(lines, delimiter)
    elif fmt == "total_dist":
        data = parse_total_dist(lines, delimiter)
    else:
        raise ValueError(f"Unknown format: {fmt}")
    data.name = "competition"
    return data


def merge_contest_data(parts: list[ContestData]) -> ContestData:
    """Merge multiple partial ContestData for the same contest."""
    assert len(parts) > 0

    if len(parts) == 1:
        return parts[0]

    # Validate N consistency
    ns = {p.n for p in parts if p.n > 0}
    if len(ns) > 1:
        raise ValueError(f"Participant count mismatch across inputs: {ns}")

    n = ns.pop() if ns else 0

    # Merge fields: take first non-None
    scores_raw = next((p.scores_raw for p in parts if p.scores_raw is not None), None)
    problem_dist = next(
        (p.problem_dist for p in parts if p.problem_dist is not None), None
    )
    total_dist = next((p.total_dist for p in parts if p.total_dist is not None), None)

    # num_problems: prefer explicit
    num_problems = next(
        (p.num_problems for p in parts if p.num_problems is not None), None
    )

    # problem_names: prefer non-default names
    problem_names: list[str] = []
    for p in parts:
        if p.problem_names and not all(
            name.startswith("P") and name[1:].isdigit() for name in p.problem_names
        ):
            problem_names = p.problem_names
            break
    if not problem_names:
        problem_names = next((p.problem_names for p in parts if p.problem_names), [])

    # Use first non-empty name
    name = next((p.name for p in parts if p.name), "competition")

    # Cross-validate: sum of problem scores == sum of total scores
    if problem_dist is not None and total_dist is not None:
        problem_score_sum = sum(
            score * count for dist in problem_dist for score, count in enumerate(dist)
        )
        total_score_sum = sum(score * count for score, count in enumerate(total_dist))
        if problem_score_sum != total_score_sum:
            raise ValueError(
                f"Score sum mismatch: problem distributions sum to {problem_score_sum}, "
                f"total distribution sums to {total_score_sum}"
            )

    return ContestData(
        name=name,
        num_problems=num_problems,
        n=n,
        problem_names=problem_names,
        scores_raw=scores_raw,
        problem_dist=problem_dist,
        total_dist=total_dist,
    )
