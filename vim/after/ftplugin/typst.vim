call ale#linter#Define('typst', {
\   'name': 'proselint',
\   'executable': 'proselint',
\   'command': 'proselint %t',
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
let b:ale_linters = ['proselint']

" compile continuously
nnoremap <silent> <localleader>p :update<CR>:TypstWatch<CR>
nnoremap <silent> <localleader>c :update<CR>:!typst compile %<CR>:redraw<CR>

set tw=96
