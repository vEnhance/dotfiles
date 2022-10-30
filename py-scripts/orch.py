#!/bin/python3

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

load_dotenv(Path('~/dotfiles/secrets/otis.env').expanduser())
OTIS_API_URL = 'https://otis.evanchen.cc/aincrad/api/'
OTIS_WEB_TOKEN = os.getenv('OTIS_WEB_TOKEN')
assert OTIS_WEB_TOKEN is not None

yaml.SafeDumper.orig_represent_str = yaml.SafeDumper.represent_str  # type: ignore


def repr_str(dumper, data):
	if '\n' in data:
		data = data.replace("\r", "")
		return dumper.represent_scalar(u'tag:yaml.org,2002:str', data, style='|')
	return dumper.orig_represent_str(data)


yaml.add_representer(str, repr_str, Dumper=yaml.SafeDumper)

ids = json.loads(Path('~/Sync/otis-evil-data/evil.json').expanduser().read_text())
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
	sys.exit(70)
puid, source = chosen.strip().split('\t')

EDITOR = os.environ.get('EDITOR', 'vim')

resp = requests.post(
	OTIS_API_URL, json={
		'action': 'get_hints',
		'puid': puid,
		'token': OTIS_WEB_TOKEN,
	}
)
if resp.status_code != 200:
	print(f"ARCH gave a return code of {resp.status_code} when asked for hints.")
	sys.exit(75)

old_hints = resp.json()['hints']

initial_message = yaml.dump(
	{
		'allow_delete_hints': False,
		'new_hints':
			[{
				'number': '<++>',
				'keywords': '<++>',
				'content': '<++>',
			} for _ in range(4)],
		'old_hints': old_hints,
	},
	sort_keys=False,
	Dumper=yaml.SafeDumper,
	allow_unicode=True
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
	edited_message = edited_message.replace(b'\t', b'  ')
	edited_message = edited_message.replace(b'<++>', b'null')
result = yaml.load(edited_message, Loader=yaml.SafeLoader)

if type(result) == dict:
	if 'new_hints' in result:
		new_hint_dicts = [
			d for d in result['new_hints'] if (
				(type(d.get('number')) == int) and (d.get('keywords') is not None) and
				(d.get('content') is not None) and len(d.keys()) == 3
			)
		]
		if len(new_hint_dicts) == 0:
			print("Aborting because no content.")
			sys.exit(65)
	else:
		new_hint_dicts = []

	data = {
		'action': 'add_many_hints',
		'token': OTIS_WEB_TOKEN,
		'puid': puid,
		'new_hints': new_hint_dicts,
		'old_hints': result['old_hints'],
		'allow_delete_hints': result['allow_delete_hints'],
	}
	resp = requests.post(OTIS_API_URL, json=data)

	if resp.status_code == 200:
		url = r'https://otis.evanchen.cc/arch/' + puid
		print(f"Added {len(resp.json()['pks'])} new hints; see {url}.")
		pyperclip.copy(url)
	else:
		print(f"Got a reply of {resp.status_code} from server when adding hints.")
else:
	print("Aborting because no content.")
	sys.exit(65)
