function yap --description "Scribble on the wall"
    cd ~/Sync/Projects/wall.evanchen.cc
    if python new_post.py
        git show
    end
end
