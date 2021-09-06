#!/bin/python

import os
import subprocess
import sys
import time
from datetime import datetime, timedelta
from pathlib import Path

import psutil
import requests
from dotenv import load_dotenv

load_dotenv(Path(__file__).parent / '.env')


def is_locked():
	return any(p.name().startswith("i3lock") for p in psutil.process_iter())


print("Triggered", datetime.now())

fired = Path('~/.cache/motion.lock').expanduser()
try:
	if fired.exists():
		last_fired_time = datetime.fromisoformat(fired.read_text())
		if datetime.now() - last_fired_time < timedelta(minutes=10):
			print("Exiting because a lock file was found")
			sys.exit(0)
	fired.write_text(datetime.now().isoformat())

	beep_path = (Path(__file__).parent / 'audio/beep459992.mp3').absolute()
	alarm_path = (Path(__file__).parent / 'audio/warning543691.mp3').absolute()
	panic_path = (Path(__file__).parent / 'audio/panic470504.mp3').absolute()

	if is_locked():
		for _ in range(10):
			subprocess.run(args=["mpg123", alarm_path])
			time.sleep(4)
			if not is_locked():
				break
		else:  # still locked, PANIC
			k = os.getenv("KEY")
			assert k is not None
			url = "https://maker.ifttt.com/trigger/front_door_opened/with/key/" + k.strip()
			print(requests.post(url=url))
			while is_locked():
				subprocess.run(args=["mpg123", panic_path])
	else:
		subprocess.run(args=["mpg123", beep_path])
		time.sleep(2)

except Exception as e:
	fired.unlink()
	raise e
fired.unlink()
