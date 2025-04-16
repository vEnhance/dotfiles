function gist
    set -l filename $argv[1]
    set -l desc (string join " " $argv[2..-1])

    if test -z "$filename"
        echo "Usage: gist <filename> [description]"
        return 1
    end

    # Create empty gist and extract URL
    set -l url (echo -e "Type your content here." | gh gist create --filename "$filename" --desc "$desc" | string trim)

    # Extract Gist ID from URL
    set -l gist_id (basename $url)

    # Clone it
    gh gist clone $gist_id

    # Rename directory
    set -l base (path basename -E $filename)
    mv $gist_id $base
    echo "Cloned to: $base"

    cd $base
    git remote set-url origin git@gist.github.com:$gist_id.git

    xdg-open $url
end
