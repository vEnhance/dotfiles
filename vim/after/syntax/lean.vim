" Vim syntax file
" Language:		Lean
" Filename extensions:	*.lean
" Maintainer:           Gabriel Ebner

scriptencoding utf-8
setlocal iskeyword=@,48-57,_,-,!,#,$,%

" tabs = evil
set expandtab

syn case match

" keywords
syn keyword leanKeyword import prelude protected private noncomputable
syn keyword leanKeyword def definition renaming hiding parameter parameters
syn keyword leanKeyword begin conjecture constant constants lemma
syn keyword leanKeyword variable variables theory #print theorem notation
syn keyword leanKeyword example open axiom inductive instance class
syn keyword leanKeyword with structure record universe universes alias help
syn keyword leanKeyword reserve match infix infixl infixr notation postfix prefix
syn keyword leanKeyword meta run_cmd do #exit
syn keyword leanKeyword #eval #check end this suppose using namespace section
syn keyword leanKeyword fields attribute local set_option extends include omit
syn keyword leanKeyword calc have show suffices
syn keyword leanKeyword by in at let if then else assume assert take obtain from

syn match leanOp        ":"
syn match leanOp        "="

" constants
syn keyword leanConstant "#" "@" "->" "∼" "↔" "/" "==" ":=" "<->" "/\\" "\\/" "∧" "∨" ">>=" ">>"
syn keyword leanConstant ≠ < > ≤ ≥ ¬ <= >= ⁻¹ ⬝ ▸ + * - / λ
syn keyword leanConstant → ∃ ∀ Π ←

" delimiters

syn match       leanBraceErr   "}"
syn match       leanParenErr   ")"
syn match       leanBrackErr   "\]"

syn region      leanEncl            matchgroup=leanDelim start="(" end=")" contains=ALLBUT,leanParenErr keepend
syn region      leanBracketEncl     matchgroup=leanDelim start="\[" end="\]" contains=ALLBUT,leanBrackErr keepend
syn region      leanEncl            matchgroup=leanDelim start="{"  end="}" contains=ALLBUT,leanBraceErr keepend

" FIXME(gabriel): distinguish backquotes in notations from names
" syn region      leanNotation        start=+`+    end=+`+

syn keyword	leanTodo	containedin=leanComment TODO FIXME BUG FIX

syn region      leanComment	start=+/-+ end=+-/+ contains=leanTodo
syn match       leanComment     contains=leanTodo +--.*+

command -nargs=+ HiLink hi def link <args>

HiLink leanTodo               Todo

HiLink leanComment            Comment

HiLink leanKeyword            Keyword
HiLink leanConstant           Constant
HiLink leanDelim              Keyword  " Delimiter is bad
HiLink leanOp                 Keyword

HiLink leanNotation           String

HiLink leanBraceError         Error
HiLink leanParenError         Error
HiLink leanBracketError       Error

delcommand HiLink

let b:current_syntax = 'lean'

" vim: ts=8 sw=8
