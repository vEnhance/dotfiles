import argparse
from pathlib import Path

PUTNAM_PATH = Path("~/Dropbox/Math-Contest/Contests/Putnam/").expanduser()

parser = argparse.ArgumentParser(
    prog="putnam", description="Reads the statement of a Putnam problem"
)
parser.add_argument("year", type=int)
parser.add_argument("question")
opts = parser.parse_args()

assert len(opts.question) == 2


def get_first_line(line, question):
    name_with_dash = question[0].upper() + "--" + question[1]
    name_without_dash = question.upper()
    for n in (name_with_dash, name_without_dash):
        stop_code = r"\item[" + n + r"]"
        if line.startswith(stop_code):
            return line[len(stop_code) :]
    return None


with open(PUTNAM_PATH / f"{opts.year}.tex") as f:
    line = ""
    for line in f:
        if (first_line := get_first_line(line, opts.question)) is not None:
            output = first_line
            break
    else:
        raise ValueError(f"{opts.question} could not be found")

    for line in f:
        if line.startswith(r"\item[A") or line.startswith(r"\item[B"):
            break
        elif line.strip() == r"\end{document}":
            output = output.strip()
            if output.endswith(r"\end{itemize}"):
                output = output[:-13]
        else:
            output += line

output = output.strip()
print(output)
