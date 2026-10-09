# Shared helpers, sourced by the other scripts.
# shellcheck shell=bash

DOTFILES=${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}

case $(uname -s) in
Linux) OS=linux ;;
Darwin) OS=macos ;;
*) echo "unsupported OS: $(uname -s)" >&2 && exit 1 ;;
esac

case $(uname -m) in
x86_64 | amd64) ARCH=amd64 ;;
aarch64 | arm64) ARCH=arm64 ;;
*) echo "unsupported arch: $(uname -m)" >&2 && exit 1 ;;
esac

export DOTFILES OS ARCH

log() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!! %s\033[0m\n' "$*" >&2; }

# Run as root without requiring sudo (e.g. in containers).
sudo() { if [ "$(id -u)" -eq 0 ]; then "$@"; else command sudo "$@"; fi; }

has() { command -v "$1" >/dev/null 2>&1; }

# Package list file -> names (drops comments and blank lines).
list() { sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$1"; }

# clone_or_pull <url> <dir>: shallow clone, or fast-forward an existing clone.
# A symlink at <dir> (left over from the old submodule layout) is replaced by a clone.
clone_or_pull() {
	local url=$1 dir=$2
	[ -L "$dir" ] && rm "$dir"
	if [ -d "$dir/.git" ]; then
		git -C "$dir" pull --quiet --ff-only || warn "could not update $dir"
	else
		git clone --quiet --depth 1 "$url" "$dir"
	fi
}
