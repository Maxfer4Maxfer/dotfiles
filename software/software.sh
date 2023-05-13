#!/bin/bash
# set -x

DOTFILES_DIR=$1

if [[ $DOTFILES_DIR == "" ]]; then
    DOTFILES_DIR="$HOME/.dotfiles"
fi

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
