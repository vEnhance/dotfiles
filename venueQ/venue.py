from pathlib import Path
from typing import List, Dict, Optional

VENUE_NAME_FIELD = '_venue_name'
VENUE_CHILDREN_FIELD = '_venue_children'

class VenueNode:
	name : str = '' # name must be unique
	parent : 'VenueNode'
	root : 'VenuePlate'
	children: List['VenueNode'] = []

	def __init__(self, parent : Optional['VenueNode'], data : Dict):
		if parent is not None:
			self.parent = parent
			self.root = parent.root
		else:
			assert isinstance(self, VenuePlate)
			self.parent = self
			self.root = self
		self.name = data.pop(VENUE_NAME_FIELD, '')
		children_dicts = data.pop(VENUE_CHILDREN_FIELD, None)
		if children_dicts is not None:
			for child_dict in children_dicts:
				self.children.append(
					VenueNode(parent = self, data = child_dict)
					)
		self.data = data

	@property
	def is_root(self) -> bool:
		return self.root is self
	@property
	def is_directory(self) -> bool:
		return len(self.children) > 0

	def get_extension(self) -> str:
		return '.venue' if self.is_directory else ''

	def get_path(self) -> Path:
		assert not self.is_root
		return self.parent.get_path() / f"{self.name}{self.get_extension()}"

	def delete(self):
		# TODO file operation
		self.parent.children.remove(self)

	def load(self):
		pass

	def dump(self):
		pass

	def postwrite(self):
		pass


class VenuePlate(VenueNode):
	sync_on_start = True

	def __init__(self, path : Path):
		self.path = path
		self.setup()
		self.load_data_from_path()
		if self.sync_on_start:
			self.sync()
	
	def setup(self):
		raise NotImplementedError

	def load_data_from_path(self):
		# recursively walk through self.path to get the initial dictionary
		# and then pass it to
		pass

	def sync(self):
		pass

	def get_path(self):
		return self.path
