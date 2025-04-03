function hunt
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
