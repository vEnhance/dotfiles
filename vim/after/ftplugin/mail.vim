" Function: QueryAbook()
"
" This function basically just calls abook --mutt-query with some special
" format options, and then presents a set of vim choices.
"
" This also works around a bug in abook, whic is documented in the function
" itself
"
" Args:
"    - name: The name or partial name of the person to lookup
"
" Sideeffect:
"    - Presents a list of names matching the partial name for the user to
"    select one
function! s:AbookQuery(name)
    let l:raw_choices = system("abook --mutt-query " . a:name)

    " Abook's '--outformat custom' doesn't work, so instead we'll have to take
    " the standard output and hack that up
    let l:raw_choices = substitute(l:raw_choices, 'XXXXX\n.\{-}YYYYY', '\n', "g")
    let l:raw_choices = substitute(l:raw_choices, '^.*YYYYY', '', "")
    let l:raw_choices = substitute(l:raw_choices, 'XXXXX.*$', '', "")

    " Reformat the output into the form we expect
    let l:choices = []
    for l:c in split(l:raw_choices, '\n')
        let l:split = split(l:c, '\t')
        call add(l:choices, l:split[1] . ' <' . l:split[0] . '>')
    endfor

    " Since inputlist will default to 0, making the count start at 1 (and
    " using the if statement at the end), means that just pressing enter will
    " cancel
    let l:i = 1
    let l:display_choices = ["Which address do you want (empty cancels):"]

    " Create a list of choices with a number prefaced on them
    for l:c in l:choices
        call add(l:display_choices, l:i . ": " . c)
        let l:i += 1
    endfor

    call inputsave()
    let l:choice = inputlist(l:display_choices)
    call inputrestore()

    if l:choice > 0
        " Choices index is 1 less than display_choices, and fixing it here
        " allows 0 to be cancel
        put =l:choices[l:choice - 1]
    else
        put =a:name
    endif

    " This is a bit hacky, but it works
    normal k
    join
endfunction

" Function: s:AbookQueryINS()
"
" This function grabs the current word and replaces it with a value from
" AbookQuery
function! s:AbookQueryINS()
    normal b"bdE
    let l:partial = @b
    call s:AbookQuery(l:partial)
endfunction

command! -nargs=1 AbookQuery call <sid>AbookQuery(<f-args>)

nnoremap <script> <leader>a <esc>:call <sid>AbookQueryINS()<cr><ins>

setlocal fo+=aw
