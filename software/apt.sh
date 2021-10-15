#!/bin/bash
set -x

#    wrk

sudo apt-get update

APPS=(
    bat
    curl
    graphviz
    htop
    jq
    locales
    lynx
    make
    man
    moreutils
    nmap
    ntfs-3g
    openssl
    python
    snapd
    socat
    sqlmap
    telnet
    tldr
    tmux
    tree
    vim 
    watch
    wget
    yq
)

sudo apt-get install -y "${APPS[@]}"

sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LANGUAGE

sudo ln -s /usr/bin/batcat /usr/local/bin/bat

# docker
sudo apt-get remove docker docker-engine docker.io containerd runcv
sudo apt-get update
sudo apt-get install apt-transport-https  ca-certificates  curl  gnupg  lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo addgroup --system docker
sudo adduser $USER docker
newgrp docker

echo 'path=(/snap/bin $path)' >> ~/.zshrc
sudo snap install kubectl --classic

sudo snap install go --classic
echo 'path=($HOME/go/bin $path)' >> ~/.zshrc
echo 'export GOPATH=$(go env GOPATH)' >> ~/.zshrc

echo 'export PATH' >> ~/.zshrc

#fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install


