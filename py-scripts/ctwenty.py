#!/bin/python3

from datetime import datetime, timedelta
import signal
import psutil
from subprocess import Popen
from typing import Optional
from pathlib import Path

def cmd(s: str):
	return Popen(s, shell=True).wait()
def audio_block():
	cmd(r'touch ~/.cache/ctwenty.lock')
	# TODO: I don't think this dpms thing is that elegant
	# it'd be better to spawn a giant fullscreen window that blocks everything
	cmd(r'xset dpms force off')
	cmd(r'mpg123 ~/dotfiles/noisemaker/435923_luhenriking.mp3')
	cmd(r'xset dpms force on')
	cmd(r'i3-msg "restart"')
	cmd(r'i3-msg workspace "1: Aleph"')
	# bug with i3 sometimes, idk why
	cmd(r'i3-msg fullscreen toggle')
	cmd(r'i3-msg fullscreen toggle')
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
		p.write_text(f"{emoji}{t.strftime('%H:%M')}")

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
		assert sig == signal.SIGALRM
		current_status += 1
	print("New state: ", current_status)

	if current_status == -1:
		t = 0 # wait until next i3lock
		write_next_time(-1)
	elif current_status == 0:
		t = 1000
		write_next_time(0, 1337)
	elif current_status == 1:
		cmd(r'notify-send -i timer-symbolic -t 5000 "Rest your eyes!" '\
				r'"You have a mandatory break coming up soon in 6 minutes"')
		t = 300
		write_next_time(1, 300)
	elif current_status == 2:
		cmd(r'notify-send -i timer-symbolic -t 5000 "Rest your eyes!" '\
				r'"You have a mandatory break coming up soon in 37 seconds"')
		t = 37
		write_next_time(2, 37)
	else:
		raise ValueError("wtf?")

	signal.alarm(t)
