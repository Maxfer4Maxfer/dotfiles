#!/usr/bin/env bash
# fzf switcher over every tmux pane running Claude Code, bound to prefix+f in tmux.conf.
# Shows the session topic Claude writes into the pane title instead of just the repo,
# sorted by repo, then by tmux session and window.
# Status comes from smilovanovic/tmux-claude's hook (~/.claude/sessions/<pid>.status);
# "unseen" is our own @claude_state=done from status.sh.
set -uo pipefail

tmux=tmux # from PATH: /usr/bin on Linux, Homebrew on macOS
sessions=$HOME/.claude/sessions
kill_key=${TMUX_CLAUDE_KILL_KEY:-ctrl-x}

entries() {
	# '|', not tab: read collapses runs of whitespace separators, so an empty @claude_state would shift
	# fields (and tmux escapes control characters like \x1f). The title is last, so a '|' in it is kept.
	$tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}|#{window_index}|#{pane_pid}|#{pane_current_command}|#{@claude_state}|#{pane_current_path}|#{pane_title}' |
		while IFS='|' read -r target win pane_pid cmd state path title; do
			[[ $cmd == claude ]] || continue
			pid=$(pgrep -P "$pane_pid" -x claude | head -1)
			status=$(cat "$sessions/$pid.status" 2>/dev/null)
			case $status in
			permission) icon='🔐' ;;
			input) icon='⌨️ ' ;;
			error) icon='❌' ;;
			thinking | tool | subagent) icon='⏳' ;;
			compacting) icon='📦' ;;
			starting) icon='🚀' ;;
			*) icon='💤' ;;
			esac
			[[ $state == "done" ]] && icon='✅'
			# Claude prefixes the title with a status glyph (✳ or a spinner) — drop it.
			topic=${title#* }
			[[ $title == *' '* ]] || topic=$title
			# Topic goes last: printf pads bytes, not characters, so Cyrillic can't be column-aligned.
			printf '%s\t%s\t%s %3s  \e[2m%-16.16s\e[0m %s\n' \
				"${path##*/}" "$target" "$icon" "$win" "${path##*/}" "$topic"
		done | sort -t$'\t' -k1,1 -k2,2V | cut -f2-
}

if [[ ${1:-} == --entries ]]; then
	entries
	exit 0
fi

list=$(entries)
if [[ -z $list ]]; then
	echo "No Claude Code sessions in tmux"
	read -r -n 1
	exit 0
fi

selected=$(printf '%s\n' "$list" | fzf \
	--ansi --reverse --no-info \
	--delimiter=$'\t' --with-nth=2.. \
	--border=rounded --border-label=' Claude Code ' \
	--header="enter: switch | ${kill_key}: kill pane | ✅ finished, unseen" \
	--preview="$tmux capture-pane -ep -t {1} -S -60" \
	--preview-window=right:55%:wrap:follow \
	--bind="${kill_key}:execute-silent($tmux kill-pane -t {1})+reload($0 --entries)")

[[ -n $selected ]] || exit 0
$tmux switch-client -t "${selected%%$'\t'*}"
