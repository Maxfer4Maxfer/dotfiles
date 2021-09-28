#!/bin/bash
# set -x

DOTFILES_DIR="$HOME/.dotfiles"
OS=$(uname -s)

git submodule update --init --recursive

######## package manager ######## 
case $OS in
    "Darwin")
        echo "----------------brew----------------"
        if [ ! -x "brew" ]; then
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            brew update && brew upgrade
        fi
        ;;
esac

echo "----------------zsh----------------"
$DOTFILES_DIR/zsh/zsh.sh $DOTFILES_DIR

echo "----------------aliases----------------"
if [ -f ~/.aliases ]; then
     rm ~/.aliases
fi
ln -s $DOTFILES_DIR/zsh/aliases ~/.aliases

echo "----------------software----------------"
case $OS in
    "Darwin")
        $DOTFILES_DIR/software/brew.sh
        ;;
    "Linux")
        $DOTFILES_DIR/software/apt.sh
        ;;
esac

$DOTFILES_DIR/software/common.sh

echo "----------------vim----------------"
$DOTFILES_DIR/vim/vim.sh $DOTFILES_DIR

echo "----------------tmux----------------"
$DOTFILES_DIR/tmux/tmux.sh $DOTFILES_DIR

######## .config ######## 
if [ -d ~/.config ]; then
    rm -rf ~/.config
fi
ln -s $DOTFILES_DIR/config ~/.config
