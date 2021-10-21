let b:ale_linters = ['proselint', 'chktex']
let b:ale_fixers = ['remove_trailing_lines', 'trim_whitespace',]

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

" Wrap in dollar signs
nnoremap <localleader>w i$<Esc>ea$<Esc>

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

function EvanCompileLaTeX(continuous)
	" von complier
	if stridx(expand('%:p'), 'OlyBase') != -1 || stridx(expand('%:t'), 'von.tex') != -1
		lcd /tmp/preview_$USER
		Shell latexmk von_preview.tex
		if a:continuous
			silent !xfce4-terminal -e "latexmk -pvc -f von_preview.tex" &
		else
			silent !xfce4-terminal -e "latexmk -pv -f von_preview.tex" &
		endif
		return
	endif
	" search for documentclass
	let n = 1
	while n < 10 && n <= line('$')
		if getline(n) =~ 'documentclass'
			" compile and fire if found
			if a:continuous
				silent !xfce4-terminal -e "latexmk -cd -pvc -f %" &
			else
				silent !xfce4-terminal -e "latexmk -cd -pv -f %" &
			endif
			return
		endif
		let n = n + 1
	endwhile
	echo "No documentclass provided. This file won't compile!"
endfunction

" latex compile continuously
nnoremap <silent> <localleader>p :call EvanCompileLaTeX(1)<CR>
" latex compile once
nnoremap <silent> <localleader>c :call EvanCompileLaTeX(0)<CR>
" latex synctex
nmap <silent> <localleader>s :call SyncTexForward()
" latex compile once
nnoremap <silent> <localleader>f :%s/\$\$/\\\[/<CR>:%s/\$\$/\\\]/<CR>

set cole=2
" Leader keys that are defined for me
" <Leader>ll -> pdflatex compile
" <Leader>lv -> latex viewer
" <Leader>rf -> refresh folds (LaTeX)
