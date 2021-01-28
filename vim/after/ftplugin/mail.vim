function! mail#ABookComplete(findstart, base)
    if a:findstart
        let l:line = getline('.')
        let l:start = col('.') - 1
        while l:start > 0 && (l:line[start - 1] =~ '\a' || l:line[start-1] =~ '-')
            let l:start -= 1
        endwhile
        return l:start
    else
        if a:base == ''
            let l:raw_choices = system("abook --mutt-query .")
        else
            let l:raw_choices = system("abook --mutt-query " . a:base)
        endif

        " Abook's '--outformat custom' doesn't work, so instead we'll have to take
        " the standard output and hack that up
        let l:raw_choices = substitute(l:raw_choices, 'XXXXX\n.\{-}YYYYY', '\n', "g")
        let l:raw_choices = substitute(l:raw_choices, '^.*YYYYY', '', "")
        let l:raw_choices = substitute(l:raw_choices, 'XXXXX.*$', '', "")

        " Reformat the output into the form we expect
        let l:choices = []
        for l:c in split(l:raw_choices, '\n')
            let l:split = split(l:c, '\t')
            if len(l:split) > 1
                call add(l:choices, l:split[1] . ' <' . l:split[0] . '>')
            endif
        endfor
        return l:choices
    endif
endfun

setlocal omnifunc=mail#ABookComplete
setlocal fo+=aw
