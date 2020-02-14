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

if [ ! -d ~/.vim ]; then
    mkdir -p ~/.vim/pack
    mkdir -p ~/.vim/swaps
    mkdir -p ~/.vim/undo
fi

if [ ! -d ~/.vim/pack ]; then
    mkdir -p ~/.vim/pack
fi
if [ -d ~/.vim/pack/plugins ]; then
    rm ~/.vim/pack/plugins
fi
ln -s $DOTFILES_DIR/vim/pack/plugins ~/.vim/pack/plugins

if [ -d ~/.vim/colors ]; then
    rm ~/.vim/colors
fi
ln -s $DOTFILES_DIR/vim/colors ~/.vim/colors
