import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

import pyperclip
import requests
import yaml
from dotenv import load_dotenv
from von import api

load_dotenv(Path('~/SkyNet/private/.env').expanduser())
OTIS_API_URL = 'https://otis.evanchen.cc/aincrad/api/'
OTIS_WEB_TOKEN = os.getenv('OTIS_WEB_TOKEN')
assert OTIS_WEB_TOKEN is not None

ids = json.loads(Path('~/ProGamer/OTIS/upload-to-server/evil.json').expanduser().read_text())
choices = '\n'.join(k + '\t' + v for k, v in ids.items())

try:
	chosen = subprocess.check_output(
		args=[
			'fzf', '-e', '--tabstop', '12', '-d', r'\t', '--preview', 'python -m von show {2}',
			'--preview-window', 'down'
		],
		input=choices,
		text=True,
	)
except subprocess.CalledProcessError as e:
	print(f"Exiting because fzf failed with return code {e.returncode}.")
	sys.exit(1)
puid, source = chosen.strip().split('\t')

EDITOR = os.environ.get('EDITOR', 'vim')

resp = requests.post(
	OTIS_API_URL, data={
		'action': 'get_hints',
		'puid': puid,
		'token': OTIS_WEB_TOKEN,
	}
)
if resp.status_code != 200:
	print(f"ARCH gave a return code of {resp.status_code} when asked for hints.")
	sys.exit(2)

old_hints = resp.json()['hints']

initial_message = yaml.dump(
	{
		'puid': puid,
		'keywords': '<++>',
		'number': '<++>',
		'content': '<++>',
		'old_hints': old_hints,
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

if type(result) == dict and 'content' in result:
	content = result['content'].strip()

	pyperclip.copy(content)
	data = {
		'action': 'add_hints',
		'token': OTIS_WEB_TOKEN,
		'puid': puid,
		'content': content,
	}
	if 'number' in result and type(result['number']) == int:
		data['number'] = result['number']
	if 'keywords' in result and type(result['keywords']) == str and result['keywords'].strip():
		data['keywords'] = result['keywords']
	resp = requests.post(OTIS_API_URL, data=data)
	if resp.status_code == 200:
		pk = resp.json()['pk']
		print(f"https://otis.evanchen.cc/arch/pk/{pk}/")
		pass
	else:
		print(f"Got a reply of {resp.status_code} from server when adding hints.")
else:
	print("Aborting because no content.")
	sys.exit(4)
