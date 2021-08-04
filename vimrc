" Evan Chen's .vimrc
set nocompatible
filetype plugin indent on
syntax on

" ------------------------------------------
" ARCH LINUX ADDONS
" ------------------------------------------
if filereadable("/bin/pacman")
	" EDIT 2021-07-09: vim-plugins on Arch Linux installs a bunch of these
	" already so this list got trimmed a lot.
	" (In fact, having both Plug and system will cause conflicts with ALE).

	" NerdTree: start if only buffer, quit if last one
	autocmd StdinReadPre * let s:std_in=1
	autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | q | endif

	call plug#begin('~/.vim/plugged')
	Plug 'aymericbeaumet/vim-symlink'
	Plug 'brooth/far.vim'
	Plug 'FelikZ/ctrlp-py-matcher'
	Plug 'junegunn/fzf'
	Plug 'junegunn/fzf.vim'
	Plug 'majutsushi/tagbar'
	Plug 'mg979/vim-visual-multi'
	Plug 'moll/vim-bbye'
	Plug 'nathanaelkane/vim-indent-guides'
	Plug 'powerman/vim-plugin-AnsiEsc'
	Plug 'svintus/vim-editexisting'
	Plug 'Shougo/echodoc'
	Plug 'vim-ctrlspace/vim-ctrlspace'
	Plug 'vim-scripts/YankRing.vim'
	Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
	" Plug 'tpope/vim-unimpaired'

	let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --layout reverse --margin=1,4 --preview 'bat --color=always --style=header,grid --line-range :300 {}'"
	let NERDTreeIgnore = ['\.pyc$']
	let g:completor_filetype_map = {}
	let g:ctrlp_clear_cache_on_exit = 0
	let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
	let g:ctrlp_max_files = 0
	let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
	let g:EasyMotion_keys = "aoeuidhtns;qjkxbmwvz',.pyfgcrl/"
	let g:far#source='rg'
	let g:fzf_layout = { 'window': { 'width': 0.7, 'height': 0.4 } }
	let g:indent_guides_auto_colors = 0
	let g:indent_guides_enable_on_vim_startup = 1
	let g:yankring_history_dir = '$HOME/.cache/'
	let grepprg = "ag --nogroup --nocolor"
	" https://github.com/junegunn/fzf.vim/issues/374
	let g:ctrlp_map = '<c-b>'
	let g:ctrlp_cmd = 'CtrlPMixed'

	" File-type specific edits
	Plug 'maralla/completor.vim', { 'for' :
		\ ['css', 'python', 'javascript', 'sh', 'fish', 'vim',
		\ 'json', 'jsonc', 'tex', 'typescript', 'go',
		\ 'gitcommit', 'gitconfig'] }
	Plug 'hura/vim-asymptote',           { 'for' : 'asy' }
	Plug 'kchmck/vim-coffee-script',     { 'for' : 'coffee' }
	Plug 'dag/vim-fish',                 { 'for' : 'fish' }
	Plug 'mboughaba/i3config.vim',       { 'for' : 'i3config' }
	Plug 'chutzpah/icalendar.vim',       { 'for' : 'icalendar' }
	Plug 'neoclide/jsonc.vim',           { 'for' : 'json' }
	Plug 'kovisoft/slimv',               { 'for' : 'lisp' }
	Plug 'plasticboy/vim-markdown',      { 'for' : 'markdown' }
	Plug 'vim-python/python-syntax',     { 'for' : 'python' }
	Plug 'petRUShka/vim-sage',           { 'for' : 'sage' }
	Plug 'vimwiki/vimwiki',              { 'for' : 'vimwiki' }
	Plug 'avakhov/vim-yaml',             { 'for' : 'yaml' }
	Plug 'farseer90718/vim-taskwarrior', { 'for' : 'taskedit' }
	Plug 'tools-life/taskwiki',          { 'for' : 'taskwiki' }
	" Plug 'leanprover/lean.vim'
	let g:python_highlight_all = 1
	let g:taskwiki_disable_concealcursor=1
	let g:vim_markdown_auto_insert_bullets = 0
	let g:vim_markdown_conceal = 0
	let g:vim_markdown_frontmatter = 1
	let g:vim_markdown_math = 1
	let g:vim_markdown_new_list_item_indent = 0
	let g:vimwiki_global_ext = 0
	let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.mkd'}]

	" Airline auto from vim-plugins
	let g:airline#extensions#coc#enabled = 1
	let g:airline#extensions#ctrlspace#enabled = 1
	let g:airline#extensions#fugitive#enabled = 1
	let g:airline#extensions#tabline#buffer_nr_show = 1
	let g:airline#extensions#tabline#ctrlspace_show_tab_nr = 0
	let g:airline#extensions#tabline#current_first = 0
	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#show_buffers = 1
	let g:airline#extensions#tabline#show_tabs = 1
	let g:airline_powerline_fonts = 1
	let g:airline_theme='wombat'
	let g:CtrlSpaceStatuslineFunction =
	\ "airline#extensions#ctrlspace#statusline()"
	function! AirlineSetup()
		let g:airline_section_a = airline#section#create_left(['mode', 'readonly',])
		let g:airline_section_b = airline#section#create_left(['tagbar',])
		let g:airline_section_c = airline#section#create_left(['crypt', 'paste', 'iminsert', ])
		let g:airline_section_gutter = airline#section#create(['%<', 'file', '%='])
		let g:airline_section_x = airline#section#create_right(['branch', 'hunks'])
		let g:airline_section_y = airline#section#create(['%3p%%', ':%3v', 'linenr', 'maxlinenr', 'spell',])
		let g:airline_section_z = airline#section#create(['filetype'])
		let g:airline_mode_map = {
				\ '__'     : '-',
				\ 'c'      : 'C',
				\ 'i'      : 'I',
				\ 'ic'     : 'I',
				\ 'ix'     : 'I',
				\ 'n'      : 'N',
				\ 'multi'  : 'M',
				\ 'ni'     : 'N',
				\ 'no'     : 'N',
				\ 'R'      : 'R',
				\ 'Rv'     : 'R',
				\ 's'      : 'S',
				\ 'S'      : 'S',
				\ ''     : 'S',
				\ 't'      : 'T',
				\ 'v'      : 'V',
				\ 'V'      : 'V',
				\ ''     : 'V',
				\ }
		let s:IA = [ 'gray15', 'gray80', 35, 234 ]
		let g:airline#themes#wombat#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)
		let g:airline#extensions#whitespace#checks = ['indent', 'trailing', 'mixed-indent-file', 'conflicts']
	endfunction
	autocmd User AirlineAfterTheme call AirlineSetup()

	" ALE + CoC (ALE installed by Arch)
	let g:ale_disable_lsp = 1
	let g:ale_echo_msg_error_str = 'E'
	let g:ale_echo_msg_format = '[%severity%] [%linter%] %s'
	let g:ale_echo_msg_warning_str = 'W'
	let g:ale_keep_list_window_open = 0
	let g:ale_open_list = 0
	let g:ale_python_mypy_enabled = 0
	let g:ale_python_mypy_options = "--ignore-missing-imports"
	let g:ale_set_balloon= 1
	let g:ale_set_loclist = 0
	let g:ale_set_quickfix = 1
	let g:ale_sign_column_always = 1
	let g:ale_sign_error = '#'
	let g:ale_sign_warning = '>'
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
	Plug 'rodrigore/coc-tailwind-intellisense', {'do': 'npm install'}
	call plug#end()

	" Vim server
	function StartServer()
		let l:target = expand('%:p')
		let l:gitdir = FugitiveGitDir()
		" Don't run the server check cases in certain cases
		if (empty(l:gitdir) || empty(l:target) || exists('g:prompted')) | return | endif
		if stridx(l:target, ".git") != -1 | let g:prompted = 1 | return | endif
		" If we find a server, offer to load there instead
		if stridx(serverlist(), l:gitdir) != -1
			let l:response = input("Open in existing server? (empty is yes) ", "")
			if stridx(l:response, 'y') != -1 || stridx(l:response, 'Y') != -1 || empty(l:response)
				bdelete
				call remote_send(l:gitdir, ":vsplit " . l:target . "<CR>")
				if winnr('$') == 1 && tabpagenr('$') == 1 && empty(expand('%:p')) | quit | endif
			endif
			let g:prompted = 1
		elseif empty(v:servername)
			call remote_startserver(l:gitdir)
			let g:prompted = 1
		endif
	endfunction
	autocmd BufEnter * call StartServer()
	" Open NerdTree on empty vim
	autocmd StdinReadPre * let g:nt_auto_off=1
	autocmd VimEnter * if argc() == 0 && !exists("g:nt_auto_off") && len(argv()) < 1 | NERDTree | endif
	" Close Vim if only NerdTree remains
	autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
