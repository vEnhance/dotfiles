" Don't expand tabs and whatever
setlocal softtabstop=2
setlocal tabstop=2
setlocal shiftwidth=2
setlocal noexpandtab

let g:python_space_error_highlight = 1
" set ofu=syntaxcomplete#Complete

" let's try using just pyright
let b:ale_linters = ['pyright']
nnoremap <localleader>b eObreakpoint()<Esc>
