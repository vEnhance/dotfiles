" Don't expand tabs and whatever
setlocal softtabstop=2
setlocal tabstop=2
setlocal shiftwidth=2
setlocal noexpandtab

let g:python_space_error_highlight = 1
" set ofu=syntaxcomplete#Complete

let b:ale_linters = ['pyflakes', 'mypy', 'pyright']
let b:ale_fixers = ['autoimport', 'isort', 'yapf']
let b:ale_python_isort_options = '-m NOQA'
let b:ale_python_yapf_options = '--style "{based_on_style: facebook, use_tabs: true}"'
nnoremap <localleader>b eObreakpoint()<Esc>

nnoremap <localleader>i :ImportName<CR><C-O>
