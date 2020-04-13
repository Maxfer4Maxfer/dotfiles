#!/bin/bash
set -x

DOTFILES_DIR="$HOME/.dotfiles"
OS=$(uname -s)

git submodule update --init --recursive

######## initial ######## 
case $OS in
    "Darwin")
        echo "----------------brew----------------"
        if [ ! -x "brew" ]; then
            $DOTFILES_DIR/brew/brew.sh
        fi
        ;;
esac

echo "----------------zsh----------------"
case $OS in
    "Darwin")
        $DOTFILES_DIR/brew/zsh.sh
        chsh -s /usr/bin/zsh root
        ;;
    "Linux")
        $DOTFILES_DIR/apt/zsh.sh
        chsh -s /usr/local/bin/zsh root
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
        $DOTFILES_DIR/brew/others.sh
        ;;
    "Linux")
        $DOTFILES_DIR/apt/others.sh
        ;;
esac

echo "----------------vim----------------"
$DOTFILES_DIR/vim/vim.sh $DOTFILES_DIR
echo "----------------tmux----------------"
$DOTFILES_DIR/tmux/tmux.sh $DOTFILES_DIR

######## .config ######## 
if [ -d ~/.config ]; then
    rm -rf ~/.config
fi
ln -s $DOTFILES_DIR/config ~/.config
