scriptencoding utf-8
if exists('b:current_syntax')
  finish
endif

" Group separator between result blocks
syn match agSeparator /^--$/
hi agSeparator ctermfg=darkgray guifg=gray

" Filename at start of each line
syn match agFile /^\f\+\ze:\d\+[:-]/ contains=@NoSpell
hi agFile ctermfg=darkgreen guifg=darkgreen

" Line number on a match line (digits between two colons)
syn match agLineMatch /:\zs\d\+\ze:/
hi agLineMatch ctermfg=yellow cterm=bold guifg=yellow gui=bold

" Line number on a context line (digits between colon and dash)
syn match agLineContext /:\zs\d\+\ze-/
hi agLineContext ctermfg=darkgray guifg=gray

let b:current_syntax = 'silversearch'
