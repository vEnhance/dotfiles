set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set formatoptions-=t

call DetectIndentIfPlugged()

let g:python_space_error_highlight = 1
" set omnifunc=syntaxcomplete#Complete

let b:ale_linters = ['pyflakes', 'pyright']
let b:ale_fixers = g:ale_fixers['*'] + ['isort', 'black']

let b:ale_python_isort_options = '--profile black'
nnoremap <localleader>b eObreakpoint()<Esc>
nnoremap <localleader>i :ImportName<CR><C-O>
