#!/bin/sh

APPS=(
    bash
    bat
    ctags
    diffutils
    fd
    ffmpeg
    git
    gnu-time
    graphviz
    htop
    jq
    kubectx
    kubernetes-cli
    lazygit
    lynx
    modd
    moreutils
    nmap
    npm
    ntfs-3g
    openssh
    openssl
    protobuf
    protoc-gen-go
    python
    sqlmap
    telnet
    tldr
    tmux
    tree
    vegeta
    vim -- --with-override-system-vi
    watch
    wget
    wrk
    youtube-dl
    zsh-syntax-highlighting
)

CASKS=(
    appcleaner
    apppolice
    balenaetcher
    caffeine
    dbeaver-community
    docker
    drawio
    dropbox
    osxfuse
    google-backup-and-sync
    google-chrome
    insomnia
    iterm2
    keyboard-cleaner
    logmein-hamachi
    macpass
    opera
    skype
    teamviewer
    telegram-desktop
    the-unarchiver
    transmission
    virtualbox
    vlc
    whatsapp
    xquartz
)

brew install "${APPS[@]}"

for cask in "${CASKS[@]}"
do
    brew install --cask $cask
done

echo '' >> ~/.zshrc
echo '# dotfiles & brew lines' >> ~/.zshrc

brew install zsh-completion
echo 'fpath=(/usr/local/share/zsh-completions $fpath)' >> ~/.zshrc
rm -f ~/.zcompdump; compinit
chmod go-w '/usr/local/share'

brew install bash-completion2
echo '[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"' >>  ~/.bash_profile

brew install coreutils
echo 'PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.zshrc

brew install findutils
echo 'PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"' >> ~/.zshrc

brew install git-lfs
git lfs install
git lfs install --system

brew install go
echo "PATH=\"$HOME/go/bin:\$PATH\"" >> ~/.zshrc
echo "export GOPRIVATE=git.wildberries.ru" >> ~/.zshrc

brew install gnu-sed
echo 'PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.zshrc

brew install gnu-tar
echo 'PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"' >> ~/.zshrc

brew install gnu-time
echo 'PATH="/usr/local/opt/gnu-time/libexec/gnubin:$PATH"' >> ~/.zshrc

brew install grep
echo 'PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"' >> ~/.zshrc

brew install fzf
$(brew --prefix)/opt/fzf/install --key-bindings --completion  --update-rc    
echo 'export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git --exclude __pycache__ --exclude .ropeproject --exclude .pytest_cache"' >> ~/.zshrc

brew install qt
echo 'export PATH="/usr/local/opt/qt/bin:$PATH"' >> ~/.zshrc

brew upgrade

go get -u github.com/jnewmano/grpc-json-prox
