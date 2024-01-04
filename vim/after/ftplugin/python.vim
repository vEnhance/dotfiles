let g:detectindent_preferred_indent = 4
let b:detectindent_preferred_expandtab = 1

set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set formatoptions-=t
set textwidth=88 " this is the black default

call DetectIndentIfPlugged()

let g:python_space_error_highlight = 1
" set omnifunc=syntaxcomplete#Complete

let b:ale_linters = ['pyright', 'ruff']
let b:ale_fixers = g:ale_fixers['*'] + ['ruff', 'ruff_format']

nnoremap <localleader>b eObreakpoint()<Esc>
nnoremap <localleader>i :ImportName<CR><C-O>
