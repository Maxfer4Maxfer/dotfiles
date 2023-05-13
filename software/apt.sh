#!/bin/bash
set -x

sudo apt update

APPS=(
    atop
    curl
    fzf
    graphviz
    htop
    jid
    jq
    locales
    lynx
    make
    man-db
    moreutils
    mysql-client-core-8.0
    nmap
    nmon
    ntfs-3g
    openssl
    postgresql-client
    python3
    python3-pip
    silversearcher-ag
    snapd
    socat
    sqlmap
    telnet
    tldr
    tmate
    tmux
    tree
    universal-ctags
    watch
    wget
    zsh
)

sudo apt install -y "${APPS[@]}"
sudo apt autoremove

echo "------------Locale & Timezone------------"
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LANGUAGE
sudo timedatectl set-timezone Europe/Moscow

echo "------------bat------------"
sudo apt install -y bat
if [ -f /usr/local/bin/bat ]; then
     sudo rm /usr/local/bin/bat
fi
sudo ln -s /usr/bin/batcat /usr/local/bin/bat

echo "----------------vim----------------"
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update
sudo apt install -y vim

echo "----------------docker----------------"
sudo apt remove docker docker-engine docker.io containerd runc
sudo apt update
sudo apt autoremove
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

echo "----------------kubectl----------------"
sudo apt install -y apt-transport-https
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl

echo "----------------snap----------------"
echo 'path=(/snap/bin $path)' >> ~/.zshrc

echo "----------------yq----------------"
sudo snap install yq

echo "----------------golang----------------"
gopackage="go1.20.4.linux-amd64.tar.gz"
curl -fsSLO https://go.dev/dl/${gopackage}
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf ${gopackage}
echo 'path=(/usr/local/go/bin $path)' >> ~/.zshrc
echo 'path=($HOME/go/bin $path)' >> ~/.zshrc
echo 'export GOPATH=$(go env GOPATH)' >> ~/.zshrc
rm -f ${gopackage}

sudo apt autoremove
echo 'export PATH' >> ~/.zshrc
