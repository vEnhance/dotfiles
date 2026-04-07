function zola-serve
    zola serve -o /tmp/(basename (pwd)) --force $argv
end
