set encoding=utf-8
if hostname() == "ArchScythe"
	set guifont=Inconsolata\ Semi-Bold\ Condensed\ 24
elseif hostname == "ArchMajestic"
	set guifont=Inconsolata\ Semi-Condensed\ 20
else
	set guifont=Inconsolata\ Medium\ 20
endif
set guioptions-=T  "remove toolbar

" colorscheme space-vim-dark
colorscheme reclipse
