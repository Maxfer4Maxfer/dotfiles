#!/usr/bin/env bash
# tmux-resurrect post-restore hook: resume every Claude session save.sh recorded,
# each in the pane it was running in.
set -uo pipefail

# Only the main server (socket "default"). A side server started with this config (tmux -L x)
# would otherwise overwrite sessions.tsv or resume every Claude session a second time.
[[ ${TMUX%%,*} == */default ]] || exit 0

file=${XDG_STATE_HOME:-$HOME/.local/state}/claude-tmux/sessions.tsv
[[ -f $file ]] || exit 0

while IFS=$'\t' read -r target sid args; do
	[[ -n $target && -n $sid ]] || continue
	tmux send-keys -t "$target" "claude ${args:+$args }--resume $sid" Enter 2>/dev/null
done <"$file"
