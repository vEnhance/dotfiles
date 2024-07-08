umask 007 # set umask

alias dropcli='dropbox-cli'
alias fixtrailspace='sed -i "s/[ \t]*\$//"'
alias getclip="xsel --clipboard"
alias gg="cd (git rev-parse --show-toplevel)"
alias gpg-loopback="gpg --clearsign --pinentry-mode loopback"
alias gsthaw="gsutil -m setmeta -R -h 'Cache-Control:private, max-age=0, no-transform'"
alias ipv4='ip addr | ag inet -w | ag -w "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"'
alias j-langtool="languagetool --disable COMMA_PARENTHESIS_WHITESPACE,WHITESPACE_RULE,UPPERCASE_SENTENCE_START,LC_AFTER_PERIOD,FILE_EXTENSIONS_CASE,ARROWS,EN_UNPAIRED_BRACKETS,UNLIKELY_OPENING_PUNCTUATION,UNIT_SPACE,ENGLISH_WORD_REPEAT_BEGINNING_RULE,CURRENCY,REP_PASSIVE_VOICE"
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

# PROMPTS {{{
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
    printf determination
    set_color normal
    set_color --italics $fish_color_greeting
    printf ".\n"

    if test (pwd) = "$HOME"
        if test $hostname = ArchScythe
            archey3 --config ~/dotfiles/archey3.cfg --color=green 2>/dev/null
        else if test $hostname = ArchSapphire
            archey3 --config ~/dotfiles/archey3.cfg --color=cyan 2>/dev/null
        else if test $hostname = ArchMajestic
            archey3 --config ~/dotfiles/archey3.cfg --color=magenta 2>/dev/null
        else if test $hostname = ArchBootes
            archey3 --config ~/dotfiles/archey3.cfg --color=magenta 2>/dev/null
        else if test $hostname = ArchDiamond
            archey3 --config ~/dotfiles/archey3.cfg --color=yellow 2>/dev/null
        end
    end

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
        echo -n -s (set_color -b blue white) (basename "$VIRTUAL_ENV" | string sub -l 2) "🐍" (set_color normal)
    end
    if set -q nvm_current_version
        echo -n -s (set_color -b blue white) (string sub -l 3 "$nvm_current_version") "☕" (set_color normal)
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
# }}}

# Exports {{{
export SHELL='/usr/bin/fish'
export EDITOR='nvim'
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
export PYTHONPATH="$PYTHONPATH:$HOME:$HOME/dotfiles/py-scripts/"
export PATH="$PATH:$HOME/dotfiles/bin/"
if test -d /opt/google-cloud-cli
    export CLOUDSDK_ROOT_DIR=/opt/google-cloud-cli
    export CLOUDSDK_PYTHON=/usr/bin/python
    export CLOUDSDK_PYTHON_ARGS=-S
    export PATH="$CLOUDSDK_ROOT_DIR/bin:$PATH"
    export GOOGLE_CLOUD_SDK_HOME="$CLOUDSDK_ROOT_DIR"
end
# }}}

# Drop-in replacements {{{
if test -f /usr/bin/nvim
    alias vim='nvim'
end
if test -f /usr/bin/nvim-qt
    alias gvim='nvim-qt'
end
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
# pikaur hack to automatically disable virtualenvs
function pikaur
    if set -q VIRTUAL_ENV
        set existing_venv (basename $VIRTUAL_ENV)
        echo "Temporarily disabling" (set_color --bold brcyan)"$existing_venv"
        vf deactivate
        set_color normal
        /usr/bin/pikaur $argv
        echo Re-enabling (set_color --bold brcyan)"$existing_venv"
        vf activate "$existing_venv"
        set_color normal
    else
        /usr/bin/pikaur $argv
    end
end
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
alias tsqx='/usr/bin/python3 ~/dotfiles/py-scripts/tsqx.py'
alias viag='/usr/bin/python3 ~/dotfiles/py-scripts/viag.py'
alias von='/usr/bin/python3 -m von'
alias wah='/usr/bin/python3 ~/dotfiles/py-scripts/wah.py'
alias wplatex='/usr/bin/python3 ~/dotfiles/py-scripts/latex2wp.py'
alias wpmd='/usr/bin/python3 ~/dotfiles/py-scripts/markdown2wp.py'
alias xfer='/usr/bin/python3 -m xfer'

alias tu='~/dotfiles/sh-scripts/task-update.sh'
# mailbox aliases
alias mu='~/dotfiles/mutt/open-mail.sh'
alias m1='~/dotfiles/mutt/open-mail.sh -F ~/.config/mutt/neomuttrc.1'
alias m2='~/dotfiles/mutt/open-mail.sh -F ~/.config/mutt/neomuttrc.2'
# }}}

# Encryption / Bitwarden utilities {{{
function aes-encode
    openssl aes-256-cbc -a -salt -pbkdf2 -pass pass:$argv
end
function aes-decode
    openssl aes-256-cbc -a -d -pbkdf2 -pass pass:$argv
