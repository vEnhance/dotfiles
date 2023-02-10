"""Miniature script:

Takes a plaintext email and
* Truncates quotes nested past depth 2
* HTML-ify's Evan's signature (3 lines long)
* Runs it through Markdown

"""

import sys
from importlib.util import find_spec
from pathlib import Path

import markdown

signature_lines = 0
signature_found = False
content = ""

for line in sys.stdin:
    if line == "-- \n":
        content += "\n" * 2
        content += "**Evan Chen (陳誼廷)**<br>" + "\n"
        content += "[https://web.evanchen.cc](https://web.evanchen.cc/)"
        content += "\n" * 2
        signature_lines = 3
        signature_found = True
    elif signature_lines > 0:
        signature_lines -= 1
        continue
    elif line.startswith(">>>>") and signature_found:
        break
    else:
        content += line.strip() + "\n"

extensions = ["extra", "sane_lists", "smarty"]
if find_spec("mdx_truly_sane_lists") is not None:
    extensions.append("mdx_truly_sane_lists")
output_html = markdown.markdown(content, extensions=extensions)

output_path = Path("/tmp/neomutt-alternative.html")
if output_path.exists():
    output_path.unlink()

with open(output_path, "w") as f:
    print(output_html, file=f)
print(output_html)
