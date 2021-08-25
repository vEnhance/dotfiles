import importlib
import sys
from pdb import DefaultConfig, Pdb  # type: ignore


def _pdb_reload(pdb, modules):
	"""
    Reload all non system/__main__ modules, without restarting debugger.

    SYNTAX:
        reload [<reload-module>, ...] [-x [<exclude-module>, ...]]

    * a dot(`.`) matches current frame's module `__name__`;
    * given modules are matched by prefix;
    * any <exclude-modules> are applied over any <reload-modules>.

    EXAMPLES:
        (Pdb++) reload                  # reload everything (brittle!)
        (Pdb++) reload  myapp.utils     # reload just `myapp.utils`
        (Pdb++) reload  myapp  -x .     # reload `myapp` BUT current module

    """

	## Derive sys-lib path prefix.
	#
	SYS_PREFIX = importlib.__file__
	SYS_PREFIX = SYS_PREFIX[:SYS_PREFIX.index("importlib")]

	## Parse args to decide prefixes to Include/Exclude.
	#
	has_excludes = False
	to_include = set()
	# Default prefixes to Exclude, or `pdb++` will break.
	to_exclude = {"__main__", "pdb", "fancycompleter", "pygments", "pyrepl"}
	for m in modules.split():
		if m == "-x":
			has_excludes = True
			continue

		if m == ".":
			m = pdb._getval("__name__")

		if has_excludes:
			to_exclude.add(m)
		else:
			to_include.add(m)

	to_reload = [
		(k, v) for k, v in sys.modules.items()
		if (not to_include or any(k.startswith(i) for i in to_include)) and
		not any(k.startswith(i) for i in to_exclude) and getattr(v, "__file__", None) and
		not v.__file__.startswith(SYS_PREFIX)
	]
	print(
		f"PDB-reloading {len(to_reload)} modules:",
		*[f"  +--{k:28s}:{getattr(v, '__file__', '')}" for k, v in to_reload],
		sep="\n",
		file=sys.stderr,
	)

	for k, v in to_reload:
		try:
			importlib.reload(v)
		except Exception as ex:
			print(
				f"Failed to PDB-reload module: {k} ({v.__file__}) due to: {ex!r}",
				file=sys.stderr,
			)


Pdb.do_re = _pdb_reload  # type: ignore


class Config(DefaultConfig):
	prompt = '\033[1;31m(PDB++) \033[m'
