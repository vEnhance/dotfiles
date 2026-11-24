scriptencoding utf-8
setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4
setlocal formatoptions-=t
setlocal textwidth=88 " this is the black default

let g:python_space_error_highlight = 1
" set omnifunc=syntaxcomplete#Complete

if empty($VIRTUAL_ENV)
  let b:ale_linters = ['ruff']
else
  let b:ale_linters = ['pyright', 'ruff']
endif

let b:ale_fixers = g:ale_fixers['*'] + ['ruff', 'ruff_format']

nnoremap <localleader>b eObreakpoint()<Esc>
nnoremap <localleader>i :ImportName<CR><C-O>
