#!/usr/bin/env python3

import argparse
import io
import math
import re
import string
import sys
import traceback

ALLOWED_CHARS = string.ascii_letters + string.digits + "_"

ADVERTISEMENT = r"""/*
Converted from GeoGebra by User:Azjps using Evan's magic cleaner
https://github.com/vEnhance/dotfiles/blob/main/py-scripts/export-ggb-clean-asy.py
*/
"""

fat_decimal_regex = re.compile(r"(\d+\.\d{5})\d+")

parser = argparse.ArgumentParser(
    description="Translates ugly GGB exported Asy to something more readable."
)
parser.add_argument(
    "-s",
    "--speedy",
    action="store_true",
    help="Speedy mode. "
    "Reads the input from the clipboard rather than stdin (using pyperclip) "
    "and writes the resulting code directly to the clipboard too.",
)
parser.add_argument(
    "-n",
    "--no-header",
    action="store_true",
    help="Don't search for the first-line header.",
)
args = parser.parse_args()


def replace_numbers(s):
    return fat_decimal_regex.sub(r"\1", s)


if args.speedy:
    import pyperclip

    input_contents = pyperclip.paste()
else:
    input_contents = "".join(sys.stdin.readlines())

try:
    input_buffer = io.StringIO(input_contents)  # replace with clipboard
    output_buffer = io.StringIO()
    point_coords_dict = {}

    if args.no_header is False:
        first_line = input_buffer.readline()
        assert "Geogebra to Asymptote conversion" in first_line, (
            f"First line is missing header\n{first_line}"
        )
        # print(r'/* start ggb to asy preamble */', file=output_buffer)

    # Preamble
    for line in input_buffer:
        line = replace_numbers(line).strip()
        if line == "" or r"/* draw figures */" in line:  # end preamble
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
            content = line[5:].strip().rstrip(";")
            assignments = content.split(", ")
            for assn in assignments:
                point_name, point_coords = assn.split(" = ")
                point_coords_dict[point_name] = eval(point_coords)
        for statement in line.split(";"):
            if statement.strip():
                print(statement.strip() + ";", file=output_buffer)

    # Process figures
    for line in input_buffer:
        line = replace_numbers(line).strip()
        if r"dots and labels" in line:  # end figures
            break
        elif r"draw figures" in line:  # ignore this line
            continue
        elif r"grid" in line:  # delete grid
            continue
        line = line.replace("linewidth(2.)", "linewidth(0.6)")
        print(line.strip(), file=output_buffer)

    # Get the figure output, modulo point labelling
    figures_output_code = output_buffer.getvalue() + "\n"

    # Process dots and labels
    dot_regex = re.compile(r"dot\(([a-zA-Z0-9_]+|\([0-9\.\-,]+\)),.*?dotstyle\);")
    label_regex = re.compile(r'label\("(.+?)", (\([0-9\.\-,]+\)), .+?\);')
    label_to_coords = {}
    while True:
        # Reads lines in pairs, two at a time
        dot_line = replace_numbers(input_buffer.readline().strip())
        if dot_line == r"/* end of picture */" or dot_line == "":  # end of file
            break
        dot_match = dot_regex.match(dot_line)
        if dot_match is None:
            continue
        label_line = replace_numbers(input_buffer.readline().strip())
        label_match = label_regex.match(label_line)
        assert label_match is not None, label_line

        point_coords = dot_match.groups()[0]
        label = label_match.groups()[0]
        label_loc = eval(label_match.groups()[1])
        if point_coords in point_coords_dict:
            coords = point_coords_dict[point_coords]
        else:
            assert all(_ in ".0123456789-,()" for _ in point_coords)
            coords = eval(point_coords)

        if coords is None:
            figures_output_code += f'dot("{label}", {point_coords}, dir(45));\n'
        else:
            # determine the direction
            dx = 100 * (label_loc[0] - coords[0])
            dy = 100 * (label_loc[1] - coords[1])
            vdir = round(math.degrees(math.atan2(dy, dx)))
            if vdir < 0:
                vdir += 360
            figures_output_code += f'dot("{label}", {point_coords}, dir({vdir}));\n'
        label_to_coords[label] = point_coords

    # now clean up the code if possible by replacing explicit coordinates where we can
    used_point_var_names: list[str] = []
    pair_declarations = ""
    for label, point_coords in label_to_coords.items():
        if label[0] != "$" or label[-1] != "$":
            continue
        label = label[1:-1]
        label = label.replace("'", "p")
        point_var_name = "".join(_ for _ in label if _ in ALLOWED_CHARS)
        while point_var_name in used_point_var_names:
            if (d := point_var_name[-1]).isdigit() and d != 9:
                point_var_name = point_var_name[:-1] + str(int(d) + 1)
            else:
                point_var_name += "_0"
        figures_output_code = figures_output_code.replace(str(point_coords), label)
        pair_declarations += f"pair {label} = {point_coords};" + "\n"

    output = ADVERTISEMENT + pair_declarations + "\n" + figures_output_code

    # print finished output
    output = output.strip()
    if args.speedy:
        print(pair_declarations[:400] + "...\n" + figures_output_code[:600] + "...\n")
        response = input("Replace clipboard contents? [y/n] ")
        if response.strip().lower() == "y":
            pyperclip.copy(output)  # pyright: ignore
    else:
        print(output)

except Exception:
    print(input_contents[0:500])
    print("-" * 50)
    traceback.print_exc()
    if args.speedy:
        response = input("Failed. Press ENTER to continue... ")
    sys.exit(1)
