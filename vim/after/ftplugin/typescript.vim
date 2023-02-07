let b:ale_fixers = ['remove_trailing_lines', 'trim_whitespace', 'prettier', 'eslint']

setlocal shiftwidth=2
setlocal softtabstop=2
setlocal tabstop=2
setlocal expandtab

call DetectIndentIfPlugged()
