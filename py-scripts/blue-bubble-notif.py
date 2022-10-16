import subprocess
import sys

sender, content = '', ''
my_messages: list[str] = []

for line in sys.stdin:
	line = line.strip()
	print(line)  # mirror the output

	if not "[INFO]" in line:
		continue
	if not line.startswith("flutter"):
		continue
	if "Client received new" in line and ";" in line:
		sender = line[line.rindex(";") + 1:]
	elif "(MessageStatus) -> Message match: [" in line:
		my_messages.append(line[95:-88])
	elif "(Actions-HandleMessage) -> New message: [" in line:
		if (x := line[101:-42]) in my_messages:
			my_messages.remove(x)
		else:
			content = x

	if sender != '' and content != '':
		subprocess.call(
			[
				'notify-send',
				'--icon=chat-message-new-symbolic',
				'--expire-time=10000',
				'--urgency=low',
				sender,
				content,
			]
		)
		sender, content = '', ''
