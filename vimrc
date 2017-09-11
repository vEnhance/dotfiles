" Evan Chen's .vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  " autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
  augroup END
else
  set autoindent		" always set autoindenting on
endif " has("autocmd")

" Backup Directories
set backupdir=~/.vim/tmp
set directory=~/.vim/tmp

set number
set shell=/bin/bash

" Plug
call plug#begin('~/.vim/plugged')

Plug 'kchmck/vim-coffee-script'
Plug 'dag/vim-fish'
Plug 'vim-latex/vim-latex'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-unimpaired'
Plug 'laoyang945/vimflowy'
Plug 'vim-syntastic/syntastic'
Plug 'SirVer/ultisnips'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'qpkorr/vim-renamer'
" Plug 'chrisbra/csv.vim'

" YCM build is a little more complicated
function! BuildYCM(info)
  if a:info.status == 'installed' || a:info.force
    !./install.py
  endif
endfunction
Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
Plug 'Valloric/ycmd'

call plug#end()

" Custom files aren't being detected, darn
augroup filetypedetect
	autocmd BufNewFile,BufRead *.asy setfiletype asy
	autocmd BufNewFile,BufRead *.darkblue setfiletype darkblue
	autocmd BufNewFile,BufRead *.pegjs setfiletype pegjs
	autocmd BufNewFile,BufRead *.ly setfiletype lilypond
	autocmd BufNewFile,BufRead *.less setfiletype css
	autocmd BufRead,BufNewFile *.ics setfiletype icalendar
augroup END


" Actual encryption: need a try / catch for backwards compatibility
try
	set cm=blowfish2
catch
	set cm=blowfish
endtry
" Lilypond
set runtimepath+=/usr/local/lilypond/usr/share/lilypond/current/vim/

" TeX-Suite
set shellslash
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'
let g:Tex_SmartKeyDot = 0
let g:Tex_comment_nospell= 1
let g:Tex_SmartKeyQuote = 0

" Certain file-specific settings which don't seem to apply in after/ftplugin
let g:tex_conceal='agms'
let g:xml_syntax_folding=1

" Calendar
let g:calendar_first_day = "sunday"
let g:calendar_google_calendar = 1

" SLIMV
let g:slimv_swank_cmd = '! xfce4-terminal -e "sbcl --load /home/evan/.vim/bundle/slimv/slime/start-swank.lisp" &'
" let g:slimv_repl_split = 0

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_tex_chktex_args = "-n 1 -n 2 -n 3 -n 8 -n 11 -n 13 -n 18 -n 24 -n 26 -n 29 -n 32 -n 34 -n 36 -n 37 -n 40 -n 44 -e 16 -e 17"
let g:syntastic_tex_checkers = ['chktex']
let g:syntastic_python_python_exec = '/usr/bin/python3'

" YouCompleteMe
let g:ycm_collect_identifiers_from_tags_files = 1 " Let YCM read tags from Ctags file
let g:ycm_use_ultisnips_completer = 1 " Default 1, just ensure
let g:ycm_seed_identifiers_with_syntax = 1 " Completion for programming language's keyword
let g:ycm_complete_in_comments = 1 " Completion in comments
let g:ycm_complete_in_strings = 1 " Completion in string

" Highlight bad spaces
let g:python_space_error_highlight = 1

" UltiSnips
let g:UltiSnipsExpandTrigger="<c-e>"

" NerdTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | q | endif
let NERDTreeIgnore = ['\.pyc$']
nnoremap <silent> NT :NERDTreeFocus<CR>

" Hide preview scratch window on leaving (why would you not do this?)
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Misc personal settings
colorscheme reclipse
set spell
set nohlsearch

set wrap
set linebreak
set textwidth=0
set wrapmargin=0
set showbreak=_

set tabstop=4
set shiftwidth=4
set guifont=Monospace\ 11

set list 
set listchars=tab:\|\ ,trail:$

" Remap arrow keys to useful things
function! DelEmptyLineAbove()
    if line(".") == 1
        return
    endif
    let l:line = getline(line(".") - 1)
    if l:line =~ '^\s*$'
        let l:colsave = col(".")
        .-1d
        "silent normal! 
        call cursor(line("."), l:colsave)
    endif
endfunction

function! AddEmptyLineAbove()
    let l:scrolloffsave = &scrolloff
    " Avoid jerky scrolling with ^E at top of window
    set scrolloff=0
    call append(line(".") - 1, "")
    if winline() != winheight(0)
        "silent normal! 
    endif
    let &scrolloff = l:scrolloffsave
endfunction

function! DelEmptyLineBelow()
    if line(".") == line("$")
        return
    endif
    let l:line = getline(line(".") + 1)
    if l:line =~ '^\s*$'
        let l:colsave = col(".")
        .+1d
        ''
        call cursor(line("."), l:colsave)
    endif
