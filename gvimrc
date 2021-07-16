set encoding=utf-8
set guifont=Inconsolata\ Semi-Condensed\ Semi-Bold\ 22
if hostname() == "ArchScythe"
	set guifont=Inconsolata\ Semi-Bold\ Condensed\ 24
elseif hostname() == "ArchDiamond"
	set guifont=Inconsolata\ Semi-Condensed\ 20
elseif hostname() == "ArchMagnet"
	set guifont=Inconsolata\ Semi-Condensed\ Semi-Bold\ 20
endif
set guioptions-=T  "remove toolbar

" colorscheme space-vim-dark
colorscheme reclipse
