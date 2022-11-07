function dn
	set -l escaped_argv (string escape --no-quoted $argv)
	bash -c "$escaped_argv &" > /dev/null
end

# Status Chars
#set __fish_git_prompt_char_dirtystate '*'
#set __fish_git_prompt_char_stagedstate '+'
#set __fish_git_prompt_char_untrackedfiles '?'
#set __fish_git_prompt_char_stashstate '$'
#set __fish_git_prompt_char_upstream_ahead '>'
#set __fish_git_prompt_char_upstream_behind '<'

set fish_color_cwd CCA700
set fish_color_name 44FFFF
set fish_color_host 11DD33
set fish_color_error FF0000
set fish_color_greeting FF3333
set fish_color_determination yellow
set fish_color_date 888888
set fish_color_arrows 00CCA7

set fish_prompt_pwd_dir_length 2

# Fish git prompt
set __fish_git_prompt_showdirtystate 1
set __fish_git_prompt_showstashstate 1
set __fish_git_prompt_showuntrackedfiles 1
set __fish_git_prompt_showcolorhints 1
set __fish_git_prompt_show_informative_status 1
set __fish_git_prompt_color 9CFEFA
set __fish_git_prompt_color_branch 00CCA7
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red

function fish_greeting
	set_color --italics $fish_color_greeting
	printf "Hello "
	set_color --bold $fish_color_name
	printf $USER
	set_color normal
	set_color --italics $fish_color_host
	printf @
	printf (hostname)
	set_color $fish_color_greeting
	printf "! You are filled with "
	set_color --bold $fish_color_determination
	printf "determination"
	set_color normal
	set_color --italics $fish_color_greeting
	printf ".\n"
	set_color --italics $fish_color_date
	printf "It is "
	printf (date +'%a %d %b %Y, %R %Z')
	printf ".\n"
	set_color normal
end

function fish_prompt
	set last_status $status
	if set -q SUDO_USER
		or set -q SSH_TTY
		set_color --italics yellow
		printf (prompt_pwd)
	else
		set_color --italics $fish_color_cwd
		printf (prompt_pwd)
	end
	set_color normal
	if not test $last_status -eq 0
		set_color $fish_color_error
		printf ' ['
		printf $last_status
		printf ']'
	end
	if set -q SUDO_USER
		or set -q SSH_TTY
		printf ' '
		set_color -b blue yellow --bold
		printf '('
		printf $USER
		printf ')'
		set_color normal
		printf ' '
	else
		set_color --bold $fish_color_arrows
		printf ' >> '
	end
	set_color normal
end

function fish_right_prompt
	set_color normal
	if set -q VIRTUAL_ENV
		echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal)
	end
	set_color normal
	printf '%s ' (__fish_git_prompt)
	set_color normal
	set_color $fish_color_date
	printf "["
	printf (date +'%R')
	printf "]"
end

function fish_right_prompt_loading_indicator -a last_prompt
	echo -n "$last_prompt" | sed -r 's/\x1B\[[0-9;]*[JKmsu]//g' | read -zl uncolored_last_prompt
	echo -n (set_color brblack)"$uncolored_last_prompt"(set_color normal)
end

# Exports
export SHELL='/usr/bin/fish'
export EDITOR='vim'
export TERM='xterm-256color'
export GPG_TTY=(tty)

# the auto prompt-edited detetction is not enabled somehow
export VIRTUAL_ENV_DISABLE_PROMPT=1
set -U -x VIRTUAL_ENV_DISABLE_PROMPT 1

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

umask 007 # set umask

# Vim aliases (tiny, basic, file, slim, ale, coc)
alias bvim="vim --cmd 'let g:mana=0'"
alias tvim="vim --cmd 'let g:mana=20'"
alias fvim="vim --cmd 'let g:mana=40'"
alias svim="vim --cmd 'let g:mana=60'"
alias ale="vim --cmd 'let g:mana=80'"
alias coc="vim --cmd 'let g:mana=100'"

