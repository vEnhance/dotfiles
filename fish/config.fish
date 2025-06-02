umask 007 # set umask

alias dropcli='dropbox-cli'
alias fixtrailspace='sed -i "s/[ \t]*\$//"'
alias getclip="xsel --clipboard"
alias gg="cd (git rev-parse --show-toplevel)"
alias gpg-loopback="gpg --clearsign --pinentry-mode loopback"
alias gsthaw='gcloud storage objects update --cache-control="private,max-age=0"'
alias ipv4="hostname -i | cut -d' ' -f2"
alias j-langtool="languagetool --disable COMMA_PARENTHESIS_WHITESPACE,WHITESPACE_RULE,UPPERCASE_SENTENCE_START,LC_AFTER_PERIOD,FILE_EXTENSIONS_CASE,ARROWS,EN_UNPAIRED_BRACKETS,UNLIKELY_OPENING_PUNCTUATION,UNIT_SPACE,ENGLISH_WORD_REPEAT_BEGINNING_RULE,CURRENCY,REP_PASSIVE_VOICE"
alias ksp="hunspell -d ko_KR"
alias memtop='ps aux  | awk \'{printf "%8.3f MB\t\t%s\n", $6/1024, $11}\'  | sort -n | grep -v "^   0.000 MB"'
alias panmd2pdf='pandoc --from=markdown --to=pdf -V fonsize=12t -V colorlinks -V indent=true -V documentclass=amsart -V linestretch=1.5'
alias putclip="xsel --clipboard"
alias todo='task ready'
alias trash='gio trash'

alias dj='python (git rev-parse --show-toplevel)/manage.py runserver_plus'
alias pdb='ipython --pdb'
alias ut='python manage.py test --pdb'

function dn
    set -l escaped_argv (string escape --no-quoted $argv)
    bash -c "$escaped_argv &" >/dev/null
end

# PROMPT CONFIG {{{
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
# }}}

# Exports {{{
export SHELL='/usr/bin/fish'
export EDITOR='vim'
export TERM='xterm-256color'
export GPG_TTY=(tty)
# the auto prompt-edited detection is not enabled somehow
export VIRTUAL_ENV_DISABLE_PROMPT=1
set -U -x VIRTUAL_ENV_DISABLE_PROMPT 1
if test -d $HOME/.texmf
    export TEXMFHOME=$HOME/.texmf
end
if test -d $HOME/.sage
    export DOT_SAGENB=$HOME/.sage
end
if test -f /usr/bin/zathura
    export PDFVIEWER='zathura'
end
# path exports
export PYTHONPATH="$PYTHONPATH:$HOME/dotfiles/py-scripts/"
export PATH="$PATH:$HOME/dotfiles/bin/:$HOME/.cargo/bin"
export HATCH_USE_ENV=1
if test -d /opt/google-cloud-cli
    export CLOUDSDK_ROOT_DIR=/opt/google-cloud-cli
    export CLOUDSDK_PYTHON=/usr/bin/python
    export CLOUDSDK_PYTHON_ARGS=-S
    export PATH="$CLOUDSDK_ROOT_DIR/bin:$PATH"
    export GOOGLE_CLOUD_SDK_HOME="$CLOUDSDK_ROOT_DIR"
end
# }}}

# Drop-in replacements {{{
if test -f /usr/bin/delta
    alias diff=delta
else
    alias diff='diff --color' # show differences in color
end
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias less='less -R' # less should detect colors correctly
alias egrep='egrep --color=auto' # show differences in color
alias fgrep='fgrep --color=auto' # show differences in color
alias pip='pip3' #gd ubuntu
alias python='python3' #gd ubuntu
# }}}

# Aliases to custom Python/shell and mailbox programs {{{
alias demacro='/usr/bin/python3 ~/dotfiles/py-scripts/demacro.py'
alias dragon='/usr/bin/python3 ~/Sync/Projects/dragon/'
alias md='/usr/bin/python3 ~/dotfiles/py-scripts/sane_markdown.py'
alias odus='/usr/bin/python3 ~/dotfiles/py-scripts/odus.py'
alias orch='/usr/bin/python3 ~/dotfiles/py-scripts/orch.py'
alias oscar='/usr/bin/python3 ~/dotfiles/py-scripts/oscar.py'
alias sparky='/usr/bin/python3 ~/Sync/Projects/sparky/'
alias stomp='/usr/bin/python3 ~/dotfiles/py-scripts/stomp.py'
alias viag='/usr/bin/python3 ~/dotfiles/py-scripts/viag.py'
alias wah='/usr/bin/python3 ~/dotfiles/py-scripts/wah.py'
alias wplatex='/usr/bin/python3 ~/dotfiles/py-scripts/latex2wp.py'
alias wpmd='/usr/bin/python3 ~/dotfiles/py-scripts/markdown2wp.py'
alias yao='/usr/bin/python3 ~/dotfiles/py-scripts/yao.py'

