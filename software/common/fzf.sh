#!/bin/sh
set -x

echo "----------------fzf----------------"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --update-rc
