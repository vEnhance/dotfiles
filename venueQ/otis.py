import os
import random
import re
import smtplib
import ssl
import subprocess
import time
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from pathlib import Path
from typing import Optional

import markdown
import requests
from dotenv import load_dotenv

from venueQ import Data, VenueQNode, VenueQRoot, logger

OTIS_PDF_PATH = Path('/tmp/otis-pdf')
if not OTIS_PDF_PATH.exists():
	OTIS_PDF_PATH.mkdir()
	OTIS_PDF_PATH.chmod(0o777)
HANDOUTS_PATH = Path('~/ProGamer/OTIS/Materials')
CHACHING_SOUND_PATH = Path('~/dotfiles/sh-scripts/noisemaker.sh').expanduser()


def send_email(subject: str, recipient: str, body: str):
	mail = MIMEMultipart('alternative')
	mail['From'] = 'OTIS Overlord <evan@evanchen.cc>'
	mail['To'] = recipient
	mail['Subject'] = subject

	plain_msg = body
	plain_msg += '\n' * 2
	plain_msg += '**Evan Chen (陳誼廷)**<br>' + '\n'
	plain_msg += '[https://web.evanchen.cc](https://web.evanchen.cc/)'
	html_msg = markdown.markdown(plain_msg, extensions=['extra', 'sane_lists', 'smarty'])
	mail.attach(MIMEText(plain_msg, 'plain'))
	mail.attach(MIMEText(html_msg, 'html'))

	password = subprocess.run(
		['secret-tool', 'lookup', 'user', 'evanchen.mit', 'type', 'gmail'],
		text=True,
		capture_output=True
	).stdout

	session = smtplib.SMTP('smtp.gmail.com', 587)
	session.starttls(context=ssl.create_default_context())
	session.login('evanchen.mit@gmail.com', password)
	session.sendmail('evan@evanchen.cc', recipient, mail.as_string())


load_dotenv(Path('~/dotfiles/otis.env').expanduser())
TOKEN = os.getenv('OTIS_WEB_TOKEN')
assert TOKEN is not None
PRODUCTION = os.getenv('PRODUCTION', False)
if PRODUCTION:
	OTIS_API_URL = 'https://otis.evanchen.cc/aincrad/api/'
else:
	OTIS_API_URL = 'http://127.0.0.1:8000/aincrad/api/'


def query_otis_server(payload: Data, play_sound=True) -> Optional[requests.Response]:
	payload['token'] = TOKEN
	logger.debug(payload)
	resp = requests.post(OTIS_API_URL, json=payload)
	if resp.status_code == 200:
		logger.info("Got a 200 response back from server")
		if play_sound:
			subprocess.run([CHACHING_SOUND_PATH.absolute().as_posix(), '5'])
		return resp
	else:
		logger.error(
			f"OTIS-WEB threw an exception with status code {resp.status_code}\n" +
			resp.content.decode('utf-8')
		)
		return None


class ProblemSet(VenueQNode):
	EXTENSIONS = ('pdf', 'txt', 'tex', 'jpg', 'png')
	HARDNESS_CHART = {
		'E': 2,
		'M': 3,
		'H': 5,
		'Z': 9,
		'X': 0,
		'I': 0,
	}
	VON_RE = re.compile(r'^\\von([EMHZXI])(R?)(\[.*?\]|\*)?\{(.*?)\}')
	PROB_RE = re.compile(r'^\\begin\{prob([EMHZXI])(R?)\}')

	def get_initial_data(self) -> Data:
		return {
			'action': 'grade_problem_set',
		}

	def get_name(self, data: Data) -> str:
		return str(data['pk'])

	def get_path(self, ext='pdf'):
		assert ext in ProblemSet.EXTENSIONS
		fname = f'otis_{self.data["pk"]:06d}'
		fname += '_'
		fname += self.data["student__user__first_name"][0]
		fname += self.data["student__user__last_name"][0]
		fname += '_'
		fname += self.data["unit__code"]
		fname += '_'
		fname += self.data["unit__group__name"].replace(' ', '_')
		return OTIS_PDF_PATH / f"{fname}.{ext}"

	def init_hook(self):
		self.data['approved'] = True
		for ext in ProblemSet.EXTENSIONS:
			if self.get_path(ext).exists():
				break
		else:
			url = f"https://storage.googleapis.com/otisweb-media/{self.data['upload__content']}"
			_, ext = os.path.splitext(self.data['upload__content'])
			ext = ext.lstrip('.')
			assert ext in ProblemSet.EXTENSIONS
			file_response = requests.get(url=url)
			self.get_path(ext).write_bytes(file_response.content)
			self.get_path(ext).chmod(0o666)

		if HANDOUTS_PATH.exists():
			filename = f'**/{self.data["unit__code"]}-{self.data["unit__group__slug"]}.tex'
			handouts = list(HANDOUTS_PATH.glob(filename))
			if len(handouts) == 1:
				total = 0
				with open(handouts[0]) as f:
					for line in f:
						if (m := ProblemSet.VON_RE.match(line)) is not None:
							d, *_ = m.groups()
						elif (m := ProblemSet.PROB_RE.match(line)) is not None:
							d, *_ = m.groups()
						else:
							d = None
						if d is not None:
							w = ProblemSet.HARDNESS_CHART[d]
							total += w
				self.data["clubs_max"] = 1 + total

	def on_buffer_open(self, data: Data):
		super().on_buffer_open(data)
		self.edit_temp(extension='mkd')
		for ext in ProblemSet.EXTENSIONS:
			if (p := self.get_path(ext)).exists():
				if ext == 'pdf':
					tool = 'zathura'
				elif ext == 'tex' or ext == 'txt':
					tool = 'gvim'
				elif ext == 'png' or ext == 'jpg':
					tool = 'feh'
				else:
					raise AssertionError
				subprocess.Popen([tool, p.absolute()])

	def on_buffer_close(self, data: Data):
		super().on_buffer_close(data)
		salutation = random.choice(["Hi", "Hello", "Hey"])
		closing = random.choice(
			[
				"Cheers",
				"Cheers",
				"Best",
				"Regards",
				"Warm wishes",
				"Later",
				"Cordially",
				"With appreciation",
				"Sincerely",
			]
		)

		if data['approved'] and data['rejected']:
			data['approved'] = False  # fix a common mistake :P

		comments_to_email = self.read_temp(extension='mkd').strip()
		body = comments_to_email
		body = f"{salutation} {data['student__user__first_name']}," + "\n\n" + body + "\n\n"
		if data.get('next_unit_to_unlock__pk', None) and data['approved']:
			body += f"I unlocked {data['next_unit_to_unlock__code']} {data['next_unit_to_unlock__group__name']}."
			body += '\n\n'
		body += f"{closing},\n\nEvan (aka OTIS Overlord)"
		link = f"https://otis.evanchen.cc/dash/pset/{data['pk']}/"
		if (data['approved'] or data['rejected']) and comments_to_email != '':
			if query_otis_server(payload=data) is True:
				body += '\n\n' + '-' * 40 + '\n\n'
				if data['approved']:
					body += f"Earned: [{data.get('clubs', 0)} clubs and {data.get('hours', 0)} hearts]({link})" + '\n' * 2
				if data['feedback'] or data['special_notes']:
					body += r"```latex" + "\n"
					body += data['feedback']
					if data['feedback'] and data['special_notes']:
						body += '\n\n'
					body += data['special_notes']
					body += "\n" + r"```"
				recipient = data['student__user__email']
				subject = f"OTIS: {data['unit__code']} {data['unit__group__name']} checked off"
				try:
					# send_email(subject=subject, recipient=recipient, body=body)
					pass
				except Exception as e:
					logger.error(f"Email {subject} to {recipient} failed", exc_info=e)
				else:
					logger.info(f"Email {subject} to {recipient} sent!")
				self.delete()


