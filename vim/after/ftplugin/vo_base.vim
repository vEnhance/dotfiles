if has("gui_running")
	colorscheme vo_light
else
	hi OL2 guifg=lightblue	ctermfg=lightblue
	hi OL3 guifg=violet	ctermfg=magenta
	hi OL4 guifg=red	ctermfg=red
endif
autocmd BufEnter * :normal zR " is this how you do it??
