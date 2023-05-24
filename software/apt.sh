#!/bin/bash
set -x

DOTFILES_DIR="$HOME/.dotfiles"

echo "----------------software-apt----------------"

$DOTFILES_DIR/software/apt/common.sh
$DOTFILES_DIR/software/apt/bat.sh
$DOTFILES_DIR/software/apt/docker.sh
$DOTFILES_DIR/software/apt/golang.sh
$DOTFILES_DIR/software/apt/helm.sh
$DOTFILES_DIR/software/apt/kubectl.sh
$DOTFILES_DIR/software/apt/vim.sh
$DOTFILES_DIR/software/apt/xrdp.sh
$DOTFILES_DIR/software/apt/yq.sh

sudo apt autoremove
