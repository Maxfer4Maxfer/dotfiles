#!/usr/bin/env bash
# Bootstrap or update a machine from this repo. Idempotent: safe to re-run any time.
#
#   ./install.sh                 # everything: packages, link, tools (+ system on macOS)
#   ./install.sh link            # only (re)create symlinks
#   ./install.sh packages tools  # any subset, in this order
#   ./install.sh system          # macOS settings / Linux dev VM tuning (opt-in on Linux)
set -euo pipefail
source "$(dirname "$0")/scripts/lib.sh"

steps=("$@")
if [ ${#steps[@]} -eq 0 ]; then
	steps=(packages link tools)
	# macOS settings are safe to apply everywhere; the Linux system step purges packages, so it stays opt-in
	[ "$OS" = macos ] && steps+=(system)
fi

for step in "${steps[@]}"; do
	case $step in
	packages) "$DOTFILES/scripts/packages-$OS.sh" ;;
	link) "$DOTFILES/scripts/link.sh" ;;
	tools) "$DOTFILES/scripts/tools.sh" ;;
	system) "$DOTFILES/scripts/system-$OS.sh" ;;
	*) echo "unknown step: $step (expected: packages link tools system)" >&2 && exit 1 ;;
	esac
done
log "done ($OS/$ARCH)"
