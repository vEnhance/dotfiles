#
# .bashrc
# Evan Chen
#

if [ "x${SSH_TTY}" = "x" ]; then
	# Git magic / Sourcing
	GIT_PS1_SHOWDIRTYSTATE=1
	GIT_PS1_SHOWSTASHSTATE=1
	GIT_PS1_SHOWUPSTREAM="auto"
	source ~/dotfiles/sh-scripts/git-complete.sh
	source ~/dotfiles/sh-scripts/git-prompt.sh
	export PS1='\[\033[0;32m\]${debian_chroot:+($debian_chroot)}\u@\h \[\033[0;33m\]\w$(__git_ps1 " \[\033[1;31m\]#%s")\n\[\033[0m\]\$ '
else
	export PS1='\[\033[0;31m\]${debian_chroot:+($debian_chroot)}\u@\h \[\033[1;37m\]\w\n\[\033[0m\]\$ '
	if [ -f ~/banner ]; then
		cat ~/banner
	fi
fi

# Exports
export EDITOR='vim'
export TERM='xterm-256color'
if [ -d $HOME/.texmf ]; then
   	export TEXMFHOME=$HOME/.texmf
fi
if [ -d $HOME/.sage ]; then
   	export DOT_SAGENB=$HOME/.sage
fi
if [ -f /usr/bin/zathura ]; then
   	export PDFVIEWER='zathura'
fi

umask 007 # set umask

# Aliases
alias bcsum='paste -sd+ - | bc'
alias dropcli='dropbox-cli'
alias getclip="xsel --clipboard"
alias kitty="cat"
alias lisp='sbcl --script'
alias putclip="xsel --clipboard"
alias python='python3'
alias trash='gio trash'
alias voice='arecord -f S16_LE -c 2 -r 96000 -D hw:0,0'
alias winf='wine winefile'
alias winx='startx /bin/wine winefile --kiosk --'

alias demacro='python2 ~/dotfiles/py-scripts/demacro.py'
alias dragon='python2 ~/Documents/Projects/dragon/'
alias odus='python3 ~/dotfiles/py-scripts/odus.py'
alias oscar='python3 ~/dotfiles/py-scripts/oscar.py'
alias sparky='python3 ~/Documents/Projects/sparky/'
alias todo='~/dotfiles/sh-scripts/get-todo.sh'
alias tsq='python3 ~/dotfiles/py-scripts/tsq.py'
alias von='python3 -m von'
alias wplatex='python2 ~/dotfiles/py-scripts/latex2wp.py'
alias wpmd='python3 ~/dotfiles/py-scripts/markdown2wp.py'

alias mu='neomutt'
alias m1='neomutt -F ~/.config/mutt/neomuttrc.1'
alias m2='neomutt -F ~/.config/mutt/neomuttrc.2'

alias sudo='sudo ' # allows my aliases to get into sudo in bash

export PYTHONPATH="$PYTHONPATH:$HOME:$HOME/dotfiles/py-scripts"
export PATH=$PATH:$HOME/.local/bin

# Various functions
function rot13 () {
	if [ -r $1 ]; then
		cat $1 | tr '[N-ZA-Mn-za-m5-90-4]' '[A-Za-z0-9]';
	else
		echo $* | tr '[N-ZA-Mn-za-m5-90-4]' '[A-Za-z0-9]';
   	fi
}
# Uses the locate utility to find a certain file
function hunt () {
	python3 ~/dotfiles/py-scripts/hunt.py "${1}"
	cd "$(cat /tmp/hunt.$(whoami))"
	pwd
	ls -l --color=tty
}

#It speaks!
alias aoeu="echo I see you are a Dvorak user."
alias bleh="echo Meh."
alias bye="echo So long, and thanks for all the fish."
alias darn="echo Heh."
alias fml="echo HAHAHAHAHA"
alias hello="echo Hello!"
alias hi="echo Hi!"
alias hm="echo Hm?"
alias kk="echo Glad you approve."
alias lolwut="echo idk"
alias meow="echo Here, kitty! \<3"
alias ok="echo Glad you approve."
alias purr="echo Here, kitty! \<3"

#QQ
alias qq="echo QQ!"
alias qqq="echo QQ!"
alias qqqq="echo QQ!"
alias qqqqq="echo QQ!"
alias qqqqqq="echo QQ!"
alias qqqqqqq="echo QQ!"
alias qqqqqqqq="echo QQ!"
alias qqqqqqqqq="echo QQ!"
alias qqqqqqqqqq="echo QQ!"
alias qqqqqqqqqqq="echo QQ!"
alias qqqqqqqqqqqq="echo QQ!"
alias qqqqqqqqqqqqq="echo QQ!"
alias qqqqqqqqqqqqqq="echo QQ!"
alias qqqqqqqqqqqqqqq="echo QQ!"
alias qqqqqqqqqqqqqqqq="echo QQ!"
alias qqqqqqqqqqqqqqqqq="echo QQ!"
alias qqqqqqqqqqqqqqqqqq="echo QQ!"
alias qqqqqqqqqqqqqqqqqqq="echo QQ!"

# Interactive operation...
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Misc :)
alias less='less -R'                          # raw control characters
alias diff='diff --color'                     # show differences in color
alias grep='grep --color'                     # show differences in color
alias egrep='egrep --color=auto'              # show differences in color
alias fgrep='fgrep --color=auto'              # show differences in color

# Some shortcuts for different directory listings
if [ -f /bin/pacman ]; then
	alias ls='ls --color=tty --quoting-style=literal' # classify files in color
	alias ll='ls -l --color=tty'                  # long list
	alias l='ls -CF'                              #
elif [ -f /sbin/apk ]; then
	alias ls='ls --color=always' # classify files in color
	alias ll='ls -l --color=tty'                  # long list
	alias l='ls -CF'                              #
elif [ "$(uname)" = Darwin ]; then
	alias ls='ls -G' # classify files in color
	alias ll='ls -Gl'                             # long list
	alias l='ls -CF'                              #
fi
