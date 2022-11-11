" https://vi.stackexchange.com/a/9917/1851
hi PythonFuncCall ctermfg=218 cterm=none guifg=#0000dd gui=none
hi PythonClassVar ctermfg=194 cterm=none guifg=#770077 gui=none

syntax match   pythonObjectProp         contained /\<\K\k*/
syntax match   pythonFuncCall           /\<\K\k*\ze\s*(/ nextgroup=pythonFuncArgs contains=pythonBuiltinObj
syntax region  pythonFuncArgs           contained matchgroup=pythonParens start=/(/ end=/)/       contains=pythonFuncArgCommas,pythonKeywordArgument,@pythonExpression,pythonComment skipwhite skipempty extend
syntax match   pythonKeywordArgument    contained /\<\K\k*\ze\s*=/ nextgroup=pythonOperator skipwhite
syntax match   pythonFuncArgCommas      contained ','
hi pythonKeywordArgument ctermfg=154 cterm=italic guifg=#228822 gui=italic

" match breakpoints
syntax match pythonBreakpoint /breakpoint()/
hi link pythonBreakpoint Error

" https://github.com/vim-python/python-syntax/issues/65
syn match pythonStrFormatNotFString "{\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)\=\%(\.\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\[\%(\d\+\|[^!:\}]\+\)\]\)*\%(![rsa]\)\=\%(:\%({\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)}\|\%([^}]\=[<>=^]\)\=[ +-]\=#\=0\=\d*,\=\%(\.\d\+\)\=[bcdeEfFgGnosxX%]\=\)\=\)\=}" contained containedin=pythonString
hi pythonStrFormatNotFString ctermbg=88 ctermfg=225 guibg=#870000 guifg=#ffd7ff

syn match pythonStrFormatRawString "{\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)\=\%(\.\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\[\%(\d\+\|[^!:\}]\+\)\]\)*\%(![rsa]\)\=\%(:\%({\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)}\|\%([^}]\=[<>=^]\)\=[ +-]\=#\=0\=\d*,\=\%(\.\d\+\)\=[bcdeEfFgGnosxX%]\=\)\=\)\=}" contained containedin=pythonRawString
hi pythonStrFormatRawString ctermbg=94 ctermfg=229 guibg=#875f00 guifg=#ffffaf

" misc settings
set foldmethod=indent
set foldlevelstart=1
