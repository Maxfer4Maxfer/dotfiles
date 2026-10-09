# Linux-specific shell setup, sourced first from ~/.zshrc.

path=(/usr/local/go/bin /snap/bin $path)

# Debian/Ubuntu ship bat as batcat
command -v bat >/dev/null || alias bat=batcat