endif

" ------------------------------------------
" CUSTOM KEYBINDINGS (NON-LEADER)
" ------------------------------------------
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
map <Up> :call DelEmptyLineAbove()<CR>
map <Down> :call AddEmptyLineAbove()<CR>

" INDENTATION COMMANDS
" candidate for deletion since i never use these
" Jump to the next or previous line that has the same level or a lower
" level of indentation than the current line.
"   exclusive (bool): Motion is exclusive / Motion is inclusive
"   fwd (bool): Go to next line / Go to prev line
"   lowerlevel (bool): Go to line with (lower/same) indentation level
"   skipblanks (bool): Skip blank lines
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

" CoC based maps
nmap <silent> gd :vsplit<CR><Plug>(coc-definition)
nmap <silent> gy :vsplit<CR><Plug>(coc-type-definition)
nmap <silent> gr :vsplit<CR><Plug>(coc-references)
nmap cv <Plug>(coc-rename)
nmap <silent> [g :ALEPreviousWrap<CR>
nmap <silent> ]g :ALENextWrap<CR>
" smart find and replace
nnoremap <C-h> :Farr<CR>
" write all buffers shortcut
nnoremap <silent> ZW :wa<CR>
" move page so that cursor is on 7th line
nnoremap <silent> za zt7k7j
" system clipboard
vnoremap <silent> <C-C> "+y
nnoremap <silent> <C-c> :%y+<CR>
nnoremap <silent> <C-V> "+p
vnoremap <silent> <C-X> "+d
" Navigate buffers with backspace
nnoremap <Backspace> :CtrlSpaceGoUp<CR>
nnoremap <S-Backspace> :CtrlSpaceGoDown<CR>
" Buffer and ctrlP
command! -bang -nargs=* BLinesExtra
	\ call fzf#vim#grep(
	\ 'rg --with-filename --column --line-number --no-heading . '.fnameescape(expand('%:p')), 1,
	\ fzf#vim#with_preview({'options': '--layout reverse --query '.shellescape(<q-args>).' --with-nth=4.. --delimiter=":"'}, 'right:50%'))
