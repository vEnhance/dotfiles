# https://puzzmon.world/story?cutscene=fate%27s_thread_casino_intro
function fate
    echo (set_color --bold green)"✨💖 Don't think, just pull! 🎰🪙"(set_color normal)
    echo "================================="
    for i in */.git
        set dir (dirname $i)
        if not git -C $dir remote | string length -q
            echo "$i (no remote, skipping)"
            continue
        end
        set -l branch (git -C $dir branch --show-current)
        set -l ahead (git -C $dir rev-list --count @{u}..HEAD 2>/dev/null; or echo 0)
        set -l behind (git -C $dir rev-list --count HEAD..@{u} 2>/dev/null; or echo 0)
        set -l staged (git -C $dir diff --cached --numstat 2>/dev/null | count)
        set -l dirty (git -C $dir diff --numstat 2>/dev/null | count)
        set -l untracked (git -C $dir ls-files --others --exclude-standard 2>/dev/null | count)

        set -l status_parts
        test $ahead -gt 0; and set -a status_parts (set_color cyan)"↑$ahead"(set_color normal)
        test $behind -gt 0; and set -a status_parts (set_color cyan)"↓$behind"(set_color normal)
        test $staged -gt 0; and set -a status_parts (set_color green)"●$staged"(set_color normal)
        test $dirty -gt 0; and set -a status_parts (set_color red)"✚$dirty"(set_color normal)
        test $untracked -gt 0; and set -a status_parts (set_color blue)"…$untracked"(set_color normal)

        set -l status_str ""
        if test (count $status_parts) -gt 0
            set status_str " "(string join " " $status_parts)
        end

        echo (set_color --bold blue)$i(set_color normal) (set_color yellow)"($branch)"(set_color normal)$status_str

        if test $dirty -gt 0 -o $staged -gt 0
            echo (set_color red)"Skipping: dirty working tree"(set_color normal)
            continue
        end
        git -C $dir pull
    end
end
