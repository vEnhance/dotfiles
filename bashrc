# 
# .bashrc 
# Evan Chen
#

[[ -n "$DISPLAY" && "$TERM" = "xterm" ]] && export TERM=xterm-256color

[[ -f /bin/python2 ]] && alias python='python2' # Use Python 2 on Arch Linux

shopt -s globstar

# Git magic / Sourcing
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUPSTREAM="auto"
source ~/dotfiles/git-scripts/git-complete.sh
source ~/dotfiles/git-scripts/git-prompt.sh

# Exports
export PS1='\[\033[0;32m\]${debian_chroot:+($debian_chroot)}\u@\h \[\033[0;33m\]\w$(__git_ps1 " \[\033[1;31m\]#%s")\n\[\033[0m\]\$ '
export EDITOR='vim'
export TEXMFHOME=$HOME/.texmf
export PYTHONPATH=$PYTHONPATH:$HOME/Dropbox/Documents/Projects/
export PDFVIEWER='zathura'
export DOT_SAGENB='/home/evan/.sage/'

# Aliases
alias kitty="cat"
alias getclip="xsel --clipboard"
alias putclip="xsel --clipboard"
alias lisp='sbcl --script'

alias dragon='python -m dragon'
alias sparky='python -m sparky'
alias tsq='python ~/dotfiles/py-scripts/tsq.py'
alias wplatex='python ~/dotflies/py-scripts/latex2wp.py'	
alias demacro='python ~/dotfiles/py-scripts/demacro.py'
alias toss='~/.PlayOnLinux/wine/linux-x86/1.5.1-Starcraft_battlenet/bin/wine ~/.stermchains/seriouscombo.exe'

alias workflowy='/usr/bin/chromium --profile-directory=Default --app-id=koegeopamaoljbmhnfjbclbocehhgmkm'
alias pudb='python -m pudb.run'
alias dropcli='python ~/dotfiles/py-scripts/dropbox.py'
alias trash='gvfs-trash'
alias emacs='vim' # Sorry, can't help it
alias gogogo='startx'
alias voice='arecord -f S16_LE -c 2 -r 96000 -D hw:0,0'

# Various functions
function rot13 {
	if [ -r $1 ]; then cat $1 | tr '[N-ZA-Mn-za-m5-90-4]' '[A-Za-z0-9]';
	else echo $* | tr '[N-ZA-Mn-za-m5-90-4]' '[A-Za-z0-9]'; fi
}
# Create a new TeX file
function newtex () {
	mkdir "${1}"
	cd "${1}"
	cat ~/Dropbox/Archive/Code/LaTeX-Templates/Generic.tex >> "${1}.tex"
	# vim "${1}.tex"
	gvim "${1}.tex"
}	
function cclean() {
	rm -f *.out
	rm -f *.class
}

alias jerm='python ~/dotfiles/py-scripts/jpc.py'
alias piglet='python ~/dotfiles/py-scripts/jpc.py'
alias cow='python ~/dotfiles/py-scripts/jpc.py'
alias jpc='python ~/dotfiles/py-scripts/jpc.py'
alias grade='python ~/dotfiles/py-scripts/grade.py'

# Custom change-directory function: cd + ls = cs
function cs () {
	[ -n "${1}" ] && cd "${1}"
	echo -n "`pwd`: "
	ls -l --color=tty
}
alias c='cs'

# Shortcut for editors and the like
function pdf() { 
	if [ -f "${1}pdf" ]
	then
		$PDFVIEWER "${1}pdf" &
	elif [ -f "${1}.pdf" ]
	then
		$PDFVIEWER "${1}.pdf" &
	elif [ -f "${1}" ]
	then
		$PDFVIEWER "${1}" &
	else
		echo "Cannot found a suitable file."
	fi
}

# Uses the locate utility to find a certain file
function hunt () {
	python ~/dotfiles/py-scripts/hunt.py "${1}"
	cd "$(cat /tmp/hunt)"
	pwd
	ls -l --color=tty
}


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

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -r'                          # raw control characters
alias whence='type -a'                        # where, of a sort
alias grep='grep --color'                     # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'              # show differences in colour

# Some shortcuts for different directory listings
alias ls='ls --color=tty'                 # classify files in colour
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -l --color=tty'                  # long list
alias la='ls -A'                              # all but . and ..
alias l='ls -CF'                              #
