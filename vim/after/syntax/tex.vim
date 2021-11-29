" fix spellcheck
syntax spell toplevel
set spell

" Conceal modifications
if has("gui_running")
	" Match ^(-1)
	syntax match Minus contained "\\i" conceal cchar=⁻
	syntax match One contained "nv" conceal cchar=¹
	syntax match MinusOne "\\inv\>" containedin=texStatement contains=Minus,One
	
	" Match 1/2, and other symbols
	syntax match texMathSymbol "\\half\>" contained conceal cchar=½
	syntax match texMathSymbol "\\eps\>" contained conceal cchar=ε
    syntax match texMathSymbol "\\dang\>" contained conceal cchar=∡
    syntax match texMathSymbol "\\then\>" contained conceal cchar=⊃

	" Match absolute value bars
	syntax match texMathSymbol "\\left\\lvert\>" contained conceal cchar=|
	syntax match texMathSymbol "\\right\\rvert\>" contained conceal cchar=|
	syntax match texMathSymbol "\\left<\>" contained conceal cchar=<
	syntax match texMathSymbol "\\right<\>" contained conceal cchar=>
	syntax match texMathSymbol "\\left\\langle\>" contained conceal cchar=<
	syntax match texMathSymbol "\\right\\rangle\>" contained conceal cchar=>

	" Flip the phi so that it's right.
	fun! s:Greek(group,pat,cchar)
		exe 'syn match '.a:group." '".a:pat."' contained conceal cchar=".a:cchar
	endfun
	call s:Greek('texGreek','\\varphi\>'		,'φ')
	call s:Greek('texGreek','\\phi\>'		,'ϕ')
endif


" Include cleverref as a ref in highlighting.
syn region texRefZone		matchgroup=texStatement start="\\cref{"	end="}\|%stopzone\>"	contains=@texRefGroup
syn region texRefZone		matchgroup=texStatement start="\\Cref{"	end="}\|%stopzone\>"	contains=@texRefGroup

" Highlight \alert, \vocab like \emph
syn match texTypeStyle		"\\vocab\>"
syn match texTypeStyle		"\\alert\>"

"Syntax highlighting: render asymptote
syntax include @ASY after/ftplugin/asy.vim
syntax region asySnip matchgroup=Snip start="\\begin{asy}" end="\\end{asy}" contains=@ASY containedin=texPartZone,texChapterZone,texSectionZone,texSubSectionZone,texSubSubSectionZone,texDocZone
syntax region asySnip matchgroup=Snip start="\\begin{asydef}" end="\\end{asydef}" contains=@ASY containedin=texPartZone,texChapterZone,texSectionZone,texSubSectionZone,texSubSubSectionZone,texDocZone
hi link Snip PreProc

" wef why were these removed in f0b03c4e98f8a7184d8b4a5d702cbcd602426923
call TexNewMathZone("V","align",1)
call TexNewMathZone("W","alignat",1)
call TexNewMathZone("X","flalign",1)
call TexNewMathZone("Y","multiline",1)
call TexNewMathZone("Z","gather",1)
" Highlight diagram as math environment.
call TexNewMathZone("Z","diagram",0)
call TexNewMathZone("Z","tikzcd",0)
call TexNewMathZone("Z","ytableau",0)
