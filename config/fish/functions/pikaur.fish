# pikaur hack to automatically disable virtualenvs
function pikaur
    if set -q VIRTUAL_ENV
        set existing_venv (basename $VIRTUAL_ENV)
        echo "Temporarily disabling" (set_color --bold brcyan)"$existing_venv"
        vf deactivate
        set_color normal
        /usr/bin/pikaur $argv
        echo Re-enabling (set_color --bold brcyan)"$existing_venv"
        vf activate "$existing_venv"
        set_color normal
    else
        /usr/bin/pikaur $argv
    end
end
