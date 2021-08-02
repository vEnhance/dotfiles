" tsq -> asy compile and open
nnoremap <Leader>lo :update<CR>:silent !python -m tsq -p % \| asy -f pdf -V - &<CR>:redraw<CR>
" tsq -> asy
nnoremap <Leader>la :update<CR>:!python -m tsq -p % \| asy -f pdf -<CR><CR>:redraw<CR>
" tsq -> asy but show error
nnoremap <Leader>le :update<CR>:!python -m tsq -p % \| asy -f pdf -<CR>

let b:ale_linters = ['proselint']
