#!/bin/bash
set -x

DOTFILES_DIR="$HOME/.dotfiles"

git submodule update --init --recursive

#TODO
#Preinstall packages:
#   Rasbian: 
#       https://github.com/ierton/xkb-switch

######## brew ######## 
if [ ! -x "brew" ]; then
	"$DOTFILES_DIR/brew/brew.sh"
fi

######## zsh ######## 
"$DOTFILES_DIR/brew/zsh.sh"
"$DOTFILES_DIR/zsh/oh-my-zsh.sh"

if [ -f ~/.zshrc ]; then
     rm ~/.zshrc
fi
# ln -s $DOTFILES_DIR/zsh/zshrc ~/.zshrc
echo "source $DOTFILES_DIR/zsh/oh-my-zshrc" > ~/.zshrc

if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
    rm -fr ~/.oh-my-zsh/custom/themes/powerlevel10k
fi
ln -s $DOTFILES_DIR/zsh/oh-my-zsh/custom/themes/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k

if [ -f ~/.p10k.zsh ]; then
    rm ~/.p10k.zsh
fi
ln -s $DOTFILES_DIR/zsh/p10k.zsh ~/.p10k.zsh


######## brew: others ######## 
"$DOTFILES_DIR/brew/others.sh"


######## Vim ######## 
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

if [ -d ~/.vim/pack/plugins ]; then
    rm -rf ~/.vim/pack/plugins
fi
ln -s $DOTFILES_DIR/vim/pack/plugins ~/.vim/pack/plugins

if [ -d ~/.vim/colors ]; then
    rm -rf ~/.vim/colors
fi
ln -s $DOTFILES_DIR/vim/colors ~/.vim/colors

######## .config ######## 
if [ -d ~/.config ]; then
    rm -rf ~/.config
fi
ln -s $DOTFILES_DIR/config ~/.config
