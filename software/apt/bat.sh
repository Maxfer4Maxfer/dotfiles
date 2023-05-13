#!/bin/bash
set -x

echo "------------bat------------"

sudo apt install -y bat
if [ -f /usr/local/bin/bat ]; then
     sudo rm /usr/local/bin/bat
fi
sudo ln -s /usr/bin/batcat /usr/local/bin/bat
