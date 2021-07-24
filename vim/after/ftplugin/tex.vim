let b:ale_linters = ['proselint', 'chktex']

" Always use \\dots
call IMAP('...', "\\dots",'tex')

" Disable sections
call IMAP('SPA', 'SPA', 'tex')
call IMAP('SCH', 'SCH', 'tex')
call IMAP('SSE', 'SSE', 'tex')
call IMAP('SSS', 'SSS', 'tex')
call IMAP('SS2', 'SS2', 'tex')
call IMAP('SPG', 'SPG', 'tex')
call IMAP('SSP', 'SSP', 'tex')

" Enumeration environments
call IMAP('enum ', "\\begin{enumerate}\<CR>\\ii <++>\<CR>\\end{enumerate}<++>\<ESC>k<<",'tex')
call IMAP('itemize ', "\\begin{itemize}\<CR>\\ii <++>\<CR>\\end{itemize}<++>\<ESC>k<<",'tex')
call IMAP('enuma ', "\\begin{enumerate}[<++>]\<CR>\\ii <++>\<CR>\\end{enumerate}<++>\<ESC>k<<",'tex')
call IMAP('.desc ', "\\begin{description}\<CR>\\ii[<++>] <++>\<CR>\\end{description}<++>\<ESC>k<<",'tex')

"Other environments
call IMAP('.fasy ', "\\begin{figure}[ht]\<CR>\\centering\<CR>\\begin{asy}\<CR><++>\<CR>\\end{asy}\<CR>\\caption{<++>}\<CR>\\end{figure}<++>", 'tex')
call IMAP('.asy ', "\\begin{asy}\<CR><++>\<CR>\\end{asy}<++>", 'tex')
call IMAP('.casy ', "\\begin{center}\<CR>\\begin{asy}\<CR><++>\<CR>\\end{asy}\<CR>\\end{center}<++>\<ESC>k<<k<<k<<", 'tex')
call IMAP('.ftk ', "\\begin{center}\<CR>\\begin{tikzpicture}[scale=<++>]\<CR>\\SetVertex<++>\<CR><++>\<CR>\\end{tikzpicture}\<CR>\\end{center}<++>", 'tex')
call IMAP('.block ', "\\begin{block}{<++>}\<CR><++>\<CR>\\end{block}<++>", 'tex')
call IMAP('.ablock ', "\\begin{alertblock}{<++>}\<CR><++>\<CR>\\end{alertblock}<++>", 'tex')
call IMAP('.eblock ', "\\begin{exampleblock}{<++>}\<CR><++>\<CR>\\end{exampleblock}<++>", 'tex')
call IMAP('.center ', "\\begin{center}\<CR><++>\<CR>\\end{center}<++>", 'tex')
call IMAP('.frame ', "\\begin{frame}\<CR>\\frametitle{<++>}\<CR><++>\<CR>\\end{frame}", 'tex')
call IMAP('.align ', "\\begin{align*}\<CR><++>\<CR>\\end{align*}<++>", 'tex')
call IMAP('.box ', "\\begin{mdframed}\<CR><++>\<CR>\\end{mdframed}<++>", 'tex')
call IMAP('.diag ', "\\begin{diagram}\<CR><++>\<CR>\\end{diagram}<++>", 'tex')
call IMAP('.cd ', "\\begin{center}\<CR>\\begin{tikzcd}\<CR><++>\<CR>\\end{tikzcd}\<CR>\\end{center}<++>\<ESC>k<<k<<k<<", 'tex')
call IMAP('.cases ', "\\begin{cases}\<CR><++>\<CR>\\end{cases}<++>", 'tex')
call IMAP('.fig ', "\\begin{figure}[ht]\<CR>\\centering\<CR>\\includegraphics[<++>]{<++>}\<CR>\\caption{<++>}\<CR>\\end{figure}\<CR><++>", 'tex')
call IMAP('.img ', "\\begin{center}\<CR>\\includegraphics[<++>]{<++>}\<CR>\\end{center}\<CR><++>", 'tex')
call IMAP('.code ', "\\begin{lstlisting}\<CR><++>\<CR>\\end{lstlisting}\<CR><++>\<ESC>k<<", 'tex')
call IMAP('.mat ', "\\begin{bmatrix}\<CR><++>\<CR>\\end{bmatrix}<++>", 'tex')
call IMAP('.beg ', "\\begin{<++>}\<CR><++>\<CR>\\end{<++>}<++>", 'tex') " BEST IDEA EVER

