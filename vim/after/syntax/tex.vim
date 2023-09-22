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

" Include cleverref as a ref in highlighting.
syn region texRefZone    matchgroup=texStatement start="\\cref{"  end="}\|%stopzone\>"  contains=@texRefGroup
syn region texRefZone    matchgroup=texStatement start="\\Cref{"  end="}\|%stopzone\>"  contains=@texRefGroup

syn region texStyleBold  matchgroup=Identifier start="\\vocab{"  end="}\|%stopzone\>"  contains=@texGroup
syn region texStyleBold  matchgroup=Identifier start="\\alert{"  end="}\|%stopzone\>"  contains=@texGroup

" Inline syntax highlighting
call SyntaxRange#Include('\\begin{asy}', '\\end{asy}', 'asy', 'PreProc')
call SyntaxRange#Include('\\begin{asydef}', '\\end{asydef}', 'asy', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}', '\\end{lstlisting}', 'text', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Jj]ava.*\]', '\\end{lstlisting}', 'java', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Pp]ython.*\]', '\\end{lstlisting}', 'python', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Rr]uby.*\]', '\\end{lstlisting}', 'ruby', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Ss]QL.*\]', '\\end{lstlisting}', 'sql', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Bb]ash.*\]', '\\end{lstlisting}', 'bash', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=gitcommit.*\]', '\\end{lstlisting}', 'git', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=gitlog.*\]', '\\end{lstlisting}', 'git', 'PreProc')
call SyntaxRange#Include('\\begin{lstlisting}\[language=[Mm]ake.*\]', '\\end{lstlisting}', 'make', 'PreProc')
