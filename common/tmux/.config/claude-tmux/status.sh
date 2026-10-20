#!/usr/bin/env bash
# Claude Code hook: mark the tmux window this Claude runs in with its state, so the
# status bar shows which tabs are working and which wait for you.
#   status.sh working  — a prompt was submitted / a tool ran
#   status.sh done     — Claude finished its turn (cleared when you open the window)
#   status.sh ask      — Claude is blocked on you: a permission prompt or a question
#   status.sh off      — the session ended
# The window-status formats in ~/.config/tmux/theme.conf render @claude_state.
payload=$(cat) # the hook's JSON

# A background session (a job the Claude in a pane parked) runs outside tmux, without
# $TMUX_PANE. ~/.claude/sessions/<pid>.json link it to that pane: the job's own file has its
# sessionId and jobId, the parking Claude's has parkedJobId and "tmux": "<session>:@<win>.%<pane>".
parked_pane() {
	local sid job pid where
	sid=$(jq -r '.session_id // empty' <<<"$payload" 2>/dev/null)
	[ -n "$sid" ] || return 0
	job=$(jq -r --arg s "$sid" 'select(.sessionId == $s) | .jobId // empty' ~/.claude/sessions/*.json 2>/dev/null | head -1)
	[ -n "$job" ] || return 0
	jq -r --arg j "$job" 'select(.parkedJobId == $j and .tmux) | "\(.pid) \(.tmux)"' ~/.claude/sessions/*.json 2>/dev/null |
		while read -r pid where; do
			kill -0 "$pid" 2>/dev/null && { echo "${where##*.}"; break; }
		done
}

pane=${TMUX_PANE:-$(parked_pane)}
[[ -n $pane ]] || exit 0

tmux=tmux # from PATH: /usr/bin on Linux, Homebrew on macOS
case ${1:-} in
off) $tmux set -wu -t "$pane" @claude_state 2>/dev/null ;;
working | done | ask) $tmux set -w -t "$pane" @claude_state "$1" 2>/dev/null ;;
esac
exit 0
