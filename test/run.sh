#!/usr/bin/env bash
# Entry point of the test container: install from /src (read-only mount of the repo), then smoke test.
set -euo pipefail

mkdir -p ~/.dotfiles
tar -C /src --exclude=./.git --exclude=./config -cf - . | tar -C ~/.dotfiles -xf -

~/.dotfiles/install.sh packages link
# private modules need GitHub auth, which the container does not have;
# GO_CLEAN keeps the go caches from filling the disk
GO_EXCLUDE=farawaygg GO_CLEAN=1 ~/.dotfiles/install.sh tools
~/.dotfiles/test/smoke.sh
