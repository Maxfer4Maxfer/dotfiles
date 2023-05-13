#!/bin/bash
set -x 

DOTFILES_DIR=$1

if [[ $DOTFILES_DIR == "" ]]; then
    DOTFILES_DIR="$HOME/.dotfiles"
fi

echo "----------------zsh----------------"
OS=$(uname -s)
case $OS in
    "Darwin")
        brew install zsh
        ;;
    "Linux")
        sudo apt install -y zsh
        ;;
esac

echo "----------------oh-my-zsh----------------"
wget -O - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
    rm -fr ~/.oh-my-zsh/custom/themes/powerlevel10k
fi
ln -s $DOTFILES_DIR/zsh/oh-my-zsh/custom/themes/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k

if [ -f ~/.p10k.zsh ]; then
    rm ~/.p10k.zsh
fi
ln -s $DOTFILES_DIR/zsh/p10k.zsh ~/.p10k.zsh

git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/


echo "----------------zshrc----------------"
if [ -f ~/.zshrc ]; then
     rm ~/.zshrc
fi
ln -s $DOTFILES_DIR/zsh/zshrc ~/.zshrc
source ~/.zshrc


chsh -s $(which zsh)
