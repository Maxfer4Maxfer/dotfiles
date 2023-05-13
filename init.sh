#!/bin/bash
set -x

DOTFILES_DIR="$HOME/.dotfiles"
OS=$(uname -s)

git submodule update --init --recursive

echo "----------------aliases----------------"
if [ -f ~/.aliases ]; then
     rm ~/.aliases
fi
ln -s $DOTFILES_DIR/aliases ~/.aliases

echo "----------------general----------------"
case $OS in
    "Darwin")
        echo "----------------brew----------------"
        if [ ! -x "brew" ]; then
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            brew update && brew upgrade
        fi
        ;;
    "Linux")
        sudo locale-gen en_US.UTF-8
        sudo update-locale LANG=en_US.UTF-8 LANGUAGE
        sudo timedatectl set-timezone Europe/Moscow
        ;;
esac

$DOTFILES_DIR/zsh/zsh.sh $DOTFILES_DIR
$DOTFILES_DIR/software/software.sh $DOTFILES_DIR
$DOTFILES_DIR/vim/vim.sh $DOTFILES_DIR
$DOTFILES_DIR/tmux/tmux.sh $DOTFILES_DIR

echo "---------------config---------------"
if [ -d ~/.config ]; then
    rm -rf ~/.config
fi
ln -s $DOTFILES_DIR/config ~/.config