alias gbvim="gvim --cmd 'let g:mana=0'"
alias gtvim="gvim --cmd 'let g:mana=20'"
alias gfvim="gvim --cmd 'let g:mana=40'"
alias gsvim="gvim --cmd 'let g:mana=60'"
alias gale="gvim --cmd 'let g:mana=80'"
alias gcoc="gvim --servername '' --cmd 'let g:mana=100'"

# alias emacs='vim'
alias bcsum='paste -sd+ - | bc'
alias dj='python -m pdb -c continue manage.py runserver'
alias dropcli='dropbox-cli'
alias getclip="xsel --clipboard"
alias gim="vim --cmd 'let g:nt_auto_off=1' -c Git -c only"
alias lisp='sbcl --script'
alias lt="languagetool --disable COMMA_PARENTHESIS_WHITESPACE,WHITESPACE_RULE,UPPERCASE_SENTENCE_START,LC_AFTER_PERIOD,FILE_EXTENSIONS_CASE,ARROWS,EN_UNPAIRED_BRACKETS,UNLIKELY_OPENING_PUNCTUATION,UNIT_SPACE,ENGLISH_WORD_REPEAT_BEGINNING_RULE,CURRENCY,REP_PASSIVE_VOICE"
alias panmkd2pdf='pandoc --from=markdown --to=pdf -V fonsize=12t -V colorlinks -V indent=true -V documentclass=amsart -V linestretch=1.5'
alias pdb='python -m pdb -c continue'
alias poetry-outdated='poetry show --outdated --ansi | grep --file=(poetry show --tree | grep "^\\w" | sed "s/^\\([^ ]*\\).*/^.\\\\\\[36m\\1/" | psub)'
alias putclip="xsel --clipboard"
alias swank="sbcl --load ~/.vim/plugged/slimv/slime/start-swank.lisp"
alias todo='task ready'
alias trash='gio trash'
alias ut='python manage.py test --pdb'
alias voice='arecord -f S16_LE -c 2 -r 96000 -D hw:0,0'
alias winf='wine winefile'
alias winx='startx /bin/wine winefile --kiosk --'
alias wut='watch -b -c -n 10 "python manage.py test"'
#gd ubuntu
alias pip='pip3'
alias pudb='pudb3'
alias getpip='curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10'


# OTIS venue Q
alias otis='gvim -c ":let g:venue_entry=\'~/dotfiles/venueQ/otis.py\'" -c ":source ~/dotfiles/venueQ/venueQ.vim"'


alias demacro='/usr/bin/python3 ~/dotfiles/py-scripts/demacro.py'
alias dragon='/usr/bin/python3 ~/Sync/Projects/dragon/'
alias md='/usr/bin/python3 ~/dotfiles/py-scripts/sane_markdown.py'
alias odus='/usr/bin/python3 ~/dotfiles/py-scripts/odus.py'
alias orch='/usr/bin/python3 ~/dotfiles/py-scripts/orch.py'
alias oscar='/usr/bin/python3 ~/dotfiles/py-scripts/oscar.py'
alias sparky='/usr/bin/python3 ~/Sync/Projects/sparky/'
alias tsq='/usr/bin/python3 ~/dotfiles/py-scripts/tsq.py'
alias viag='/usr/bin/python3 ~/dotfiles/py-scripts/viag.py'
alias von='/usr/bin/python3 -m von'
alias wah='/usr/bin/python3 ~/dotfiles/py-scripts/wah.py'
alias wplatex='/usr/bin/python3 ~/dotfiles/py-scripts/latex2wp.py'
alias wpmd='/usr/bin/python3 ~/dotfiles/py-scripts/markdown2wp.py'
alias xfer='/usr/bin/python3 -m xfer'

alias mu='~/dotfiles/mutt/open-mail.sh'
alias m1='~/dotfiles/mutt/open-mail.sh -F ~/.config/mutt/neomuttrc.1'
alias m2='~/dotfiles/mutt/open-mail.sh -F ~/.config/mutt/neomuttrc.2'

