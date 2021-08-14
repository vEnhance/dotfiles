" venueQ.vim

py3 << EOF
import sys
from pathlib import Path
ROOT_NODE = None

def onVenueBuffer(func_name: str):
	pk = Path(vim.current.buffer.name).absolute().as_posix()
	if pk in ROOT_NODE.lookup:
		node = ROOT_NODE.lookup[pk]
		if hasattr(node, func_name):
			getattr(node, func_name)(node.load())
	else:
		print(f"The file {pk} is not tracked by Venue")
EOF

" Add the path to venueQ.py before this execution
exec "py3 sys.path.append('" . expand('<sfile>:p:h') . "')"
exec "py3file " . argv(0)

py3 << EOF
assert ROOT_NODE is not None, "ROOT_NODE should be set by now"
# print(ROOT_NODE.directory)
vim.command(f'cd {ROOT_NODE.directory.absolute().as_posix()}')
vim.command(f'edit {ROOT_NODE.path.absolute().as_posix()}')
EOF

augroup venueQ
	au BufReadPost *.venueQ.* py3 onVenueBuffer("on_buffer_open")
	au BufUnload *.venueQ.* py3 onVenueBuffer("on_buffer_close")
augroup END

if get(g:, 'loaded_nerd_tree', 0)
	NERDTreeFocus
endif
