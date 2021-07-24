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

" ------------------------------------------
" ARROW KEY REMAPPINGS
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
" map <C-Up> :call DelEmptyLineBelow()<CR>
" map <C-Down> :call AddEmptyLineBelow()<CR>
map <Up> :call DelEmptyLineAbove()<CR>
map <Down> :call AddEmptyLineAbove()<CR>

" ------------------------------------------
" INDENTATION COMMANDS

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

" ------------------------------------------
" GENERAL CONFIGURATION

" Filetype detection manual cases
autocmd BufNewFile,BufRead *.asy setfiletype asy
autocmd BufNewFile,BufRead *.ly setfiletype lilypond
autocmd BufNewFile,BufRead *.less setfiletype css
autocmd BufNewFile,BufRead *.ics setfiletype icalendar

" Plug
call plug#begin('~/.vim/plugged')

" Lighter plugns that are always enabled
Plug 'mg979/vim-visual-multi'
Plug 'vim-scripts/Tabmerge'

" File-type specific edits
Plug 'kchmck/vim-coffee-script'
Plug 'neoclide/jsonc.vim'
Plug 'dag/vim-fish'
Plug 'petRUShka/vim-sage'
Plug 'plasticboy/vim-markdown'
let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0
Plug 'avakhov/vim-yaml'
Plug 'hura/vim-asymptote'
Plug 'chutzpah/icalendar.vim'
" Plug 'leanprover/lean.vim'

" General plugins
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-unimpaired'

