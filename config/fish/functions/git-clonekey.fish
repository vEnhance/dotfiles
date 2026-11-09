function git-clonekey --description "git clone using a specific SSH key, and keep it set in the new repo"
    # Usage: git-clonekey KEY URL [DIR] [other git clone args...]
    # KEY is a name in ~/.ssh or a path, as for git-setkey.
    if test (count $argv) -lt 2; or contains -- $argv[1] -h --help
        echo "Usage: git-clonekey KEY URL [DIR] [git clone args...]"
        test (count $argv) -ge 1; and contains -- $argv[1] -h --help
        return
    end

    set -l cmd (__git_setkey_cmd $argv[1] 2>&1)
    or begin
        echo "git-clonekey: $cmd" >&2
        return 1
    end
    # clone -c writes the setting into the new repo before fetching,
    # so it is used for the clone itself and every later fetch/push.
    git clone -c core.sshCommand=$cmd $argv[2..]
end
