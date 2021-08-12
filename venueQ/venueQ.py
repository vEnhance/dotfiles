from pathlib import Path
from pprint import pformat
from typing import Any, Dict, List, Optional
import yaml

VENUE_NAME_FIELD = 'venue-name'
VENUE_CHILDREN_FIELD = 'venue-children'

class VenueNode:
	name: str = '' # name must be unique
	parent: 'VenueNode'
	root: 'VenueNode'
	children: List['VenueNode']
	root_path: Path = Path('.')
	lookup: Dict[Path, 'VenueNode']

	def __init__(self, data: Dict, parent: Optional['VenueNode'] = None):
		self.children = []
		if parent is not None:
			self.parent = parent
			self.lookup = self.parent.lookup
		else:
			self.parent = self
			self.lookup = {}
		self.name = data.pop(VENUE_NAME_FIELD, '')
		children_dicts = data.pop(VENUE_CHILDREN_FIELD, None)
		if children_dicts is not None:
			child_dict: Dict[str, Any]
			for child_dict in children_dicts:
				cls = self.get_class_for_child(child_dict)
				node = cls(data = child_dict, parent = self)
				self.children.append(node)
				self.lookup[node.path] = node
		self.data = self.get_initial_data()
		self.data.update(data)
		self.process_data()
	@property
	def is_root(self) -> bool:
		return self.parent is self
	@property
	def is_directory(self) -> bool:
		return len(self.children) > 0
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

	def delete(self):
		self.path.unlink()
	
	def get_initial_data(self) -> Dict[str, Any]:
		return {}
	def process_data(self):
		pass
	def get_class_for_child(self, child_dict: Dict[str, Any]) -> type:
		return type(self)
	def get_extension(self) -> str:
		return 'yaml'
	
	def dump(self):
		return self.path.write_text(yaml.dump(self.data))
	def load(self):
		return yaml.load(self.path.read_text(), Loader=yaml.SafeLoader)
	def onwrite(self):
		pass

	@property
	def debug_dict(self) -> Dict[str, Any]:
		d: Dict[str, Any] = self.data
		d["CLASS"] = type(self)
		d["NAME"] = self.name
		d["PATH"] = self.path
		if self.is_directory:
			d["NODES"] = [c.debug_dict for c in self.children]
		return d

	def __str__(self) -> str:
		return pformat(self.debug_dict)
