# ~/.zshrc — managed by ~/.dotfiles (stow package common/zsh).
# Machine-local settings and secrets go to ~/.zshrc.local (not in git).

export LC_ALL=en_US.UTF-8

# OS-specific PATH and tweaks (linux/zsh or macos/zsh package)
[ -f ~/.config/zsh/os.zsh ] && source ~/.config/zsh/os.zsh

typeset -U path
path=(
    $HOME/.local/bin
    $HOME/go/bin
    $HOME/.fzf/bin
    $path
)
export PATH

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
    colored-man-pages
    command-not-found
    docker
    git
    golang
    helm
    kubectl
    tmux
)
[[ $OSTYPE == darwin* ]] && plugins+=(macos)
plugins+=(zsh-syntax-highlighting) # must be the last one
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

source ~/.config/zsh/aliases.zsh

# fzf (key bindings + completion)
command -v fzf >/dev/null && source <(fzf --zsh)

# tmux: over ssh, attach to the last session (or start one) instead of a new session per login
if [[ $SSH_CONNECTION != "" && $TMUX == "" ]]; then
    tmux attach-session 2>/dev/null || tmux new-session
fi

# machine-local secrets & overrides (not in git)
# (if, not &&: without the file the shell would start with exit status 1)
if [ -f ~/.zshrc.local ]; then source ~/.zshrc.local; fi
