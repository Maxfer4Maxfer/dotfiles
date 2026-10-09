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

# pinned <bin> <version> <github-repo> <tag> <asset> <checksums-asset>: install a release binary
# into ~/.local/bin unless `<bin> --version` already reports <version>; sha256 is verified.
# A .zip asset holds the binary under the name <bin>; any other asset is the binary itself.
pinned() {
	local bin=$1 ver=$2 base="https://github.com/$3/releases/download/$4" asset=$5 sums=$6 tmp
	"$bin" --version 2>/dev/null | head -1 | grep -qF "$ver" && return 0
	tmp=$(mktemp -d)
	if curl -fsSL "$base/$asset" -o "$tmp/$asset" && curl -fsSL "$base/$sums" -o "$tmp/sums" &&
		(cd "$tmp" && grep -E " [*]?$asset\$" sums | shasum -a 256 -c --status -); then
		if [[ $asset == *.zip ]]; then
			unzip -qo "$tmp/$asset" "$bin" -d "$tmp" && install -m 755 "$tmp/$bin" ~/.local/bin/"$bin"
		else
			install -m 755 "$tmp/$asset" ~/.local/bin/"$bin"
		fi
	else
		warn "$bin $ver: download or checksum failed"
		false
	fi
	local rc=$?
	rm -rf "$tmp"
	return $rc
}

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
