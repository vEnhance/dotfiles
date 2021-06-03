from typing import List, Tuple
from ics import Calendar, Event
from discord_webhook import DiscordWebhook, DiscordEmbed
import pytz
import datetime
import requests
import argparse
import yaml
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('config')
parser.add_argument('--dry', action='store_true')
args = parser.parse_args()
with open(args.config) as f:
	options = yaml.load(f, Loader=yaml.SafeLoader)

tz = pytz.timezone('US/Eastern')
now = datetime.datetime.now(tz)
interval_start = now + datetime.timedelta(hours=-4)
interval_end = now + datetime.timedelta(hours=168)

calendars = [(_['name'], Calendar(requests.get(_['url']).text)) \
		for _ in options['calendars']]

events : List[Tuple[str, Event]] = []
for (calname, c) in calendars:
	for e in c.timeline:
		if interval_start < e.end < interval_end:
			events.append( (calname,e) )
events.sort(key = lambda t : t[1].begin)

output_string = ''

shorthands = [
		'☀️', 
		'🐒',
		'🇹',
		'💍',
		'🌩️',
		'🍟',
		'📡'
		]

# get a silly calendar
calendar_lines = subprocess.check_output(['cal']).decode('utf-8').split('\n')
calendar_lines[1] = f'{shorthands[0]}  {shorthands[1]} {shorthands[2]} {shorthands[3]} {shorthands[4]} {shorthands[5]} {shorthands[6]}'
k = now.isoweekday() % 7
d = now.day
print(k)
print(now.strftime('%c'))
row = (d + (6-k)) // 7
calendar_lines[row+2] = calendar_lines[row+2][:3*k] \
		+ '💚' + calendar_lines[row+2][3*k+2:]
calendar_text = '\n'.join(calendar_lines)
print(calendar_text)

embed = DiscordEmbed(
		title = options.get('title', 'Calendar'),
		description = f"Generated on {now.strftime('%A, %B %d, %H:%M')}" \
				+ "\n" + f"Time zone: {tz.zone}" + "\n" \
				+ "```" + "\n" + calendar_text + "\n" + "```",
		color = options.get('color', 0x00ff00),
		)
if 'url' in options:
	embed.set_url(options['url'])

for calname, e in events[0:options.get('limit',27)]:
	emoji = shorthands[e.begin.weekday()]
	when = f"{emoji} {e.begin.strftime('%b %d %H:%M')}\n" \
			f"{calname} {e.begin.humanize()}"
	embed.add_embed_field(
			name = e.name,
			value = when,
			)

webhook = DiscordWebhook(options['webhook_url'])
webhook.add_embed(embed)
if not args.dry:
	print(webhook.execute())
