" https://vi.stackexchange.com/a/9917/1851

" syntax match PythonArg "\v[\(\,]\s{-}\zs\w+\ze\s{-}\=(\=)@!"
hi PythonFuncCall ctermfg=218 cterm=none guifg=#0000dd gui=none
hi PythonClassVar ctermfg=194 cterm=none guifg=#770077 gui=none

syntax match   pythonObjectProp         contained /\<\K\k*/
syntax match   pythonFuncCall           /\<\K\k*\ze\s*(/ nextgroup=pythonFuncArgs contains=pythonBuiltinObj
syntax region  pythonFuncArgs           contained matchgroup=pythonParens start=/(/ end=/)/       contains=pythonFuncArgCommas,pythonKeywordArgument,@pythonExpression,pythonComment skipwhite skipempty extend
syntax match   pythonKeywordArgument    contained /\<\K\k*\ze\s*=/ nextgroup=pythonOperator skipwhite
syntax match   pythonFuncArgCommas      contained ','
hi pythonKeywordArgument ctermfg=154 cterm=italic guifg=#228822 gui=italic
