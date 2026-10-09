#!/usr/bin/env bash
# User-level tools for both OSes: zsh/tmux/nvim plugins, Go/Rust/JS toolchains, CLIs.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

export PATH="$HOME/.local/bin:$HOME/go/bin:/usr/local/go/bin:$HOME/.cargo/bin:$HOME/.krew/bin:$HOME/.fzf/bin:$PATH"
failed=()

log "oh-my-zsh + theme + plugins"
clone_or_pull https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
clone_or_pull https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

if [ "$OS" = linux ]; then
	log "fzf"
	clone_or_pull https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --bin >/dev/null 2>&1
fi

log "tmux plugins"
clone_or_pull https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# tpm talks to a running server: use a throwaway session (an already running server keeps its sessions)
tmux new-session -d -s tpm-install
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins/"
~/.tmux/plugins/tpm/bin/install_plugins >/dev/null
~/.tmux/plugins/tpm/bin/update_plugins all >/dev/null
tmux kill-session -t tpm-install

log "rust"
if ! has rustup; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path >/dev/null
fi
if [ "$OS" = linux ] && ! has feroxbuster; then
	cargo install --quiet feroxbuster || failed+=(feroxbuster)
fi

log "uv, bun, claude, rover"
has uv || curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh >/dev/null
# SHELL=sh keeps the installer from appending to ~/.zshrc (it lives in this repo)
has bun || [ -x ~/.bun/bin/bun ] || curl -fsSL https://bun.sh/install | SHELL=/bin/sh bash >/dev/null
has claude || curl -fsSL https://claude.ai/install.sh | bash >/dev/null
[ -x ~/.rover/bin/rover ] || curl -sSL https://rover.apollo.dev/nix/latest | sh -s -- --elv2-license accept >/dev/null || failed+=(rover)
# Claude state markers in tmux tabs (theme.conf @claude_mark)
~/.config/claude-tmux/install-hooks.sh || failed+=(claude-tmux-hooks)

log "go tools"
export GOPRIVATE="github.com/farawaygg/*"
go_lists=("$DOTFILES/packages/go.txt")
[ "$OS" = linux ] && go_lists+=("$DOTFILES/packages/go-security.txt")
while read -r pkg flags; do
	# GO_EXCLUDE: regex of modules to skip (e.g. private ones in CI)
	[[ -n ${GO_EXCLUDE:-} && $pkg =~ $GO_EXCLUDE ]] && continue
	# shellcheck disable=SC2086 # flags are intentionally word-split
	go install $flags "$pkg@latest" 2>/dev/null || failed+=("$pkg")
	# GO_CLEAN=1: drop build/module caches after each tool (low-disk containers)
	[ -n "${GO_CLEAN:-}" ] && go clean -cache -modcache
done < <(cat "${go_lists[@]}" | sed -e 's/#.*//' -e '/^[[:space:]]*$/d')

if [ "$OS" = linux ]; then
	# no `go install` for these: replace directives in go.mod / heavy builds — use release binaries
	log "release binaries: terragrunt, logcli, rclone"
	tmp=$(mktemp -d)
	has terragrunt || { curl -fsSL "https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_$ARCH" -o ~/.local/bin/terragrunt && chmod +x ~/.local/bin/terragrunt; } || failed+=(terragrunt)
	has logcli || { curl -fsSL "https://github.com/grafana/loki/releases/latest/download/logcli-linux-$ARCH.zip" -o "$tmp/logcli.zip" &&
		unzip -qo "$tmp/logcli.zip" -d "$tmp" && install -m 755 "$tmp/logcli-linux-$ARCH" ~/.local/bin/logcli; } || failed+=(logcli)
	has rclone || { curl -fsSL "https://downloads.rclone.org/rclone-current-linux-$ARCH.zip" -o "$tmp/rclone.zip" &&
		unzip -qo "$tmp/rclone.zip" -d "$tmp" && install -m 755 "$tmp"/rclone-*/rclone ~/.local/bin/rclone; } || failed+=(rclone)
	rm -rf "$tmp"
fi

log "kubectl krew"
if ! [ -x ~/.krew/bin/kubectl-krew ]; then
	tmp=$(mktemp -d)
	curl -fsSL "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-${OS/macos/darwin}_$ARCH.tar.gz" | tar -xz -C "$tmp"
	"$tmp/krew-${OS/macos/darwin}_$ARCH" install krew >/dev/null 2>&1 && rm -rf "$tmp"
fi
kubectl krew update >/dev/null 2>&1 || true
for plugin in ctx ns df-pv fuzzy images open-svc tree; do
	kubectl krew install "$plugin" >/dev/null 2>&1 || true
done

log "neovim plugins (pinned by lazy-lock.json)"
# Mason's LSP servers / debuggers install on the first interactive start
nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || failed+=(nvim-plugins)

log "tldr cache"
tldr --update >/dev/null 2>&1 || true

if [ ${#failed[@]} -gt 0 ]; then
	warn "failed to install: ${failed[*]}"
	exit 1
fi
