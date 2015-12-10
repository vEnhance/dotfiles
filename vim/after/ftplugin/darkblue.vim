set filetype=yaml
unlet b:current_syntax
syntax include @TeX syntax/tex.vim
syntax region ProbStatement matchgroup=yamlBlockMappingKey start="state:" end="^\(  \)*[a-zA-Z0-9]*:" containedin=yamlPlainScalar contains=@TeX,@Spell
syntax region ProbClarify matchgroup=yamlBlockMappingKey start="clarify:" end="^\(  \)*[a-zA-Z0-9]*:" containedin=yamlPlainScalar contains=@TeX,@Spell
let b:current_syntax='yaml'

inoremap (( \left(  \right)<++><ESC>Bhi
inoremap [[ \left[  \right]<++><ESC>Bhi
inoremap {{ \left\{  \right\}<++><ESC>Bhi
inoremap << \left<  \right><++><ESC>Bhi
inoremap \|\| \left\lvert  \right\rvert<++><ESC>Bhi
inoremap .cycsum<SPACE> \sum_{\text{cyc}}
inoremap .symsum<SPACE> \sum_{\text{sym}}
inoremap .floor<SPACE> \left\lfloor  \right\rfloor<++><ESC>Bhi
inoremap .ceil<SPACE> \left\lceil  \right\rceil<++><ESC>Bhi
"inoremap // \textstyle\frac{ }{}<ESC>Bs
inoremap .align<SPACE> \[\begin{align*}<CR>aoeu<CR>\end{align*}\]<ESC>kFaC
