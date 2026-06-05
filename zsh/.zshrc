# Powerlevel10k instant prompt - keep at top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Base PATH (mac homebrew + user bin)
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  bundler
  dotenv
  macos
  rake
  rbenv
  web-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# Prompt
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
ZSH_DOTENV_PROMPT=false

# Modular scripts
source ~/.bashscripts/init.sh

# Aliases
alias dce="docker compose exec"
alias dcu="docker compose up"
alias dcd="docker compose down"
alias dcmp="docker compose"

# Env
export UV_KEYRING_PROVIDER=subprocess

# Tool hooks
eval "$(direnv hook zsh)"

# Machine-specific overrides (NOT in git)
[ -r ~/.zshrc.local ] && source ~/.zshrc.local
