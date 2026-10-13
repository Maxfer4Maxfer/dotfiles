#!/usr/bin/env bash
# User-level tools for both OSes: zsh/tmux/nvim plugins, Go/Rust/JS toolchains, CLIs.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

export PATH="$HOME/.local/bin:$HOME/go/bin:/usr/local/go/bin:$HOME/.cargo/bin:$HOME/.fzf/bin:$PATH"
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

log "uv, claude"
has uv || curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh >/dev/null
has claude || curl -fsSL https://claude.ai/install.sh | bash >/dev/null
# Claude state markers in tmux tabs (theme.conf @claude_mark)
~/.config/claude-tmux/install-hooks.sh || failed+=(claude-tmux-hooks)

log "go tools"
while read -r pkg flags; do
	# shellcheck disable=SC2086 # flags are intentionally word-split
	go install $flags "$pkg@latest" 2>/dev/null || failed+=("$pkg")
	# GO_CLEAN=1: drop build/module caches after each tool (low-disk containers)
	[ -n "${GO_CLEAN:-}" ] && go clean -cache -modcache
done < <(list "$DOTFILES/packages/go.txt")

if [ "$OS" = linux ]; then
	# no `go install` for these: replace directives in go.mod / heavy builds — use release binaries
	log "release binaries: rclone"
	tmp=$(mktemp -d)
	has rclone || { curl -fsSL "https://downloads.rclone.org/rclone-current-linux-$ARCH.zip" -o "$tmp/rclone.zip" &&
		unzip -qo "$tmp/rclone.zip" -d "$tmp" && install -m 755 "$tmp"/rclone-*/rclone ~/.local/bin/rclone; } || failed+=(rclone)
	rm -rf "$tmp"
fi

log "IaC: tofu, terragrunt, tflint"
# Pinned on purpose: bump deliberately, together with the IaC repos that use them.
TOFU_VERSION=1.12.6
TERRAGRUNT_VERSION=1.1.5
TFLINT_VERSION=0.64.0
pinned tofu "$TOFU_VERSION" opentofu/opentofu "v$TOFU_VERSION" \
	"tofu_${TOFU_VERSION}_${OS/macos/darwin}_$ARCH.zip" "tofu_${TOFU_VERSION}_SHA256SUMS" || failed+=(tofu)
pinned terragrunt "$TERRAGRUNT_VERSION" gruntwork-io/terragrunt "v$TERRAGRUNT_VERSION" \
	"terragrunt_${OS/macos/darwin}_$ARCH" SHA256SUMS || failed+=(terragrunt)
pinned tflint "$TFLINT_VERSION" terraform-linters/tflint "v$TFLINT_VERSION" \
	"tflint_${OS/macos/darwin}_$ARCH.zip" checksums.txt || failed+=(tflint)

log "neovim plugins (pinned by lazy-lock.json)"
# Mason's LSP servers / debuggers install on the first interactive start
nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || failed+=(nvim-plugins)

log "tldr cache"
tldr --update >/dev/null 2>&1 || true

if [ ${#failed[@]} -gt 0 ]; then
	warn "failed to install: ${failed[*]}"
	exit 1
fi
