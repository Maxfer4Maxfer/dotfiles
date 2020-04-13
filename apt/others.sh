#!/bin/bash
set -x

APPS=(
    fzf
    graphviz
    htop
    jq
    kubectx
    kubernetes-cli
    lazygit
    lynx
    modd
    moreutils
    nmap
    ntfs-3g
    openssh
    openssl
    python
    sqlmap
    telnet
    tmux
    tree
    vegeta
    vim -- --with-override-system-vi
    watch
    wget
    wrk
    youtube-dl
)

sudo apt-get install -y "${APPS[@]}"
