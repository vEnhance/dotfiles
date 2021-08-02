" Vim color file
" Customized by Evan Chen
" Based on eclipse:
" URL: http://www.axisym3.net/jdany/vim-the-editor/#eclipse

set background=light
highlight clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "reclipse"

highlight Normal gui=none guifg=#000000 guibg=#ffffff ctermfg=white

" Search
highlight IncSearch gui=underline guifg=#404040 guibg=#e0e040
highlight Search    gui=none      guifg=#544060 guibg=#f0c0ff ctermbg=1

" Messages
highlight ErrorMsg   gui=none guifg=#f8f8f8 guibg=#4040ff
highlight WarningMsg gui=none guifg=#f8f8f8 guibg=#4040ff
highlight ModeMsg    gui=none guifg=#d06000 guibg=bg
highlight MoreMsg    gui=none guifg=#0090a0 guibg=bg
highlight Question   gui=none guifg=#8000ff guibg=bg

" Split area
highlight StatusLine   gui=none guifg=#ffffff guibg=#4570aa cterm=bold       ctermbg=blue     ctermfg=white
highlight StatusLineNC gui=none guifg=#ffffff guibg=#75a0da cterm=none       ctermfg=darkgrey ctermbg=blue
highlight VertSplit    gui=none guifg=#f8f8f8 guibg=#904838 ctermfg=darkgrey cterm=none       ctermbg=blue
highlight WildMenu     gui=none guifg=#f8f8f8 guibg=#ff3030

" Diff
highlight DiffText       gui=none guifg=red   guibg=#ffd0d0 cterm=bold    ctermbg=5  ctermfg=3
highlight DiffChange     gui=none guifg=black guibg=#ffe7e7 cterm=none    ctermbg=5  ctermfg=7
highlight DiffDelete     gui=none guifg=bg    guibg=#e7e7ff ctermbg=black
highlight DiffAdd        gui=none guifg=blue  guibg=#e7e7ff ctermbg=green cterm=bold
highlight DiffRemoved    gui=none guifg=red   guibg=#e7e7ff ctermfg=red   cterm=none
highlight DiffAdded      gui=none guifg=green guibg=#e7e7ff ctermfg=green cterm=none
highlight DiffSubname    gui=none guifg=blue  guibg=#ffd0d0 ctermfg=blue  cterm=none
highlight DiffLine       gui=bold guifg=blue  guibg=#ffd0d0 ctermfg=blue  cterm=bold
highlight DiffIndexLine  gui=bold guifg=blue  guibg=#ffd0d0 ctermfg=3     cterm=bold

" Cursor
highlight Cursor   gui=none guifg=#ffffff guibg=#0080f0
highlight lCursor  gui=none guifg=#ffffff guibg=#8040ff
highlight CursorIM gui=none guifg=#ffffff guibg=#8040ff

" Fold
highlight Folded     gui=none guifg=#804030 guibg=#fff0d0 ctermbg=black ctermfg=grey cterm=bold
highlight FoldColumn gui=none guifg=#6b6b6b guibg=#e7e7e7 ctermfg=black ctermbg=brown

" Popup Menu
highlight PMenu      ctermbg=blue ctermfg=white
highlight PMenuSel   ctermbg=white ctermfg=black
highlight PMenuSBar  ctermbg=red   ctermfg=white
highlight PMenuThumb ctermbg=white ctermfg=red

" Other
highlight Directory  gui=none guifg=#7050ff guibg=bg ctermfg=39
highlight LineNr     gui=none guifg=#6b6b6b guibg=#eeeeee
highlight NonText    gui=none guifg=#707070 guibg=#e7e7e7
highlight SpecialKey gui=none guifg=#c0c0c0 guibg=bg      ctermfg=105
highlight Title      gui=bold guifg=#0033cc guibg=bg
highlight Visual     gui=none guifg=#804020 guibg=#ffc0a0 ctermfg=105

" Syntax group
highlight Constant   gui=none guifg=#00884c guibg=bg      ctermfg=Cyan cterm=bold
highlight Error      gui=none guifg=#f8f8f8 guibg=#4040ff term=reverse        ctermbg=Red    ctermfg=White
highlight Ignore     gui=none guifg=bg      guibg=bg      ctermfg=Black
highlight Statement  gui=none guifg=#0066FF guibg=bg      cterm=Bold ctermfg=117
highlight Todo       gui=none guifg=#ff5050 guibg=white   term=standout       ctermbg=Brown ctermfg=Black
highlight Underlined gui=none guifg=blue    guibg=bg
highlight Conceal    gui=none guifg=#4a9400 guibg=bg      ctermfg=Yellow ctermbg=none

" Further changes
highlight Comment    gui=none guifg=#4a9400 guibg=bg      ctermfg=2
highlight PreProc    gui=none guifg=#7f0055 guibg=bg      ctermfg=Red
highlight Type       gui=bold guifg=#006600 guibg=bg      ctermfg=47 cterm=bold
highlight String     gui=none guifg=#b07800 guibg=bg      ctermfg=Yellow
highlight Special    gui=none guifg=#4a9400 guibg=bg      ctermfg=85 cterm=bold
highlight Number     gui=none guifg=#cc0033 guibg=bg      ctermfg=Magenta
highlight Identifier gui=bold guifg=#006633 guibg=bg      ctermfg=LightGreen cterm=bold
highlight SpellBad   cterm=underline ctermfg=Red ctermbg=none
highlight SpellCap   cterm=underline ctermfg=Cyan ctermbg=none

highlight texComment    gui=none guifg=#ff1cae guibg=bg      ctermfg=2
highlight texSection    gui=none guifg=#ff1cae guibg=bg      ctermfg=Red cterm=bold
hi link pythonString String
hi link Directory Identifier

hi IndentGuidesOdd  guibg=#ffffff guifg=#cccccc   ctermbg=none ctermfg=240
hi IndentGuidesEven guibg=#f1f1f1 guifg=#7788dd ctermbg=237  ctermfg=22

if !has("gui_running")
	hi link Float          Number
	hi link Conditional    Repeat
	hi link Include        PreProc
	hi link Macro          PreProc
	hi link PreCondit      PreProc
	hi link StorageClass   Type
	hi link Structure      Type
	hi link Typedef        Type
	hi link Tag            Special
	hi link Delimiter      Normal
	hi link SpecialComment Special
	hi link Debug          Special
	hi link pythonBuiltin   Special
	hi link pythonStatement Statement
endif
hi mkdURL guifg=#999999

" vim:ff=unix:
