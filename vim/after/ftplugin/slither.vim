scriptencoding utf-8

function! SlitherToggle()
    let l:char = getline('.')[col('.') - 1]  " Get character under cursor
    let l:lnum = line('.')                   " Get line number
    let l:cnum = col('.')                    " Get column number
    let l:line = getline(l:lnum)             " Get current line content
    let l:above = l:lnum > 1 ? getline(l:lnum - 1) : ''
    let l:below = l:lnum < line('$') ? getline(l:lnum + 1) : ''

    if l:char =~# '[+\-|]'
        " Change +, -, | to .
        execute 'normal! r.'
    elseif l:char ==# '.'
        if l:lnum % 2 == 0 && l:cnum % 2 == 1
            " Even line, odd column → |
            execute 'normal! r|'
        elseif l:lnum % 2 == 1 && l:cnum % 2 == 0
            " Odd line, even column → -
            execute 'normal! r-'
        elseif l:lnum % 2 == 1 && l:cnum % 2 == 1
            " Odd line, odd column → +
            execute 'normal! r+'
        elseif l:lnum % 2 == 0 && l:cnum % 2 == 0
            " Odd line, odd column → +
            execute 'normal! r#'
        endif
    elseif l:char ==# '#'
        " Count adjacent "." characters
        let l:dot_count = 0

        " Check left
        if l:cnum > 1 && l:line[l:cnum - 2] ==# '.'
            let l:dot_count += 1
        endif

        " Check right
        if l:cnum < len(l:line) && l:line[l:cnum] ==# '.'
            let l:dot_count += 1
        endif

        " Check above
        if l:above !=# '' && l:cnum <= len(l:above) && l:above[l:cnum - 1] ==# '.'
            let l:dot_count += 1
        endif

        " Check below
        if l:below !=# '' && l:cnum <= len(l:below) && l:below[l:cnum - 1] ==# '.'
            let l:dot_count += 1
        endif

        " Replace # with 4 - dot_count
        execute 'normal! r' . (4 - l:dot_count)
    elseif l:char =~# '[0-9]'
        execute 'normal! r#'
    endif
endfunction

nnoremap <buffer> e :call SlitherToggle()<CR>
