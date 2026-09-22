scriptencoding utf-8
" tsqx -> asy compile and open
nnoremap <localleader>p :update<CR>:silent !/usr/bin/python3 -m tsqx -p % \| asy -f pdf -V - &<CR>:redraw<CR>
" tsqx -> asy compile
nnoremap <localleader>c :update<CR>:!/usr/bin/python3 -m tsqx -p % \| asy -f pdf -<CR><CR>:redraw<CR>
" tsqx -> asy verbose
nnoremap <localleader>v :update<CR>:!/usr/bin/python3 -m tsqx -p % \| asy -f pdf -<CR>
