function hub -w gh
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
        if command -q bugwarrior-pull
            bugwarrior-pull &
        end
    else if test (echo $argv | cut -d " " -f 1) = close
        gh $argv
        if command -q bugwarrior-pull
            bugwarrior-pull &
        end
    else
        gh $argv
    end
end
