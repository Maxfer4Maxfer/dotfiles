#!/bin/bash
set -x

sudo apt update

APPS=(
    bat
    curl
    graphviz
    htop
    jid
    jq
    locales
    lynx
    make
    man-db
    moreutils
    nmap
    ntfs-3g
    openssl
    python3
    silversearcher-ag
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
    zsh
)

sudo apt install -y "${APPS[@]}"
sudo apt autoremove

if [ -f /usr/local/bin/bat ]; then
     sudo rm /usr/local/bin/bat
fi
sudo ln -s /usr/bin/batcat /usr/local/bin/bat

echo "------------Locale & Timezone------------"
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LANGUAGE
sudo timedatectl set-timezone Europe/Moscow

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
gopackage="go1.19.linux-amd64.tar.gz"
curl -sSO https://go.dev/dl/${gopackege}
rm -rf /usr/local/go && tar -C /usr/local -xzf ${gopackege}
echo 'path=(/usr/local/go/bin $path)' >> ~/.zshrc
echo 'export GOPATH=$(go env GOPATH)' >> ~/.zshrc
rm -f ${gopackage}

sudo apt autoremove
echo 'export PATH' >> ~/.zshrc
