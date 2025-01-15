import datetime
import logging
import subprocess
import time
from pathlib import Path
from pprint import pformat
from typing import TYPE_CHECKING, Any, Dict, List, Optional

import yaml

yaml.SafeDumper.orig_represent_str = yaml.SafeDumper.represent_str  # type: ignore


def repr_str(dumper: yaml.SafeDumper, data: str) -> yaml.ScalarNode:
    if "\n" in data:
        data = data.replace("\r", "")
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.orig_represent_str(data)  # type: ignore


yaml.add_representer(str, repr_str, Dumper=yaml.SafeDumper)

if TYPE_CHECKING:
    vim: Any = None
    VIM_ENABLED = True
else:
    try:
        import vim
    except ImportError:
        VIM_ENABLED = False
    else:
        VIM_ENABLED = True

VENUE_NAME_FIELD = "_name"
VENUE_CHILDREN_FIELD = "_children"
Data = Dict[str, Any]

logger = logging.getLogger()
logger.setLevel(logging.INFO)

if VIM_ENABLED:
    formatter = logging.Formatter(
        "[{levelname}] {asctime} {module} {name} [{filename}:{lineno}]: {message}\n",
        style="{",
    )
    for b in vim.buffers:
        if "venueQlog" in b.name:
            VIM_LOG_BUFFER = b
            break
    else:
        raise Exception("Couldn't find the venueQ log buffer")

    class VimLogHandler(logging.Handler):
        level = 0

        def emit(self, record: logging.LogRecord):
            msg = formatter.format(record)
            try:
                for line in msg.splitlines():
                    VIM_LOG_BUFFER.append(line)
            except vim.error:
                pass

    vim_handler = VimLogHandler()
    vim_handler.setLevel(logging.INFO)
    file_handler = logging.FileHandler(
        f"/tmp/venueQ:{datetime.datetime.now().isoformat()}.log"
    )
    file_handler.setLevel(logging.DEBUG)

    logger.addHandler(vim_handler)
    logger.addHandler(file_handler)


class VenueQNode:
    name: str = ""  # name must be unique
    parent: Optional["VenueQNode"]
    root: "VenueQRoot"
    is_directory = False
    is_root = False

    def __init__(self, data: Data, parent: Optional["VenueQNode"] = None):
        self.name = self.get_name(data)
        if parent is None:
            self.parent = self
            assert self.is_root
        else:
            self.parent = parent
            self.root = parent.root
        self.mkdir()
        self.data = self.get_initial_data()
        self.update_by_dictionary(data)
        self.init_hook()
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
                node = cls(data=child_dict, parent=self)
                if node.pk not in self.root.lookup:
                    self.root.lookup[node.pk] = node
                else:
                    self.root.lookup[node.pk].update_by_dictionary(child_dict)
        self.data.update(data)
        self.process_data()

    def get_initial_data(self) -> Data:
        if self.path.exists():
            return self.load()
        else:
            return self.get_default_data()

    def temp_path(self, extension: str, name: str | None = None) -> Path:
        return self.directory / f"{name or self.name}.venueQ.tmp.{extension}"

    def edit_temp(self, extension: str, name: str | None = None):
        p = self.temp_path(extension, name)
        p.touch()
        if VIM_ENABLED:
            vim.command(f":split {p}")
            vim.command(r":filetype detect")
        else:
            subprocess.run(["vim", p], shell=True)

    def read_temp(self, extension: str, name: str | None = None):
        if self.temp_path(extension, name).exists():
            text = self.temp_path(extension, name).read_text()
            return text
        else:
            return ""

    def erase_temp(self, extension: str, name: str | None = None):
        self.root.queue_wipe(self.temp_path(extension, name))

    @property
    def pk(self) -> str:
        return self.path.resolve().as_posix()

    @property
    def directory(self) -> Path:
        if self.is_root:
            return self.root.root_dir
        else:
            assert self.parent is not None
            return self.parent.directory / self.parent.name

    @property
    def path(self) -> Path:
        return self.directory / f"{self.name}.{self.get_extension()}"

    def __eq__(self, other: object) -> bool:
        assert isinstance(other, VenueQNode)
        return self.pk == other.pk

    def delete(self):
        self.root.queue_wipe(self.path)
        del self.root.lookup[self.pk]

    def mkdir(self):
        if self.parent is not None and not self.parent.directory.exists():
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

    def init_hook(self):
        """Hook called just before saving data each time the node is initialized"""
        pass

    def process_data(self):
        """ "Post update hook called each time this node has its dictionary updated"""
        pass

    def get_extension(self) -> str:
        """Returns the file extension for these venueQ nodes"""
        return "venueQ.yaml"

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
        Override it to change how the data on disk is written."""
        return yaml.dump(self.data, Dumper=yaml.SafeDumper, allow_unicode=True)

    def on_buffer_open(self, data: Data):
        """This method is called when the buffer is loaded.
        This is called with an argument data = self.load().
        Override this to perform actions."""
        logging.info(f"Opened buffer {self.path}")

    def on_buffer_close(self, data: Data):
        """This method is called when the disk data is edited and saved.
        This is called with an argument data = self.load().
        Override this to perform actions."""
        logging.info(f"Closed buffer {self.path}")
        self.data.update(data)


class VenueQRoot(VenueQNode):
    is_root = True
    lookup: Dict[str, "VenueQNode"]

    def __init__(self, data: Data, root_dir: Path, shelf_life: Optional[float] = None):
        if not root_dir.exists():
            root_dir.mkdir()
        root_dir = root_dir.resolve()
        self.lookup = {}
        self.wipe_queue: List[int] = []
        self.root = self
        self.root_dir = root_dir
        self.shelf_life = shelf_life  # in hours: redownload any nodes older than this

        logger.info(f"Setting root_node at {root_dir}")
        self.erase_stale_files()
        super().__init__(data, None)

    def erase_stale_files(self):
        for p in self.root_dir.rglob("*.venueQ.*"):
            if (
                p.is_file()
                and self.shelf_life is not None
                and (
                    (age_hours := (time.time() - p.stat().st_mtime) / (60 * 60))
                    > self.shelf_life
                )
            ):
                logger.info(f"Erasing stale file {p} which is {age_hours} hours old")
                p.unlink()

    def queue_wipe(self, p: Path):
        if VIM_ENABLED:
            for b in vim.buffers:
                if Path(b.name).exists() and p.samefile(Path(b.name)):
                    self.wipe_queue.append(b.number)
                    break
            else:
                logger.warn(
                    f"Tried to wipe {p} but found no buffer for it among "
                    + ", ".join(b.name for b in vim.buffers)
                )
        p.unlink()

    def wipe(self):
        if VIM_ENABLED:
            for bn in self.wipe_queue:
                try:
                    vim.command(f"bdelete! {bn}")
                except vim.error:
                    logging.warn(
                        f"Could not delete buffer {bn}, maybe it was deleted already."
                    )
            self.wipe_queue = []
