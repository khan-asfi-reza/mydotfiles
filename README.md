# mydotfiles

My Personal config managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level dir is a stow "package" that mirrors the target paths
relative to `$HOME`. Created this readme so I don't forget myself.

## Layout

```
mydotfiles/
  nvim/         .config/nvim/         -> ~/.config/nvim/
  tmux/         .tmux.conf            -> ~/.tmux.conf
  wezterm/      .wezterm.lua          -> ~/.wezterm.lua
  ghostty/      .config/ghostty/      -> ~/.config/ghostty/
  bashscripts/  .bashscripts/         -> ~/.bashscripts/
  zsh/          .zshrc                -> ~/.zshrc
  ideavim/      .ideavimrc            -> ~/.ideavimrc
  p10k/         .p10k.zsh             -> ~/.p10k.zsh
  fonts/        *.ttf + install.sh    (NOT stowed - run install.sh)
```

Machine-specific overrides live in `~/.zshrc.local` (NOT stowed, NOT
tracked). `.zshrc` sources it at the end if present.

## New machine bootstrap

One-shot installer covers macOS (Darwin), Arch Linux, and Debian/Ubuntu.
Installs all CLI tools (neovim, tmux, zsh, direnv, uv, fzf, ripgrep, fd,
bat, jq, lazygit, gh, ghostty), oh-my-zsh + powerlevel10k + zsh plugins,
TPM, fonts, then stows all packages.

```bash
# 1. Clone
git clone git@github.com:khan-asfi-reza/my-config.git ~/mydotfiles

# 2. Run installer (will prompt for sudo on Linux)
cd ~/mydotfiles && ./install.sh
```

Idempotent - re-run safely. Skips anything already installed.

Post-install:
- `exec zsh` to enter the new shell
- Inside tmux: `prefix + I` (capital i) to install TPM plugins
- Open nvim - lazy.nvim auto-installs plugins on first run
- Edit `~/.zshrc.local` for per-machine PATH / tool inits (seeded with a template)
- `gh auth login` to authenticate GitHub

### Manual stow (if you skip install.sh)

```bash
cd ~/mydotfiles
stow nvim tmux wezterm ghostty bashscripts zsh ideavim p10k
~/mydotfiles/fonts/install.sh
```

Or auto-stow all dirs except fonts:

```bash
cd ~/mydotfiles
stow $(ls -d */ | tr -d '/' | grep -v fonts)
```

Do NOT run `stow */` blindly - it would try to stow `fonts/` (handled
separately by `install.sh`, not stow).

## Daily flow

Edit files normally (writes follow symlink, land in this repo):

```bash
nvim ~/.config/nvim/lua/plugins/lspconfig.lua

cd ~/mydotfiles
git status                          # sees the edit
git add -A
git commit -m "tweak pyrefly cmd"
git push
```

## Adding a new package

```bash
mkdir -p ~/mydotfiles/<pkg>
# place files mirroring target path inside <pkg>/
# e.g. ~/.config/foo/bar.toml -> ~/mydotfiles/<pkg>/.config/foo/bar.toml

# move existing config into package
mv ~/.config/foo ~/mydotfiles/<pkg>/.config/foo

# stow
cd ~/mydotfiles
stow <pkg>
```

## Removing / re-stowing

```bash
cd ~/mydotfiles
stow -D <pkg>      # remove symlinks
stow -R <pkg>      # restow (remove + add) - use after restructuring
```

## Conflicts

If `stow <pkg>` fails with "existing target is not owned by stow":

```bash
# Move the conflicting file into the package first
mv ~/<conflict> ~/mydotfiles/<pkg>/<conflict>
stow <pkg>
```

Or force-overwrite (destructive — back up first):
```bash
stow --adopt <pkg>     # imports existing target into package
```

# fonts

Nerd Fonts used across terminal apps (wezterm, ghostty, nvim, JetBrains
IDEs, iTerm2).

## Included

| Family | Variants | Source | Used by |
|---|---|---|---|
| **MesloLGS NF** | Regular / Bold / Italic / Bold Italic | romkatv/powerlevel10k-media | wezterm, ghostty, p10k recommended font |
| **Hack Nerd Font** | full set (Mono, Propo, regular variants) | ryanoasis/nerd-fonts releases | IDE / editor fallback |

All glyphs include Nerd Font icon ranges (powerline, dev-icons,
font-awesome).

## Install

```bash
~/mydotfiles/fonts/install.sh
```

The script:
- macOS: downloads to `~/Library/Fonts/`
- Linux: downloads to `~/.local/share/fonts/`, runs `fc-cache -f`
- Idempotent: skips files already present
- Requires: `curl`, `unzip` (already installed by top-level `install.sh`)

## Verify

After install, restart your terminal:

```bash
# macOS - needs fontconfig: brew install fontconfig
fc-list | grep -i "MesloLGS NF"

# Linux
fc-list | grep -i "MesloLGS NF"
```

Or open `Font Book` (mac) / your file manager and confirm the .ttf files
landed in the right dir.

## Adding a new font family

Edit `install.sh`, add another `dl` call (for direct URLs) or another
`unzip` block (for github release zips). Then commit `install.sh`. Next
machine picks it up.

Don't add font binaries to the repo - `.gitignore` blocks `*.ttf` /
`*.otf` to enforce this.

## Sources

- MesloLGS NF: https://github.com/romkatv/powerlevel10k#manual-font-installation
- Nerd Fonts releases: https://github.com/ryanoasis/nerd-fonts/releases
