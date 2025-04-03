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
