#!/bin/sh
set -x

DOTFILES_DIR="$HOME/.dotfiles"

echo "------------software-common----------"

$DOTFILES_DIR/software/common/fzf.sh
$DOTFILES_DIR/software/common/golang.sh
$DOTFILES_DIR/software/common/helm.sh
$DOTFILES_DIR/software/common/kubectl.sh
$DOTFILES_DIR/software/common/tldr.sh
