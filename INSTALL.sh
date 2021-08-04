#!/bin/sh

# Use at your own risk ;)
# makes many symlinks

cd ~/dotfiles/py3status
make

cd ~
mv .bashrc .bashrc.bak

# symlink in home
ln -s ~/dotfiles/agignore ~/.aignore
ln -s ~/dotfiles/asy ~/.asy
ln -s ~/dotfiles/bashrc ~/.bashrc
ln -s ~/dotfiles/chktexrc ~/.chktexrc
ln -s ~/dotfiles/gitconfig ~/.gitconfig
ln -s ~/dotfiles/latexmkrc ~/.latexmkrc
ln -s ~/dotfiles/screenrc ~/.screenrc
# ln -s ~/dotfiles/ssh ~/.ssh
ln -s ~/dotfiles/taskrc ~/.taskrc
ln -s ~/dotfiles/texmf ~/.texmf
ln -s ~/dotfiles/vimrc ~/.vimrc
ln -s ~/dotfiles/xprofile ~/.xprofile
echo "[ -f ~/.xprofile ] && . ~/.xprofile" > ~/.xinitrc
echo "exec i3" > ~/.xinitrc

# file/dir in .config
mkdir -p .config
ln -s ~/dotfiles/fish ~/.config/fish
ln -s ~/dotfiles/i3 ~/.config/i3
ln -s ~/dotfiles/mutt ~/.config/mutt
ln -s ~/dotfiles/picom.conf ~/.config/picom.conf
ln -s ~/dotfiles/qutebrowser ~/.config/qutebrowser
ln -s ~/dotfiles/rofi ~/.config/rofi

# nested config
mkdir -p ~/.config/dunst
ln -s ~/dotfiles/dunst/dunstrc ~/.config/dunst/dunstrc
mkdir -p ~/.config/proselint
ln -s ~/dotfiles/vim/proselintrc ~/.config/proselint/config
mkdir -p ~/.config/zathura
ln -s ~/dotfiles/zathurarc ~/.config/zathura/zathurarc
mkdir -p ~/.config/py3status
ln -s ~/dotfiles/py3status/py3status.$(hostname).conf ~/.config/py3status/config
mkdir -p ~/.vit
ln -s ~/dotfiles/vit-config.ini ~/.vit/config.ini
mkdir -p ~/.config/gtk-3.0
ln -s ~/dotfiles/gtk3-config.ini ~/.config/gtk-3.0/settings.ini

# vim
mkdir -p ~/.vim/tmp/
mkdir -p ~/.vim/after
ln -s ~/dotfiles/vim/after/ftplugin ~/.vim/after/ftplugin
ln -s ~/dotfiles/vim/autoload ~/.vim/autoload
ln -s ~/dotfiles/vim/colors ~/.vim/colors
ln -s ~/dotfiles/vim/coc-settings.json ~/.vim/coc-settings.json
mkdir ~/dotfiles/vim/spell
ln -s ~/dotfiles/vim/spell ~/.vim/spell

# systemd
mkdir -p ~/.config/systemd/user
for i in $(ls -D ~/dotfiles/custom-systemd-units/*); do
	ln -s $i ~/.config/systemd/user/
done