nnoremap <C-/> :BLinesExtra<CR>
nnoremap <C-_> :BLinesExtra<CR>
nnoremap <C-b> :CtrlPMixed<CR>
map , <Plug>(easymotion-prefix)

" ------------------------------------------
" CUSTOM LEADER KEYBINDINGS (SPACE BAR)
" ------------------------------------------
" use space as leader key
let mapleader = "\<Space>"
let maplocalleader = "\\"
nnoremap <Leader> <Nop>

" LEADER KEY
" ALE Details
nnoremap <Leader>a :ALEDetail<CR>
" show syntax group
nnoremap <Leader>y :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
" e is for emulator
nnoremap <Leader>e :let $VIM_DIR=expand('%:p:h')<CR>:silent !xfce4-terminal --working-directory="$VIM_DIR" &<CR>:redraw<CR>
" fold by indent
nnoremap <Leader>f :set foldmethod=indent<CR>
" NerdTree
nnoremap <silent> <leader>t :NERDTreeFocus<CR>

" git main -> open in new tab, and show mini help (defined in fugitive.vim)
nnoremap <Leader>G :Git<CR><C-W>T:call ShowFugitiveMiniHelp()<CR>
nnoremap <Leader>gb :Git blame<CR>
nnoremap <Leader>gd :Gdiffsplit<CR>
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
" git undo (really git read)
nnoremap <Leader>gu :Gread<CR>

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

" Replacement for :q that is smarter
function! EvanClose()
	if winnr('$') == 1
		if tabpagenr('$') == 1
			bdelete
			if expand('%:p') == ''
				quit
			endif
		else
			bdelete
		endif
	else
		close
	endif
endfunction
nnoremap <Leader>- :call EvanClose()<CR>

" Leader keys that are forced on me by LaTeX
" <Leader>ll -> pdflatex compile
" <Leader>lv -> latex viewer
" <Leader>rf -> refresh folds (LaTeX)

" ------------------------------------------
" SETTINGS
" ------------------------------------------
colorscheme reclipse
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif
set backupdir=~/.vim/tmp
set directory=~/.vim/tmp

" Personal settings
set backspace=indent,eol,start
set backup     " keep a backup file
set cm=blowfish2
set completeopt=menuone,noselect,preview
set conceallevel=2
set foldlevelstart=3
set guicursor+=n-v-c:blinkon0
set guifont=Monospace\ 11
set hidden
set history=50 " keep 50 lines of command line history
set hlsearch
set incsearch  " do incremental searching
set laststatus=2
set linebreak
set list
set listchars=tab:\|\ ,trail:_
set mouse=a    " mouse enabled
set noautoindent
set nohlsearch
set noshowmode " don't need mode shown if we have airline
set number
set omnifunc=ale#completion#OmniFunc
set ruler      " show the cursor position all the time
set shell=/bin/bash
set shellslash
set shiftwidth=2
set showbreak=_
set showcmd    " display incomplete commands
set spell
set splitright
set t_Co=256
set tabstop=2
set textwidth=0
set updatetime=100
set wrap
set wrapmargin=0

" ------------------------------------------
" SPECIFIC FILETYPE CONFIG
" ------------------------------------------
autocmd FileType gitcommit set nosmartindent | set formatoptions-=t
autocmd BufNewFile,BufRead *.asy setfiletype asy
autocmd BufNewFile,BufRead *.ly setfiletype lilypond
autocmd BufNewFile,BufRead *.less setfiletype css
autocmd BufNewFile,BufRead *.ics setfiletype icalendar

let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_GotoError = 1
let g:Tex_Leader2='\\'
let g:Tex_SmartKeyDot = 0
let g:Tex_SmartKeyQuote = 0
let g:Tex_ViewRule_pdf = 'zathura'
let g:Tex_comment_nospell= 1
let g:tex_flavor='latex'
function! SyncTexForward()
	exec "silent !zathura --synctex-forward ".line(".").":".col(".").":%:p %:p:r.pdf &"
endfunction
let g:tex_conceal='agms'
let g:xml_syntax_folding=1
set runtimepath+=/usr/local/lilypond/usr/share/lilypond/current/vim/

" vim: ft=vim
