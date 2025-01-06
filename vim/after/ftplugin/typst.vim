let b:ale_linters = ['vale']

" compile continuously
nnoremap <silent> <localleader>p :update<CR>:TypstWatch<CR>
nnoremap <silent> <localleader>c :update<CR>:!typst compile %<CR>:redraw<CR>

set tw=96
