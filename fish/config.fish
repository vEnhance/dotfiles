set FISH_CLIPBOARD_CMD "cat" # Stop that.

set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set red (set_color red)
set gray (set_color -o black)

# Fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'no'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch 'FFFFFF'
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red

# Status Chars
set __fish_git_prompt_char_dirtystate '*'
set __fish_git_prompt_char_stagedstate '+'
set __fish_git_prompt_char_untrackedfiles '?'
set __fish_git_prompt_char_stashstate '$'
set __fish_git_prompt_char_upstream_ahead '>'
set __fish_git_prompt_char_upstream_behind '<'

set fish_color_cwd CCA700
set fish_color_name 00CCA7
set fish_color_greeting FF3333

function fish_greeting
	set_color $fish_color_greeting
	printf "Hello "
	set_color $fish_color_name
	printf (whoami)
	set_color $fish_color_greeting
	printf "! You are filled with "
	set_color $fish_color_name
	printf "determination"
	set_color $fish_color_greeting
	printf "."
end

function fish_prompt
  set last_status $status

  set_color $fish_color_name
  printf (whoami)@(hostname)
  printf ' '
  set_color $fish_color_cwd
  printf (dirs)

  set_color normal
  printf '%s ' (__fish_git_prompt)
  set_color normal
  printf '\n$ '

  zd --add "$PWD"
end


if [ -f /bin/python2 ]
   	alias python='python2'
end
if [ -f /bin/pip2 ]
	alias pip2='pip2'
end
if [ "(uname)" = Linux ]
	shopt -s globstar
end

# Exports
export SHELL='/bin/fish'
export EDITOR='vim'
export TERM='xterm-256color'
if [ -d $HOME/.texmf ]
   	export TEXMFHOME=$HOME/.texmf
end
if [ -d $HOME/.sage ]
   	export DOT_SAGENB=$HOME/.sage
end
if [ -f /usr/bin/zathura ]
   	export PDFVIEWER='zathura'
end
if [ -f ~/dotfiles/aws-hmmt ]
   	source ~/dotfiles/aws-hmmt
end

# Aliases
alias kitty="cat"
alias getclip="xsel --clipboard"
alias putclip="xsel --clipboard"
alias lisp='sbcl --script'
alias bcsum='paste -sd+ - | bc'

alias dragon='python ~/Documents/Projects/dragon/'
alias sparky='python ~/Documents/Projects/sparky/'
alias von='python ~/Documents/Projects/von/'
alias tsq='python ~/dotfiles/py-scripts/tsq.py'
alias wplatex='python ~/dotflies/py-scripts/latex2wp.py'	
alias demacro='python ~/dotfiles/py-scripts/demacro.py'
alias winf='wine winefile'
alias winx='startx /bin/wine winefile --kiosk --'
alias s3='aws s3'
alias todo='vim ~/Documents/VimFlowy/TODO.otl'
alias frn='vim ~/Documents/VimFlowy/FRIENDZ.otl'

alias pudb='python -m pudb.run'
alias dropcli='python ~/dotfiles/py-scripts/dropbox.py'
alias trash='gvfs-trash'
alias emacs='vim' # Sorry, can't help it
alias gogogo='startx'
alias voice='arecord -f S16_LE -c 2 -r 96000 -D hw:0,0'
alias sudo='sudo ' # allows my aliases to get into sudo

# Create a new TeX file
function newtex 
	mkdir $argv
	cd $argv
	cat ~/Dropbox/Archive/Code/LaTeX-Templates/Generic.tex >> "$argv.tex"
	gvim "$argv.tex"
end

# Shortcut for editors and the like
function pdf
	if test -f "$argv""pdf"
		zathura "$argv""pdf" &
	else if test -f "$argv.pdf"
		zathura "$argv.pdf" &
	else if test -f "$argv"
		zathura "$argv" &
	else
		echo "Cannot found a suitable file."
	end
end

# Uses the locate utility to find a certain file
function hunt ()
	python ~/dotfiles/py-scripts/hunt.py "$argv"
	cd (cat /tmp/hunt)
	pwd
	ls -l --color=tty
end

#export LESS_TERMCAP_mb='\e[01;31m'
#export LESS_TERMCAP_md='\e[01;38;5;208m'
#export LESS_TERMCAP_me='\e[0m'
#export LESS_TERMCAP_se='\e[0m'
#export LESS_TERMCAP_so='\e[01;44;33m'
#export LESS_TERMCAP_ue='\e[0m'
#export LESS_TERMCAP_us='\e[04;38;5;111m'

#It speaks!
alias hi="echo Hi!"
alias hello="echo Hello!"
alias ok="echo Glad you approve."
alias kk="echo Glad you approve."
alias bye="echo So long, and thanks for all the fish."
alias darn="echo Heh."
alias bleh="echo Meh."
alias hm="echo Hm?"
alias aoeu="echo I see you are a Dvorak user."
alias fml="echo HAHAHAHAHA"
alias lolwut="echo idk"
alias meow="echo Here, kitty! \<3"
alias purr="echo Here, kitty! \<3"

#QQ
alias qq="echo QQ!"
alias qqq="echo QQ!"
alias qqqq="echo QQ!"

# Interactive operation...
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Misc :)
alias less='less -r'                          # raw control characters
alias grep='grep --color'                     # show differences in color
alias egrep='egrep --color=auto'              # show differences in color
alias fgrep='fgrep --color=auto'              # show differences in color

# Some shortcuts for different directory listings
if [ (uname) = Linux ]
	alias ls='ls --color=tty --quoting-style=literal' # classify files in color
	alias ll='ls -l --color=tty'                  # long list
	alias l='ls -CF'                              #
end
if [ (uname) = Darwin ]
	alias ls='ls -G' # classify files in color
	alias ll='ls -Gl'                             # long list
	alias l='ls -CF'                              #
end

# Custom change-directory function: cd + ls = cs
function cs
	if [ -n $argv ]
		cd $argv
	end
	ll
end
alias c='cs'

# Fish completions
complete -x -c cs -a "(__fish_complete_directories)"

source ~/dotfiles/z.fish
function z
	zd $argv
	ll
end

# vim: ft=sh