"Miscellaneous maps
call IMAP('<C-/>', "\\frac{<++>}{<++>}<++>", 'tex')
call IMAP('[]', "[]", 'tex')
call IMAP('<<', "\\left< <++>\\right><++>", 'tex')
call IMAP('||', "\\left\\lvert <++> \\right\\rvert<++>", 'tex')
call IMAP('.floor ', "\\left\\lfloor <++> \\right\\rfloor<++>", 'tex')
call IMAP('.ceil ', "\\left\\lceil <++> \\right\\rceil<++>", 'tex')
call IMAP('.cycsum ', "\\sum_{\\text{cyc}} ", 'tex')
call IMAP('.symsum ', "\\sum_{\\text{sym}} ", 'tex')
call IMAP('.cycprod ', "\\prod_{\\text{cyc}} ", 'tex')
call IMAP('.symprod ', "\\prod_{\\text{sym}} ", 'tex')

" TeX Customizations
let g:Tex_FoldedEnvironments='titlepage,abstract,asy,tikzpicture' " Folding of certain environments
let g:Tex_Leader=',' " No more backtick nonsense
set iskeyword+=: " Autocomplete for fig: etc. references
set iskeyword+=_ " Add _ to autocomplete list

" Map <C-M> to 'Put word in math mode'
nnoremap <C-M> i$<Esc>ea$<Esc>

" Spell
set spell

