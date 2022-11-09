" tsqx -> asy compile and open
nnoremap <localleader>p :update<CR>:silent !python -m tsqx -p % \| asy -f pdf -V - &<CR>:redraw<CR>
" tsqx -> asy
nnoremap <localleader>a :update<CR>:!python -m tsqx -p % \| asy -f pdf -<CR><CR>:redraw<CR>
" tsqx -> asy but show error
nnoremap <localleader>o :update<CR>:!python -m tsqx -p % \| asy -f pdf -<CR>
