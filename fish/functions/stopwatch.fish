function stopwatch
    xterm \
        -bg black -fg white -fa "Inconsolata Condensed ExtraBold" -fs 14 \
        -e "echo 'STOPWATCH: $argv'; read -P 'Press enter to start... '; termdown $argv[..] -b"
end
