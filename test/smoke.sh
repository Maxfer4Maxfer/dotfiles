#!/usr/bin/env bash
# Smoke test of an installed machine: links, shell, tmux, nvim, tools.
# Runs on a real machine and in the test container alike.
set -uo pipefail
source "$(dirname "$0")/../scripts/lib.sh"

fails=0
ok() { printf '  \033[32mok\033[0m   %s\n' "$1"; }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fails=$((fails + 1)); }
check() { local name=$1; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else fail "$name"; fi; }

log "links"
for group in common "$OS"; do
	for pkgdir in "$DOTFILES/$group"/*/; do
		while IFS= read -r rel; do
			[[ $(readlink -f "$HOME/$rel") == "$(readlink -f "$pkgdir$rel")" ]] || fail "~/$rel is not linked to $group/$(basename "$pkgdir")"
		done < <(cd "$pkgdir" && find . -type f | sed 's|^\./||')
	done
done
[ "$fails" -eq 0 ] && ok "all package files are linked into \$HOME"

# zi <cmd>: run cmd in an interactive zsh inside a pseudo-terminal, like a real terminal window
# (without a tty zsh disables job control/zle and p10k does not load)
zi() {
	if [ "$OS" = macos ]; then
		script -q /dev/null zsh -i -c "$1"
	else
		script -qec "zsh -i -c $(printf %q "$1")" /dev/null
	fi
}

log "zsh"
err=$(zi exit 2>&1 | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g; s/\x1b\][^\a]*\a//g' | tr -d '\r' | grep -iE 'error|not found|no such|can.t')
if [ -z "$err" ]; then ok "starts without errors"; else fail "startup errors: $err"; fi
# best of 3 warm starts; SMOKE_ZSH_MAX_MS raises the limit on slow CI runners
ms=$(zsh -c 'zmodload zsh/datetime; best=999999; repeat 3 { s=$EPOCHREALTIME; zsh -i -c exit >/dev/null 2>&1; t=$(((EPOCHREALTIME - s) * 1000)); ((t < best)) && best=$t }; printf "%.0f" $best')
max=${SMOKE_ZSH_MAX_MS:-1000}
if [ "$ms" -lt "$max" ]; then ok "startup ${ms}ms"; else fail "startup ${ms}ms (>${max}ms)"; fi
check "powerlevel10k theme loaded" zi '(( $+functions[p10k] ))'
check "syntax highlighting loaded" zi '(( $+functions[_zsh_highlight] ))'
check "aliases loaded" zi 'whence kpc && whence kg'
check "fzf key bindings" zi '(( $+widgets[fzf-history-widget] ))'
check "os-specific config loaded" test -f ~/.config/zsh/os.zsh

log "git"
check "user identity" test -n "$(git config user.email)"
check "gh credential helper" bash -c 'git config --get-all credential.https://github.com.helper | grep -q "gh auth git-credential"'

log "tmux"
sock=smoke-$$
# A side server on the real config would run continuum's auto-restore: the whole saved layout,
# Claude sessions included. continuum skips it while this file exists.
halt=~/tmux_no_auto_restore
own_halt=
if [ ! -e $halt ]; then touch $halt && own_halt=1; fi
if tmux -L $sock -f ~/.tmux.conf new-session -d -s smoke 2>/dev/null; then
	ok "config loads"
	# continuum autosaves only on the single tmux server: with the main one running it rightly
	# leaves this side server alone, so check the main server when there is one.
	check "continuum hooked into status-right" bash -c "{ tmux show -gv status-right 2>/dev/null || tmux -L $sock show -gv status-right; } | grep -q continuum_save"
	check "nvim-autokill hook set" bash -c "tmux -L $sock show-hooks -g | grep -q nvim-autokill"
	# -u: without a UTF-8 locale (CI container) the client prints Cyrillic keys as _
	check "russian layout keys mirrored" bash -c "tmux -u -L $sock list-keys -T prefix | grep -q ' ы '"
	check "claude tab markers in window format" bash -c "tmux -L $sock show -gv window-status-format | grep -q claude_mark"
	tmux -L $sock kill-server 2>/dev/null
	rm -f "${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/$sock" # kill-server can leave the socket file behind
else
	fail "config loads"
fi
if [ -n "$own_halt" ]; then rm -f $halt; fi
check "claude tmux hooks registered" bash -c "jq -e '.hooks.Stop[]?.hooks[]? | select(.command | contains(\"claude-tmux/status.sh\"))' ~/.claude/settings.json >/dev/null"
for p in tpm tmux-resurrect tmux-continuum tmux-yank tmux-thumbs tmux-claude; do
	check "plugin $p installed" test -d ~/.tmux/plugins/$p
done

log "neovim"
check "starts and loads lazy.nvim" nvim --headless "+lua assert(require('lazy'))" +qa
missing=$(nvim --headless "+lua for _, p in ipairs(require('lazy').plugins()) do if not p._.installed then io.stdout:write(p.name, ' ') end end" +qa 2>/dev/null)
if [ -z "$missing" ]; then ok "all plugins installed"; else fail "plugins not installed: $missing"; fi

# only where `install.sh system` ran (not in the test container or on macOS)
if [ -f /etc/sysctl.d/99-devstation.conf ]; then
	log "system"
	check "zram swap on" grep -q '^/dev/zram' /proc/swaps
	check "swappiness 150" test "$(cat /proc/sys/vm/swappiness)" = 150
	check "inotify watches raised" test "$(cat /proc/sys/fs/inotify/max_user_watches)" -ge 524288
	check "virtio disks without I/O scheduler" bash -c '! grep -L "\[none\]" /sys/block/vd*/queue/scheduler | grep -q .'
	left=$(list "$DOTFILES/packages/apt-purge.txt" | installed | tr '\n' ' ')
	if [ -z "$left" ]; then ok "nothing from apt-purge.txt installed"; else fail "installed again: $left"; fi
fi

log "tools"
tools=(git zsh tmux nvim stow fzf rg jq bat curl go gopls goimports dlv golangci-lint lazygit yq evans grpcurl
	kubectl helm gh tofu terragrunt tflint cargo uv claude)
[ "$OS" = linux ] && tools+=(docker gcloud aws)
for t in "${tools[@]}"; do
	check "$t" zsh -i -c "whence -p $t || whence $t"
done

echo
if [ "$fails" -eq 0 ]; then log "all checks passed"; else warn "$fails check(s) failed"; exit 1; fi
