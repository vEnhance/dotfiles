"""Miniature script:

Takes a plaintext email and
* Truncates quotes nested past depth 2
* HTML-ify's Evan's signature (3 lines long)
* Runs it through Markdown

"""

import sys
from pathlib import Path

import markdown

signature_lines = 0
signature_found = False
content = ""

for line in sys.stdin:
	if line == '-- \n':
		content += '\n' * 2
		content += '**Evan Chen (陳誼廷)**<br>' + '\n'
		content += '[https://web.evanchen.cc](https://web.evanchen.cc/)'
		content += '\n' * 2
		signature_lines = 3
		signature_found = True
	elif signature_lines > 0:
		signature_lines -= 1
		continue
	elif line.startswith('>>>>') and signature_found:
		break
	else:
		content += line.strip() + '\n'

output_path = Path('/tmp/neomutt-alternative.html')
if output_path.exists():
	output_path.unlink()

with open(output_path, 'w') as f:
	print(markdown.markdown(content, extensions=['extra', 'sane_lists', 'smarty']), file=f)
