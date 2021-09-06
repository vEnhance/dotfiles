import subprocess

from dotenv import load_dotenv
from flask import Flask, render_template

app = Flask(__name__)

load_dotenv()


@app.route("/")
def index():
	return render_template("base.html", title="SkyNet")


@app.route("/mosp")
def restart_mosp():
	process = subprocess.run(
		["systemctl", "restart", "mosp-2021.service", "--user"],
		capture_output=True,
		encoding='UTF-8',
	)
	return render_template("output.html", title="MOSP Bots", process=process)


@app.route("/evil")
def restart_evil():
	process = subprocess.run(
		["systemctl", "restart", "evil-chin.service", "--user"],
		capture_output=True,
		encoding='UTF-8',
	)
	return render_template("output.html", title="Evil Chin", process=process)