end
function bw-unlock
    set_color brpurple
    echo "Enter PIN to continue (or leave blank if none):"
    set_color normal
    read -s -P "[echo hidden]: " USER_PIN
    set MASTER_PASSWORD ""
    if test -n "$USER_PIN"
        set MASTER_PASSWORD (secret-tool lookup type bitwarden user local |
            openssl aes-256-cbc -a -d -pbkdf2 -pass "pass:$USER_PIN")
    end
    if test -z "$MASTER_PASSWORD"
        export BW_SESSION=(bw unlock --raw)
    else
        export BW_SESSION=(bw unlock "$MASTER_PASSWORD" --raw)
    end
    bw status | jq
end
function bw-new
    if test -z "$BW_SESSION"
        echo "First, unlocking the BitWarden vault..."
        bw-unlock
    end

    set password0 (python ~/dotfiles/py-scripts/gen-password.py)
    set password1 (python ~/dotfiles/py-scripts/gen-password.py)
    set password2 (python ~/dotfiles/py-scripts/gen-password.py)
    set password3 (python ~/dotfiles/py-scripts/gen-password.py)
    set password4 (python ~/dotfiles/py-scripts/gen-password.py)
    echo "0. $password0"
    echo "1. $password1"
    echo "2. $password2"
    echo "3. $password3"
    echo "4. $password4"
    echo ------------------------
    read -P "Selected password (empty to take first): " response
    if test -z "$response"
        set new_password $password0
    else if test $response = 0
        set new_password $password0
    else if test $response = 1
        set new_password $password1
    else if test $response = 2
        set new_password $password2
    else if test $response = 3
        set new_password $password3
    else if test $response = 4
        set new_password $password4
    else
        set new_password $response
    end
    set_color brwhite
    echo "Chosen password: $new_password"
    set_color normal
    echo $new_password | xsel --primary
    echo "(copied to primary clipboard)"

    echo ------------------------
    read -P "Username: " new_user
    if test -z "$new_user"
        echo "Error: No user provided"
        return 1
    end
    read -P "Website: " new_uri
    if test -z "$new_uri"
        echo "Error: No URI provided"
        return 1
    end
    set new_name (echo $new_uri |
        sed "s/^https\?\:\/\///" |
        sed "s/\/.*//")
    set revision_date (date -Iseconds --utc)
    set item_login_uri (bw get template item.login.uri |
        jq ".uri=\"$new_uri\"")
    set item_login (bw get template item.login |
        jq ".username=\"$new_user\" |
        .password=\"$new_password\" |
        .passwordRevisionDate=null |
        .uris=[$item_login_uri]"
    )
    set item (bw get template item |
        jq ".name=\"$new_name\" |
        .revisionDate=\"$revision_date\" |
        .notes=null |
        .collectionIds = [] |
        .login = $item_login")
    echo $item | bw encode | bw create item | jq
end
# }}}

# Miscellaneous utility functions {{{
alias bcsum='paste -sd+ - | bc'
alias rot13="tr 'A-Za-z' 'N-ZA-Mn-za-m'"
alias lisp='sbcl --script'
alias swank="sbcl --load ~/.vim/plugged/slimv/slime/start-swank.lisp"

function rs1
    set regex "[abe-hjkn-uwyz]*"(
        echo $argv[1] |
        string lower |
        string split '' |
        string join '[abe-hjkn-uwyz]*'
    )"[abe-hjkn-uwyz]*"
    ag -w $regex $argv[2..]
end
function rs2
    set regex "[abe-hjkn-uwyz]*"(
        echo $argv[1] |
        string lower |
        string split '' |
        string join '[abe-hjkn-uwyz ]*'
    )"[abe-hjkn-uwyz]*"
    ag -w $regex $argv[2..]
end
function pytex -w pythontex
    for x in $argv
        pythontex $x
    end
end
# correct horse battery staple
function chbs
    shuf -n 1000 /usr/share/dict/words | ag "^[a-z]{3,9}\$" | head -n 12
end
# language tool wrapper
function lt -w j-langtool
    j-langtool $argv | cut -c 1-80 | bat -l verilog --wrap=never --paging=never
end
# Create a new TeX file
function newtex
    if string match '*.tex' $argv
        echo "That's probably not what you meant to do"
        return 1
    end
    mkdir "$argv"
    cd "$argv"
    echo '\documentclass[11pt]{scrartcl}' >"$argv.tex"
    echo '\usepackage{evan}' >>"$argv.tex"
    echo '\begin{document}' >>"$argv.tex"
    echo '\title{}' >>"$argv.tex"
    echo '' >>"$argv.tex"
    echo '\end{document}' >>"$argv.tex"
    nvim "$argv.tex"
end
# Shortcut for editors and the like
function pdf -w zathura
    string match '*.pdf' "$argv" >/dev/null
    if test \( -f "$argv" \) -a \( $status -eq 0 \)
        dn zathura $argv &>/dev/null
    else if test -f (echo $argv | cut -f 1 -d '.').pdf
        dn zathura (echo $argv | cut -f 1 -d '.').pdf &>/dev/null
    else if test -f "$argv""pdf"
        dn zathura "$argv""pdf" &>/dev/null
    else if test -f "$argv.pdf"
        dn zathura "$argv.pdf" &>/dev/null
    else
        echo "Cannot found a suitable file."
    end
end

function pdfenc --argument-names infile outfile password
    qpdf --encrypt "$password" "$password" 256 --print=none --modify=none -- $infile $outfile
end
function pdfjoin
    qpdf $argv[1] --pages $argv[1..-2] -- $argv[-1]
end
function pdfsplit
    qpdf --split-pages=1 $argv[1] page%d-$argv[1]
end

function otis-clean
    cd /tmp/junk-for-otis/
    latexmk -C
    rm -f {email,otis}*.{pdf,tex,log,txt,aux,fdb_latexmk,fls,out,pre,synctex.gz,asy,md}
end
# }}}

function hunt # {{{
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
end # }}}

function hub -w gh # {{{
    set -l digits (echo $argv | ag --only-matching "[0-9]+" --nocolor)
    # first decide if we are a PR or an issue
    if test -n "$digits"
        gh issue view $digits &>/dev/null
        if test $status -eq 0
            set flavor issue
        else
            set flavor pr
        end
    end
    if test -z "$argv" -o (echo $argv | cut -c 1) = -
        gh issue list $argv --limit 10
        gh pr list $argv --limit 10
    else if test "$argv" = issue
        gh issue list
    else if test "$argv" = pr
        gh pr list
    else if test "$argv" = "claim $digits"
        gh $flavor edit --add-assignee "@me"
        if command -q bugwarrior-pull
            bugwarrior-pull
        end
    else if test "$argv" = "lb $digits"
        GH_FORCE_TTY=50% gh $flavor view $digits | head -n 8
        set_color --bold cyan
        echo "Choose a label to add..."
        set_color normal
        gh $flavor edit $digits --add-label (GH_FORCE_TTY='50%' gh label list | fzf --height 15 --ansi --header-first --header-lines 3 | sed "s/  /\t/" | cut -f 1)
    else if test "$argv" = "re $digits"
        GH_FORCE_TTY=1 GH_PAGER=cat gh $flavor view --comments $digits | awk -v n=4 'NR <= n { print; next } { delete lines[NR - n]; lines[NR] = $0 } END { for(i = NR - n + 1; i <= NR; ++i) print lines[i] }'
        set_color --bold yellow
        echo "Enter your comment below, or blank to open Vi..."
        set_color normal
        cat >/tmp/gh-comment.txt
        if ag "[^\s]+" /tmp/gh-comment.txt >/dev/null
            gh $flavor comment $digits -F /tmp/gh-comment.txt
        else
            gh $flavor comment $digits
        end
    else if test (echo $argv | cut -d " " -f 1) = "$digits"
        hub $flavor view $argv
    else if test (echo $argv | cut -d " " -f 1) = done
        gh $argv
        bugwarrior-pull &
    else if test (echo $argv | cut -d " " -f 1) = close
        gh $argv
        bugwarrior-pull &
    else
        gh $argv
    end
end # }}}

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

# directory listing customization {{{
if test (uname) = Linux
    function ll
        if test (count *) -gt 1024
            # grep is going to choke anyways, so just list stuff
            ls -l --block-size=K --color=yes $argv
            return
        end
        if test (count *.tex) -eq 0
            ls -l --block-size=K --color=yes $argv
            return
        end
        set --function regex '('(string join '|' (string sub --end=-5 (string escape --style=regex *.tex)))')'
        set --function regex $regex'\.(aux|bbl|bcf|blg|fdb_latexmk|fls|log|maf|mtc0?|nav|out|pre|ptc[0-9]+|pytxcode|pytxmcr|pytxpyg|run\.xml|snm|synctex(\.gz|\(busy\))|toc|von|vrb|xdv)|-[0-9]{1,2}\.(asy|pdf)$'
        set --function regex '('$regex')|pythontex_data\.pkl'
        set num_hidden (ls -l --block-size=K --color=yes $argv | grep -E $regex 2> /dev/null | wc --lines)
        ls -l --block-size=K --color=yes $argv | grep -Ev $regex 2>/dev/null
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

# fish vi key bindings {{{
fish_vi_key_bindings
bind -M default \ce accept-autosuggestion
bind -M insert \ce accept-autosuggestion
function fish_mode_prompt
    if test "$fish_key_bindings" = fish_vi_key_bindings
        or test "$fish_key_bindings" = fish_hybrid_key_bindings
        switch $fish_bind_mode
            case default
                set_color --bold --background red white
                echo N
            case insert
                set_color --bold --background green white
                echo I
            case replace_one
                set_color --bold --background green white
                echo R
            case replace
                set_color --bold --background cyan white
                echo R
            case visual
                set_color --bold --background magenta white
                echo V
        end
        set_color normal
        echo -n ' '
    end
end
# }}}

complete -c disown -x -a "(__fish_complete_subcommand -u -g)"
complete -c dn -x -a "(__fish_complete_subcommand -u -g)"
fzf_configure_bindings --git_log=\cg --directory=\cf --git_status=\cs

status is-interactive && tabs -4 # https://github.com/jorgebucaran/fisher/issues/747
status is-interactive && zoxide init fish | source

# vim: fdm=marker
