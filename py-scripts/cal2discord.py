from typing import List, Tuple, Any
from calendar import TextCalendar
from icalendar import Calendar, Event
from discord_webhook import DiscordWebhook, DiscordEmbed
import argparse
import datetime
import humanize
import pytz
import recurring_ical_events
import requests
import yaml

parser = argparse.ArgumentParser()
parser.add_argument('config')
parser.add_argument('--dry', action='store_true')
parser.add_argument('--cal-exec', default=None)
args = parser.parse_args()
with open(args.config) as f:
	options = yaml.load(f, Loader=yaml.SafeLoader)

tz = pytz.timezone('US/Eastern')
now = datetime.datetime.now(tz)
interval_start = now + datetime.timedelta(hours=-4)
interval_end = now + datetime.timedelta(hours=60)

calendars : List[Tuple[str, Any]] = [
		(_['name'],
			Calendar.from_ical(requests.get(_['url']).text)) \
					for _ in options['calendars']]

events : List[Tuple[str, Event]] = []
for (calname, calendar) in calendars:
	for component in recurring_ical_events.of(calendar)\
			.between(interval_start, interval_end):
		events.append( (calname, component))

events.sort(key = lambda t : t[1]['DTEND'].dt)
output_string = ''

shorthands = [
		'🌞',
		'🐒',
		'🇹',
		'💍',
		'🌩️',
		'🍟',
		'📡'
		]
calendar_lines = TextCalendar(firstweekday=6).formatmonth(
		theyear = now.year,
		themonth = now.month,
		).strip().split('\n')
calendar_lines[1] = ' '.join(shorthands)
k = now.isoweekday() % 7
d = now.day
# that means the 1st was on (k-d+1)'th day of week
# so the calendar starts with (k-d+1) extra days
row = (d + ((k-d+1)%7) - 1) // 7 # 0-indexed row number to get

calendar_lines[row+2] = calendar_lines[row+2][:3*k] \
		+ '💚' + calendar_lines[row+2][3*k+2:]
calendar_text = '\n'.join(calendar_lines)
embed = DiscordEmbed(
		title = options.get('title', 'Calendar'),
		description = f"Generated on {now.strftime('%A, %B %d, %H:%M')}" \
				+ "\n" + f"Time zone: {tz.zone}" + "\n" \
				+ "```" + "\n" + calendar_text + "\n" + "```",
		color = options.get('color', 0x00ff00),
		)
if 'url' in options:
	embed.set_url(options['url'])

for calname, component in events[0:options.get('limit',27)]:
	start_time = component['DTSTART'].dt.astimezone(tz)
	delta = humanize.precisedelta(
			start_time - now,
			minimum_unit = "hours",
			# suppress = ('days',),
			format = "%.1f",
			)
	emoji = shorthands[start_time.isoweekday() % 7]
	when = f"{calname} {emoji} {start_time.strftime('%b %d %H:%M')}\n"
	if start_time < now:
		when += f"{delta} ago"
	else:
		when += f"in {delta}"
	embed.add_embed_field(
			name = component['SUMMARY'],
			value = when,
			)
	print(component['SUMMARY'] + '\n' + when + '\n')

webhook = DiscordWebhook(options['webhook_url'])
webhook.add_embed(embed)
if not args.dry:
	print(webhook.execute())
