# ~/.zshrc — managed by ~/.dotfiles (stow package common/zsh).
# Machine-local settings and secrets go to ~/.zshrc.local (not in git).

export LC_ALL=en_US.UTF-8

# OS-specific PATH and tweaks (linux/zsh or macos/zsh package)
[ -f ~/.config/zsh/os.zsh ] && source ~/.config/zsh/os.zsh

typeset -U path
path=(
    $HOME/.local/bin
    $HOME/bin
    $HOME/go/bin
    ${KREW_ROOT:-$HOME/.krew}/bin
    $HOME/.bun/bin
    $HOME/.fzf/bin
    $path
)
export PATH

# golang
export GOPRIVATE="github.com/farawaygg/*"

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

# tmux: attach automatically over ssh
if [[ $SSH_CONNECTION != "" && $TMUX == "" ]]; then
    tmux
fi

export TERM=xterm-256color

# bun
export BUN_INSTALL="$HOME/.bun"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# machine-local secrets & overrides (not in git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
