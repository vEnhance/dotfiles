if !has('gui_running')
	hi mkdLink ctermfg=87
	hi link mkdHeading Special
	hi htmlH1 ctermfg=red
	hi htmlH2 ctermfg=red
	hi htmlH3 ctermfg=red
	hi htmlH4 ctermfg=red
	hi htmlH5 ctermfg=red
	hi htmlH6 ctermfg=red
endif

syn region mkdURL matchgroup=mkdDelimiter   start="("     end=")"  contained oneline contains=protocol,truncate
syn region mkdLinkDefTarget start="<\?\zs\S" excludenl end="\ze[>[:space:]\n]"   contained nextgroup=mkdLinkTitle,mkdLinkDef skipwhite skipnl oneline contains=protocol,truncate

syn match protocol `https\:` contained cchar=: conceal
syn match truncate `\%(///\=[^/ \t]\+/\)\zs\S\+\ze\%([/#?]\w\|\S\{10}\)` contained cchar=… conceal
hi link protocol mkdURL
hi link truncate mkdURL

hi link mkdLinkDefTarget mkdURL
hi mkdURL ctermfg=Gray
