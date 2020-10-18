import pyperclip
import re
import string
import io
import traceback

banner = "# Evan's GGB to Asy Cleanup script #"
print("#"*len(banner))
print("# Evan's GGB to Asy Cleanup script #")
print("#"*len(banner))
print()

fat_decimal_regex = re.compile(r'(\d+\.\d{5})\d+')
def replace_numbers(s):
	return fat_decimal_regex.sub(r"\1", s)

clipboard_contents = pyperclip.paste()
try:
	input_buffer = io.StringIO(clipboard_contents)
	output_buffer = io.StringIO()

	first_line = input_buffer.readline()
	assert "Geogebra to Asymptote conversion" in first_line,\
			"First line is missing header\n" + first_line
	# print(r'/* start ggb to asy preamble */', file=output_buffer)
	points_dict = {}

	# preamble
	for line in input_buffer:
		line = replace_numbers(line).strip()
		if not line: # end preamble
			# print(r'/* end preamble */', file=output_buffer)
			break
		elif "real labelscalefactor" in line:
			continue
		elif "pen dps" in line:
			continue
		elif "pen dotstyle" in line:
			continue
		elif "real xmin" in line:
			continue
		elif line.startswith("pair "):
			# collect the coordinates of all the points
			content = line[5:].strip().rstrip(';')
			assignments = content.split(', ')
			for assn in assignments:
				point_name, pair = assn.split(' = ')
				points_dict[point_name] = eval(pair)
		print(line, file=output_buffer)

	# process figures
	for line in input_buffer:
		line = replace_numbers(line).strip()
		if line == "/* dots and labels */": # end figures
			break
		elif line == "/* draw figures */": # ignore this line
			continue
		elif "grid" in line: # delete grid
			continue
		line = line.replace("linewidth(2.)", "linewidth(0.6)")
		print(line.strip(), file=output_buffer)

	# process dots and labels
	dot_regex = re.compile(r'dot\(([a-zA-Z0-9_]+|\([0-9\.\-,]+\)),.*?dotstyle\);')
	label_regex = re.compile(r'label\("(.+?)", (\([0-9\.\-,]+\)), .+?\);')

	while True:
		dot_line = replace_numbers(input_buffer.readline().strip())
		if dot_line == r"/* end of picture */": # end of file
			break
		dot_match = dot_regex.match(dot_line)
		if dot_match is None:
			continue
		label_line = replace_numbers(input_buffer.readline().strip())
		label_match = label_regex.match(label_line)
		assert label_match is not None, label_line

		point = dot_match.groups()[0]
		label = label_match.groups()[0]
		label_loc = eval(label_match.groups()[1])
		# determine the direction
		if point in points_dict:
			coords = points_dict[point]
		else:
			assert all(_ in '.0123456789-,()' for _ in point)
			coords = eval(point)

		if coords is None:
			print(r'dot("%s", %s, dir(45));' %(label, point), file=output_buffer)
		else:
			dx = 100*(label_loc[0]-coords[0])
			dy = 100*(label_loc[1]-coords[1])
			print(r'dot("%s", %s, dir((%.3f, %.3f)));' %(label, point, dx, dy), file=output_buffer)

	output = output_buffer.getvalue()
	print(output[:500] + '\n...\n' + output[-500:])
	response = input("Replace clipboard contents? [y/n] ")
	if response.strip().lower() == 'y':
		pyperclip.copy(output)

except:
	print("Input:")
	print()
	print(clipboard_contents[0:500] + '...')
	print('-'*40 + '\n')
	traceback.print_exc()
	response = input("Failed. Press ENTER to continue... ")
