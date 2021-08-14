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

from venueQ import Data, VenueQNode


def send_email(subject, recipient, body):
	mail = MIMEMultipart('alternative')
	mail['From'] = 'Evan Chen, OTIS Overlord <evan@evanchen.cc>'
	mail['To'] = recipient
	mail['Subject'] = subject
	subprocess.run(['python',
			Path('~/dotfiles/mutt/mutt-markdown.py').expanduser().absolute().as_posix()],
		input = body,
		text = True,
		)
	html_msg = Path('/tmp/neomutt-alternative.html').read_text()
	mail.attach(MIMEText(body, 'plain'))
	mail.attach(MIMEText(html_msg, 'html'))

	password = subprocess.run(
			['secret-tool', 'lookup', 'user', 'evanchen.mit', 'type', 'gmail'],
			text = True, capture_output = True
			).stdout

	session = smtplib.SMTP('smtp.gmail.com', 587)
	session.starttls(context = ssl.create_default_context())
	session.login('evanchen.mit@gmail.com', password)
	session.sendmail('evan@evanchen.cc', recipient, mail.as_string())

load_dotenv()
TOKEN = os.getenv('OTIS_WEB_TOKEN')
DASHBOARD_API_URL = 'https://otis.evanchen.cc/dash/api/'

class ProblemSet(VenueQNode):
	def get_initial_data(self) -> Data:
		return {
				'action' : 'grade_problem_set',
				}
	def get_name(self, data: Data) -> str:
		return str(data['pk'])
	def on_buffer_open(self, data: Data):
		url = f"https://storage.googleapis.com/otisweb-media/{data['upload__content']}"
		pdf_response = requests.get(url=url)
		def clean(key) -> str:
			return ''.join(c for c in data[key] if c in string.ascii_letters)
		pdf_name = \
				clean('student__user__first_name') \
				+ clean('student__user__last_name') \
				+ '-' \
				+ clean('unit__code') \
				+ '-' \
				+ clean('unit__group__name')
		pdf_target_path = Path(f"/tmp/otis_{pdf_name}.pdf")
		pdf_target_path.write_bytes(pdf_response.content)
		os.system(f'zathura "{pdf_target_path.as_posix()}"&')
	def on_buffer_exit(self, data: Data):
		if data['approved']:
			requests.post(DASHBOARD_API_URL, data = data)
		else:
			super().on_buffer_exit(data)

class ProblemSetCarrier(VenueQNode):
	def get_class_for_child(self, _: Data):
		return ProblemSet

class Inquiries(VenueQNode):
	pass

class Suggestion(VenueQNode):
	def get_name(self, data: Data) -> str:
		return str(data['pk'])
	pass

class SuggestionCarrier(VenueQNode):
	def get_class_for_child(self, _: Data):
		return Suggestion

class OTISRoot(VenueQNode):
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
	otis_response = requests.post(
			url = DASHBOARD_API_URL,
			data = {'token' : TOKEN}
			)
	otis = OTISRoot(otis_response.json(), root_path = Path('trial'))
	pset1 = otis.lookup[Path('trial/Root/Problem sets/1.yaml').absolute().as_posix()]
	print(pset1.data)
	# pset1.on_buffer_open(pset1.load())

# vim: ft=venue.python
