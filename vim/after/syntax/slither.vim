if exists('b:current_syntax')
  finish
endif

" De-emphasized (light gray) .
syn match slitherDot /\./
hi slitherDot ctermfg=darkgray guifg=gray

" De-emphasized (blue) #
syn match slitherHash /#/
hi slitherHash ctermfg=blue guifg=blue

" Bold and emphasized digits (yellow)
syn match slitherDigit /[0-9]/
hi slitherDigit ctermfg=yellow cterm=bold guifg=yellow gui=bold

" Different color for +, -, |
syn match slitherSymbol /[+\-|]/
hi slitherSymbol ctermfg=cyan guifg=cyan

let b:current_syntax = 'slither'
