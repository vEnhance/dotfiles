from __future__ import annotations

import re
import statistics


def ssum(S):
    return sum(_ or 0 for _ in S)


def quadratic_mean(S):
    return statistics.mean(x**2 for x in S) ** 0.5


def mean_from_dist(dist: list[int]) -> float:
    total = sum(score * count for score, count in enumerate(dist))
    n = sum(dist)
    return total / n


def qm_from_dist(dist: list[int]) -> float:
    total = sum(score**2 * count for score, count in enumerate(dist))
    n = sum(dist)
    return (total / n) ** 0.5


def clean_name(s: str) -> str:
    if "." in s:
        s = s[: s.index(".")]
    s = s.replace("_", " ")
    return re.sub("([A-Z][a-z]+|[A-Z]+)", lambda e: e[0] + " ", s).strip()


def get_table_cell(s: int, n: int, N: int) -> str:
    if s == 0:
        color = "orange"
    elif s == 1:
        color = "yellow"
    elif s == 2:
        color = "cyan"
    elif s == 3 or s == 4:
        color = "blue"
    elif s >= 5:
        color = "green"
    else:
        raise ValueError(f"No color for s = {s}")
    intensity = int(round((n / N) ** (0.6) * 100))
    return r"{\cellcolor{%s!%d!white} %d}" % (color, int(intensity), n)


def get_bottom_cell(n: int, N: int, percent: bool) -> str:
    r = n / N
    assert 0 <= r <= 1
    if r >= 0.7:
        intensity = 5
        colorA = "black"
        colorB = "white"
        textcolor = "black"
    elif r >= 0.2:
        intensity = int(35 - (r - 0.2) * 60)
        colorA = "black"
        colorB = "white"
        textcolor = "black"
    else:
        intensity = 100 - 60 * 0.2 ** (5 * r)
        colorA = "white!40!black"
        colorB = "red"
        textcolor = "white"

    if percent:
        content = r"{}^{\%}" + f"{100 * r:.1f}"
    else:
        content = r"\textbf{" + str(n) + "}"

    return r"{\cellcolor{%s!%d!%s}\color{%s}%s}" % (
        colorA,
        int(intensity),
        colorB,
        textcolor,
        content,
    )
