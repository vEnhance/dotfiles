#!/bin/python3

import signal
import psutil
from subprocess import Popen

def cmd(s: str):
	return Popen(s, shell=True).wait()
def audio_block():
	cmd(r'touch ~/.cache/ctwenty.lock')
	cmd(r'xset dpms force off')
	cmd(r'mpg123 ~/dotfiles/noisemaker/435923_luhenriking.mp3')
	cmd(r'xset dpms force on')
	cmd(r'i3-msg "restart"')
	cmd(r'i3-msg workspace "1: Aleph"')
	# bug with i3 sometimes, idk why
	cmd(r'i3-msg fullscreen toggle')
	cmd(r'i3-msg fullscreen toggle')
	cmd(r'rm -f ~/.cache/ctwenty.lock')

# we need to make sure the signals don't end the program
SIGNALS = [signal.SIGALRM, signal.SIGUSR1, signal.SIGTSTP,
		signal.SIGINT, signal.SIGTERM, signal.SIGCONT]
def noop(signum, frame):
	pass
for s in SIGNALS:
	signal.signal(s, noop)

current_status = -1
signal.alarm(120)
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
	elif current_status == 0:
		t = 1000
	elif current_status == 1:
		cmd(r'notify-send -i timer-symbolic -t 5000 "Rest your eyes!" '\
				r'"You have a mandatory break coming up soon in 4 minutes"')
		t = 300
	elif current_status == 2:
		cmd(r'notify-send -i timer-symbolic -t 5000 "Rest your eyes!" '\
				r'"You have a mandatory break coming up soon in 4 minutes"')
		t = 60
	else:
		raise ValueError("wtf?")

	signal.alarm(t)
