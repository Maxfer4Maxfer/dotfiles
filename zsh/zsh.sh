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

######## zsh ########
wget -O - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

echo "source $DOTFILES_DIR/zsh/oh-my-zshrc" > ~/.zshrc
echo "export TERM=xterm-256color" >> ~/.zshrc
echo "source $HOME/.aliases" >> ~/.zshrc

if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
    rm -fr ~/.oh-my-zsh/custom/themes/powerlevel10k
fi
ln -s $DOTFILES_DIR/zsh/oh-my-zsh/custom/themes/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k

if [ -f ~/.p10k.zsh ]; then
    rm ~/.p10k.zsh
fi
ln -s $DOTFILES_DIR/zsh/p10k.zsh ~/.p10k.zsh

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/
