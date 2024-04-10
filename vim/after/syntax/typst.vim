syn match typstMathSymbol '\zsdot\ze[, ]' contained conceal cchar=⋅
syn match typstMathSymbol '\zsdots\ze[, ]' contained conceal cchar=…
syn match typstMathSymbol '\zsdots\.c\ze[, ]' contained conceal cchar=⋯
hi link Conceal typstMathSymbol