class ProblemSetCarrier(VenueQNode):
	def get_class_for_child(self, data: Data):
		return ProblemSet


class Inquiries(VenueQNode):
	def init_hook(self):
		self.data['approve_all'] = False

	def on_buffer_close(self, data: Data):
		super().on_buffer_close(data)
		if data['approve_all']:
			if query_otis_server(payload={'action': 'approve_inquiries'}):
				self.delete()


class Suggestion(VenueQNode):
	statement: str
	solution: str

	def get_name(self, data: Data) -> str:
		return str(data['pk'])

	def get_initial_data(self) -> Data:
		return {
			'action': 'mark_suggestion',
		}

	def init_hook(self):
		self.statement = self.data.pop('statement')
		self.solution = self.data.pop('solution')

	def on_buffer_open(self, data: Data):
		super().on_buffer_open(data)
		self.edit_temp(extension='mkd')
		tmp_path = f"/tmp/sg{int(time.time())}.tex"

		with open(tmp_path, 'w') as f:
			print(self.statement, file=f)
			print('\n---\n', file=f)
			if data['acknowledge'] is True:
				print(
					r'\emph{This problem and solution were contributed by ' + data['user__first_name'] +
					' ' + data['user__last_name'] + '}.',
					file=f
				)
				print('', file=f)
			print(self.solution, file=f)
		subprocess.Popen(
			[
				"xfce4-terminal",
				"-x",
				"python",
				"-m",
				"von",
				"add",
				data['source'],
				"-f",
				tmp_path,
			]
		)

	def on_buffer_close(self, data: Data):
		super().on_buffer_close(data)
		comments_to_email = self.read_temp(extension='mkd').strip()
		if comments_to_email != '':
			recipient = data['user__email']
			subject = f"OTIS: Suggestion {data['source']} processed"
			body = comments_to_email
			body += '\n\n' + '-' * 40 + '\n\n'
			body += r"```latex" + "\n"
			body += self.statement
			body += "\n" + r"```"
			try:
				send_email(subject=subject, recipient=recipient, body=body)
			except Exception as e:
				logger.error(f"Email {subject} to {recipient} failed", exc_info=e)
			else:
				logger.info(f"Email {subject} to {recipient} sent!")
			if query_otis_server(payload=data) is True:
				self.delete()


class SuggestionCarrier(VenueQNode):
	def get_class_for_child(self, data: Data):
		return Suggestion


class OTISRoot(VenueQRoot):
	def get_class_for_child(self, data: Data):
		if data['_name'] == 'Problem sets':
			return ProblemSetCarrier
		elif data['_name'] == 'Inquiries':
			return Inquiries
		elif data['_name'] == 'Suggestions':
			return SuggestionCarrier
		else:
			raise ValueError('wtf is ' + data['_name'])


if __name__ == "__main__":
	otis_response = query_otis_server(
		payload={
			'token': TOKEN,
			'action': 'init'
		},
		play_sound=False,
	)
	assert otis_response is not None

	if PRODUCTION:
		otis_dir = Path('~/ProGamer/OTIS/queue').expanduser()
	else:
		otis_dir = Path('/tmp/otis-debug')
	if not otis_dir.exists():
		otis_dir.mkdir()
	ROOT_NODE = OTISRoot(otis_response.json(), root_dir=otis_dir)
