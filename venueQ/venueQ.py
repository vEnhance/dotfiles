from pathlib import Path
from pprint import pformat
from typing import Any, Dict, Optional

import yaml

VENUE_NAME_FIELD = '_name'
VENUE_CHILDREN_FIELD = '_children'

class VenueNode:
	name: str = '' # name must be unique
	parent: 'VenueNode'
	root: 'VenueNode'
	lookup: Dict[Path, 'VenueNode']
	is_directory = False

	def __init__(self,
			data: Dict[str, Any],
			parent: Optional['VenueNode'] = None,
			root_path: Optional[Path] = None,
			):
		assert parent is not None or root_path is not None
		self.name = data.pop(VENUE_NAME_FIELD, None)
		self.root_path = root_path

		if parent is not None:
			self.parent = parent
			self.lookup = self.parent.lookup # linked by ref, which is what we want i think
		else:
			self.parent = self
			self.lookup = {self.pk : self}
		self.lookup[self.pk] = self
		if not self.directory.exists():
			self.mkdir()
		self.data = self.get_initial_data()
		self.update_by_dictionary(data)
		self.dump()
	def update_by_dictionary(self, data: Dict[str, Any]):
		self.name = data.pop(VENUE_NAME_FIELD, '')
		children_dicts = data.pop(VENUE_CHILDREN_FIELD, None)
		if children_dicts is not None:
			self.is_directory = True
			child_dict: Dict[str, Any]
			for child_dict in children_dicts:
				cls = self.get_class_for_child(child_dict)
				node = cls(data = child_dict, parent = self)
		self.data.update(data)
		self.process_data()

	@property
	def pk(self) -> Path:
		return self.path.absolute()
	@property
	def is_root(self) -> bool:
		return self.parent is self
	@property
	def directory(self) -> Path:
		if self.is_root:
			return self.root_path
		else:
			return self.parent.directory / self.parent.name
	@property
	def path(self) -> Path:
		return self.directory \
				/ f'{self.name}.{self.get_extension()}'
	def __eq__(self, other) -> bool:
		return self.pk.samefile(other.pk)
	def delete(self):
		del self.lookup[self.pk]
		self.path.unlink()

	def get_initial_data(self) -> Dict[str, Any]:
		if self.path.exists():
			return self.load()
		else:
			return self.get_default_data()
	def get_default_data(self) -> Dict[str, Any]:
		return {}
	def process_data(self):
		pass
	def get_extension(self) -> str:
		return 'yaml'

	def mkdir(self):
		if not self.parent.directory.exists() and not self.is_root:
			self.parent.mkdir()
		if not self.directory.exists():
			self.directory.mkdir()
	def save(self):
		self.mkdir()
		return self.path.write_text(self.dump())
	def read(self):
		return self.path.read_text()
	@property
	def debug_dict(self) -> Dict[str, Any]:
		d: Dict[str, Any] = self.data
		d["CLASS"] = type(self)
		d["PATH"] = self.path
		return d

	def __str__(self) -> str:
		return pformat(self.debug_dict)

	def get_class_for_child(self, child_dict: Dict[str, Any]) -> type:
		"""Gets the class type for child dictionaries"""
		return type(self)
	
	def get_name(self) -> str:
		"""Gets the name of the node"""
		return self.data.get(VENUE_NAME_FIELD, str(id(self)))

	def load(self):
		"""This method loads a dictionary object from disk.
		Override it to change how the data on disk is interpreted."""
		return yaml.load(self.read(), Loader=yaml.SafeLoader)
	def dump(self):
		"""This method serializes the dictionary object to save to disk.
		Override it to change how the data on disk is interpreted."""
		return yaml.dump(self.data)

	def on_buffer_open(self):
		"""This method is called when the buffer is loaded.
		Override this to perform actions."""
		self.data.update(self.load())
	def on_buffer_exit(self):
		"""This method is called when the disk data is edited and saved.
		Override this to perform actions."""
		self.data.update(self.load())
