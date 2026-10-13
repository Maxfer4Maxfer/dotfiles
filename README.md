# dotfiles

Linux (Ubuntu 24.04, arm64/amd64) and macOS. Configs are [GNU stow](https://www.gnu.org/software/stow/) packages,
installation is a few idempotent bash scripts — re-run them any time to bring a machine up to date.

## New machine

```sh
git clone https://github.com/Maxfer4Maxfer/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

Then put secrets and machine-specific settings into `~/.zshrc.local` (never committed):

```sh
export GITHUB_TOKEN=...
export KUBECONFIG="$HOME/.kube/config.work"
```

and log in: `gh auth login`, `gcloud auth login`.

### macOS

`install.sh` on a Mac also applies the `system` step (Dock, Finder, keyboard, screenshots, iTerm2, launch agents).
Before it, sign in to the App Store (the `mas` apps of the Brewfile are skipped with a warning otherwise);
casks that ship a `.pkg` ask for the sudo password. After it, log out and in once (keyboard layouts, key repeat).

Not in the Brewfile — install by hand: nekoray, Max, KokoroTTS (+ its "Speak with Kokoro" service for `kokoro-say`),
ArchiCAD (Graphisoft, CodeMeter, WIBUKEY), the PF Fusion Sans font. Then log in to Dropbox, Google Drive, Slack, Okta Verify.

## Layout

| path | what |
| --- | --- |
| `common/<pkg>/` | stow packages for both OSes: `zsh`, `git`, `tmux`, `nvim`, `apps` |
| `linux/<pkg>/`, `macos/<pkg>/` | OS-specific packages: `zsh` (`~/.config/zsh/os.zsh`); macOS `ssh` (`~/.ssh/config`), `bin` (`~/.local/bin` scripts) |
| `packages/apt.txt` | Ubuntu packages |
| `packages/apt-purge.txt` | what `install.sh system` removes from a headless VM (desktop, laptop/firmware agents, snapd, apport …) |
| `packages/Brewfile` | everything on the Mac: formulae, casks, App Store apps (`mas`) |
| `iterm2/` | iTerm2 preferences; iTerm2 loads and saves them here (`PrefsCustomFolder`), commit what you change |
| `launchd/` | launch agent templates (`$HOME` is filled in by `system-macos.sh`) |
| `packages/go.txt` | `go install …@latest` |
| `scripts/packages-{linux,macos}.sh` | system packages, third-party apt repos, Go, Neovim, AWS CLI |
| `scripts/link.sh` | `stow` all packages into `$HOME` |
| `scripts/system-macos.sh` | macOS defaults (Dock, Finder, keyboard, trackpad, screenshots), iTerm2 prefs folder, launch agents |
| `scripts/system-linux.sh` | opt-in dev VM tuning: zram swap, sysctl (swappiness, inotify), no I/O scheduler on virtio, docker log/cache limits, journald cap, purge |
| `scripts/tools.sh` | oh-my-zsh + p10k, tmux/nvim plugins, rust, uv, claude, go tools, tofu/terragrunt/tflint at pinned versions |

Every file in a package mirrors its place in `$HOME`: `common/tmux/.config/tmux/theme.conf` → `~/.config/tmux/theme.conf`.
To add a config, move it into a package and run `./install.sh link`.

## Commands

```sh
./install.sh                 # everything: packages → link → tools (→ system on macOS)
./install.sh link            # only symlinks
./install.sh tools           # update plugins and user-level tools
./install.sh system          # macOS: settings; Linux dev VM (opt-in): tuning + purge of the desktop and other cruft (sudo)
make smoke                   # check this machine
make test                    # install from scratch into a clean Ubuntu container + smoke test
make lint                    # shellcheck
```

CI (`.github/workflows/ci.yml`) runs lint, the container test on arm64 and a macOS install on every push.

## Notes

- Neovim plugins are pinned by `lazy-lock.json` (`Lazy! restore`); update them in nvim with `:Lazy update` and commit the lock file.
- LSP servers and formatters come from Mason (`mason-tool-installer` list in `lua/plugins/lsp.lua`), installed by `install.sh tools`; `gopls`/`goimports` come from `packages/go.txt`.
- `~/.gitconfig` stays local (`safe.directory`, a work `user.email` and other overrides); the shared part is `~/.config/git/config`.
- tmux reads machine-local settings from `~/.tmux.conf.local` (e.g. extra `@nvim-autokill-keep` sessions).
- tmux starts on boot via tmux-continuum (`@continuum-boot`), which creates the systemd unit / launchd agent itself.
