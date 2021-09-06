import subprocess

from dotenv import load_dotenv
from flask import Flask, redirect, render_template

app = Flask(__name__)

load_dotenv()


@app.route("/")
def index():
	return render_template("base.html", title="SkyNet", content="blah")


@app.route("/mosp")
def restart_mosp():
	subprocess.run(["systemctl", "restart", "mosp-2021.service", "--user"])
	return redirect('index')


@app.route("/evil")
def restart_evil():
	subprocess.run(["systemctl", "restart", "evil-chin.service", "--user"])
	return redirect('index')
