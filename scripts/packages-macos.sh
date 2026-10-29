#!/usr/bin/env bash
# System packages for macOS: Homebrew + packages/Brewfile.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# brew may be installed but not on PATH (a non-login shell over ssh): look in its prefixes first
shellenv() {
	for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
		[ -x $brew ] && eval "$($brew shellenv)" && return
	done
}
shellenv
if ! has brew; then
	log "homebrew"
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	shellenv
fi

log "brew bundle"
# brew bundle has no --no-cask: filter the Brewfile instead. App Store apps go separately:
# without an App Store login they fail, which must not stop the rest.
tmp=$(mktemp -d)
skip='^mas '
[ -n "${BREW_NO_CASKS:-}" ] && skip='^(cask|mas) ' # formulae only (CI)
grep -Ev "$skip" "$DOTFILES/packages/Brewfile" >"$tmp/Brewfile"
brew bundle --file "$tmp/Brewfile"
if [ -z "${BREW_NO_CASKS:-}" ]; then
	log "brew bundle: App Store"
	grep -E '^mas ' "$DOTFILES/packages/Brewfile" >"$tmp/Brewfile.mas"
	brew bundle --file "$tmp/Brewfile.mas" ||
		warn "App Store apps not installed: sign in to the App Store, then ./install.sh packages"
fi
rm -rf "$tmp"
