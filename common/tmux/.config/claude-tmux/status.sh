#!/usr/bin/env bash
# Claude Code hook: mark the tmux window this Claude runs in with its state, so the
# status bar shows which tabs are working and which wait for you.
#   status.sh working  — a prompt was submitted / a tool ran
#   status.sh done     — Claude finished its turn (cleared when you open the window)
#   status.sh ask      — Claude is blocked on you: a permission prompt or a question
#   status.sh off      — the session ended
# The window-status formats in ~/.config/tmux/theme.conf render @claude_state.
[[ -n ${TMUX_PANE:-} ]] || exit 0
cat >/dev/null # drain the hook's JSON payload

tmux=tmux # from PATH: /usr/bin on Linux, Homebrew on macOS
case ${1:-} in
off) $tmux set -wu -t "$TMUX_PANE" @claude_state 2>/dev/null ;;
working | done | ask) $tmux set -w -t "$TMUX_PANE" @claude_state "$1" 2>/dev/null ;;
esac
exit 0
