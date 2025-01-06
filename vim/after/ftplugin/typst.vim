call ale#linter#Define('typst', {
\   'name': 'vale',
\   'executable': 'vale',
\   'command': 'vale --output=JSON %t',
\   'callback': 'ale#handlers#vale#Handle',
\})
let b:ale_linters = ['vale']

" compile continuously
nnoremap <silent> <localleader>p :update<CR>:TypstWatch<CR>
nnoremap <silent> <localleader>c :update<CR>:!typst compile %<CR>:redraw<CR>

set textwidth=96
