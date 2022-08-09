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

######## vim ########
if [ -f ~/.vimrc ]; then
    rm ~/.vimrc
fi
ln -s $DOTFILES_DIR/vim/vimrc ~/.vimrc

if [ ! -d ~/.vim ]; then
    mkdir -p ~/.vim/swaps
    mkdir -p ~/.vim/undo
fi

if [ ! -d ~/.vim/pack ]; then
    mkdir -p ~/.vim/pack
fi

######## plug ########
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [[ $OS == "Darwin" ]]; then
    curl -fLo /usr/local/lib/libxkbswitch.dylib https://raw.githubusercontent.com/myshov/libxkbswitch-macosx/master/bin/libxkbswitch.dylib
    curl -fLo /usr/local/bin/xkbswitch https://raw.githubusercontent.com/myshov/xkbswitch-macosx/master/bin/xkbswitch
    chmod +x /usr/local/bin/xkbswitch
fi

vim -c "execute 'silent PlugInstall' | execute 'qall'"
vim -c "execute 'silent PlugUpdate' | execute 'qall'"

######## golang ########
vim -c "execute 'silent GoUpdateBinaries' | execute 'qall'"
