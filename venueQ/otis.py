import os
from pathlib import Path

import requests
from dotenv import load_dotenv

from venueQ import Data, VenueNode

load_dotenv()
TOKEN = os.getenv('OTIS_WEB_TOKEN')

class ProblemSet(VenueNode):
	pass

class ProblemSetCarrier(VenueNode):
	def get_class_for_child(self, _: Data):
		return ProblemSet

class Inquiries(VenueNode):
	pass

class Suggestion(VenueNode):
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

otis_response = requests.post(
		url = 'https://otis.evanchen.cc/dash/api/',
		data = {'token' : TOKEN}
		)
otis = OTISRoot(otis_response.json(), root_path = Path('trial'))
