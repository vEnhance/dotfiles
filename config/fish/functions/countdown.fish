function countdown
    xterm \
        -bg black -fg white -fa "Inconsolata Condensed ExtraBold" -fs 14 \
        -e "echo 'TIMER: $argv'; read -P 'Press enter to start... '; termdown $argv[..] -b -t END --exec-cmd \"if [ '{0}' == '1' ]; then sleep 1 && $HOME/dotfiles/sh-scripts/noisemaker.sh B; fi\"" &
end
