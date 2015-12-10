" Don't expand tabs and whatever
set noexpandtab
set tabstop=4
set shiftwidth=4

let g:pydiction_location = '~/.vim/ftplugin/complete-dict'

"Save the current file and run it.
nmap <buffer> <F9> :w<CR>:!python % <CR>

"Save the current file and run it from insertion mode
imap <buffer> <F9> <ESC>:w<CR>:!python % <CR>

"Show the pydoc for the item under cursor
nmap <buffer> <F11> :!xterm +fullscreen -fn 10x20 -hold -e pydoc <cword>& <CR>

"Run pychecker on the code
nmap <buffer> <F7> :w<CR>:!pychecker --limit 20 % <CR>


" Taglist variables
" Display function name in status bar:
let g:ctags_statusline=1
" Automatically start script
let generate_tags=1
" Displays taglist results in a vertical window:
let Tlist_Use_Horiz_Window=0
" Shorter commands to toggle Taglist display
nnoremap TT :TlistToggle<CR>
map <F4> :TlistToggle<CR>
" Various Taglist diplay config:
let Tlist_Use_Right_Window = 1
let Tlist_Compact_Format = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_File_Fold_Auto_Close = 1

set ofu=syntaxcomplete#Complete


au! BufLeave <buffer>

au! BufEnter <buffer> 
au! InsertLeave <buffer>
au! InsertEnter <buffer> 
"au! BufWritePost <buffer> 

au! CursorHold <buffer> 
au! CursorHoldI <buffer> 

au! CursorHold <buffer> 
au! CursorMoved <buffer> 

set omnifunc=pythoncomplete#Complete
