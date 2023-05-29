#!/bin/bash
set -x

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
    plantuml
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

sudo apt update
sudo apt install -y "${APPS[@]}"
sudo apt autoremove
