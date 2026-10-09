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
export KUBECONFIG="$HOME/.kube/config.faraway"
```

and log in: `gh auth login`, `gcloud auth login`.

## Layout

| path | what |
| --- | --- |
| `common/<pkg>/` | stow packages for both OSes: `zsh`, `git`, `tmux`, `nvim`, `apps` |
| `linux/<pkg>/`, `macos/<pkg>/` | OS-specific packages (`~/.config/zsh/os.zsh`) |
| `packages/apt.txt`, `apt-desktop.txt` | Ubuntu packages (desktop list only where `ubuntu-desktop` is installed) |
| `packages/Brewfile` | macOS formulae and casks |
| `packages/go.txt` | `go install …@latest` |
| `scripts/packages-{linux,macos}.sh` | system packages, third-party apt repos, Go, Neovim, AWS CLI |
| `scripts/link.sh` | `stow` all packages into `$HOME` |
| `scripts/tools.sh` | oh-my-zsh + p10k, tmux/nvim plugins, rust, uv, claude, go tools, tofu/terragrunt/tflint pinned to `rift-iac` |

Every file in a package mirrors its place in `$HOME`: `common/tmux/.config/tmux/theme.conf` → `~/.config/tmux/theme.conf`.
To add a config, move it into a package and run `./install.sh link`.

## Commands

```sh
./install.sh                 # everything: packages → link → tools
./install.sh link            # only symlinks
./install.sh tools           # update plugins and user-level tools
make smoke                   # check this machine
make test                    # install from scratch into a clean Ubuntu container + smoke test
make lint                    # shellcheck
```

CI (`.github/workflows/ci.yml`) runs lint, the container test on arm64 and a macOS install on every push.

## Notes

- Neovim plugins are pinned by `lazy-lock.json` (`Lazy! restore`); update them in nvim with `:Lazy update` and commit the lock file.
- `~/.gitconfig` stays local (`safe.directory` and other overrides); the shared part is `~/.config/git/config`.
- tmux starts on boot via tmux-continuum (`@continuum-boot`), which creates the systemd unit / launchd agent itself.
