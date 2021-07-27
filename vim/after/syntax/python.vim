" https://vi.stackexchange.com/a/9917/1851

syntax match PythonArg "\v[\(\,]\s{-}\zs\w+\ze\s{-}\=(\=)@!"
hi PythonArg ctermfg=magenta cterm=italic guifg=#cc0095
