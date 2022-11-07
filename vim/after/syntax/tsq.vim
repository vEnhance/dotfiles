syn match tsqEscapeLine "\!.*"
syn match tsqDefineHeader "^\([A-Za-z\\*\\'\\_0-9]\+\) [:\\.]\?= "

syn match tsqFunctionName "circumcenter\|orthocenter\|incircle\|circumcircle\|centroid\|incenter\|midpoint\|extension\|foot\|CP\|CR\|dir\|conj\|intersect\|IP\|OP\|Line\|bisectorpoint\|arc\|abs" contains=@NoSpell
syn match tsqBuiltinName "unitcircle" contains=@NoSpell
syn match tsqCycle "cycle"
syn match tsqNumber "[\\.0-9]\+"
syn match tsqRotate "\([\\.0-9]*\)R[\\.0-9]\+" contains=@NoSpell
syn region tsqCommentOneLine start="//" end="$" contains=@Spell
syn region tsqCommentMultiLine start="/\*" end="\*/" contains=@Spell

syn match tsqPenName "\(pale\|light\|medium\|heavy\|dark\)\?\(red\|green\|blue\|cyan\|black\|white\|gray\|purple\|magenta\|pink\|yellow\|olive\)" contains=@NoSpell
syn match tsqPenName "dashed\|dotted" contains=@NoSpell

hi def link tsqBuiltinName Constant
hi def link tsqCommentOneLine Comment
hi def link tsqCommentMultiLine Comment
hi def link tsqCycle PreProc
hi def link tsqDefineHeader Identifier
hi def link tsqEscapeLine String
hi def link tsqFunctionName Keyword
hi def link tsqPenName Constant
hi def link tsqNumber Number
hi def link tsqRotate Structure
hi def link tsqVarName Identifier
