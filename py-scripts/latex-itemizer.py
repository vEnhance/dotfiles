import sys

initial_indent = 0
prev_indent = initial_indent

first_line = sys.stdin.readline()
print("% " + first_line)

for line in sys.stdin.readlines():
	if not line.strip(): continue
	line = line.rstrip()
	line = line.replace("$$", "$")
	num_spaces = len(line) - len(line.lstrip(' '))
	curr_indent = int(num_spaces / 4)
	while curr_indent > prev_indent:
		print("\t" * prev_indent + r"\begin{itemize}")
		prev_indent += 1
	while curr_indent < prev_indent:
		print("\t" * (prev_indent-1) + r"\end{itemize}")
		prev_indent -= 1
	print(curr_indent*"\t" + r"\ii " + line.strip())

while curr_indent > initial_indent:
	print("\t" * (curr_indent-1) + r"\end{itemize}")
	curr_indent -= 1