if ($USER ==# "evan")
    " EDIT 2021-07-09: vim-plugins on Arch Linux installs a bunch of these
    " already so this list got trimmed a lot.
    " (In fact, having both Plug and system will cause conflicts with ALE).

    Plug 'vim-ctrlspace/vim-ctrlspace'
    let g:EasyMotion_keys = "aoeuidhtns;qjkxbmwvz',.pyfgcrl/"

    set completeopt=menuone,noselect,preview
    Plug 'maralla/completor.vim', { 'for' :
        \ ['css', 'python', 'javascript', 'sh', 'fish', 'vim',
        \ 'json', 'jsonc', 'tex', 'typescript', 'go',
        \ 'gitcommit', 'gitconfig'] }
    let g:completor_filetype_map = {}
    Plug 'Shougo/echodoc'

    " Airline auto from vim-plugins
    let g:airline_theme='wombat'
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#show_tabs = 1
    let g:airline#extensions#tabline#show_buffers = 1
    let g:airline#extensions#tabline#buffer_nr_show = 1
    let g:airline#extensions#tabline#current_first = 0
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#ctrlspace_show_tab_nr = 0

    Plug 'rodrigore/coc-tailwind-intellisense', {'do': 'npm install'}
    " ALE + CoC
    let g:ale_sign_column_always = 1
    let g:ale_sign_error = '#'
    let g:ale_sign_warning = '>'
    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format = '[%severity%] [%linter%] %s'
    let g:ale_python_mypy_options = "--ignore-missing-imports"
    let g:ale_disable_lsp = 1
    set omnifunc=ale#completion#OmniFunc
    let g:coc_global_extensions = [
                \ 'coc-css',
                \ 'coc-html',
                \ 'coc-htmldjango',
                \ 'coc-json',
                \ 'coc-markdownlint',
                \ 'coc-pyright',
                \ 'coc-sh',
                \ 'coc-snippets',
                \ 'coc-tabnine',
                \ 'coc-tailwind-intellisense',
                \ 'coc-texlab',
                \ 'coc-tsserver',
                \ 'coc-vimlsp',
                \ 'coc-yaml',
                \ ]
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    " More general plugins
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'kovisoft/slimv'

    " Task manager
    Plug 'vimwiki/vimwiki'
    Plug 'tools-life/taskwiki'
    Plug 'powerman/vim-plugin-AnsiEsc'
    Plug 'majutsushi/tagbar'
    Plug 'farseer90718/vim-taskwarrior'
    let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.mkd'}]
    let g:vimwiki_global_ext = 0
    let g:taskwiki_disable_concealcursor=1
endif

" Plug 'qpkorr/vim-renamer' not needed due to vidir
" Plug 'chrisbra/csv.vim'
call plug#end()
"
" Uncomment to auto open NerdTree on empty vim
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" Uncomment below to close Vim if only NerdTree remains
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" CoC go-to keybindings
nmap <silent> gd :vsplit<CR><Plug>(coc-definition)
nmap <silent> gy :vsplit<CR><Plug>(coc-type-definition)
nmap <silent> gr :vsplit<CR><Plug>(coc-references)
nmap cv <Plug>(coc-rename)
nmap <silent> [g :ALEPreviousWrap<CR>
nmap <silent> ]g :ALENextWrap<CR>

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Backup Directories
set backupdir=~/.vim/tmp
set directory=~/.vim/tmp
set number
set shell=/bin/bash
set updatetime=100

" Actual encryption: need a try / catch for backwards compatibility
try
	set cm=blowfish2
catch
	set cm=blowfish
endtry

" Hide preview scratch window on leaving (why would you not do this?)
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Personal settings
colorscheme reclipse
set spell
set nohlsearch
" don't need mode shown if we have airline
set noshowmode

set wrap
set linebreak
set textwidth=0
set wrapmargin=0
set showbreak=_

set tabstop=2
set shiftwidth=2
set guifont=Monospace\ 11

set list
set listchars=tab:\|\ ,trail:_
set laststatus=2
set splitright
set guicursor+=n-v-c:blinkon0
set foldlevelstart=3
set hidden
set conceallevel=2

" use space as leader key
let mapleader = "\<Space>"
nnoremap <Leader> <Nop>
map , <Plug>(easymotion-prefix)

" Another few tricks
nnoremap <silent> ZW :update<CR>
vnoremap <silent> <C-C> "+y
nnoremap <silent> <C-V> "+p
nnoremap <silent> za zt7k7j

" LEADER KEY
" e is for emulator

nnoremap <Backspace> :CtrlSpaceGoUp<CR>
nnoremap <S-Backspace> :CtrlSpaceGoDown<CR>

nnoremap <Leader>e :let $VIM_DIR=expand('%:p:h')<CR>:silent !xfce4-terminal --working-directory="$VIM_DIR" &<CR>:redraw<CR>

" Global leader things at O
" open nerdtree
nnoremap <Leader>ot :NERDTreeToggle<CR>
" open new tab
nnoremap <Leader>on :tabnew<CR>
" open buffers
nnoremap <Leader>ob :Buffers<CR>
" open history
nnoremap <Leader>oh :History<CR>
" open lines (as `open to`)
nnoremap <Leader>ol :Lines<CR>
" open file
nnoremap <Leader>of :Files<CR>
" ALE Details
nnoremap <Leader>oa :ALEDetail<CR>
" merge tab to right
nnoremap <Leader>os :Tabmerge right<CR>
" yank all
nnoremap <Leader>oy :%y+<CR>
" change directory
nnoremap <Leader>cd :lcd %:p:h<CR>

" syntax group
nnoremap <Leader>og :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" git status
nnoremap <Leader>gs :Git<CR>
" git blame
nnoremap <Leader>gb :Git blame<CR>
" git diff
nnoremap <Leader>gd :Gdiffsplit<CR>
" git undo (really git read)
nnoremap <Leader>gu :Gread<CR>
" git add current file (w for write)
nnoremap <Leader>gw :Gwrite<CR>

" git commit (current file)
nnoremap <Leader>gc :Git commit %<CR>
" git commit all
nnoremap <Leader>ga :Git commit --all<CR>

" git create commit --amend [edit commit]
nnoremap <Leader>gec :Git commit --amend<CR>
" git commit --amend current file [edit write]
nnoremap <Leader>gew :Git commit % --amend<CR>
" git commit --amend all [edit all]
nnoremap <Leader>gea :Git commit --all --amend<CR>

" Buffer
nnoremap <Leader>1 :b 1<CR>
nnoremap <Leader>2 :b 2<CR>
nnoremap <Leader>3 :b 3<CR>
nnoremap <Leader>4 :b 4<CR>
nnoremap <Leader>5 :b 5<CR>
nnoremap <Leader>6 :b 6<CR>
nnoremap <Leader>7 :b 7<CR>
nnoremap <Leader>8 :b 8<CR>
nnoremap <Leader>9 :b 9<CR>
nnoremap <Leader>0 :b 10<CR>

" Python
" nnoremap <Leader>i :ImportName<CR>

" Leader keys that are defined for me
" <Leader>ll -> pdflatex compile
" <Leader>lv -> latex viewer
" <Leader>rf -> refresh folds (LaTeX)


" ------------------------------------------
" LaTeX Configuration

" TeX-Suite
set shellslash
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'
let g:Tex_SmartKeyDot = 0
let g:Tex_comment_nospell= 1
let g:Tex_SmartKeyQuote = 0
let g:Tex_DefaultTargetFormat = 'pdf'
" let g:Tex_CompileRule_pdf = 'latexmk -f -pdf $*'
let g:Tex_ViewRule_pdf = 'zathura'
let g:Tex_GotoError = 1
function! SyncTexForward()
    let execstr = "silent !zathura --synctex-forward ".line(".").":".col(".").":%:p %:p:r.pdf &"
    exec execstr
endfunction

" s stands for synctex
au FileType tex nmap <Leader>s :call SyncTexForward()<CR>

" Certain file-specific settings which don't seem to apply in after/ftplugin
let g:tex_conceal='agms'
let g:xml_syntax_folding=1

" NerdTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | q | endif
let NERDTreeIgnore = ['\.pyc$']
nnoremap <silent> NT :NERDTreeFocus<CR>

" Lilypond
set runtimepath+=/usr/local/lilypond/usr/share/lilypond/current/vim/

" Git Gutter
highlight! link SignColumn LineNr

" vim: expandtab
