scriptencoding utf-8

syn match typstMathSymbol '\zsdot\ze[, ]' contained conceal cchar=⋅
syn match typstMathSymbol '\zsdots\ze[, ]' contained conceal cchar=…
syn match typstMathSymbol '\zsdots\.c\ze[, ]' contained conceal cchar=⋯
syn match typstMathSymbol '\zspm\ze[, ]' contained conceal cchar=±
syn match typstMathSymbol '\zsmp\ze[, ]' contained conceal cchar=∓
syn match typstMathSymbol '\zsint\ze[,_^ ]' contained conceal cchar=∫
syn match typstMathSymbol '\zsiint\ze[,_^ ]' contained conceal cchar=∬
syn match typstMathSymbol '\zsiiint\ze[,_^ ]' contained conceal cchar=∭
syn match typstMathSymbol '\zsoint\ze[,_^ ]' contained conceal cchar=∮
syn match typstMathSymbol '\zsoiint\ze[,_^ ]' contained conceal cchar=∯
syn match typstMathSymbol '\zsoiiint\ze[,_^ ]' contained conceal cchar=∰
hi link Conceal typstMathSymbol
