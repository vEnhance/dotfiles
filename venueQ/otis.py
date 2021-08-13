import os
import string
from pathlib import Path

import requests
from dotenv import load_dotenv

from venueQ import Data, VenueNode

load_dotenv()
TOKEN = os.getenv('OTIS_WEB_TOKEN')

class ProblemSet(VenueNode):
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
		pdf_target_path = Path(f"/tmp/{pdf_name}.pdf")
		pdf_target_path.write_bytes(pdf_response.content)
		os.system(f'zathura "{pdf_target_path.as_posix()}"&')
	def on_buffer_exit(self, data: Data):
		super().on_buffer_exit(data)

class ProblemSetCarrier(VenueNode):
	def get_class_for_child(self, _: Data):
		return ProblemSet

class Inquiries(VenueNode):
	pass

class Suggestion(VenueNode):
	def get_name(self, data: Data) -> str:
		return str(data['pk'])
	pass

class SuggestionCarrier(VenueNode):
	def get_class_for_child(self, _: Data):
		return Suggestion

class OTISRoot(VenueNode):
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
			url = 'https://otis.evanchen.cc/dash/api/',
			data = {'token' : TOKEN}
			)
	otis = OTISRoot(otis_response.json(), root_path = Path('trial'))
	pset1 = otis.lookup[Path('trial/Root/Problem sets/1.yaml').absolute().as_posix()]
	pset1.on_buffer_open(pset1.load())
