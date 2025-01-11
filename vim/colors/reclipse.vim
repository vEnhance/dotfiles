" Vim color file
" Customized by Evan Chen
" Originally based on https://www.vim.org/scripts/script.php?script_id=1802
"
" GUI colors give light mode colors
" cterm colors give normal colors

scriptencoding 'utf-8'

set background=light
highlight clear
if exists('syntax_on')
  syntax reset
endif
if !has('gui_running')
  set notgc
endif

let g:colors_name = 'reclipse'

highlight Normal gui=none guifg=#000000 guibg=#ffffff ctermfg=white

" Search
highlight IncSearch gui=underline guifg=#404040 guibg=#e0e040 ctermbg=228 ctermfg=4 cterm=underline
highlight CurSearch gui=none      guifg=#544060 guibg=#f0c0ff ctermbg=57  cterm=underline
highlight Search    gui=none      guifg=#544060 guibg=#f0c0ff ctermbg=242 cterm=underline

" Messages
highlight ErrorMsg   gui=none guifg=#f8f8f8 guibg=#4040ff ctermfg=15 ctermbg=1
highlight WarningMsg gui=none guifg=#f8f8f8 guibg=#4040ff ctermfg=1
highlight ModeMsg    gui=none guifg=#d06000 guibg=bg cterm=bold
highlight MoreMsg    gui=none guifg=#0090a0 guibg=bg ctermfg=2
highlight Question   gui=none guifg=#8000ff guibg=bg ctermfg=2

" Split area
highlight StatusLine   gui=none guifg=#ffffff guibg=#4570aa cterm=bold       ctermbg=blue     ctermfg=white
highlight StatusLineNC gui=none guifg=#ffffff guibg=#75a0da cterm=none       ctermfg=darkgrey ctermbg=blue
highlight VertSplit    gui=none guifg=#f8f8f8 guibg=#904838 ctermfg=darkgrey cterm=none       ctermbg=blue
highlight WildMenu     gui=none guifg=#f8f8f8 guibg=#ff3030 ctermfg=0 ctermbg=11

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
highlight lCursor  gui=none guifg=#ffffff guibg=#8040ff
highlight CursorIM gui=none guifg=#ffffff guibg=#8040ff
highlight Cursor  guifg=white guibg=black
highlight iCursor guifg=white guibg=steelblue
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10

" Fold
highlight Folded     gui=none guifg=#804030 guibg=#fff0d0 ctermbg=black ctermfg=grey cterm=bold
highlight FoldColumn gui=none guifg=#6b6b6b guibg=#e7e7e7 ctermfg=black ctermbg=brown

" Popup Menu
highlight PMenu      ctermbg=15 ctermfg=39
highlight PMenuSel   ctermbg=18 ctermfg=46 cterm=bold
highlight PMenuSBar  ctermbg=1  ctermfg=7
highlight PMenuThumb ctermbg=7  ctermfg=9

" Lines
highlight! link SignColumn LineNr
highlight LineNr     gui=none guibg=#cccccc guifg=#6b6b6b ctermfg=130
highlight CursorLineNr        guibg=#eeeeee ctermbg=29 ctermfg=122 cterm=bold
highlight ALEVirtualTextError        ctermfg=0 ctermbg=210 cterm=italic guifg=#000000 guibg=#ff8787 gui=italic
highlight ALEVirtualTextWarning      ctermfg=0 ctermbg=166 cterm=italic guifg=#000000 guibg=#d7af00 gui=italic
highlight ALEVirtualTextInfo         ctermfg=109 ctermbg=none cterm=italic guifg=#000000 guibg=#87afaf gui=italic
highlight ALEVirtualTextStyleError   ctermfg=0 ctermbg=210 cterm=italic guifg=#000000 guibg=#ff8787 gui=italic
highlight ALEVirtualTextStyleWarning ctermfg=0 ctermbg=166 cterm=italic guifg=#000000 guibg=#d7af00 gui=italic
highlight link DiagnosticVirtualTextError ALEVirtualTextError
highlight link DiagnosticVirtualTextWarn ALEVirtualTextWarning
highlight link DiagnosticVirtualTextInfo ALEVirtualTextInfo
highlight link DiagnosticFloatingError ALEVirtualTextError
highlight link DiagnosticFloatingWarn ALEVirtualTextWarning
highlight link DiagnosticFloatingInfo ALEVirtualTextInfo

" Error highlighting
if has('nvim')
  highlight SpellBad   cterm=undercurl ctermfg=Red ctermbg=none guisp=1
  highlight SpellCap   cterm=undercurl ctermfg=Cyan ctermbg=none guisp=6
else
  highlight SpellBad   cterm=underline ctermfg=Red ctermbg=none guisp=Red
  highlight SpellCap   cterm=underline ctermfg=Cyan ctermbg=none guisp=Yellow
