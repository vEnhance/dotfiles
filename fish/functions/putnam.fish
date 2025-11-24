function putnam --description "Grab a statement of a Putnam problem"
    set --function title "Putnam $(string upper "$argv")"
    python ~/dotfiles/py-scripts/putnam.py $argv | bat --file-name $title --language tex
end
