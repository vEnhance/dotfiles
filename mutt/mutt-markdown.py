"""Miniature script:

Takes a plaintext email and
* Truncates quotes nested past depth 2
* Removes Evan's signature (3 lines long)
* Runs it through Darkdown

"""

import sys
import markdown

signature_lines = 0
signature_found = False
content = ""

for line in sys.stdin:
	if line == '-- \n':
		content += '\n'*2
		content += '**Evan Chen (陳誼廷)**<br>'
		content += '[https://web.evanchen.cc](https://web.evanchen.cc/)'
		content += '\n'*2
		signature_lines = 3
		signature_found = True
	elif signature_lines > 0:
		signature_lines -= 1
		continue
	elif line.startswith('>>') and signature_found:
		break
	else:
		content += line.strip() + '\n'

with open('/tmp/neomutt-alternative.html', 'w') as f:
	print(markdown.markdown(content), file=f)
