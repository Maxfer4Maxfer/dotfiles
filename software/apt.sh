#!/bin/bash
set -x

#    wrk
#    bat
#    kubectx 

sudo apt-get update

APPS=(
    curl
    graphviz
    htop
    jq
    locales
    lynx
    man
    moreutils
    nmap
    ntfs-3g
    openssl
    python
    snapd
    sqlmap
    telnet
    tmux
    tree
    vim 
    watch
    wget
)

sudo apt-get install -y "${APPS[@]}"

sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LANGUAGE

# https://docs.docker.com/engine/install/debian/
sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo 'path=(/snap/bin $path)' >> ~/.zshrc
sudo snap install kubectl --classic

sudo snap install go --classic
echo 'path=($HOME/go/bin $path)' >> ~/.zshrc

echo 'export PATH' >> ~/.zshrc

#fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install


