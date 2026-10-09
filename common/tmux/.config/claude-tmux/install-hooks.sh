#!/usr/bin/env bash
# Register status.sh as Claude Code hooks in ~/.claude/settings.json (idempotent: our old
# entries are dropped first, everything else in the file is kept). Run by scripts/tools.sh.
set -euo pipefail

settings=$HOME/.claude/settings.json
cmd='~/.config/claude-tmux/status.sh'

mkdir -p "${settings%/*}"
[ -f "$settings" ] || echo '{}' >"$settings"

tmp=$(mktemp)
jq --arg cmd "$cmd" '
def ours: (.hooks // []) | any(.command | startswith($cmd));
def h($state): [{"type": "command", "command": ($cmd + " " + $state), "timeout": 5}];
.hooks = ((.hooks // {}) | map_values(map(select(ours | not)))) |
.hooks |= reduce ({
	"SessionStart":     [{"hooks": h("off")}],
	"UserPromptSubmit": [{"hooks": h("working")}],
	"PostToolUse":      [{"hooks": h("working")}],
	"PreToolUse":       [{"matcher": "AskUserQuestion", "hooks": h("ask")}],
	"Notification":     [{"matcher": "permission_prompt|elicitation_dialog", "hooks": h("ask")}],
	"Stop":             [{"hooks": h("done")}],
	"SessionEnd":       [{"hooks": h("off")}]
} | to_entries[]) as $e (.; .[$e.key] = ((.[$e.key] // []) + $e.value))
' "$settings" >"$tmp"
cat "$tmp" >"$settings" # keep the file's mode (it may be 0600)
rm "$tmp"
