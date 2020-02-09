#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

submodule update --init --recursive

#TODO
#Preinstall packages:
#   Rasbian: 
#       https://github.com/ierton/xkb-switch

# Vim
ln -s $DOTFILES_DIR/.vimrc ~/.vimrc
ln -s $DOTFILES_DIR/vim/pack/plugins ~/.vim/pack/plugins