endfunction

function! AddEmptyLineBelow()
    call append(line("."), "")
endfunction

map <Left> <<
map <Right> >>
map <C-Up> :call DelEmptyLineBelow()<CR>
map <C-Down> :call AddEmptyLineBelow()<CR>
map <Up> :call DelEmptyLineAbove()<CR>
map <Down> :call AddEmptyLineAbove()<CR>

" Tabs
set showtabline=2
if exists("+showtabline")
    function! TerminalVimTabLine()
        let s = ''
        let t = tabpagenr()
        let i = 1
        while i <= tabpagenr('$')
            let buflist = tabpagebuflist(i)
            let winnr = tabpagewinnr(i)
            let s .= '%' . i . 'T'
            let s .= (i == t ? '%1*' : '%2*')
            let s .= ' '
            let s .= i . '.'
            let s .= ' %*'
            let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
            let file = bufname(buflist[winnr - 1])
            let file = fnamemodify(file, ':p:t')
            if file == ''
                let file = '[No Name]'
            endif
            let s .= file
	     let s .= '  '
            let i = i + 1
        endwhile
        let s .= '%T%#TabLineFill#%='
        let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
        return s
    endfunction
    set tabline=%!TerminalVimTabLine()

    " set up tab labels with tab number, buffer name, number of windows
    function! GuiTabLabel()
      let label = ''
      let bufnrlist = tabpagebuflist(v:lnum)
      " Add '+' if one of the buffers in the tab page is modified
      for bufnr in bufnrlist
        if getbufvar(bufnr, "&modified")
          let label = '+'
          break
        endif
      endfor
      " Append the tab number
      let label .= v:lnum.'. '
      " Append the buffer name
      let name = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
      if name == ''
        " give a name to no-name documents
        if &buftype=='quickfix'
          let name = '[Quickfix List]'
        else
          let name = '[No Name]'
        endif
      else
        " get only the file name
        let name = fnamemodify(name,":t")
      endif
      let label .= name
      " Append the number of windows in the tab page
      let wincount = tabpagewinnr(v:lnum, '$')
      return label . '  [' . wincount . ']'
    endfunction
    set guitablabel=%{GuiTabLabel()}
endif

" Jump to the next or previous line that has the same level or a lower
" level of indentation than the current line.
"
" exclusive (bool): true: Motion is exclusive
" false: Motion is inclusive
" fwd (bool): true: Go to next line
" false: Go to previous line
" lowerlevel (bool): true: Go to line with lower indentation level
" false: Go to line with the same indentation level
" skipblanks (bool): true: Skip blank lines
" false: Don't skip blank lines
function! NextIndent(exclusive, fwd, lowerlevel, skipblanks)
  let line = line('.')
  let column = col('.')
  let lastline = line('$')
  let indent = indent(line)
  let stepvalue = a:fwd ? 1 : -1
  while (line > 0 && line <= lastline)
    let line = line + stepvalue
    if ( ! a:lowerlevel && indent(line) == indent ||
          \ a:lowerlevel && indent(line) < indent)
      if (! a:skipblanks || strlen(getline(line)) > 0)
        if (a:exclusive)
          let line = line - stepvalue
        endif
        exe line
        exe "normal " column . "|"
        return
      endif
    endif
  endwhile
endfunction

" Moving back and forth between lines of same or lower indentation.
nnoremap <silent> [u :call NextIndent(0, 0, 0, 1)<CR>
nnoremap <silent> ]u :call NextIndent(0, 1, 0, 1)<CR>
nnoremap <silent> [U :call NextIndent(0, 0, 1, 1)<CR>
nnoremap <silent> ]U :call NextIndent(0, 1, 1, 1)<CR>
vnoremap <silent> [u <Esc>:call NextIndent(0, 0, 0, 1)<CR>m'gv''
vnoremap <silent> ]u <Esc>:call NextIndent(0, 1, 0, 1)<CR>m'gv''
vnoremap <silent> [U <Esc>:call NextIndent(0, 0, 1, 1)<CR>m'gv''
vnoremap <silent> ]U <Esc>:call NextIndent(0, 1, 1, 1)<CR>m'gv''
onoremap <silent> [u :call NextIndent(0, 0, 0, 1)<CR>
onoremap <silent> ]u :call NextIndent(0, 1, 0, 1)<CR>
onoremap <silent> [U :call NextIndent(1, 0, 1, 1)<CR>
onoremap <silent> ]U :call NextIndent(1, 1, 1, 1)<CR>

" Another few tricks
nnoremap <silent> ZW :update<CR>
vnoremap <silent> <C-C> "+y
nnoremap <silent> <C-V> "+p

nnoremap <silent> za zt7k7j

