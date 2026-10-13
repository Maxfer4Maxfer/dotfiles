#!/usr/bin/env bash
# One-time migration from the old layout, where ~/.config was a symlink to ~/.dotfiles/config,
# to stow packages. Safe to re-run: every step checks whether it is still needed.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

if [ -L ~/.config ] && [ "$(readlink -f ~/.config)" = "$DOTFILES/config" ]; then
	log "~/.config: symlink -> real directory"
	# same filesystem: a rename, nothing is copied; the gap without ~/.config is a few ms
	mv "$DOTFILES/config" ~/.config.migrating
	rm ~/.config && mv ~/.config.migrating ~/.config
fi

# Copies of files that now come from stow packages: drop them when identical to the repo,
# otherwise keep the local version next to it.
for rel in nvim htop evans claude-tmux git/ignore jesseduffield/lazygit/config.yml; do
	t=~/.config/$rel
	[ -e "$t" ] || [ -L "$t" ] || continue
	[ -L "$t" ] && { rm "$t"; continue; }
	src=
	for s in "$DOTFILES"/common/*/.config/"$rel"; do [ -e "$s" ] && src=$s && break; done
	if [ -n "$src" ] && diff -rq "$t" "$src" >/dev/null; then
		rm -r "$t"
	else
		mv "$t" "$t.pre-dotfiles"
		warn "~/.config/$rel differs from the repo, kept as ~/.config/$rel.pre-dotfiles"
	fi
done

# Home links of the old layout that have no successor.
for f in ~/.aliases ~/.vimrc; do
	if [ -L "$f" ] && [[ $(readlink "$f") == "$DOTFILES"/* ]]; then rm "$f"; fi
done

log "migration done, now run: ./install.sh link"
