function yap --description "Scribble on the wall at wall.evanchen.cc"
    cd ~/Sync/Websites/wall.evanchen.cc
    git pull
    if python new_post.py
        git show
        read -P "Push to remote and announce? (y/n): " -l push_response
        if test "$push_response" = y -o "$push_response" = yes
            if git push
                jq "." latest.json
                if python /home/evan/dotfiles/py-scripts/wall-announce.py
                    nohup /home/evan/dotfiles/sh-scripts/noisemaker/noisemaker.sh 2 >/dev/null
                else
                    nohup /home/evan/dotfiles/sh-scripts/noisemaker/noisemaker.sh 7 >/dev/null
                end
            else
                nohup /home/evan/dotfiles/sh-scripts/noisemaker/noisemaker.sh 7 >/dev/null
            end
            read -P "Press Enter to dismiss."
        end
    end
end
