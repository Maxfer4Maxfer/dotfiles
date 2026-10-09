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
ms=$(zsh -c 'zmodload zsh/datetime; s=$EPOCHREALTIME; zsh -i -c exit >/dev/null 2>&1; printf "%.0f" $(((EPOCHREALTIME - s) * 1000))')
if [ "$ms" -lt 1000 ]; then ok "startup ${ms}ms"; else fail "startup ${ms}ms (>1s)"; fi
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
	sleep 3 # tpm loads plugins asynchronously
	check "continuum hooked into status-right" bash -c "tmux -L $sock show -gv status-right | grep -q continuum_save"
	check "nvim-autokill hook set" bash -c "tmux -L $sock show-hooks -g | grep -q nvim-autokill"
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

log "tools"
tools=(git zsh tmux nvim stow fzf rg jq bat curl go gopls goimports dlv golangci-lint lazygit yq evans grpcurl
	kubectl helm gh terraform cargo uv bun claude)
[ "$OS" = linux ] && tools+=(docker gcloud aws nuclei feroxbuster)
for t in "${tools[@]}"; do
	check "$t" zsh -i -c "whence -p $t || whence $t"
done

echo
if [ "$fails" -eq 0 ]; then log "all checks passed"; else warn "$fails check(s) failed"; exit 1; fi
