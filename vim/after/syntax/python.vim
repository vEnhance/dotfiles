scriptencoding utf-8
" https://vi.stackexchange.com/a/9917/1851
hi PythonFuncCall ctermfg=218 cterm=none guifg=#0000dd gui=none
hi PythonClassVar ctermfg=194 cterm=none guifg=#770077 gui=none

syntax cluster pythonExpression contains=pythonFuncCall,pythonString,pythonRawString,pythonFString,pythonRawFString,pythonBytes,pythonRawBytes,pythonNumber,pythonBuiltin,pythonBoolean,pythonConstant,pythonOperator,pythonAttribute,pythonEllipsis,pythonExceptions,pythonConditional,pythonRepeat,pythonStatement,pythonAsync,pythonMatrixMultiply
syntax match   pythonFuncCall           /\<\K\k*\ze\s*(/ nextgroup=pythonFuncArgs contains=pythonBuiltin
syntax region  pythonFuncArgs           contained matchgroup=pythonParens start=/(/ end=/)/       contains=pythonFuncArgCommas,pythonKeywordArgument,@pythonExpression,pythonComment skipwhite skipempty extend
syntax match   pythonKeywordArgument    contained /\<\K\k*\ze\s*=/ nextgroup=pythonOperator skipwhite
syntax match   pythonFuncArgCommas      contained ','
hi pythonKeywordArgument ctermfg=154 cterm=italic guifg=#228822 gui=italic

" https://github.com/vim-python/python-syntax/issues/65
syn match pythonStrFormatNotFString "{\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)\=\%(\.\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\[\%(\d\+\|[^!:\}]\+\)\]\)*\%(![rsa]\)\=\%(:\%({\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)}\|\%([^}]\=[<>=^]\)\=[ +-]\=#\=0\=\d*,\=\%(\.\d\+\)\=[bcdeEfFgGnosxX%]\=\)\=\)\=}" contained containedin=pythonString
hi pythonStrFormatNotFString ctermbg=88 ctermfg=225 guibg=#870000 guifg=#ffd7ff

" misc settings
setlocal foldmethod=indent
setlocal foldlevel=1
