function fish_greeting
    set_color --italics $fish_color_greeting
    printf "Hello "
    set_color --bold $fish_color_name
    printf $USER
    set_color normal
    set_color --italics $fish_color_host
    printf @
    printf (hostname)
    set_color $fish_color_greeting
    printf "! You are filled with "
    set_color --bold $fish_color_determination
    printf determination
    set_color normal
    set_color --italics $fish_color_greeting
    printf ".\n"

    if test (pwd) = "$HOME"
        if test $hostname = ArchScythe
            archey3 --config ~/dotfiles/archey3.cfg --color=green 2>/dev/null
        else if test $hostname = ArchSapphire
            archey3 --config ~/dotfiles/archey3.cfg --color=cyan 2>/dev/null
        else if test $hostname = ArchMajestic
            archey3 --config ~/dotfiles/archey3.cfg --color=magenta 2>/dev/null
        else if test $hostname = ArchBootes
            archey3 --config ~/dotfiles/archey3.cfg --color=magenta 2>/dev/null
        else if test $hostname = ArchDiamond
            archey3 --config ~/dotfiles/archey3.cfg --color=yellow 2>/dev/null
        end
    end

    set_color --italics $fish_color_date
    printf "It is "
    printf (date +'%a %d %b %Y, %R %Z')
    printf ".\n"
    set_color normal
end
