#!/bin/python3

import argparse
import os
import sys
from pathlib import Path
from pprint import pformat

import requests
from dotenv import load_dotenv

parser = argparse.ArgumentParser(description='Check Twitch status')
parser.add_argument('username', type=str, help='Username to check')
parser.add_argument(
	'-s',
	'--status',
	dest='use_status',
	action='store_true',
	help="Use status code 1 if the streamer is offline"
)
parser.add_argument(
	'-q',
	'--quiet',
	dest='is_quiet',
	action='store_true',
	help="Don't output anything",
)

args = parser.parse_args()

load_dotenv(Path('~/dotfiles/secrets/twitch.env').expanduser())
client_id = os.getenv('CLIENT_ID')
client_secret = os.getenv('CLIENT_SECRET')
streamer_name = args.username
assert client_id is not None
assert client_secret is not None

body = {
	'client_id': client_id,
	'client_secret': client_secret,
	"grant_type": 'client_credentials'
}
r = requests.post('https://id.twitch.tv/oauth2/token', data=body)
assert r.status_code == 200, pformat(r.json())

#data output
keys = r.json()
headers = {'Client-ID': client_id, 'Authorization': 'Bearer ' + keys['access_token']}
stream = requests.get(
	'https://api.twitch.tv/helix/streams?user_login=' + streamer_name, headers=headers
)
data = stream.json().get('data', [])
if len(data) > 0:
	print(f'{streamer_name}上線')
	print('#00FF00')
	sys.exit(0)
else:
	print(f'{streamer_name}離線')
	print('#FF0000')
	if args.use_status:
		sys.exit(1)
