" venueQ.vim

" open a scratch buffer for logging
edit venueQlog
setlocal buftype=nofile
setlocal noswapfile

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
		vim.command(f"echo 'The file {pk} is not tracked by Venue'")

def setup():
	assert ROOT_NODE is not None, "ROOT_NODE should be set by now"
	vim.command(f'cd {ROOT_NODE.directory.absolute().as_posix()}')
	vim.command(f'tabnew {ROOT_NODE.path.absolute().as_posix()}')
EOF


if !empty(get(g:, 'venue_entry', ''))
	" Add the path to venueQ.py before this execution
	exec "py3 sys.path.append('" . expand('<sfile>:p:h') . "')"
	exec "py3file " . g:venue_entry
	py3 setup()

	" Window setup
	if get(g:, 'loaded_nerd_tree', 0)
		NERDTreeFocus
	endif

	augroup venueQ
		au BufReadPost *.venueQ.* silent py3 onVenueBuffer("on_buffer_open")
		au BufHidden *.venueQ.* silent py3 onVenueBuffer("on_buffer_close")
		au BufEnter * silent NERDTreeRefreshRoot
		au BufEnter * py3 ROOT_NODE.wipe()
	augroup END

else
	echo "g:venue_entry is not set"
endif
