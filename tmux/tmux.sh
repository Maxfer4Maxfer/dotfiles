#!/bin/bash
set -x 

DOTFILES_DIR=$1

######## tmux ########
if [ -f ~/.tmux.conf ]; then
    rm ~/.tmux.conf
fi
ln -s $DOTFILES_DIR/tmux/tmux.conf ~/.tmux.conf

if [ ! -d ~/.tmux/plugins ]; then
    mkdir -p ~/.tmux/plugins
fi

if [ -f ~/.tmux/plugins/tpm ]; then
    rm -rf ~/.tmux/plugins/tpm
fi
ln -s $DOTFILES_DIR/tmux/tpm ~/.tmux/plugins/tpm

~/.tmux/plugins/tpm/bin/install_plugins
~/.tmux/plugins/tpm/bin/update_plugins all

if [ -f ~/.tmux/plugins/tmux-themepack/my.tmuxtheme ]; then
    rm ~/.tmux/plugins/tmux-themepack/my.tmuxtheme
fi
ln -s $DOTFILES_DIR/tmux/my.tmuxtheme ~/.tmux/plugins/tmux-themepack/my.tmuxtheme
