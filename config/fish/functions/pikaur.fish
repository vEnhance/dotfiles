function pikaur
    if set -q VIRTUAL_ENV
        env -u VIRTUAL_ENV PATH=(string join : (string match -v "$VIRTUAL_ENV/bin" $PATH)) /usr/bin/pikaur $argv
    else
        /usr/bin/pikaur $argv
    end
end
