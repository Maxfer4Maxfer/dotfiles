#!/usr/bin/env bash
# Bootstrap or update a machine from this repo. Idempotent: safe to re-run any time.
#
#   ./install.sh                 # everything: packages, link, tools
#   ./install.sh link            # only (re)create symlinks
#   ./install.sh packages tools  # any subset, in this order
#   ./install.sh system          # Linux dev VM tuning, opt-in (scripts/system-linux.sh)
set -euo pipefail
source "$(dirname "$0")/scripts/lib.sh"

steps=("$@")
[ ${#steps[@]} -eq 0 ] && steps=(packages link tools)

for step in "${steps[@]}"; do
	case $step in
	packages) "$DOTFILES/scripts/packages-$OS.sh" ;;
	link) "$DOTFILES/scripts/link.sh" ;;
	tools) "$DOTFILES/scripts/tools.sh" ;;
	system) [ "$OS" = linux ] || { echo "system: Linux only" >&2 && exit 1; } && "$DOTFILES/scripts/system-linux.sh" ;;
	*) echo "unknown step: $step (expected: packages link tools system)" >&2 && exit 1 ;;
	esac
done
log "done ($OS/$ARCH)"
