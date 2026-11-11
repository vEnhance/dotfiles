function yap --description "Scribble on the wall at wall.evanchen.cc"
    cd ~/Sync/Websites/wall.evanchen.cc
    git pull
    if /usr/bin/python3 new_post.py
        git show
        set -l push_response
        while true
            read -P "Push to remote and announce? [Y/n] " -l reply
            or set reply n # treat EOF / Ctrl-C as no
            switch (string lower -- (string trim -- "$reply"))
                case '' y yes
                    set push_response yes
                    break
                case n no
                    set push_response no
                    break
            end
        end
        if test "$push_response" = yes
            if git push
                jq "." latest.json
                if /home/evan/dotfiles/py-scripts/wall-announce.py
                    /home/evan/dotfiles/sh-scripts/noisemaker/noisemaker.sh 2 >/dev/null
                else
                    /home/evan/dotfiles/sh-scripts/noisemaker/noisemaker.sh 7 >/dev/null
                end
            else
                /home/evan/dotfiles/sh-scripts/noisemaker/noisemaker.sh 7 >/dev/null
            end
            read -P "Press Enter to dismiss."
        end
    end
end
