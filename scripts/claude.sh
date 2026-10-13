#!/usr/bin/env bash
# Claude Code: settings from claude/ merged into ~/.claude/settings.json, plugins installed.
# A merge, not a symlink: Claude Code writes that file itself (/model, "always allow", hooks).
# Repo keys win, permissions.allow is a union, everything else in the file is kept.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

settings=$HOME/.claude/settings.json
mkdir -p "${settings%/*}"
[ -f "$settings" ] || echo '{}' >"$settings"

layers=("$DOTFILES/claude/settings.json")
[ -f "$DOTFILES/claude/settings-$OS.json" ] && layers+=("$DOTFILES/claude/settings-$OS.json")
merged=$(jq -s '
	reduce .[] as $l ({}; . * $l | .permissions.allow = ((.permissions.allow // []) + ($l.permissions.allow // []) | unique)) |
	if .permissions.allow == [] then del(.permissions.allow) else . end
' "$settings" "${layers[@]}")
# compare key-sorted: rewrite only when something actually changed
if [ "$(jq -S . <<<"$merged")" != "$(jq -S . "$settings")" ]; then
	printf '%s\n' "$merged" >"$settings" # keep the file's mode (0600)
	log "claude: settings updated"
fi

# plugins enabled in the settings but not installed yet
jq -r '.enabledPlugins // {} | to_entries[] | select(.value) | .key' "$settings" | while read -r id; do
	claude plugin list --json 2>/dev/null | jq -e --arg id "$id" 'any(.id == $id)' >/dev/null && continue
	market=${id#*@}
	if ! claude plugin marketplace list 2>/dev/null | grep -q "$market"; then
		[ "$market" = claude-plugins-official ] && claude plugin marketplace add anthropics/claude-plugins-official >/dev/null
	fi
	log "claude: plugin $id"
	claude plugin install "$id" >/dev/null
done
