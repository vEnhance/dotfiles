function gist
    if string match --regex --quiet '\.[^./]+$' -- $argv[1]
        set --function filename $argv[1]
        set --function base (path basename -E $filename)
    else
        set --function base $argv[1]
        set --function filename $argv[1].md
    end
    set --function desc (string join " " $argv[2..-1])

    if test -z "$filename"
        echo "Usage: gist <basename> [description]"
        return 1
    end

    # Create empty gist and extract URL
    set --function url (echo -e "Type your content here." | gh gist create --filename "$filename" --desc "$desc" | string trim)

    # Extract Gist ID from URL
    set --function gist_id (basename $url)

    # Clone it
    gh gist clone $gist_id

    # Rename directory
    mv $gist_id $base
    echo "Cloned to: $base"

    cd $base
    git remote set-url origin git@gist.github.com:$gist_id.git

    xdg-open $url
end
