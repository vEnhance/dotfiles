" Spell
set nospell

" tsq -> asy compile and open
nnoremap <Leader>to :update<CR>:silent !asy % -f pdf -V &<CR>:redraw<CR>
" tsq -> asy
nnoremap <Leader>ta :update<CR>:!asy -f pdf %<CR><CR>:redraw<CR>
" tsq -> asy but show error
nnoremap <Leader>te :update<CR>:!asy -f pdf %<CR>

" vim: ts=8