" amsthm environments defined in evan.sty
" Deferred to end because they're LONG.
call IMAP('Sol::', "\\begin{sol}\<CR><++>\<CR>\\end{sol}<++>", 'tex')
call IMAP('Sol[]::', "\\begin{sol}[<++>]\<CR><++>\<CR>\\end{sol}<++>", 'tex')
call IMAP('sol::', "\\begin{sol*}\<CR><++>\<CR>\\end{sol*}<++>", 'tex')
call IMAP('sol[]::', "\\begin{sol*}[<++>]\<CR><++>\<CR>\\end{sol*}<++>", 'tex')
call IMAP('Soln::', "\\begin{soln}\<CR><++>\<CR>\\end{soln}<++>", 'tex')
call IMAP('Soln[]::', "\\begin{soln}[<++>]\<CR><++>\<CR>\\end{soln}<++>", 'tex')
call IMAP('soln::', "\\begin{soln*}\<CR><++>\<CR>\\end{soln*}<++>", 'tex')
call IMAP('soln[]::', "\\begin{soln*}[<++>]\<CR><++>\<CR>\\end{soln*}<++>", 'tex')
call IMAP('Solution::', "\\begin{solution}\<CR><++>\<CR>\\end{solution}<++>", 'tex')
call IMAP('Solution[]::', "\\begin{solution}[<++>]\<CR><++>\<CR>\\end{solution}<++>", 'tex')
call IMAP('solution::', "\\begin{solution*}\<CR><++>\<CR>\\end{solution*}<++>", 'tex')
call IMAP('solution[]::', "\\begin{solution*}[<++>]\<CR><++>\<CR>\\end{solution*}<++>", 'tex')
call IMAP('Claim::', "\\begin{claim}\<CR><++>\<CR>\\end{claim}<++>", 'tex')
call IMAP('Claim[]::', "\\begin{claim}[<++>]\<CR><++>\<CR>\\end{claim}<++>", 'tex')
call IMAP('claim::', "\\begin{claim*}\<CR><++>\<CR>\\end{claim*}<++>", 'tex')
call IMAP('claim[]::', "\\begin{claim*}[<++>]\<CR><++>\<CR>\\end{claim*}<++>", 'tex')
call IMAP('Remark::', "\\begin{remark}\<CR><++>\<CR>\\end{remark}<++>", 'tex')
call IMAP('Remark[]::', "\\begin{remark}[<++>]\<CR><++>\<CR>\\end{remark}<++>", 'tex')
call IMAP('remark::', "\\begin{remark*}\<CR><++>\<CR>\\end{remark*}<++>", 'tex')
call IMAP('remark[]::', "\\begin{remark*}[<++>]\<CR><++>\<CR>\\end{remark*}<++>", 'tex')
call IMAP('Cor::', "\\begin{corollary}\<CR><++>\<CR>\\end{corollary}<++>", 'tex')
call IMAP('Cor[]::', "\\begin{corollary}[<++>]\<CR><++>\<CR>\\end{corollary}<++>", 'tex')
call IMAP('cor::', "\\begin{corollary*}\<CR><++>\<CR>\\end{corollary*}<++>", 'tex')
call IMAP('cor[]::', "\\begin{corollary*}[<++>]\<CR><++>\<CR>\\end{corollary*}<++>", 'tex')
call IMAP('Prob::', "\\begin{problem}\<CR><++>\<CR>\\end{problem}<++>", 'tex')
call IMAP('Prob[]::', "\\begin{problem}[<++>]\<CR><++>\<CR>\\end{problem}<++>", 'tex')
call IMAP('prob::', "\\begin{problem*}\<CR><++>\<CR>\\end{problem*}<++>", 'tex')
call IMAP('prob[]::', "\\begin{problem*}[<++>]\<CR><++>\<CR>\\end{problem*}<++>", 'tex')
call IMAP('Hint::', "\\begin{hint}\<CR><++>\<CR>\\end{hint}<++>", 'tex')
call IMAP('Hint[]::', "\\begin{hint}[<++>]\<CR><++>\<CR>\\end{hint}<++>", 'tex')
call IMAP('hint::', "\\begin{hint*}\<CR><++>\<CR>\\end{hint*}<++>", 'tex')
call IMAP('hint[]::', "\\begin{hint*}[<++>]\<CR><++>\<CR>\\end{hint*}<++>", 'tex')
call IMAP('Question::', "\\begin{ques}\<CR><++>\<CR>\\end{ques}<++>", 'tex')
call IMAP('Question[]::', "\\begin{ques}[<++>]\<CR><++>\<CR>\\end{ques}<++>", 'tex')
call IMAP('question::', "\\begin{ques*}\<CR><++>\<CR>\\end{ques*}<++>", 'tex')
call IMAP('question[]::', "\\begin{ques*}[<++>]\<CR><++>\<CR>\\end{ques*}<++>", 'tex')
call IMAP('Prop::', "\\begin{proposition}\<CR><++>\<CR>\\end{proposition}<++>", 'tex')
call IMAP('Prop[]::', "\\begin{proposition}[<++>]\<CR><++>\<CR>\\end{proposition}<++>", 'tex')
call IMAP('prop::', "\\begin{proposition*}\<CR><++>\<CR>\\end{proposition*}<++>", 'tex')
call IMAP('prop[]::', "\\begin{proposition*}[<++>]\<CR><++>\<CR>\\end{proposition*}<++>", 'tex')
call IMAP('Lemma::', "\\begin{lemma}\<CR><++>\<CR>\\end{lemma}<++>", 'tex')
call IMAP('Lemma[]::', "\\begin{lemma}[<++>]\<CR><++>\<CR>\\end{lemma}<++>", 'tex')
call IMAP('lemma::', "\\begin{lemma*}\<CR><++>\<CR>\\end{lemma*}<++>", 'tex')
call IMAP('lemma[]::', "\\begin{lemma*}[<++>]\<CR><++>\<CR>\\end{lemma*}<++>", 'tex')
call IMAP('Thm::', "\\begin{theorem}\<CR><++>\<CR>\\end{theorem}<++>", 'tex')
call IMAP('Thm[]::', "\\begin{theorem}[<++>]\<CR><++>\<CR>\\end{theorem}<++>", 'tex')
call IMAP('thm::', "\\begin{theorem*}\<CR><++>\<CR>\\end{theorem*}<++>", 'tex')
call IMAP('thm[]::', "\\begin{theorem*}[<++>]\<CR><++>\<CR>\\end{theorem*}<++>", 'tex')
call IMAP('Fact::', "\\begin{fact}\<CR><++>\<CR>\\end{fact}<++>", 'tex')
call IMAP('Fact[]::', "\\begin{fact}[<++>]\<CR><++>\<CR>\\end{fact}<++>", 'tex')
call IMAP('fact::', "\\begin{fact*}\<CR><++>\<CR>\\end{fact*}<++>", 'tex')
call IMAP('fact[]::', "\\begin{fact*}[<++>]\<CR><++>\<CR>\\end{fact*}<++>", 'tex')
call IMAP('Def::', "\\begin{definition}\<CR><++>\<CR>\\end{definition}<++>", 'tex')
call IMAP('Def[]::', "\\begin{definition}[<++>]\<CR><++>\<CR>\\end{definition}<++>", 'tex')
call IMAP('def::', "\\begin{definition*}\<CR><++>\<CR>\\end{definition*}<++>", 'tex')
call IMAP('def[]::', "\\begin{definition*}[<++>]\<CR><++>\<CR>\\end{definition*}<++>", 'tex')
call IMAP('Exer::', "\\begin{exercise}\<CR><++>\<CR>\\end{exercise}<++>", 'tex')
call IMAP('Exer[]::', "\\begin{exercise}[<++>]\<CR><++>\<CR>\\end{exercise}<++>", 'tex')
call IMAP('exer::', "\\begin{exercise*}\<CR><++>\<CR>\\end{exercise*}<++>", 'tex')
call IMAP('exer[]::', "\\begin{exercise*}[<++>]\<CR><++>\<CR>\\end{exercise*}<++>", 'tex')
call IMAP('Theorem::', "\\begin{theorem}\<CR><++>\<CR>\\end{theorem}<++>", 'tex')
call IMAP('Theorem[]::', "\\begin{theorem}[<++>]\<CR><++>\<CR>\\end{theorem}<++>", 'tex')
call IMAP('theorem::', "\\begin{theorem*}\<CR><++>\<CR>\\end{theorem*}<++>", 'tex')
call IMAP('theorem[]::', "\\begin{theorem*}[<++>]\<CR><++>\<CR>\\end{theorem*}<++>", 'tex')
call IMAP('Answer::', "\\begin{answer}\<CR><++>\<CR>\\end{answer}<++>", 'tex')
call IMAP('Answer[]::', "\\begin{answer}[<++>]\<CR><++>\<CR>\\end{answer}<++>", 'tex')
call IMAP('answer::', "\\begin{answer*}\<CR><++>\<CR>\\end{answer*}<++>", 'tex')
call IMAP('answer[]::', "\\begin{answer*}[<++>]\<CR><++>\<CR>\\end{answer*}<++>", 'tex')
call IMAP('Problem::', "\\begin{problem}\<CR><++>\<CR>\\end{problem}<++>", 'tex')
call IMAP('Problem[]::', "\\begin{problem}[<++>]\<CR><++>\<CR>\\end{problem}<++>", 'tex')
call IMAP('problem::', "\\begin{problem*}\<CR><++>\<CR>\\end{problem*}<++>", 'tex')
call IMAP('problem[]::', "\\begin{problem*}[<++>]\<CR><++>\<CR>\\end{problem*}<++>", 'tex')
call IMAP('Example::', "\\begin{example}\<CR><++>\<CR>\\end{example}<++>", 'tex')
call IMAP('Example[]::', "\\begin{example}[<++>]\<CR><++>\<CR>\\end{example}<++>", 'tex')
call IMAP('example::', "\\begin{example*}\<CR><++>\<CR>\\end{example*}<++>", 'tex')
call IMAP('example[]::', "\\begin{example*}[<++>]\<CR><++>\<CR>\\end{example*}<++>", 'tex')
call IMAP('Exercise::', "\\begin{exercise}\<CR><++>\<CR>\\end{exercise}<++>", 'tex')
call IMAP('Exercise[]::', "\\begin{exercise}[<++>]\<CR><++>\<CR>\\end{exercise}<++>", 'tex')
call IMAP('exercise::', "\\begin{exercise*}\<CR><++>\<CR>\\end{exercise*}<++>", 'tex')
call IMAP('exercise[]::', "\\begin{exercise*}[<++>]\<CR><++>\<CR>\\end{exercise*}<++>", 'tex')
call IMAP('Conj::', "\\begin{conjecture}\<CR><++>\<CR>\\end{conjecture}<++>", 'tex')
call IMAP('Conj[]::', "\\begin{conjecture}[<++>]\<CR><++>\<CR>\\end{conjecture}<++>", 'tex')
call IMAP('conj::', "\\begin{conjecture*}\<CR><++>\<CR>\\end{conjecture*}<++>", 'tex')
call IMAP('conj[]::', "\\begin{conjecture*}[<++>]\<CR><++>\<CR>\\end{conjecture*}<++>", 'tex')
call IMAP('Proof::', "\\begin{proof}\<CR><++>\<CR>\\end{proof}<++>", 'tex')
call IMAP('Proof[]::', "\\begin{proof}[<++>]\<CR><++>\<CR>\\end{proof}<++>", 'tex')
call IMAP('Subproof::', "\\begin{subproof}\<CR><++>\<CR>\\end{subproof}<++>", 'tex')
call IMAP('Subproof[]::', "\\begin{subproof}[<++>]\<CR><++>\<CR>\\end{subproof}<++>", 'tex')

