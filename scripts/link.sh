#!/usr/bin/env bash
# Symlink stow packages into $HOME: common/* plus linux/* or macos/*.
# Whatever stands in the way is moved aside as <name>.pre-dotfiles (old symlinks are just removed).
set -euo pipefail
source "$(dirname "$0")/lib.sh"

if [ -L ~/.config ]; then
	warn "~/.config is a symlink (old layout) — run scripts/migrate-config.sh first"
	exit 1
fi
# ~/.claude holds Claude Code's own state: stow must link files into it, never fold it
mkdir -p ~/.config ~/.local/bin ~/.claude

# Dirs used by OS packages are shared with common ones (e.g. ~/.config/zsh): keep them real
# directories, so stow does not fold them into a symlink owned by a single package.
while IFS= read -r dir; do
	[ -L "$HOME/$dir" ] && rm "$HOME/$dir"
	mkdir -p "$HOME/$dir"
done < <(cd "$DOTFILES/$OS" && find . -mindepth 2 -type d | sed 's|^\./[^/]*/||')

owned() { [ -L "$HOME/$2" ] && [[ $(readlink -f "$HOME/$2") == "$(readlink -f "$1")/$2" ]]; }

# clear_path <pkgdir> <rel>: make $HOME/<rel> free for stow.
clear_path() {
	local rel=$2 t=$HOME/$2
	if [ -L "$t" ]; then
		rm "$t"
	elif [ -f "$t" ]; then
		mv "$t" "$t.pre-dotfiles"
		warn "moved existing ~/$rel to ~/$rel.pre-dotfiles"
	fi
}

for group in common "$OS"; do
	for pkgdir in "$DOTFILES/$group"/*/; do
		pkgdir=${pkgdir%/}
		while IFS= read -r rel; do
			# check every path component: a stale symlinked parent blocks stow too
			parent=
			IFS=/ read -ra parts <<<"$rel"
			for part in "${parts[@]}"; do
				parent=${parent:+$parent/}$part
				owned "$pkgdir" "$parent" && break # already linked by stow (file or folded dir)
				clear_path "$pkgdir" "$parent"
			done
		done < <(cd "$pkgdir" && find . -mindepth 1 \( -type f -o -type l \) | sed 's|^\./||')
		log "stow $group/$(basename "$pkgdir")"
		stow --dir "$DOTFILES/$group" --target "$HOME" --restow "$(basename "$pkgdir")"
	done
done
