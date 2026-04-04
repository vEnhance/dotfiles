scriptencoding utf-8

" Author: Evan Chen <evan@evanchen.cc>
" Description: Replace $$...$$ with \[...\] in TeX files

function! ale#fixers#death_to_double_dollar_signs#Fix(buffer, lines) abort
    let l:index = 0
    let l:lines_new = range(len(a:lines))
    for l:line in a:lines
        let l:lines_new[l:index] = substitute(l:line, '\$\$\_s*\(.\{-}\)\_s*\$\$', '\\[ \1 \\]', 'g')
        let l:index = l:index + 1
    endfor
    return l:lines_new
endfunction