endif
highlight ALEError     cterm=underline ctermfg=210 ctermbg=237
highlight ALEWarning   cterm=underline ctermfg=178 ctermbg=237
highlight ALEInfo      cterm=underline ctermfg=109 ctermbg=237
sign define DiagnosticSignError text=⛔ texthl=ALEError linehl= numhl=
sign define DiagnosticSignWarn  text=⚠️  texthl=ALEWarning linehl= numhl=
sign define DiagnosticSignInfo  text=🛈  texthl=ALEInfo linehl= numhl=

" Other
highlight Directory  gui=none guibg=bg      guifg=#7050ff ctermfg=39
highlight NonText    gui=none guibg=#e7e7e7 guifg=#707070 ctermfg=12
highlight SpecialKey gui=none guibg=bg      guifg=#c0c0c0 ctermbg=53  ctermfg=253
highlight Title      gui=bold guibg=bg      guifg=#0033cc ctermfg=5
highlight Visual     gui=none guibg=#ffc0a0 guifg=#804020 ctermfg=17 ctermbg=208
highlight MatchParen ctermbg=22 cterm=underline

" Syntax group
highlight Constant   gui=none guifg=#00884c guibg=bg      ctermfg=Cyan                 cterm=bold
highlight Error      gui=none guifg=#f8f8f8 guibg=#4040ff ctermbg=Red    ctermfg=White  cterm=reverse
highlight Ignore     gui=none guifg=bg      guibg=bg      ctermfg=Black
highlight Statement  gui=none guifg=#0066FF guibg=bg      ctermfg=117                  cterm=Bold
highlight Todo       gui=none guifg=#ff5050 guibg=white   ctermbg=Brown  ctermfg=Black  cterm=standout
highlight Underlined gui=none guifg=blue    guibg=bg      ctermfg=5      cterm=underline
highlight Conceal    gui=none guifg=#4a9400 guibg=bg      ctermbg=none   ctermfg=Yellow

" Further changes
highlight Comment    gui=none guifg=#4a9400 guibg=bg      ctermfg=2
highlight PreProc    gui=none guifg=#7f0055 guibg=bg      ctermfg=Red
highlight Type       gui=bold guifg=#006600 guibg=bg      ctermfg=47         cterm=bold
highlight String     gui=none guifg=#b07800 guibg=bg      ctermfg=Yellow
highlight Special    gui=none guifg=#4a9400 guibg=bg      ctermfg=85         cterm=bold
highlight Number     gui=none guifg=#cc0033 guibg=bg      ctermfg=Magenta
highlight Identifier gui=bold guifg=#006633 guibg=bg      ctermfg=LightGreen cterm=bold
highlight Function   ctermfg=49

" File-specific syntax groups
highlight texComment    gui=none guifg=#ff1cae guibg=bg   ctermfg=2
highlight texSection    gui=none guifg=#ff1cae guibg=bg   ctermfg=Red cterm=bold
highlight link pythonString String
highlight link Directory Identifier
highlight mkdURL guifg=#999999
highlight htmlBold       ctermbg=237 ctermfg=195 cterm=bold
highlight link MailSignature PreProc
highlight MailQuoted1     ctermfg=34 guifg=#8700ff
highlight MailQuoted2     ctermfg=37 guifg=#5f8700
highlight MailQuoted3     ctermfg=69 guifg=#af0000
highlight MailQuoted4     ctermfg=34 guifg=#8700ff
highlight MailQuoted5     ctermfg=37 guifg=#5f8700
highlight MailQuoted6     ctermfg=69 guifg=#af0000

highlight texTitleArg         gui=bold cterm=bold ctermfg=White  guifg=#0000ff
highlight texEnvArgName       gui=bold cterm=italic ctermfg=Red  guifg=#ff00ff
highlight texMathEnvArgName   gui=bold cterm=bold ctermfg=Green  guifg=#006633
highlight texCmd              gui=bold cterm=none ctermfg=117    guifg=#0f4fff
highlight texCmdPart          gui=bold cterm=bold ctermfg=Red    guifg=#ee4444
highlight texCmdHyperref      gui=bold cterm=bold ctermfg=117    guifg=#0f4fff
highlight texPartArgTitle     gui=bold cterm=bold ctermfg=Yellow guifg=#af8700
highlight texRefZone          gui=underline cterm=underline ctermfg=Green guifg=#44aa44
highlight texUrlArg           gui=underline cterm=italic    ctermfg=118   guifg=#003399
highlight texHrefArgLink      gui=underline cterm=italic    ctermfg=159   guifg=#000099
highlight texHrefArgTextC     gui=underline cterm=underline ctermfg=118   guifg=#000099
highlight texStyleArgConc     gui=bold cterm=italic ctermfg=Yellow
highlight texEnvOpt cterm=bold ctermfg=White
highlight link texStatement texMathCmd
highlight link texRefArg texRefZone

highlight IndentGuidesOdd  guibg=#efefef guifg=#cccccc ctermbg=237 ctermfg=240
highlight IndentGuidesEven guibg=#dddddd guifg=#7788dd ctermbg=240 ctermfg=45
highlight WinBar ctermfg=232 ctermbg=155 cterm=bold
highlight WinBarNC ctermfg=34 ctermbg=none cterm=none

highlight ColorColumn guibg=#ffeeee ctermbg=23 cterm=none

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
