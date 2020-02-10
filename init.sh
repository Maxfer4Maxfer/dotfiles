#!/bin/bash
set -x

DOTFILES_DIR="$HOME/.dotfiles"

git submodule update --init --recursive

#TODO
#Preinstall packages:
#   Rasbian: 
#       https://github.com/ierton/xkb-switch

# Vim
if [ -f ~/.vimrc ]; then
    rm ~/.vimrc
fi
ln -s $DOTFILES_DIR/.vimrc ~/.vimrc

if [ -d ~/.vim/pack/plugins ]; then
    rm ~/.vim/pack/plugins
fi
ln -s $DOTFILES_DIR/vim/pack/plugins ~/.vim/pack/plugins
