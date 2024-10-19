" fix spellcheck
scriptencoding 'utf-8'

" Conceal modifications
" Match ^(-1)
syntax match Minus contained "\\i" conceal cchar=⁻
syntax match One contained "nv" conceal cchar=¹
syntax match MinusOne "\\inv\>" containedin=texMathCmd contains=Minus,One

" Match 1/2, and other symbols
syntax match texMathSymbol "\\half\>" contained conceal cchar=½
syntax match texMathSymbol "\\eps\>" contained conceal cchar=ε
syntax match texMathSymbol "\\dang\>" contained conceal cchar=∡
syntax match texMathSymbol "\\dg\>" contained conceal cchar=°
syntax match texMathSymbol "\\dotsb\>" contained conceal cchar=…
syntax match texMathSymbol "\\dotsc\>" contained conceal cchar=…
syntax match texMathSymbol "\\dotsi\>" contained conceal cchar=…
syntax match texMathSymbol "\\dotsm\>" contained conceal cchar=…
syntax match texMathSymbol "\\dotso\>" contained conceal cchar=…
" Conceal mathbb/etc.
syntax match texMathSymbol "\\CC\>" contained conceal cchar=ℂ
syntax match texMathSymbol "\\EE\>" contained conceal cchar=𝔼
syntax match texMathSymbol "\\FF\>" contained conceal cchar=𝔽
syntax match texMathSymbol "\\GG\>" contained conceal cchar=𝔾
syntax match texMathSymbol "\\NN\>" contained conceal cchar=ℕ
syntax match texMathSymbol "\\OO\>" contained conceal cchar=𝒪
syntax match texMathSymbol "\\PP\>" contained conceal cchar=ℙ
syntax match texMathSymbol "\\QQ\>" contained conceal cchar=ℚ
syntax match texMathSymbol "\\RR\>" contained conceal cchar=ℝ
syntax match texMathSymbol "\\ZZ\>" contained conceal cchar=ℤ
syntax match texMathSymbol "\\kb\>" contained conceal cchar=𝖇
syntax match texMathSymbol "\\kg\>" contained conceal cchar=𝖌
syntax match texMathSymbol "\\kh\>" contained conceal cchar=𝖍
syntax match texMathSymbol "\\km\>" contained conceal cchar=𝖒
syntax match texMathSymbol "\\kn\>" contained conceal cchar=𝖓
syntax match texMathSymbol "\\kp\>" contained conceal cchar=𝖕
syntax match texMathSymbol "\\kq\>" contained conceal cchar=𝖖
syntax match texMathSymbol "\\ku\>" contained conceal cchar=𝖚
syntax match texMathSymbol "\\kz\>" contained conceal cchar=𝖟

" Include cleverref as a ref in highlighting.
syn region texRefZone    matchgroup=texStatement start="\\cref{"  end="}\|%stopzone\>"  contains=@texRefGroup
syn region texRefZone    matchgroup=texStatement start="\\Cref{"  end="}\|%stopzone\>"  contains=@texRefGroup

syn region texStyleBold  matchgroup=Identifier start="\\vocab{"  end="}\|%stopzone\>"  contains=@texGroup
syn region texStyleBold  matchgroup=Identifier start="\\alert{"  end="}\|%stopzone\>"  contains=@texGroup

syntax match texCmdItem "\\ii\>" conceal cchar=•

" Inline syntax highlighting
call SyntaxRange#Include('\\begin{asy}', '\\end{asy}', 'asy', 'PreProc')
call SyntaxRange#Include('\\begin{asydef}', '\\end{asydef}', 'asy', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}', '\\end{lstlisting}', 'text', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Pp]ython.*\]', '\\end{lstlisting}', 'python', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Rr]uby.*\]', '\\end{lstlisting}', 'ruby', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Ss]QL.*\]', '\\end{lstlisting}', 'sql', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Bb]ash.*\]', '\\end{lstlisting}', 'bash', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=gitcommit.*\]', '\\end{lstlisting}', 'git', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=gitlog.*\]', '\\end{lstlisting}', 'git', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Mm]ake.*\]', '\\end{lstlisting}', 'make', 'PreProc')
