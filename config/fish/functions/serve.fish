function serve
    if test (count $argv) -ge 1 && test -d $argv[1]
        python -m http.server -d $argv
    else
        python -m http.server -d . $argv
    end
end
