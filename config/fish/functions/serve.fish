function serve
    # Check if we're in a git repo
    set git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$git_root"
        set repo_name (basename $git_root)

        if test -f "$git_root/zola.toml"
            env -C $git_root zola serve -o /tmp/$repo_name --force $argv
            return
        end

        if test -f "$git_root/zensical.toml"
            env -C $git_root uv run zensical serve $argv
            return
        end

        if test "$repo_name" = blog.evanchen.cc
            env -C $git_root ./scripts/recent.sh $argv
            return
        end

        if test "$repo_name" = web.evanchen.cc
            env -C $git_root ./scripts/devserver.py $argv
            return
        end

        if test -f "$git_root/manage.py"
            env -C $git_root python manage.py runserver_plus $argv
            return
        end

        for dir in site public output
            if test -d "$git_root/$dir"
                python -m http.server -d $git_root/$dir $argv
                return
            end
        end
    end

    if test (count $argv) -ge 1 && test -d $argv[1]
        python -m http.server -d $argv
    else
        for dir in site public output
            if test -d "$dir"
                python -m http.server -d $dir $argv
                return
            end
        end
        python -m http.server -d . $argv
    end
end
