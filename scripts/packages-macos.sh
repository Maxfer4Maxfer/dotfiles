#!/usr/bin/env bash
# System packages for macOS: Homebrew + packages/Brewfile.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

if ! has brew; then
	log "homebrew"
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
	[ -x $brew ] && eval "$($brew shellenv)" && break
done

log "brew bundle"
brew bundle --file "$DOTFILES/packages/Brewfile" ${BREW_NO_CASKS:+--no-cask}
