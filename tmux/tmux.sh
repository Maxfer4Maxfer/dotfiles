#!/bin/bash
set -x 

DOTFILES_DIR=$1

if [[ $DOTFILES_DIR == "" ]]; then
    DOTFILES_DIR="$HOME/.dotfiles"
fi

file(){
    if [ -e $1 ] || [ -L $1 ]; then
        rm -fR $1
    fi
}

echo "----------------tmux----------------"

file ~/.tmux.conf
ln -s $DOTFILES_DIR/tmux/tmux.conf ~/.tmux.conf

if [ ! -d ~/.tmux/plugins ]; then
    mkdir -p ~/.tmux/plugins
fi 

file ~/.tmux/plugins/tpm
ln -s $DOTFILES_DIR/tmux/tpm ~/.tmux/plugins/tpm

export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/"
~/.tmux/plugins/tpm/bin/install_plugins
~/.tmux/plugins/tpm/bin/update_plugins all

file ~/.tmux/plugins/tmux-themepack/my.tmuxtheme
ln -s $DOTFILES_DIR/tmux/my.tmuxtheme ~/.tmux/plugins/tmux-themepack/my.tmuxtheme

rm -fR  /tmp/tmux-1000
