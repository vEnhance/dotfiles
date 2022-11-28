" Spell
set nospell

" asy compile and open
nnoremap <localleader>p :update<CR>:silent !asy % -f pdf -V &<CR>:redraw<CR>
" asy compile
nnoremap <localleader>c :update<CR>:!asy -f pdf %<CR><CR>:redraw<CR>
" asy compile verbose
nnoremap <localleader>v :update<CR>:!asy -f pdf %<CR>
