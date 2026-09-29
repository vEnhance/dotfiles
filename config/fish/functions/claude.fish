function claude --description "Refuses to run Claude Code outside the box (use ccode instead)"
    echo -e "ERROR: You should always run Claude from inside the box on this computer."
    return 1
end
