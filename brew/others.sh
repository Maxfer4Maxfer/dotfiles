#!/bin/sh

APPS=(
    bash
    bat
    ffmpeg
    fzf
    git
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
    openssh
    openssl
    python
    sqlmap
    telnet
    tmux
    tree
    vegeta
    vim -- --with-override-system-vi
    watch
    wget
    wrk
    youtube-dl
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
    forticlient
    google-backup-and-sync
    google-chrome
    insomnia
    iterm2
    keyboard-cleaner
    logmein-hamachi
    macpass
    opera
    private-eye
    skype
    teamviewer
    telegram
    telegram-desktop
    the-unarchiver
    transmission
    vlc
    whatsapp
    xquartz
)

brew install "${APPS[@]}"

for cask in "${CASKS[@]}"
do
    brew cask install $cask
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

brew install grep
echo 'PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"' >> ~/.zshrc

brew install qt
echo 'export PATH="/usr/local/opt/qt/bin:$PATH"' >> ~/.zshrc

brew upgrade
