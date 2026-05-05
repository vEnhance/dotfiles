function yap --description "Scribble on the wall at wall.evanchen.cc"
    cd ~/Sync/Websites/wall.evanchen.cc
    git pull
    if python new_post.py
        git show
        read -P "Push to remote? (y/n): " -l push_response
        if test "$push_response" = y -o "$push_response" = yes
            if git push
                jq "." latest.json
                read -P "Email to everyone? (y/n): " -l email_response
                if test "$email_response" = y -o "$email_response" = yes
                    if python /home/evan/dotfiles/py-scripts/wall-email.py
                        nohup /home/evan/dotfiles/sh-scripts/noisemaker/noisemaker.sh 2 >/dev/null
                    else
                        nohup /home/evan/dotfiles/sh-scripts/noisemaker/noisemaker.sh 7 >/dev/null
                    end
                end
            else
                nohup /home/evan/dotfiles/sh-scripts/noisemaker/noisemaker.sh 7 >/dev/null
                sleep 10
            end
        end
    end
end
