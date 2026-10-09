# ~/.zshenv — read by every zsh, including non-interactive ones.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.rover/env" ] && . "$HOME/.rover/env"
