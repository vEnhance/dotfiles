from pathlib import Path
from pprint import pformat
from typing import Any, Dict, Optional

import yaml

try:
	import vim  # type: ignore

except ImportError:
	VIM_ENABLED = False
else:
	VIM_ENABLED = True

VENUE_NAME_FIELD = '_name'
VENUE_CHILDREN_FIELD = '_children'
Data = Dict[str, Any]


class VenueQNode:
	name: str = '' # name must be unique
	parent: 'VenueQNode'
	root: 'VenueQNode'
	lookup: Dict[str, 'VenueQNode']
	is_directory = False

	def __init__(self,
			data: Data,
			parent: Optional['VenueQNode'] = None,
			root_path: Optional[Path] = None,
			):

		self.name = self.get_name(data)
		if parent is not None:
			self.parent = parent
			self.root_path = self.parent.root_path
			# vv linked by ref, which is what we want i think
			self.lookup = self.parent.lookup
		else:
			self.parent = self
			assert root_path is not None
			self.root_path = root_path
			self.lookup = {self.pk : self}
		self.lookup[self.pk] = self
		if not self.directory.exists():
			self.mkdir()
		self.data = self.get_initial_data()
		self.update_by_dictionary(data)
		self.save()
	def update_by_dictionary(self, data: Data):
		children_dicts = data.pop(VENUE_CHILDREN_FIELD, None)
		if children_dicts is not None:
			self.is_directory = True
			child_dict: Data
			for child_dict in children_dicts:
				# this is pretty expensive to recreate the object
				# only to see if it exists already
				cls = self.get_class_for_child(child_dict)
				node = cls(data = child_dict, parent = self)
				if node.pk not in self.lookup:
					self.lookup[node.pk] = node
				else:
					self.lookup[node.pk].update_by_dictionary(child_dict)
		self.data.update(data)
		self.process_data()
	def get_initial_data(self) -> Data:
		if self.path.exists():
			return self.load()
		else:
			return self.get_default_data()

	def temp_path(self, extension: str, name: str = None):
		return Path(f'/tmp/{name or self.name}.venueQ.{extension}')
	def write_temp(self, extension: str, name: str = None):
		if VIM_ENABLED:
			vim.command(f":split {self.temp_path(extension, name)}")
		else:
			raise NotImplementedError
	def read_temp(self, extension: str, name: str = None):
		return self.temp_path(extension, name).read_text()

	@property
	def pk(self) -> str:
		return self.path.absolute().as_posix()
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
		return self.pk == other.pk
	def delete(self):
		del self.lookup[self.pk]
		self.path.unlink()

	def mkdir(self):
		if not self.parent.directory.exists() and not self.is_root:
			self.parent.mkdir()
		if not self.directory.exists():
			self.directory.mkdir()
	def save(self):
		self.mkdir()
		self.path.write_text(self.dump())
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

	def open_in_vim(self):
		if VIM_ENABLED:
			vim.command(f":e {self.path}")

	# Methods that the user overrides go below here

	def get_default_data(self) -> Data:
		return {}
	def process_data(self):
		""""Post update hook called each time this node has its dictionary updated"""
		pass
	def get_extension(self) -> str:
		"""Returns the file extension for these venueQ nodes"""
		return 'venueQ.yaml'

	def get_class_for_child(self, data: Data) -> type:
		"""Gets the class type for child dictionaries in terms of initial data."""
		return type(self)

	def get_name(self, data: Data) -> str:
		"""Gets the name of the node in terms of initial data."""
		return data.get(VENUE_NAME_FIELD, str(id(self)))

	def load(self):
		"""This method loads a dictionary object from disk.
		Override it to change how the data on disk is interpreted."""
		return yaml.load(self.read(), Loader=yaml.SafeLoader)

	def dump(self):
		"""This method serializes the dictionary object to save to disk.
		Override it to change how the data on disk is interpreted."""
		return yaml.dump(self.data, indent = True, default_flow_style=False)

	def on_buffer_open(self, data: Data):
		"""This method is called when the buffer is loaded.
		This is called with an argument data = self.load().
		Override this to perform actions."""
		pass

	def on_buffer_close(self, data: Data):
		"""This method is called when the disk data is edited and saved.
		This is called with an argument data = self.load().
		Override this to perform actions."""
		self.data.update(data)
