syn match tsqEscapeLine "\!.*"

syn match tsqArithmeticName "plus\|minus\|mult\|divide" contains=@NoSpell
syn match tsqFunctionName "circumcenter\|orthocenter\|incircle\|circumcircle\|centroid\|incenter\|midpoint\|extension\|foot\|CP\|CR\|dir\|conj\|intersect\|IP\|OP\|Line\|bisectorpoint\|arc\|abs" contains=@NoSpell
syn match tsqBuiltinName "unitcircle" contains=@NoSpell
syn match tsqCycle "cycle"
syn match tsqNumber "[\\.0-9]\+"

syn region tsqComment start="#" end="$" contains=@Spell

syn match tsqDefineHeader "^\([A-Za-z\\&\\'\\_0-9]\+\)\( [0-9A-Z\\.]\+\)\? [:\\.]\?= " contains=tsqRotate
syn match tsqRotate contained "\( [0-9A-Z\\.]\+\)"

syn match tsqSlash "/"

syn match tsqPenName "\(pale\|light\|medium\|heavy\|dark\|deep\)\?\(red\|green\|blue\|cyan\|black\|white\|gray\|grey\|purple\|magenta\|pink\|yellow\|olive\|orange\|brown\)" contains=@NoSpell
syn match tsqPenName "dashed\|dotted" contains=@NoSpell

hi def link tsqArithmeticName PreProc
hi def link tsqBuiltinName Constant
hi def link tsqComment Comment
hi def link tsqCycle PreProc
hi def link tsqDefineHeader Structure
hi def link tsqEscapeLine String
hi def link tsqFunctionName Keyword
hi def link tsqPenName Constant
hi def link tsqNumber Number
hi def link tsqRotate Identifier
hi def link tsqSlash NonText
hi def link tsqVarName Identifier
