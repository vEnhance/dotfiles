import json
import os
import subprocess
import tempfile
from pathlib import Path

import pyperclip
import requests
import yaml
from dotenv import load_dotenv
from von import api

load_dotenv(Path('~/SkyNet/private/.env'))

ids = json.loads(Path('~/ProGamer/OTIS/upload-to-server/evil.json').expanduser().read_text())
choices = '\n'.join(k + '\t' + v for k, v in ids.items())

chosen = subprocess.check_output(
	args=['fzf', '-e', '--tabstop', '12'],
	input=choices,
	text=True,
)
puid, source = chosen.strip().split('\t')

EDITOR = os.environ.get('EDITOR', 'vim')
initial_message = yaml.dump(
	{
		'puid': puid,
		'keywords': '<++>',
		'number': '<++>',
		'content': '<++>',
	}
)
initial_message += '\n' * 2
statement = api.get_statement(source)
for line in statement.splitlines():
	initial_message += ('# ' + line).strip() + '\n'
solution = api.get_solution(source)

if solution:
	initial_message += '\n\n' + '#' + '-' * 30 + '\n\n'
	for line in solution.splitlines():
		initial_message += ('# ' + line).strip() + '\n'

subprocess.Popen(
	args=['python', '-m', 'von', 'po', source],
	stdout=subprocess.DEVNULL,
	stderr=subprocess.DEVNULL,
)

with tempfile.NamedTemporaryFile(suffix=".yaml") as tf:
	tf.write(initial_message.encode('utf-8'))
	tf.flush()
	subprocess.call([EDITOR, tf.name])

	# do the parsing with `tf` using regular File operations.
	# for instance:
	tf.seek(0)
	edited_message = tf.read()
result = yaml.load(edited_message, Loader=yaml.SafeLoader)
content = result['content'].strip()

pyperclip.copy(content)

requests.post(
	'https://otis.evanchen.cc/aincrad/api',
	data={
		'action': 'add_hints',
		'token': os.getenv('OTIS_WEB_TOKEN'),
		'puid': puid,
		'content': content,
		'keywords': result['keywords'],
		'number': int(result['number']),
	}
)
