function ranger-cd
    if test -z "$RANGER_LEVEL"
        set tempfile "/tmp/(whoami)chosendir"
        ranger --choosedir=$tempfile (pwd)
        if test -f $tempfile
            if [ (cat $tempfile) != (pwd) ]
                cd (cat $tempfile)
            end
        end
        rm -f $tempfile
    else
        exit
    end
end