alias tu='~/dotfiles/sh-scripts/task-update.sh'
# mailbox aliases
alias mu='~/dotfiles/mutt/open-mail.sh'
alias m1='~/dotfiles/mutt/open-mail.sh -F ~/.config/mutt/neomuttrc.1'
alias m2='~/dotfiles/mutt/open-mail.sh -F ~/.config/mutt/neomuttrc.2'
# }}}

# Miscellaneous utility functions {{{
alias bcsum='paste -sd+ - | bc'
alias rot13="tr 'A-Za-z' 'N-ZA-Mn-za-m'"
alias lisp='sbcl --script'
alias swank="sbcl --load ~/.vim/plugged/slimv/slime/start-swank.lisp"
# }}}

# less termcap settings {{{
set -x LESS_TERMCAP_md (printf "\e[01;31m")
set -x LESS_TERMCAP_me (printf "\e[0m")
set -x LESS_TERMCAP_se (printf "\e[0m")
set -x LESS_TERMCAP_so (printf "\e[01;44;33m")
set -x LESS_TERMCAP_ue (printf "\e[0m")
set -x LESS_TERMCAP_us (printf "\e[01;32m")
# }}}

# dumb speaking aliases {{{
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
# }}}

set -U __done_notification_urgency_level normal

# Fish colors {{{
set -U fish_color_autosuggestion ffd7d7\x1e\x2d\x2dunderline
set -U fish_color_cancel \x2d\x2dreverse
set -U fish_color_command aaffff\x1e\x2d\x2dbold
set -U fish_color_comment 5fffaf
set -U fish_color_cwd CCA700
set -U fish_color_cwd_root red
set -U fish_color_end F29668
set -U fish_color_error FF0000
set -U fish_color_escape 95E6CB
set -U fish_color_history_current \x2d\x2dbold
set -U fish_color_host 11DD33
set -U fish_color_host_remote \x1d
set -U fish_color_keyword \x1d
set -U fish_color_match F07178
set -U fish_color_normal B3B1AD
set -U fish_color_operator E6B450
set -U fish_color_option \x1d
set -U fish_color_param 5fffff
set -U fish_color_quote ffd75f
set -U fish_color_redirection 00ff00\x1e\x2d\x2dbold
set -U fish_color_search_match \x2d\x2dbackground\x3dE6B450
set -U fish_color_selection \x2d\x2dbackground\x3dE6B450
set -U fish_color_status red
set -U fish_color_user brgreen
set -U fish_color_valid_path \x2d\x2dunderline
set -U fish_pager_color_completion normal
set -U fish_pager_color_description B3A06D
set -U fish_pager_color_prefix normal\x1e\x2d\x2dbold\x1e\x2d\x2dunderline
set -U fish_pager_color_progress brwhite\x1e\x2d\x2dbackground\x3dcyan
set -U fish_pager_color_secondary_background \x1d
set -U fish_pager_color_secondary_completion \x1d
set -U fish_pager_color_secondary_description \x1d
set -U fish_pager_color_secondary_prefix \x1d
set -U fish_pager_color_selected_background \x2d\x2dbackground\x3dE6B450
set -U fish_pager_color_selected_completion \x1d
set -U fish_pager_color_selected_description \x1d
set -U fish_pager_color_selected_prefix \x1d
# }}}

fish_vi_key_bindings
bind -M default \ce accept-autosuggestion
bind -M insert \ce accept-autosuggestion

complete -c disown -x -a "(__fish_complete_subcommand -u -g)"
complete -c dn -x -a "(__fish_complete_subcommand -u -g)"
fzf_configure_bindings --git_log=\cg --directory=\cf --git_status=\cs

status is-interactive && tabs -4 # https://github.com/jorgebucaran/fisher/issues/747
status is-interactive && zoxide init fish | source

# vim: fdm=marker