export PYTHONPATH="$PYTHONPATH:$HOME:$HOME/dotfiles/py-scripts/"
export PATH="$PATH:$HOME/dotfiles/bin/"

# Create a new TeX file
function newtex
	if string match '*.tex' $argv
		echo "That's probably not what you meant to do"
		return 1
	end
	mkdir "$argv"
	cd "$argv"
	echo '\documentclass[11pt]{scrartcl}' > "$argv.tex"
	echo '\usepackage{evan}' >> "$argv.tex"
	echo '\begin{document}' >> "$argv.tex"
	echo '\title{<++>}' >> "$argv.tex"
	echo '<++>' >> "$argv.tex"
	echo '\end{document}' >> "$argv.tex"
	gvim "$argv.tex"
end

# Shortcut for editors and the like
function pdf
	string match '*.pdf' "$argv" > /dev/null
	if test \( -f "$argv" \) -a \( $status -eq 0 \)
		dn zathura $argv &> /dev/null
	else if test -f (echo $argv | cut -f 1 -d '.').pdf
		dn zathura (echo $argv | cut -f 1 -d '.').pdf &> /dev/null
	else if test -f "$argv""pdf"
		dn zathura "$argv""pdf" &> /dev/null
	else if test -f "$argv.pdf"
		dn zathura "$argv.pdf" &> /dev/null
	else
		echo "Cannot found a suitable file."
	end
end

# Uses the locate utility to find a certain file
function hunt ()
	python3 ~/dotfiles/py-scripts/hunt.py "$argv"
	if test $status -eq 0
		if test -n (cat /tmp/hunt.(whoami))
			cd (cat /tmp/hunt.(whoami))
			echo (set_color --bold --italic brcyan)(pwd)(set_color normal)
			ll | head -n 25
			set num_hidden (math (ll | wc --lines) - 25)
			if test $num_hidden -gt 0
				echo (set_color yellow)"... and" (set_color --bold yellow)$num_hidden(set_color normal)(set_color yellow) "additional items not shown"(set_color normal)
			end
		else
			echo Error: (set_color bryellow)\""$argv"\"(set_color normal) "not found"
		end
	else
		echo Search for (set_color brred)\""$argv"\"(set_color normal) aborted
	end
end

function pdfenc --argument-names 'infile' 'outfile' 'password'
	qpdf --encrypt "$password" "$password" 256 --print=none --modify=none -- $infile $outfile
end

function pdfjoin
	qpdf $argv[1] --pages $argv[1..-2] -- $argv[-1]
end

function pdfsplit
	qpdf --split-pages=1 $argv[1] page%d-$argv[1]
end

# correct horse battery staple
function chbs
	shuf -n 1000 /usr/share/dict/words | ag "^[a-z]{3,9}\$" | head -n 12
end

function hub
	set -l digits (echo $argv | ag --only-matching "[0-9]+" --nocolor)
	if test -z "$argv" -o (echo $argv | cut -c 1) = "-"
		gh issue list $argv
		gh pr list $argv
	else if test "$argv" = "pr"
		gh pr list
	else if test "$argv" = "re $digits"
		gh issue view --comments $digits 2> /dev/null
		if test $status -eq 0
			echo "Enter your comment below, or blank to open Vi..."
			cat > /tmp/gh-comment.txt
			if ag "[^\s]+" /tmp/gh-comment.txt > /dev/null
				gh issue comment $digits -F /tmp/gh-comment.txt
			else
				gh issue comment $digits
			end
		else
			gh pr view --comments $digits
			echo "Enter your comment below, or blank to open Vi..."
			cat > /tmp/gh-comment.txt
			if ag "[^\s]+" /tmp/gh-comment.txt > /dev/null
				gh pr comment $digits -F /tmp/gh-comment.txt
			else
				gh pr comment $digits
			end
		end
	else if test (echo $argv | cut -d " " -f 1) = "$digits"
		gh issue view $argv 2> /dev/null
		if test $status -ne 0
			gh pr view $argv
		end
	else
		gh $argv
	end
end

