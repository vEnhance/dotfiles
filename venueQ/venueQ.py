from pathlib import Path
from pprint import pformat
from typing import Any, Dict, List, Optional

VENUE_NAME_FIELD = 'venue-name'
VENUE_CHILDREN_FIELD = 'venue-children'

class VenueNode:
	name : str = '' # name must be unique
	parent : 'VenueNode'
	children : List['VenueNode']
	root_path : Path = Path('.')

	def __init__(self, data : Dict, parent : Optional['VenueNode'] = None):
		self.children = []
		if parent is not None:
			self.parent = parent
		else:
			self.parent = self
		self.name = data.pop(VENUE_NAME_FIELD, '')
		children_dicts = data.pop(VENUE_CHILDREN_FIELD, None)
		if children_dicts is not None:
			child_dict : Dict[str, Any]
			for child_dict in children_dicts:
				cls = self.get_class(child_dict)
				self.children.append(
					cls(data = child_dict, parent = self,)
					)
		self.data = data
	@property
	def is_root(self) -> bool:
		return self.parent is self
	@property
	def is_directory(self) -> bool:
		return len(self.children) > 0

	def get_class(self, child_dict : Dict[str, Any]) -> type:
		return type(self)
	def get_extension(self) -> str:
		return '.yaml'
	def get_parent_path(self) -> Path:
		if self.is_root:
			return self.root_path
		else:
			return self.parent.get_parent_path() / self.parent.name
	def get_path(self) -> Path:
		return self.get_parent_path() \
				/ f'{self.name}.{self.get_extension()}'
	
	@property
	def debug_dict(self) -> Dict[str, Any]:
		d : Dict[str, Any] = self.data
		d["CLASS"] = type(self)
		d["NAME"] = self.name
		if self.is_directory:
			d["NODES"] = [c.debug_dict for c in self.children]
		return d

	def __str__(self) -> str:
		return pformat(self.debug_dict)
