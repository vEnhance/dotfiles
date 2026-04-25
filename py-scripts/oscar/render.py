from __future__ import annotations

import sys
from typing import IO

from oscar.models import ContestData
from oscar.utils import (
    get_bottom_cell,
    get_table_cell,
    mean_from_dist,
    qm_from_dist,
    ssum,
)


def render_summary(contest: ContestData, outfile: IO[str], *, a: int, b: int) -> None:
    scores_total = contest.scores_total
    assert scores_total is not None
    N = contest.n
    name = contest.name

    print(r"\section{Summary of scores for %s}" % name, file=outfile)
    mu = sum(scores_total) / float(N)
    sigma = (sum([(sc - mu) ** 2 for sc in scores_total]) / N) ** 0.5

    print(r"\[", file=outfile)
    print(r"\begin{array}{rl}", file=outfile)
    print("N & %d" % N, r"\\", file=outfile)
    print(r"\mu & %.2f" % (mu), r"\\", file=outfile)
    print(r"\sigma & %.2f" % (sigma), file=outfile)
    print(r"\end{array}", file=outfile)
    print(r"\qquad", file=outfile)

    print(r"\begin{array}{rl}", file=outfile)
    print(r"\text{1st Q} & %d" % (scores_total[N // 4]), r"\\", file=outfile)
    print(r"\text{Median} & %d" % (scores_total[N // 2]), r"\\", file=outfile)
    print(r"\text{3rd Q} & %d" % (scores_total[(3 * N) // 4]), file=outfile)
    print(r"\end{array}", file=outfile)
    print(r"\qquad", file=outfile)

    print(r"\begin{array}{rl}", file=outfile)
    print(r"\text{Max} & %d" % (scores_total[-1]), r"\\", file=outfile)
    if a <= N:
        print(r"\text{Top %d} & %d" % (a, scores_total[-a]), r"\\", file=outfile)
    if b <= N:
        print(r"\text{Top %d} & %d" % (b, scores_total[-b]), file=outfile)
    print(r"\end{array}", file=outfile)
    print(r"\]", file=outfile)
    print("\n", file=outfile)


def render_problem_stats(contest: ContestData, outfile: IO[str]) -> None:
    assert contest.problem_dist is not None
    N = contest.n
    num_problems = contest.num_problems
    assert num_problems is not None
    problem_names = contest.problem_names or [f"P{i + 1}" for i in range(num_problems)]
    problem_dist = contest.problem_dist
    name = contest.name

    print(r"\section{Problem statistics for %s}" % name, file=outfile)
    print(r"\[", file=outfile)
    print(r"\arraycolsep=0.4em\def\arraystretch{1.2}", file=outfile)
    print(r"\begin{array}{|r|" + "r" * num_problems + "|}", file=outfile)
    print(r"\hline", file=outfile)
    width = round(18 / num_problems + 1, ndigits=2)
    print(
        "".join(
            [
                r" & \multicolumn{1}{p{%sem}|}{\sffamily\bfseries\centering %s} "
                % (width, problem_names[i])
                for i in range(num_problems)
            ]
        ),
        end=" ",
        file=outfile,
    )
    print(r"\\ \hline", file=outfile)
    for s in range(0, 8):
        print(
            str(s)
            + " & "
            + "\n\t& ".join(
                [get_table_cell(s, problem_dist[i][s], N) for i in range(num_problems)]
            ),
            end=" ",
            file=outfile,
        )
        print(r"\\", file=outfile)
    print(r"\hline", file=outfile)
    # Avg
    print(r"\text{Avg} &", file=outfile)
    print(
        r" & ".join(
            ["%.2f" % mean_from_dist(problem_dist[i]) for i in range(num_problems)]
        ),
        file=outfile,
    )
    print(r"\\", file=outfile)
    # QM
    print(r"\text{QM} &", file=outfile)
    print(
        r" & ".join(
            ["%.2f" % qm_from_dist(problem_dist[i]) for i in range(num_problems)]
        ),
        file=outfile,
    )
    print(r"\\", file=outfile)
    # #(solve)
    print(r"{}^{\#}5+ &", file=outfile)
    print(
        r" & ".join(
            [
                get_bottom_cell(
                    sum(problem_dist[i][s] for s in range(5, 8)), N, percent=False
                )
                for i in range(num_problems)
            ]
        ),
        file=outfile,
    )
    print(r"\\", file=outfile)
    # %(solve)
    print(r"{}^{\%}5+ &", file=outfile)
    print(
        r" & ".join(
            [
                get_bottom_cell(
                    sum(problem_dist[i][s] for s in range(5, 8)), N, percent=True
                )
                for i in range(num_problems)
            ]
        ),
        file=outfile,
    )
    print(r"\\ \hline", file=outfile)
    print(r"\end{array}", file=outfile)
    print(r"\]", file=outfile)
    print("\n", file=outfile)


def render_rankings(contest: ContestData, outfile: IO[str]) -> dict[int, int]:
    scores_total = contest.scores_total
    assert scores_total is not None
    N = contest.n
    max_total = contest.max_total
    assert max_total is not None
    name = contest.name

    print(r"\section{Rankings for %s}" % name, file=outfile)
    ranks: dict[int, int] = {max_total: 1}

    def printMP(S0, start, stop):
        S = S0
        print(r"\begin{minipage}[t]{0.32\textwidth}", file=outfile)
        print(r"\begin{verbatim}", file=outfile)
        print(r"Sc  Num  Cu   Per", file=outfile)
        i = start
        while i >= stop:
            S += scores_total.count(i)
            print(
                r"%2d  %3d  %3d  %.2f%%"
                % (i, scores_total.count(i), S, float(S) * 100.0 / N),
                file=outfile,
            )
            i -= 1
            ranks[i] = S + 1
        print(r"\end{verbatim}", file=outfile)
        print(r"\end{minipage}", file=outfile)
        return S

    print(r"\begin{center}", file=outfile)
    S = printMP(0, max_total, int(2 * max_total / 3) + 1)
    S = printMP(S, int(2 * max_total / 3), int(max_total / 3) + 1)
    S = printMP(S, int(max_total / 3), 0)
    print(r"\end{center}", file=outfile)

    return ranks


def render_histogram(contest: ContestData, outfile: IO[str]) -> None:
    assert contest.total_dist is not None
    assert contest.num_problems is not None
    max_total = contest.max_total
    assert max_total is not None
    total_dist = contest.total_dist
    name = contest.name

    print(r"\section{Histogram for %s}" % name, file=outfile)
    if contest.num_problems <= 6:
        yscale = 1
    else:
        yscale = 2
    print(r"\begin{center}", file=outfile)
    print(r"\begin{asy}", file=outfile)
    print(
        "\t"
        + r"""size(14cm, 0);
    real[] hist;
    real x = 2;
    real y = %f;"""
        % yscale,
        file=outfile,
    )

    for i in range(max_total + 1):
        count = total_dist[i] if i < len(total_dist) else 0
        print("\t" + "hist[%d] = %d;" % (i, count), file=outfile)
    print(
        r"""
    draw ((-x,0)--(%d*x,0));
    for(int i = 0; i <= %d; ++i) {
        filldraw(((i - 1)*x,0)--((i - 1)*x,hist[i]*y)--(i*x,hist[i]*y)--(i*x,0)--cycle, palecyan, black);
        if (hist[i] > 0) {
            label("$\mathsf{" + (string) hist[i] + "}$",((i - 0.5)*x,(hist[i])*y), dir(90), blue+fontsize(8pt));
        }
        if (i-i#7*7 == 0) {
            label((string) i, ((i-0.5)*x,0), 3*dir(-90), black+fontsize(8pt));
        }
        else {
            label((string) (i-i#10*10), ((i-0.5)*x,0), dir(-90), grey+fontsize(7pt));
        }
    }"""
        % (max_total, max_total),
        file=outfile,
    )
    print(r"\end{asy}", file=outfile)
    print(r"\end{center}", file=outfile)


def render_full_stats(
    contest: ContestData, outfile: IO[str], ranks: dict[int, int]
) -> None:
    assert contest.scores_raw is not None
    assert contest.num_problems is not None
    num_problems = contest.num_problems
    problem_names = contest.problem_names or [f"P{i + 1}" for i in range(num_problems)]
    name = contest.name

    print(r"\section{Full stats for %s}" % name, file=outfile)
    print(r"\begin{longtable}{r|" + "r" * num_problems + "|r}", file=outfile)
    print(
        "Rank & " + " & ".join(problem_names),
        file=outfile,
    )
    print(r"& $\Sigma$ \\ \hline \endhead", file=outfile)
    for scores in contest.scores_raw:
        total = ssum(scores)
        print(
            r"{\footnotesize\sffamily %3d.} &    " % ranks[total],
            end="",
            file=outfile,
        )
        print(
            " & ".join([str(_) if _ is not None else "-" for _ in scores]),
            end="",
            file=outfile,
        )
        print(f"    & {total:2d}" + r" \\", file=outfile)
    print(r"\end{longtable}", file=outfile)


def render(
    contest: ContestData,
    outfile: IO[str],
    *,
    full: bool,
    a: int,
    b: int,
    standalone: bool = False,
) -> None:
    if standalone:
        from datetime import date

        print(r"\documentclass[fontsize=11pt]{scrartcl}", file=outfile)
        print(r"\usepackage[colorsec]{evan}", file=outfile)
        print(file=outfile)
        print(r"\begin{document}", file=outfile)
        print(file=outfile)
        print(r"\title{%s Statistics}" % contest.name, file=outfile)
        print(r"\date{%s}" % date.today().isoformat(), file=outfile)
        print(r"\maketitle", file=outfile)
        print(file=outfile)

    scores_total = contest.scores_total

    if scores_total is not None:
        render_summary(contest, outfile, a=a, b=b)

    if contest.problem_dist is not None:
        render_problem_stats(contest, outfile)

    ranks = None
    if scores_total is not None and contest.max_total is not None:
        ranks = render_rankings(contest, outfile)

    if contest.total_dist is not None and contest.num_problems is not None:
        render_histogram(contest, outfile)

    if full:
        if contest.scores_raw is not None and ranks is not None:
            render_full_stats(contest, outfile, ranks)
        elif contest.scores_raw is None:
            print(
                "Warning: --full requires per-student data; skipping full stats.",
                file=sys.stderr,
            )

    if standalone:
        print(file=outfile)
        print(r"\end{document}", file=outfile)
