setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4

setlocal formatoptions-=t

call DetectIndentIfNoLocalRC()

let g:python_space_error_highlight = 1
" set omnifunc=syntaxcomplete#Complete

let b:ale_linters = ['pyflakes', 'pyright']
let b:ale_fixers = g:ale_fixers['*'] + ['black']

let b:ale_python_isort_options = '-m NOQA'
nnoremap <localleader>b eObreakpoint()<Esc>
nnoremap <localleader>i :ImportName<CR><C-O>
