#!/usr/bin/env bash
# Supported: macOS (Darwin), Arch Linux, Debian/Ubuntu.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m!! %s\033[0m\n" "$*" >&2; }
err() { printf "\033[1;31mXX %s\033[0m\n" "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# OS detection
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux)
      if [ -f /etc/arch-release ] || have pacman; then
        echo "arch"
      elif have apt-get; then
        echo "debian"
      else
        echo "unknown"
      fi
      ;;
    *) echo "unknown" ;;
  esac
}

OS="$(detect_os)"
[ "$OS" = "unknown" ] && err "unsupported OS (need Darwin, Arch, or Debian-based)"
log "OS detected: $OS"

# per-OS package install
install_darwin() {
  if ! have brew; then
    log "installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  local pkgs=(stow git gh neovim tmux zsh direnv uv fzf ripgrep fd bat jq lazygit)
  for p in "${pkgs[@]}"; do
    if brew list --formula "$p" >/dev/null 2>&1; then
      echo "  - $p already installed"
    else
      brew install "$p"
    fi
  done
  if [ ! -d /Applications/Ghostty.app ]; then
    log "installing Ghostty (cask)"
    brew install --cask ghostty
  else
    echo "  - Ghostty already installed"
  fi
}

install_arch() {
  local pkgs=(stow git github-cli neovim tmux zsh direnv uv fzf ripgrep fd bat jq lazygit ghostty unzip)
  log "installing via pacman"
  sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

install_debian() {
  log "apt update"
  sudo apt-get update -y
  local apt_pkgs=(stow git neovim tmux zsh direnv fzf ripgrep fd-find bat jq curl ca-certificates gnupg unzip)
  sudo apt-get install -y "${apt_pkgs[@]}"

  # symlink fd (debian ships as fdfind)
  if have fdfind && ! have fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
  fi
  # symlink bat (debian ships as batcat)
  if have batcat && ! have bat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
  fi

  # gh from official apt repo
  if ! have gh; then
    log "installing gh from official apt repo"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y gh
  fi

  # uv via official installer
  if ! have uv; then
    log "installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi

  # lazygit from github release
  if ! have lazygit; then
    log "installing lazygit from github"
    LZG_VER=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LZG_VER}_Linux_x86_64.tar.gz" \
      | tar -xz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin/lazygit
    rm -f /tmp/lazygit
  fi

  # Ghostty - prefer snap, else build hint
  if ! have ghostty; then
    log "installing Ghostty"
    if have snap; then
      sudo snap install ghostty --classic
    else
      warn "snap not present. Install snapd ('sudo apt install snapd') then re-run, or build Ghostty from source: https://ghostty.org/docs/install/build"
    fi
  fi
}

case "$OS" in
  darwin) install_darwin ;;
  arch)   install_arch ;;
  debian) install_debian ;;
esac

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "installing oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "oh-my-zsh present"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# powerlevel10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  log "installing powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
  log "powerlevel10k present"
fi

# zsh plugins
declare -A ZSH_PLUGINS=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
)
for plug in "${!ZSH_PLUGINS[@]}"; do
  dest="$ZSH_CUSTOM/plugins/$plug"
  if [ ! -d "$dest" ]; then
    log "installing zsh plugin: $plug"
    git clone --depth=1 "${ZSH_PLUGINS[$plug]}" "$dest"
  else
    echo "  - $plug present"
  fi
done

# TPM (tmux plugin manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  log "installing TPM"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  log "TPM present"
fi

# stow packages (skip wezterm + fonts)
log "stowing packages"
cd "$DOTFILES"
PACKAGES=$(ls -d */ | tr -d '/' | grep -vE '^(wezterm|fonts)$')
for pkg in $PACKAGES; do
  echo "  - stow $pkg"
  stow --restow "$pkg" 2>&1 | sed 's/^/      /' || warn "stow failed for $pkg"
done

# fonts
if [ -x "$DOTFILES/fonts/install.sh" ]; then
  log "installing fonts"
  "$DOTFILES/fonts/install.sh"
fi

# seed ~/.zshrc.local (machine-specific overrides, NOT tracked)
if [ ! -f "$HOME/.zshrc.local" ]; then
  log "creating ~/.zshrc.local"
  cat > "$HOME/.zshrc.local" <<'EOF'
# Machine-specific overrides. NOT tracked in mydotfiles repo.
# Sourced at the end of ~/.zshrc.
#
# Put per-machine stuff here: PATH prepends, gcloud/conda inits,
# work-specific env vars, secrets.

# Example:
# export PATH="$HOME/google-cloud-sdk/bin:$PATH"
# export AWS_PROFILE=work
EOF
fi

# fzf shell integration (Ctrl+R history, Ctrl+T files, Alt+C dirs)
if have fzf; then
  log "setting up fzf shell integration"
  case "$OS" in
    darwin)
      "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish || warn "fzf integration script failed"
      ;;
    arch|debian)
      MARKER="# fzf integration (added by mydotfiles install.sh)"
      if ! grep -qF "$MARKER" "$HOME/.zshrc.local" 2>/dev/null; then
        cat >> "$HOME/.zshrc.local" <<EOF

$MARKER
[ -f /usr/share/fzf/key-bindings.zsh ]              && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ]                && source /usr/share/fzf/completion.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ]   && source /usr/share/doc/fzf/examples/completion.zsh
EOF
      fi
      ;;
  esac
fi

# default shell
ZSH_BIN="$(command -v zsh || true)"
if [ -n "$ZSH_BIN" ] && [ "$SHELL" != "$ZSH_BIN" ]; then
  log "setting zsh as default shell"
  if ! grep -q "^$ZSH_BIN$" /etc/shells; then
    echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$ZSH_BIN" || warn "chsh failed - set zsh as default manually"
fi

log "done"
