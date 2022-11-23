" Vim color file
" Customized by Evan Chen
" Based on eclipse:
" URL: http://www.axisym3.net/jdany/vim-the-editor/#eclipse

set background=light
highlight clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'reclipse'

highlight Normal gui=none guifg=#000000 guibg=#ffffff ctermfg=white

" Search
highlight IncSearch gui=underline guifg=#404040 guibg=#e0e040 ctermbg=228 ctermfg=4 cterm=underline
highlight CurSearch gui=none      guifg=#544060 guibg=#f0c0ff ctermbg=57  cterm=underline
highlight Search    gui=none      guifg=#544060 guibg=#f0c0ff ctermbg=242 cterm=underline

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
highlight DiffText       gui=none guifg=red     guibg=#ffd0d0 cterm=bold    ctermbg=5  ctermfg=3
highlight DiffChange     gui=none guifg=black   guibg=#ffe7e7 cterm=none    ctermbg=5  ctermfg=7
highlight DiffDelete     gui=none guifg=bg      guibg=#e7e7ff ctermbg=black
highlight DiffAdd        gui=none guifg=blue    guibg=#e7e7ff ctermbg=green cterm=bold
highlight DiffRemoved    gui=none guifg=red     guibg=#e7e7ff ctermfg=red   cterm=none
highlight DiffAdded      gui=none guifg=#007700 guibg=#e7e7ff ctermfg=green cterm=none
highlight DiffSubname    gui=none guifg=blue  ctermfg=blue  cterm=none
highlight DiffLine       gui=bold guifg=blue  ctermfg=blue  cterm=bold
highlight DiffIndexLine  gui=bold guifg=blue  ctermfg=3     cterm=bold

" Cursor
highlight Cursor   gui=none guifg=#ffffff guibg=#0080f0
highlight lCursor  gui=none guifg=#ffffff guibg=#8040ff
highlight CursorIM gui=none guifg=#ffffff guibg=#8040ff
highlight Cursor guifg=white guibg=black
highlight iCursor guifg=white guibg=steelblue
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10

" Fold
highlight Folded     gui=none guifg=#804030 guibg=#fff0d0 ctermbg=black ctermfg=grey cterm=bold
highlight FoldColumn gui=none guifg=#6b6b6b guibg=#e7e7e7 ctermfg=black ctermbg=brown

" Popup Menu
highlight PMenu      ctermbg=blue ctermfg=white
highlight PMenuSel   ctermbg=white ctermfg=black
highlight PMenuSBar  ctermbg=red   ctermfg=white
highlight PMenuThumb ctermbg=white ctermfg=red

" Other
highlight! link SignColumn LineNr
highlight Directory  gui=none guibg=bg      guifg=#7050ff ctermfg=39
highlight LineNr     gui=none guibg=#cccccc guifg=#6b6b6b
highlight NonText    gui=none guibg=#e7e7e7 guifg=#707070
highlight SpecialKey gui=none guibg=bg      guifg=#c0c0c0 ctermbg=53  ctermfg=253
highlight Title      gui=bold guibg=bg      guifg=#0033cc
highlight Visual     gui=none guibg=#ffc0a0 guifg=#804020 ctermfg=105
highlight CursorLineNr        guibg=#eeeeee               ctermbg=239 ctermfg=122 cterm=bold

" Syntax group
highlight Constant   gui=none guifg=#00884c guibg=bg      ctermfg=Cyan                 cterm=bold
highlight Error      gui=none guifg=#f8f8f8 guibg=#4040ff ctermbg=Red    ctermfg=White  term=reverse
highlight Ignore     gui=none guifg=bg      guibg=bg      ctermfg=Black
highlight Statement  gui=none guifg=#0066FF guibg=bg      ctermfg=117                  cterm=Bold
highlight Todo       gui=none guifg=#ff5050 guibg=white   ctermbg=Brown  ctermfg=Black  term=standout
highlight Underlined gui=none guifg=blue    guibg=bg
highlight Conceal    gui=none guifg=#4a9400 guibg=bg      ctermbg=none   ctermfg=Yellow

" Further changes
highlight Comment    gui=none guifg=#4a9400 guibg=bg      ctermfg=2
highlight PreProc    gui=none guifg=#7f0055 guibg=bg      ctermfg=Red
highlight Type       gui=bold guifg=#006600 guibg=bg      ctermfg=47         cterm=bold
highlight String     gui=none guifg=#b07800 guibg=bg      ctermfg=Yellow
highlight Special    gui=none guifg=#4a9400 guibg=bg      ctermfg=85         cterm=bold
highlight Number     gui=none guifg=#cc0033 guibg=bg      ctermfg=Magenta
highlight Identifier gui=bold guifg=#006633 guibg=bg      ctermfg=LightGreen cterm=bold
highlight SpellBad   cterm=underline ctermfg=Red ctermbg=none
highlight SpellCap   cterm=underline ctermfg=Cyan ctermbg=none

" File-specific syntax groups
highlight texComment    gui=none guifg=#ff1cae guibg=bg   ctermfg=2
highlight texSection    gui=none guifg=#ff1cae guibg=bg   ctermfg=Red cterm=bold
highlight link pythonString String
highlight link Directory Identifier
highlight mkdURL guifg=#999999
highlight htmlBold       ctermbg=237 ctermfg=195 cterm=bold

highlight IndentGuidesOdd  guibg=#efefef guifg=#cccccc ctermbg=none ctermfg=240
highlight IndentGuidesEven guibg=#dddddd guifg=#7788dd ctermbg=239  ctermfg=45

highlight ColorColumn guibg=#ffeeee ctermbg=23

if !has('gui_running')
  highlight link Float          Number
  highlight link Conditional    Repeat
  highlight link Include        PreProc
  highlight link Macro          PreProc
  highlight link PreCondit      PreProc
  highlight link StorageClass   Type
  highlight link Structure      Type
  highlight link Typedef        Type
  highlight link Tag            Special
  highlight link Delimiter      Normal
  highlight link SpecialComment Special
  highlight link Debug          Special
  highlight link pythonBuiltin   Special
  highlight link pythonStatement Statement
endif

" CoC
highlight CocFloating  ctermbg=238            guibg=#bbbbbb
highlight CocMenuSel   ctermbg=22             guibg=#aaccaa
highlight CocInlayHint ctermbg=18 ctermfg=112 guibg=#cceeee guifg=#004400 cterm=italic gui=italic

" vim: ff=unix
