#!/usr/bin/env python3

## OSCAR (OLY SCORER)
# Takes a TSV and produces pretty LaTeX for statistics

__version__ = "2022-10-28"

import argparse
import os
import re
import statistics
import sys
from typing import List


def ssum(S):
    return sum(_ or 0 for _ in S)


def quadratic_mean(S):
    return statistics.mean(x**2 for x in S) ** 0.5


parser = argparse.ArgumentParser(description="Process some scores")
parser.add_argument(
    "files",
    nargs="*",
    type=argparse.FileType("r"),
    default=[sys.stdin],
    help="File to read; default to sys.stdin if not provided.",
)
parser.add_argument(
    "-o",
    "--output",
    nargs="?",
    const=sys.stdout,
    default=None,
    type=argparse.FileType("w"),
    help="Print output to this file (only works with one filename), pass with no argument for stdout.",
)
parser.add_argument(
    "-f",
    "--full",
    action="store_true",
    help="When passed, print the full breakdowns of all contestants.",
)
parser.add_argument(
    "-n",
    "--name",
    action="store",
    default=None,
    type=str,
    help="Name of competition for section headers (defaults to reading from filename).",
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
args = parser.parse_args(sys.argv[1:])


def main(tsv_file, outfile, name):
    # Read input
    scores_raw = []
    scores_total = []

    tsv_lines = tsv_file.readlines()

    for line in tsv_lines:
        if not line.strip():
            continue
        data = line.split("\t")  # e.g. 7 7 - 7 7 - 28
        pr_data = [int(x) if x in "01234567" and x else None for x in data[:-1]]
        total = ssum(pr_data)
        assert int(data[-1]) == total, data
        scores_raw.append(pr_data)
        scores_total.append(total)

    scores_raw.sort(key=lambda s: (-ssum(s), tuple(-(x or 0) for x in s)))
    scores_total.sort()
    N = len(scores_total)
    assert len(scores_raw) == N

    NUM_PROBLEMS = len(scores_raw[0])
    MAX_SCORE = 7 * NUM_PROBLEMS

    print(r"\section{Summary of scores for %s}" % name, file=outfile)
    mu = sum(scores_total) / float(N)
    sigma = (sum([(sc - mu) ** 2 for sc in scores_total]) / N) ** 0.5

    print(r"\[", file=outfile)
    print(r"\begin{array}{rl}", file=outfile)
    print("N&%d" % N, r"\\", file=outfile)
    print(r"\mu&%.2f" % (mu), r"\\", file=outfile)
    print(r"\sigma&%.2f" % (sigma), file=outfile)
    print(r"\end{array}", file=outfile)
    print(r"\qquad", file=outfile)

    print(r"\begin{array}{rl}", file=outfile)
    print(r"\text{1st Q}&%d" % (scores_total[N // 4]), r"\\", file=outfile)
    print(r"\text{Median}&%d" % (scores_total[N // 2]), r"\\", file=outfile)
    print(r"\text{3rd Q}&%d" % (scores_total[(3 * N) // 4]), file=outfile)
    print(r"\end{array}", file=outfile)
    print(r"\qquad", file=outfile)

    print(r"\begin{array}{rl}", file=outfile)
    print(r"\text{Max}&%d" % (scores_total[-1]), r"\\", file=outfile)
    print(r"\text{Top %d}&%d" % (args.a, scores_total[-args.a]), r"\\", file=outfile)
    print(r"\text{Top %d}&%d" % (args.b, scores_total[-args.b]), file=outfile)
    print(r"\end{array}", file=outfile)
    print(r"\]", file=outfile)
    print("\n", file=outfile)

    def get_table_cell(s, n):
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

    def get_bottom_cell(n: int, percent: bool):
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
        # intensity = int(round(0.01**(n / N) * 100))
        # textcolor = 'white' if n / N < 0.2 else 'black'

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

    # Now read scores by problem
    scores_by_pr: List[List[int]] = [
        [] for i in range(NUM_PROBLEMS)
    ]  # scores by problem
    for line in tsv_lines:
        if not line.strip:
            continue
        data = line.split("\t")
        studentscores = [int(x) if (x in "01234567" and x) else 0 for x in data[:-1]]
        assert sum(studentscores) == int(data[-1]), (
            f"Total doesn't match: {studentscores} != {data[-1]}"
        )
        for i in range(NUM_PROBLEMS):
            scores_by_pr[i].append(studentscores[i])

    print(r"\section{Problem statistics for %s}" % name, file=outfile)
    print(r"\[", file=outfile)
    print(r"\arraycolsep=0.4em\def\arraystretch{1.2}", file=outfile)
    print(r"\begin{array}{|r|" + "r" * NUM_PROBLEMS + "|}", file=outfile)
    print(r"\hline", file=outfile)
    width = round(18 / NUM_PROBLEMS + 1, ndigits=2)
    print(
        "".join(
            [
                r" & \multicolumn{1}{p{%sem}|}{\sffamily\bfseries\centering P%d} "
                % (width, i + 1)
                for i in range(NUM_PROBLEMS)
            ]
        ),
        end=" ",
        file=outfile,
    )
    print(r"\\ \hline", file=outfile)
    for s in range(0, 8):  # scores 0-7
        print(
            str(s)
            + " & "
            + "\n\t& ".join(
                [
                    get_table_cell(s, scores_by_pr[i].count(s))
                    for i in range(NUM_PROBLEMS)
                ]
            ),
            end=" ",
            file=outfile,
        )
        print(r"\\", file=outfile)
    print(r"\hline", file=outfile)
    # Compute mean
    print(r"\text{Avg} &", file=outfile)
    print(
        r" & ".join(
            ["%.2f" % statistics.mean(scores_by_pr[i]) for i in range(NUM_PROBLEMS)]
        ),
        file=outfile,
    )
    print(r"\\", file=outfile)
    # Compute quadratic mean
    print(r"\text{QM} &", file=outfile)
    print(
        r" & ".join(
            ["%.2f" % quadratic_mean(scores_by_pr[i]) for i in range(NUM_PROBLEMS)]
        ),
        file=outfile,
    )
    print(r"\\", file=outfile)
    # Compute #(solve)
    print(r"{}^{\#}5+ &", file=outfile)
    print(
        r" & ".join(
            [
                get_bottom_cell(
                    sum(int(x >= 5) for x in scores_by_pr[i]), percent=False
                )
                for i in range(NUM_PROBLEMS)
            ]
        ),
        file=outfile,
    )
    print(r"\\", file=outfile)
    # Compute %(solve)
    print(r"{}^{\%}5+ &", file=outfile)
    print(
        r" & ".join(
            [
                get_bottom_cell(sum(int(x >= 5) for x in scores_by_pr[i]), percent=True)
                for i in range(NUM_PROBLEMS)
            ]
        ),
        file=outfile,
    )
    print(r"\\ \hline", file=outfile)
    print(r"\end{array}", file=outfile)
    print(r"\]", file=outfile)
    print("\n", file=outfile)

    # Frequency stuffs
    print(r"\section{Rankings for %s}" % name, file=outfile)
    S = 0  # running sum for ranks
    i = MAX_SCORE
    ranks = {MAX_SCORE: 1}

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
    S = printMP(S, MAX_SCORE, int(2 * MAX_SCORE / 3) + 1)
    S = printMP(S, int(2 * MAX_SCORE / 3), int(MAX_SCORE / 3) + 1)
    S = printMP(S, int(MAX_SCORE / 3), 0)
    print(r"\end{center}", file=outfile)

    print(r"\section{Histogram for %s}" % name, file=outfile)
    if NUM_PROBLEMS <= 6:
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

    for i in range(MAX_SCORE + 1):
        print("\t" + "hist[%d] = %d;" % (i, scores_total.count(i)), file=outfile)
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
        % (MAX_SCORE, MAX_SCORE),
        file=outfile,
    )
    print(r"\end{asy}", file=outfile)
    print(r"\end{center}", file=outfile)

    # Full stats
    if args.full is True:
        print(r"\section{Full stats for %s}" % name, file=outfile)
        print(r"\begin{longtable}{r|" + "r" * NUM_PROBLEMS + "|r}", file=outfile)
        print(
            "Rank & " + " & ".join(f"P{i + 1}" for i in range(NUM_PROBLEMS)),
            file=outfile,
        )
        print(r"& $\Sigma$ \\ \hline \endhead", file=outfile)
        for scores in scores_raw:
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


def clean_name(s):
    if "." in s:
        s = s[: s.index(".")]
    s = s.replace("_", " ")
    return re.sub("([A-Z][a-z]+|[A-Z]+)", lambda e: e[0] + " ", s).strip()


if __name__ == "__main__":
    files = args.files
    assert len(files) == 1 or (args.output is None and args.name is None), (
        "can't write multiple inputs to a single output"
    )

    if len(files) == 1:
        f = files[0]
        if f == sys.stdin:
            if args.output is None:
                args.output = sys.stdout
            name = args.name or "competition"
        else:
            name = args.name or clean_name(os.path.basename(f.name))

        if args.output is None:
            with open(os.path.splitext(f.name)[0] + ".oscar.tex", "w") as o:
                main(f, o, name)
        else:
            main(f, args.output, name)

    else:
        for f in files:
            name = clean_name(os.path.basename(f.name))
            with open(os.path.splitext(f.name)[0] + ".oscar.tex", "w") as o:
                main(f, o, clean_name(name))
