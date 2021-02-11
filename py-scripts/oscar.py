#!/bin/python3

## OSCAR (OLY SCORER)
# Takes a TSV and produces pretty LaTeX for statistics

__version__ = "2020-11"

import sys
import argparse
import statistics

def ssum(S):
	return sum(_ or 0 for _ in S)

parser = argparse.ArgumentParser(description="Process some scores")
parser.add_argument('filename',
		help='File to read; default to sys.stdin otherwise.')
parser.add_argument('-s', '--summary', action='store_true',
		help='When passed, only print summary stats, not full table.')
args = parser.parse_args(sys.argv[1:])

with open(args.filename, 'r') as tsvfile:
	scores_raw = []
	scores_total = []
	for line in tsvfile:
		if not line.strip(): continue
		data = line.split('\t') # e.g. 7 7 - 7 7 - 28
		pr_data = [int(x) if x in '01234567' and x else None \
				for x in data[:-1]]
		total = ssum(pr_data)
		assert int(data[-1]) == total, data
		scores_raw.append(pr_data)
		scores_total.append(total)

	scores_raw.sort(key = lambda s : (-ssum(s), str(s)))
	scores_total.sort()
	N = len(scores_total)
	assert len(scores_raw) == N

NUM_PROBLEMS = len(scores_raw[0])
MAX_SCORE = 7 * NUM_PROBLEMS

print(r"\section{Summary of Scores}")
mu = sum(scores_total) / float(N)
sigma = (sum([(sc-mu)**2 for sc in scores_total]) / N)**0.5

print(r"\[")
print(r"\begin{array}{rl}")
print("N&%d" %N, r"\\")
print(r"\mu&%.2f" %(mu), r"\\")
print(r"\sigma&%.2f" %(sigma))
print(r"\end{array}")
print(r"\qquad")

print(r"\begin{array}{rl}")
print(r"\text{1st Q}&%d" %(scores_total[N//4]), r"\\")
print(r"\text{Median}&%d" %(scores_total[N//2]), r"\\")
print(r"\text{3rd Q}&%d" %(scores_total[(3*N)//4]))
print(r"\end{array}")
print(r"\qquad")

print(r"\begin{array}{rl}")
print(r"\text{Max}&%d" %(scores_total[-1]), r"\\")
print(r"\text{Top 3}&%d" %(scores_total[-3]), r"\\")
print(r"\text{Top 10}&%d" %(scores_total[-10]))
print(r"\end{array}")
print(r"\]")
print("\n")

def get_table_cell(s, n):
	if s == 0:
		color = "orange"
	elif s == 1:
		color = "yellow"
	elif s == 2:
		color = "blue"
	elif s == 3 or s == 4:
		color = "cyan"
	elif s >= 5:
		color = "green"
	intensity = int(round( (n/N)**(0.6) * 100 ))
	return r"{\cellcolor{%s!%d!white} %d}" %(color, int(intensity), n)

with open(args.filename, "r") as tsvfile:
	scores_by_pr = [[] for i in range(NUM_PROBLEMS)] # scores by problem
	for line in tsvfile:
		if not line.strip: continue
		data = line.split('\t')
		studentscores = [int(x) if (x in '01234567' and x) else 0 for x in data[:-1]]
		assert sum(studentscores) == int(data[-1]), \
				"Total doesn't match: " + str(studentscores) + " != " + data[-1]
		for i in range(NUM_PROBLEMS):
			scores_by_pr[i].append(studentscores[i])
print(r"\section{Problem Statistics}")
print(r"\[")
print(r"\arraycolsep=1em\def\arraystretch{1.2}")
print(r"\begin{array}{|r|" + "r"*NUM_PROBLEMS + "|}")
print(r'\hline')
print(''.join([r" & \text{P%d}" %(i+1) for i in range(NUM_PROBLEMS)]), end=' ')
print(r"\\ \hline")
for s in range(0,8): # scores 0-7
	print(str(s) + " & " + "\n\t& ".join([
			get_table_cell(s, scores_by_pr[i].count(s)) \
			for i in range(NUM_PROBLEMS)]), end=' ')
	print(r"\\")
print(r"\hline")
print(r"\text{Avg} & ")
print(r" & ".join(["%.2f" % statistics.mean(scores_by_pr[i]) \
		for i in range(NUM_PROBLEMS)]))
print(r"\\ \hline")
print(r"\end{array}")
print(r"\]")
print("\n")
#Frequency stuffs
print(r"\section{Rankings}")
S = 0 # running sum for ranks
i = MAX_SCORE
ranks = {MAX_SCORE : 1}
def printMP(start, stop):
	global S # sigh
	print(r"\begin{minipage}[t]{0.32\textwidth}")
	print(r"\begin{verbatim}")
	print(r"Sc  Num  Cu   Per")
	i = start
	while i >= stop:
		S += scores_total.count(i)
		print(r"%2d  %3d  %3d  %.2f%%" %(i, scores_total.count(i), S, float(S) * 100.0 / N))
		i -= 1
		ranks[i] = S+1
	print(r"\end{verbatim}")
	print(r"\end{minipage}")

print(r"\begin{center}")
printMP(MAX_SCORE, int(2*MAX_SCORE/3)+1)
printMP(int(2*MAX_SCORE/3), int(MAX_SCORE/3)+1)
printMP(int(MAX_SCORE/3), 0)
print(r"\end{center}")

print(r"\section{Histogram}")
if NUM_PROBLEMS <= 6:
	yscale = 1
else:
	yscale = 2
print(r"\begin{center}")
print(r"\begin{asy}")
print(r"""size(14cm, 0);
real[] hist;
real x = 2;
real y = %f;""" %yscale )

for i in range(MAX_SCORE+1):
	print("hist[%d] = %d;" %(i, scores_total.count(i)))
print(r"""
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
}
""" %(MAX_SCORE, MAX_SCORE))
print(r"\end{asy}")
print(r"\end{center}")

# Full stats
if args.summary is False:
	print(r"\section{Full stats}")
	print(r"\begin{longtable}{r|" + "r"*NUM_PROBLEMS + "|r}")
	print("Rank & " + " & ".join("P%d" %(i+1) for i in range(NUM_PROBLEMS)) \
			+ r"& $\Sigma$ \\ \hline \endhead")
	for s in scores_raw:
		total = ssum(s)
		print(r"{\footnotesize\sffamily %d.} & " % ranks[total] \
				+ ' & '.join([str(_) if _ is not None else '-' for _ in s])
				+ '\t & ' + str(total) + r'\\')
	print(r"\end{longtable}")
