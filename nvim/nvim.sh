#!/bin/bash
set -x 

DOTFILES_DIR=$1

if [[ $DOTFILES_DIR == "" ]]; then
    DOTFILES_DIR="$HOME/.dotfiles"
fi

file(){
    if [ -e $1 ] || [ -L $1 ]; then
        rm $1
    fi
}

echo "----------------neovim----------------"
if [ -f ~/.config/nvim ]; then
    rm ~/.config/nvim
fi
ln -s $DOTFILES_DIR/nvim/config ~/.config/nvim


echo "----------------installing plugins via lazy.nvim----------------"
nvim --headless "+Lazy! sync" +qa
