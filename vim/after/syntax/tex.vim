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
syntax match texMathSymbol "\\coloneq\>" contained conceal cchar=≔
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

syntax match texCmdItem "\\ii\>" conceal cchar=•
