if has("gui_running")
	colorscheme vo_light
	hi OL2 guifg=blue	ctermfg=blue
	hi OL3 guifg=green	ctermfg=green

	hi BT1 guifg=red	ctermfg=red
	hi BT2 guifg=red	ctermfg=red
	hi BT3 guifg=red	ctermfg=red
	hi BT4 guifg=red	ctermfg=red
	hi BT5 guifg=red	ctermfg=red
	hi BT6 guifg=red	ctermfg=red
	hi BT7 guifg=red	ctermfg=red
	hi BT8 guifg=red	ctermfg=red
	hi BT9 guifg=red	ctermfg=red

else
	hi OL2 guifg=lightblue	ctermfg=lightblue
	hi OL3 guifg=green	ctermfg=green
	hi OL4 guifg=red	ctermfg=red
	hi OL5 guifg=violet	ctermfg=magenta

	hi BT1 guifg=white	ctermfg=white
	hi BT2 guifg=white	ctermfg=white
	hi BT3 guifg=white	ctermfg=white
	hi BT4 guifg=white	ctermfg=white
	hi BT5 guifg=white	ctermfg=white
	hi BT6 guifg=white	ctermfg=white
	hi BT7 guifg=white	ctermfg=white
	hi BT8 guifg=white	ctermfg=white
	hi BT9 guifg=white	ctermfg=white

endif
autocmd BufEnter * :normal zR " is this how you do it??
