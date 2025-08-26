function yap --description "Scribble on the wall at wall.evanchen.cc"
    cd ~/Sync/Projects/wall.evanchen.cc
    vf activate wall
    if python new_post.py
        git show
        read -P "Push to remote? (y/n): " -l response
        if test "$response" = y -o "$response" = yes
            if git push
                nohup /home/evan/dotfiles/sh-scripts/noisemaker.sh 2 >/dev/null
            else
                nohup /home/evan/dotfiles/sh-scripts/noisemaker.sh 7 >/dev/null
                sleep 10
            end
        else
            nohup /home/evan/dotfiles/sh-scripts/noisemaker.sh 4 >/dev/null
        end
    end
end
