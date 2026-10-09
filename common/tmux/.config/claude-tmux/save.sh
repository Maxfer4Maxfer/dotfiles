#!/usr/bin/env bash
# tmux-resurrect post-save hook: remember which Claude session runs in which pane,
# so restore.sh can bring each one back with `claude --resume <id>`.
set -uo pipefail

# Only the main server (socket "default"). A side server started with this config (tmux -L x)
# would otherwise overwrite sessions.tsv or resume every Claude session a second time.
[[ ${TMUX%%,*} == */default ]] || exit 0

state=${XDG_STATE_HOME:-$HOME/.local/state}/claude-tmux
mkdir -p "$state"
tmp=$(mktemp "$state/sessions.XXXXXX")

tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}	#{pane_pid}	#{pane_current_command}' |
	while IFS=$'\t' read -r target pane_pid cmd; do
		[[ $cmd == claude ]] || continue
		pid=$(pgrep -P "$pane_pid" -x claude | head -1)
		[[ -n $pid ]] || continue
		# Claude Code keeps the live session id of each process here (updated on /clear, /resume).
		sid=$(jq -r '.sessionId // empty' "$HOME/.claude/sessions/$pid.json" 2>/dev/null)
		[[ -n $sid ]] || continue
		# Keep the original flags (e.g. --dangerously-skip-permissions), drop any resume/continue ones.
		read -ra argv < <(ps -o args= -p "$pid")
		args=()
		skip=0
		for a in "${argv[@]:1}"; do
			if ((skip)); then
				skip=0
				[[ $a == -* ]] || continue
			fi
			case $a in
			--resume | -r | --session-id) skip=1 ;;
			--resume=* | --session-id=* | --continue | -c) ;;
			*) args+=("$a") ;;
			esac
		done
		printf '%s\t%s\t%s\n' "$target" "$sid" "${args[*]}"
	done >"$tmp"

mv "$tmp" "$state/sessions.tsv"
