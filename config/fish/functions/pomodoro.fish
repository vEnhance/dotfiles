function pomodoro
    i3-msg '[class="^(?!Anki)"] move scratchpad'

    i3-msg workspace 8
    xterm -bg black -fg white -fa "Inconsolata Condensed ExtraBold" -fs 14 \
        -e "termdown 25m -b -t END --exec-cmd \"if [ '{0}' == '1' ]; then sleep 1 && $HOME/dotfiles/sh-scripts/noisemaker/noisemaker.sh B; fi\"" &

    ~/dotfiles/sh-scripts/noisemaker/noisemaker.sh H
    set now (date +%Y%m%d-%H%M%S)
    mkdir -p /tmp/pomodoro
    touch "/tmp/pomodoro/$now.md"

    i3-msg split h
    i3-sensible-terminal -e nvim "/tmp/pomodoro/$now.md" >/dev/null 2>&1 &
end
