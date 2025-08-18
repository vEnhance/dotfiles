function yap --description "Scribble on the wall"
    cd ~/Sync/Projects/wall.evanchen.cc
    if python new_post.py
        git show
        read -P "Push to remote? (y/n): " -l response
        if test "$response" = y -o "$response" = yes
            git push
            ~/dotfiles/sh-scripts/noisemaker.sh 3
        else
            ~/dotfiles/sh-scripts/noisemaker.sh 4
        end
    end
end
