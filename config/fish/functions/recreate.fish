function recreate --description "Copy file to destination, then trash original (preserves setgid group)"
    if test (count $argv) -lt 1
        echo "Usage: recreate <source> [destination]" >&2
        return 1
    end

    set -f source $argv[1]
    set -f dest (test (count $argv) -ge 2; and echo $argv[2]; or echo .)

    cp --no-preserve=mode,ownership $source $dest; or return 1
    gio trash $source
end
