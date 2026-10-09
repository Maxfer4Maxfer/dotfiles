# macOS-specific shell setup, sourced first from ~/.zshrc.

# Homebrew: /opt/homebrew on Apple Silicon, /usr/local on Intel
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x $brew ] && eval "$($brew shellenv)" && break
done

# Prefer GNU tools over the BSD ones shipped with macOS
if [ -n "$HOMEBREW_PREFIX" ]; then
    for pkg in coreutils findutils gnu-sed gnu-tar grep; do
        path=($HOMEBREW_PREFIX/opt/$pkg/libexec/gnubin $path)
    done
    fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
fi

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git --exclude __pycache__ --exclude .pytest_cache"
