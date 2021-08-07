from pathlib import Path
from typing import Any, Dict, List, Optional

VENUE_NAME_FIELD = 'venue-name'
VENUE_CHILDREN_FIELD = 'venue-children'

class VenueNode:
	name : str = '' # name must be unique
	parent : 'VenueNode'
	children: List['VenueNode'] = []

	def __init__(self, data : Dict, parent : Optional['VenueNode']):
		if parent is not None:
			self.parent = parent
		else:
			self.parent = self
		self.name = data.pop(VENUE_NAME_FIELD, '')
		children_dicts = data.pop(VENUE_CHILDREN_FIELD, None)
		if children_dicts is not None:
			child_dict : Dict[str, Any]
			for child_dict in children_dicts:
				cls = self.get_class_name(child_dict)
				self.children.append(
					vars()[cls](data = child_dict, parent = self,)
					)
		self.data = data
	@property
	def is_root(self) -> bool:
		return self.parent is self
	@property
	def is_directory(self) -> bool:
		return len(self.children) > 0

	def get_class_name(self, child_dict : Dict[str, Any]):
		return 'VenueNode'
	def get_extension(self) -> str:
		return '.yaml'
	def get_parent_path(self) -> Path:
		if self.is_root:
			return Path('.')
		else:
			return self.parent.get_parent_path() / self.parent.name
	def get_path(self) -> Path:
		return self.get_parent_path() \
				/ f'{self.name}.{self.get_extension()}'
