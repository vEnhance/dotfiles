function countdown
    ghostty -e fish -c "echo 'TIMER: $argv'; read -P 'Press enter to start... '; termdown $argv[..] -b -t END --exec-cmd \"if [ '{1}' == '1' ]; then sleep 1 && $HOME/dotfiles/sh-scripts/noisemaker/noisemaker.sh B; fi\"" &
end
