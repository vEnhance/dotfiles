function code --description "Starts Claude if we're in a Git repository (but fails otherwise)"
    set git_check_output (git rev-parse --is-inside-work-tree 2> /dev/null)
    if test "$git_check_output" = true
        claude
    else if test "$git_check_output" = false
        echo "Currently in a .git system folder"
    else
        echo "Not in a Git repository"
    end
end
