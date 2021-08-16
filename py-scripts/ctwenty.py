#!/bin/python3
"""
C-TWENTY

According to the American Optometric Association:
every 20 minutes you spend looking at a digital device or computer screen, you
should look at something else that is 20 feet away for a period of 20 seconds.

This is a Python script I wrote to enforce this. When run in the background,
using this dotfile system, it will cause i3 to enter an unusable state "trap"
while a short melody plays in the background for around 20 seconds.

It can be disabled temporarily by sending the SIGTSTP signal to it.
It will also automatically disable itself if it sees i3lock running.
It will resume when sent a SIGCONT signal.

Also, sending a SIGUSR1 will cause the script to fire immediately.
This is useful so that I can essentially *choose* my breaks
so long as there is one at least every twenty minutes.
Otherwise, I find myself constantly interrupted mid-sentence,
which is pretty annoying. :P
"""

import signal
import time
from datetime import datetime, timedelta
from pathlib import Path
from subprocess import Popen
from typing import Optional

import psutil


def cmd(s: str):
	return Popen(s, shell=True).wait()
def audio_block():
	cmd(r'touch ~/.cache/ctwenty.lock')
	cmd(r'i3-msg mode trap')
	cmd(r'i3-msg workspace "Trap"')
	time.sleep(1)
	cmd(r'mpg123 -f 3084 ~/dotfiles/noisemaker/435923_luhenriking.mp3')
	time.sleep(2)
	cmd(r'i3-msg workspace back_and_forth')
	cmd(r'i3-msg mode default')
	cmd(r'rm -f ~/.cache/ctwenty.lock')

def write_next_time(current_status : int, seconds: Optional[int] = None):
	p = Path('~/.cache/ctwenty.target').expanduser()
	if current_status == -1:
		if p.exists():
			p.unlink()
	else:
		assert seconds is not None
		t = datetime.now() + timedelta(seconds = seconds)
		if current_status == 2:
			emoji = "💛"
		elif current_status == 1:
			emoji = "💙"
		else:
			emoji = "🤍"
		p.write_text(f"{emoji}{t.strftime(':%M')}")

# we need to make sure the signals don't end the program
SIGNALS = [signal.SIGALRM, signal.SIGUSR1, signal.SIGTSTP,
		signal.SIGINT, signal.SIGTERM, signal.SIGCONT]
def noop(signum, frame):
	print(signum, frame)
for s in SIGNALS:
	signal.signal(s, noop)

current_status = -1
signal.alarm(120)
write_next_time(-1)
# -1: manually disabled until next time i3 unlocks
# 0: neutral state
# 1: first warning
# 2: second warning issued

while True:
	print("Current state:", current_status)
	sig = signal.sigwait(SIGNALS)
	print(sig)

	# update
	if sig == signal.SIGINT or sig == signal.SIGTERM:
		break
	elif sig == signal.SIGTSTP or "i3lock" in (p.name() for p in psutil.process_iter()):
		current_status = -1
		signal.alarm(0) # clear any pending alarms
	elif sig == signal.SIGUSR1 or current_status == 2:
		audio_block()
		current_status = 0
	else:
		current_status += 1
	print("New state: ", current_status)

	if current_status == -1:
		t = 0 # wait until next i3lock
		write_next_time(-1)
	elif current_status == 0:
		t = 1000
		write_next_time(0, 1337)
	elif current_status == 1:
		cmd(r'notify-send -i timer-symbolic -u low -t 120000 "Rest your eyes!" '\
				r'"You have a mandatory break coming up soon in 6 minutes"')
		t = 300
		write_next_time(1, 337)
	elif current_status == 2:
		cmd(r'notify-send -i timer-symbolic -t 30000 "Rest your eyes!" '\
				r'"You have a mandatory break coming up soon in 37 seconds"')
		t = 37
		write_next_time(2, 37)
	else:
		raise ValueError("wtf?")

	signal.alarm(t)
