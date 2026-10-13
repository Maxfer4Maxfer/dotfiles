#!/usr/bin/env bash
# macOS settings: defaults, iTerm2 preferences from the repo, launch agents.
# Idempotent: writes only what differs and restarts only the apps whose settings changed.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

restart=()

# def [-currentHost] <domain> <key> <type> <value> [app to restart]
def() {
	local host=()
	[ "$1" = -currentHost ] && host=(-currentHost) && shift
	local domain=$1 key=$2 type=$3 value=$4 app=${5:-} want=$4
	[ "$type" = -bool ] && { [ "$value" = true ] && want=1 || want=0; }
	# ${host[@]+…}: an empty array under set -u is an error in macOS bash 3.2
	[ "$(defaults ${host[@]+"${host[@]}"} read "$domain" "$key" 2>/dev/null)" = "$want" ] && return 0
	defaults ${host[@]+"${host[@]}"} write "$domain" "$key" "$type" "$value"
	if [ -n "$app" ]; then restart+=("$app"); fi
}

log "defaults: dock, finder"
def com.apple.dock autohide -bool true Dock
def com.apple.dock tilesize -int 67 Dock
def com.apple.dock show-recents -bool false Dock
def com.apple.dock mru-spaces -bool false Dock
def com.apple.finder FXPreferredViewStyle -string Nlsv Finder
def NSGlobalDomain AppleShowAllExtensions -bool true Finder

log "defaults: keyboard, trackpad"
def NSGlobalDomain KeyRepeat -int 2
def NSGlobalDomain InitialKeyRepeat -int 15
def NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
def com.apple.HIToolbox AppleFnUsageType -int 0
def com.apple.AppleMultitouchTrackpad Clicking -bool true
def com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
def -currentHost NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# Russian next to the default ABC layout (takes effect after the next login)
if ! defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -q '"KeyboardLayout Name" = Russian'; then
	defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
		'<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>19456</integer><key>KeyboardLayout Name</key><string>Russian</string></dict>'
fi

log "defaults: screenshots -> ~/vm_shared/screenshots (shared with the dev VM)"
mkdir -p ~/vm_shared/screenshots
def com.apple.screencapture location -string "$HOME/vm_shared/screenshots" SystemUIServer

log "iTerm2: preferences from $DOTFILES/iterm2"
def com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES/iterm2"
def com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

log "launch agents"
mkdir -p ~/Library/LaunchAgents ~/Library/Logs
for tpl in "$DOTFILES"/launchd/*.plist; do
	label=$(basename "$tpl" .plist)
	dst=~/Library/LaunchAgents/$label.plist
	rendered=$(sed "s|\$HOME|$HOME|g" "$tpl")
	if [ "$rendered" != "$(cat "$dst" 2>/dev/null)" ]; then
		launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
		printf '%s\n' "$rendered" >"$dst"
	fi
	launchctl print "gui/$(id -u)/$label" >/dev/null 2>&1 ||
		launchctl bootstrap "gui/$(id -u)" "$dst" || warn "could not load $label"
done

if [ ${#restart[@]} -gt 0 ]; then
	log "restart: $(printf '%s\n' "${restart[@]}" | sort -u | tr '\n' ' ')"
	printf '%s\n' "${restart[@]}" | sort -u | xargs -n1 killall 2>/dev/null || true
fi