function diary
	vim -O ~/Sync/alONE/(ag include ~/Sync/alONE/alONE.tex | tail -n 1 | cut -d \{ -f 2 | sed s/\}/.tex/) ~/Sync/alONE/alONE.tex
end

set -x LESS_TERMCAP_md (printf "\e[01;31m")
set -x LESS_TERMCAP_me (printf "\e[0m")
set -x LESS_TERMCAP_se (printf "\e[0m")
set -x LESS_TERMCAP_so (printf "\e[01;44;33m")
set -x LESS_TERMCAP_ue (printf "\e[0m")
set -x LESS_TERMCAP_us (printf "\e[01;32m")

#It speaks!
alias aoeu="echo I see you are a Dvorak user."
alias bleh="echo Meh."
alias bye="echo So long, and thanks for all the fish."
alias darn="echo Heh."
alias fml="echo HAHAHAHAHA"
alias hello="echo Hello!"
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
alias less='less -R'                          # less should detect colors correctly
alias diff='diff --color'                     # show differences in color
alias egrep='egrep --color=auto'              # show differences in color
alias fgrep='fgrep --color=auto'              # show differences in color

# Some shortcuts for different directory listings

if test (uname) = "Linux"
	alias ls='ls --color=tty --quoting-style=literal'
	alias la='ls -l --block-size=K'
	function ll
		if test (count *.tex) -eq 0
			ls -l --block-size=K --color=yes $argv
			return
		end
		set --function regex '('(string join '|' (string sub --end=-5 (string escape --style=regex *.tex)))')'
		set --function regex $regex'\.(aux|bbl|bcf|blg|fdb_latexmk|fls|log|maf|mtc0?|out|pre|ptc[0-9]+|pytxcode|pytxmcr|pytxpyg|run\.xml|synctex(\.gz|\(busy\))|toc|von|xdv)|-[0-9]{1,2}\.(asy|pdf)$'
		set --function regex '('$regex')|pythontex_data\.pkl'
		set num_hidden (ls -l --block-size=K --color=yes $argv | grep -E $regex 2> /dev/null | wc --lines)
		ls -l --block-size=K --color=yes $argv | grep -Ev $regex 2> /dev/null
		if test $num_hidden -gt 0
			echo (set_color cyan)"... and" (set_color --bold brgreen)$num_hidden(set_color normal)(set_color cyan) "garbage files not shown"(set_color normal)
			end
	end
	function ranger-cd
		if test -z "$RANGER_LEVEL"
			set tempfile "/tmp/(whoami)chosendir"
			ranger --choosedir=$tempfile (pwd)
			if test -f $tempfile
					if [ (cat $tempfile) != (pwd) ]
						cd (cat $tempfile)
					end
			end
			rm -f $tempfile
		else
			exit
		end
	end
	alias hi='ranger-cd'
else
	alias ls='ls -G'
	alias l='ls -lG'
	alias ll='ls -lG'
end

# Fish completions
complete -c disown -x -a "(__fish_complete_subcommand -u -g)"
complete -c dn -x -a "(__fish_complete_subcommand -u -g)"

# Addon settings
set -U __done_notification_urgency_level normal

# fish vi key bindings
fish_vi_key_bindings
bind -M default \ce 'accept-autosuggestion'
bind -M insert \ce 'accept-autosuggestion'

# fzf keybindings
fzf_configure_bindings --git_log=\cg --directory=\cf --git_status=\cs

function fish_mode_prompt
	if test "$fish_key_bindings" = "fish_vi_key_bindings"
			or test "$fish_key_bindings" = "fish_hybrid_key_bindings"
			switch $fish_bind_mode
				case default
					set_color --bold --background red white
					echo 'N'
				case insert
					set_color --bold --background green white
					echo 'I'
				case replace_one
					set_color --bold --background green white
					echo 'R'
				case replace
					set_color --bold --background cyan white
					echo 'R'
				case visual
					set_color --bold --background magenta white
					echo 'V'
				end
			set_color normal
			echo -n ' '
	end
end
tabs -2
