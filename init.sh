#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

git submodule update --remote --merge

ln -s $DOTFILES_DIR/vim/pack/plugins ~/.vim/pack/plugins