if filereadable("local.tex.vim")
    so local.tex.vim
endif

" latex compile
nnoremap <Leader>lc :silent !xfce4-terminal -e "latexmk % -cd -pvc" &<CR>
" latex von compile (mnemonic O for olympiad)
nnoremap <Leader>lo :lcd /tmp/preview_$USER<CR>:silent !xfce4-terminal -e "latexmk von_preview.tex -pvc" &<CR>

set cole=2

" Leader keys that are defined for me
" <Leader>ll -> pdflatex compile
" <Leader>lv -> latex viewer
" <Leader>rf -> refresh folds (LaTeX)

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


" Include cleverref as a ref in highlighting.
syn region texRefZone		matchgroup=texStatement start="\\cref{"	end="}\|%stopzone\>"	contains=@texRefGroup
syn region texRefZone		matchgroup=texStatement start="\\Cref{"	end="}\|%stopzone\>"	contains=@texRefGroup

" Highlight \alert, \vocab like \emph
syn match texTypeStyle		"\\vocab\>"
syn match texTypeStyle		"\\alert\>"

" Highlight diagram as math environment.
call TexNewMathZone("Z","diagram",0)
call TexNewMathZone("Z","tikzcd",0)
call TexNewMathZone("Z","ytableau",0)

" TeX Conceal
set cole=2

" Conceal modifications
if has("gui_running")
	" Match ^(-1)
	syntax match Minus contained "\\i" conceal cchar=⁻
	syntax match One contained "nv" conceal cchar=¹
	syntax match MinusOne "\\inv\>" containedin=texStatement contains=Minus,One
	
	" Match 1/2, and other symbls
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
