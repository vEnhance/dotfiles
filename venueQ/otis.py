import os
import smtplib
import ssl
import string
import subprocess
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from pathlib import Path

import requests
from dotenv import load_dotenv

from venueQ import Data, VenueQNode, VenueQRoot, logger

OTIS_PDF_PATH = Path('/tmp/otis-pdf')
if not OTIS_PDF_PATH.exists():
	OTIS_PDF_PATH.mkdir()


def send_email(subject: str, recipient: str, body: str):
	mail = MIMEMultipart('alternative')
	mail['From'] = 'OTIS Overlord <evan@evanchen.cc>'
	mail['To'] = recipient
	mail['Subject'] = subject
	subprocess.run(
		['python',
			Path('~/dotfiles/mutt/mutt-markdown.py').expanduser().absolute().as_posix()],
		input=body,
		text=True,
	)
	html_msg = Path('/tmp/neomutt-alternative.html').read_text()
	mail.attach(MIMEText(body, 'plain'))
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


load_dotenv(Path('~/SkyNet/private/.env').expanduser())
TOKEN = os.getenv('OTIS_WEB_TOKEN')
assert TOKEN is not None
PRODUCTION = os.getenv('PRODUCTION', False)
if PRODUCTION:
	DASHBOARD_API_URL = 'https://otis.evanchen.cc/dash/api/'
else:
	DASHBOARD_API_URL = 'http://127.0.0.1:8000/dash/api/'


def query_otis_server(payload: Data) -> bool:
	payload['token'] = TOKEN
	resp = requests.post(DASHBOARD_API_URL, data=payload)
	if resp.status_code == 200:
		logger.info("Got a 200 response back from server")
		subprocess.run(
			[Path('~/dotfiles/sh-scripts/noisemaker.sh').expanduser().absolute().as_posix(), '5']
		)
		return True
	else:
		logger.error(f"OTIS-WEB threw an exception with status code {resp.status_code}\n" \
        + resp.content.decode('utf-8'))
		return False


class ProblemSet(VenueQNode):
	def get_initial_data(self) -> Data:
		return {
			'action': 'grade_problem_set',
		}

	def get_name(self, data: Data) -> str:
		return str(data['pk'])

	@property
	def pdf_target_path(self):
		def clean(key) -> str:
			return ''.join(c for c in self.data[key] if c in string.ascii_letters)
		fname = \
        clean('student__user__first_name') \
        + clean('student__user__last_name') \
        + '-' \
        + clean('unit__code') \
        + '-' \
        + clean('unit__group__name')
		return OTIS_PDF_PATH / f"otis_{fname}.pdf"

	def init_hook(self):
		self.data['approved'] = True
		if not self.pdf_target_path.exists():
			url = f"https://storage.googleapis.com/otisweb-media/{self.data['upload__content']}"
			pdf_response = requests.get(url=url)
			self.pdf_target_path.write_bytes(pdf_response.content)

	def on_buffer_open(self, data: Data):
		super().on_buffer_open(data)
		self.edit_temp(extension='mkd')
		subprocess.Popen(['zathura', self.pdf_target_path.absolute()])

	def on_buffer_close(self, data: Data):
		super().on_buffer_close(data)
		comments_to_email = self.read_temp(extension='mkd').strip()
		if data['approved'] and comments_to_email != '':
			if data.get('next_unit_to_unlock__pk', None):
				comments_to_email += '\n\n'
				comments_to_email += \
              f"I unlocked {data['next_unit_to_unlock__code']} {data['next_unit_to_unlock__group__name']}."
			recipient = data['student__user__email']
			subject = f"OTIS: {data['unit__code']} {data['unit__group__name']} checked off"
			try:
				send_email(subject=subject, recipient=recipient, body=comments_to_email)
			except Exception as e:
				logger.error(f"Email {subject} to {recipient} failed", exc_info=e)
			else:
				logger.info(f"Email {subject} to {recipient} sent!")
			if query_otis_server(payload=data) is True:
				self.delete()


class ProblemSetCarrier(VenueQNode):
	def get_class_for_child(self, _: Data):
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
	def get_name(self, data: Data) -> str:
		return str(data['pk'])

	pass


class SuggestionCarrier(VenueQNode):
	def get_class_for_child(self, _: Data):
		return Suggestion


class OTISRoot(VenueQRoot):
	def get_class_for_child(self, child_dict: Data):
		if child_dict['_name'] == 'Problem sets':
			return ProblemSetCarrier
		elif child_dict['_name'] == 'Inquiries':
			return Inquiries
		elif child_dict['_name'] == 'Suggestions':
			return SuggestionCarrier
		else:
			raise ValueError('wtf is ' + child_dict['_name'])


if __name__ == "__main__":
	otis_response = requests.post(url=DASHBOARD_API_URL, data={'token': TOKEN, 'action': 'init'})

	otis_dir = Path('/tmp/otis') if PRODUCTION else Path('/tmp/otis-debug')
	if not otis_dir.exists():
		otis_dir.mkdir()
	ROOT_NODE = OTISRoot(otis_response.json(), root_dir=otis_dir)
