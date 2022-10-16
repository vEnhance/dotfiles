import os
import sys
from pathlib import Path
from pprint import pformat

import requests
from dotenv import load_dotenv

if len(sys.argv) != 2:
	print("WTF tell me who to look at", file=sys.stderr)
	sys.exit(2)

load_dotenv(Path('~/dotfiles/secrets/twitch.env').expanduser())
client_id = os.getenv('CLIENT_ID')
client_secret = os.getenv('CLIENT_SECRET')
streamer_name = sys.argv[1]
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
	print('Online')
	sys.exit(0)
else:
	print('Offline')
	sys.exit(1)
