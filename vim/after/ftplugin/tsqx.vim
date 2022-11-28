" tsqx -> asy compile and open
nnoremap <localleader>p :update<CR>:silent !python -m tsqx -p % \| asy -f pdf -V - &<CR>:redraw<CR>
" tsqx -> asy compile
nnoremap <localleader>c :update<CR>:!python -m tsqx -p % \| asy -f pdf -<CR><CR>:redraw<CR>
" tsqx -> asy verbose
nnoremap <localleader>v :update<CR>:!python -m tsqx -p % \| asy -f pdf -<CR>
