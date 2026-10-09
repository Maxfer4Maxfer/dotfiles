#!/usr/bin/env bash
# System packages for Ubuntu: apt (+ third-party repos), Go, Neovim, AWS CLI.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

export DEBIAN_FRONTEND=noninteractive
# shellcheck disable=SC1091
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

# apt_repo <name> <key-url> <deb-line>: install the signing key and the source list.
apt_repo() {
	local name=$1 key_url=$2 line=$3 key=/etc/apt/keyrings/$1.gpg tmp
	tmp=$(mktemp)
	curl -fsSL "$key_url" -o "$tmp"
	# keys come either ASCII-armored or already binary
	if grep -q 'BEGIN PGP' "$tmp"; then gpg --dearmor --yes -o "$tmp.gpg" "$tmp"; else cp "$tmp" "$tmp.gpg"; fi
	sudo install -m 644 "$tmp.gpg" "$key" && rm -f "$tmp" "$tmp.gpg"
	echo "deb [arch=$ARCH signed-by=$key] $line" | sudo tee "/etc/apt/sources.list.d/$name.list" >/dev/null
}

log "apt: base"
# Drop list files of the old layout first: their keys and hosts are gone, and apt-get update
# would fail on them (different key paths would also conflict with the new lists).
sudo rm -f /etc/apt/sources.list.d/{google-cloud-sdk,helm-stable-debian,cloudflare-client,github-cli}.list
# terraform is gone (rift-iac runs OpenTofu, installed by tools.sh): drop its repo
sudo rm -f /etc/apt/sources.list.d/hashicorp.list /etc/apt/keyrings/hashicorp.gpg
# kubectl comes from google-cloud-cli (a dispatcher that runs the kubectl matching the cluster);
# the pkgs.k8s.io package of the same name lost to it on version anyway
sudo rm -f /etc/apt/sources.list.d/kubernetes.list /etc/apt/keyrings/kubernetes.gpg
sudo apt-get update -qq
sudo apt-get install -y -qq ca-certificates curl gnupg lsb-release
sudo install -m 0755 -d /etc/apt/keyrings

log "apt: third-party repositories"
apt_repo docker https://download.docker.com/linux/ubuntu/gpg \
	"https://download.docker.com/linux/ubuntu $CODENAME stable"
apt_repo githubcli https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	"https://cli.github.com/packages stable main"
apt_repo google-cloud https://packages.cloud.google.com/apt/doc/apt-key.gpg \
	"https://packages.cloud.google.com/apt cloud-sdk main"
apt_repo helm https://packages.buildkite.com/helm-linux/helm-debian/gpgkey \
	"https://packages.buildkite.com/helm-linux/helm-debian/any/ any main"
apt_repo cloudflare-warp https://pkg.cloudflareclient.com/pubkey.gpg \
	"https://pkg.cloudflareclient.com/ $CODENAME main"

log "apt: packages"
sudo apt-get update -qq
mapfile -t pkgs < <(list "$DOTFILES/packages/apt.txt")
pkgs+=(
	docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	gh google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin
	helm kubectl cloudflare-warp
)
sudo apt-get install -y -qq "${pkgs[@]}"
sudo apt-get autoremove -y -qq

log "locale"
sudo locale-gen en_US.UTF-8 >/dev/null

log "go"
GO_LATEST=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)
if [ "$(/usr/local/go/bin/go env GOVERSION 2>/dev/null)" != "$GO_LATEST" ]; then
	curl -fsSL "https://go.dev/dl/$GO_LATEST.linux-$ARCH.tar.gz" -o /tmp/go.tgz
	sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go.tgz && rm /tmp/go.tgz
fi
/usr/local/go/bin/go version

log "neovim"
NVIM_ARCH=$([ "$ARCH" = amd64 ] && echo x86_64 || echo arm64)
NVIM_LATEST=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | sed -n 's/.*"tag_name": *"\(v[^"]*\)".*/\1/p')
if [ "$(nvim --version 2>/dev/null | head -1 | awk '{print $2}')" != "$NVIM_LATEST" ]; then
	curl -fsSL "https://github.com/neovim/neovim/releases/download/$NVIM_LATEST/nvim-linux-$NVIM_ARCH.tar.gz" -o /tmp/nvim.tgz
	sudo rm -rf "/opt/nvim-linux-$NVIM_ARCH" && sudo tar -C /opt -xzf /tmp/nvim.tgz && rm /tmp/nvim.tgz
	sudo ln -sf "/opt/nvim-linux-$NVIM_ARCH/bin/nvim" /usr/local/bin/nvim
fi
nvim --version | head -1

log "aws cli"
if ! has aws; then
	AWS_ARCH=$([ "$ARCH" = amd64 ] && echo x86_64 || echo aarch64)
	tmp=$(mktemp -d)
	curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$AWS_ARCH.zip" -o "$tmp/aws.zip"
	unzip -q "$tmp/aws.zip" -d "$tmp" && sudo "$tmp/aws/install" && rm -rf "$tmp"
fi

log "user groups & shell"
sudo usermod -aG docker "$USER"
mkdir -p ~/.local/bin
has bat || ln -sf /usr/bin/batcat ~/.local/bin/bat
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
	sudo chsh -s "$(command -v zsh)" "$USER"
fi
