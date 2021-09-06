import os
import subprocess
from pathlib import Path
from typing import Tuple

from dotenv import load_dotenv
from flask import Flask, redirect, render_template, request, session, url_for

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY")

VERBS = [
	'status',
	'start',
	'stop',
	'restart',
]
NOUNS = [
	'motion',
	'sentinel',
	'evil-chin',
	'mosp-2021',
	'evansync',
]
CAMERA_DOMAIN = (Path(__file__).parent / 'subdomains/camera').read_text().strip()


def check_status(noun: str) -> Tuple[str, str]:
	cmd = ["systemctl", "is-active", "--quiet", "--user", f"{noun}.service"]
	process = subprocess.run(cmd)
	if process.returncode == 4:
		return ('Not found', 'table-danger')
	elif process.returncode == 3:
		return ('Inactive', 'table-warning')
	elif process.returncode == 0:
		return ('Active', 'table-success')
	else:
		return ('Unknown', 'table-dark')


@app.route("/")
def index():
	if session.get('logged_in'):
		statuses = {noun: check_status(noun) for noun in NOUNS}
		return render_template(
			"index.html",
			title="SkyNet Sentinel Server",
			statuses=statuses,
			verbs=VERBS,
			camera=CAMERA_DOMAIN,
		)
	else:
		return render_template("login.html", title="Greetings, oh great one")


@app.route("/login", methods=['POST'])
def login():
	if request.form['password'] == os.getenv('SKYNET_PASSWORD'):
		session['logged_in'] = True
	return redirect(url_for('index'))


@app.route("/command/<verb>/<noun>/")
def run_command(verb: str, noun: str):
	if not session.get('logged_in'):
		return redirect(url_for('index'))
	assert verb in VERBS
	assert noun in NOUNS
	process = subprocess.run(
		["systemctl", verb, f"{noun}.service", "--user"],
		capture_output=True,
		encoding='UTF-8',
	)
	return render_template("output.html", title=f"{verb} {noun}", process=process)
