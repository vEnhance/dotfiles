function git-setkey --description "Set core.sshCommand of the current git repo to use a specific SSH key"
    # Usage:
    #   git-setkey id_example   use ~/.ssh/id_example for this repo
    #   git-setkey path/to/key  use an explicit key path
    #   git-setkey              show the current setting
    #   git-setkey --unset      remove the setting
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "git-setkey: not inside a git repository" >&2
        return 1
    end

    if test (count $argv) -eq 0
        set -l current (git config --local --get core.sshCommand)
        if test -n "$current"
            echo $current
        else
            echo "core.sshCommand not set for this repo"
        end
        return 0
    end

    if test (count $argv) -gt 1
        echo "git-setkey: expected exactly one key" >&2
        return 1
    end

    switch $argv[1]
        case -h --help
            echo "Usage: git-setkey [KEY | PATH | --unset]"
            return 0
        case --unset
            git config --local --unset core.sshCommand
            and echo "Unset core.sshCommand"
            return
    end

    set -l cmd (__git_setkey_cmd $argv[1] 2>&1)
    or begin
        echo "git-setkey: $cmd" >&2
        return 1
    end
    git config --local core.sshCommand $cmd
    and echo "core.sshCommand = $cmd"
end
