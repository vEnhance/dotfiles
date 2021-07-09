" tsq -> asy compile and open
nnoremap <Leader>to :update<CR>:silent !python -m tsq -p % \| asy -f pdf -V - &<CR>:redraw<CR>
" tsq -> asy
nnoremap <Leader>ta :update<CR>:!python -m tsq -p % \| asy -f pdf -<CR><CR>:redraw<CR>
" tsq -> asy but show error
nnoremap <Leader>te :update<CR>:!python -m tsq -p % \| asy -f pdf -<CR>

let b:ale_linters = ['proselint']
