function gist
    argparse --name=gist 'd/description=' -- $argv
    or return 1

    if test (count $argv) -ne 1
        echo "gist: expected exactly 1 argument, got "(count $argv) >&2
        echo "Usage: gist [-d|--description <text>] <basename>" >&2
        return 1
    end

    if string match --regex --quiet '\.[^./]+$' -- $argv[1]
        set --function filename $argv[1]
        set --function base (path basename -E $filename)
    else
        set --function base $argv[1]
        set --function filename $argv[1].md
    end

    set --function desc_flag
    if set --query _flag_description
        set desc_flag --desc "$_flag_description"
    end

    # Create empty gist and extract URL
    set --function url (echo -e "Type your content here." | gh gist create --filename "$filename" $desc_flag | string trim)

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
