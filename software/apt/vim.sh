#!/bin/bash
set -x

echo "----------------vim----------------"

sudo add-apt-repository -y ppa:jonathonf/vim
sudo apt update
sudo apt install -y vim
