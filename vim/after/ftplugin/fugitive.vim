function! ShowFugitiveMiniHelp()
	if winnr('$') == 1
		vs | view ~/dotfiles/vim/doc/fugitive-mini-help.txt
		wincmd p
	endif
endfunction
autocmd VimEnter * call ShowFugitiveMiniHelp()
