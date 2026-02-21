# =========================
# ~/.zshrc (genérico)
# =========================

# --- Helpers (reutilizáveis) ---
# Adiciona ao PATH apenas se existir e se ainda não estiver no PATH
path_add() {
  local p="$1"
  [[ -n "$p" && -d "$p" ]] || return 0
  case ":$PATH:" in
    *":$p:"*) ;;
    *) export PATH="$p:$PATH" ;;
  esac
}

# Dá source em arquivo apenas se existir/for legível
source_if() { [[ -r "$1" ]] && source "$1"; }

# --- Homebrew (somente se instalado) ---
if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/Homebrew/bin/brew" ]]; then
  eval "$($HOME/.linuxbrew/Homebrew/bin/brew shellenv)"
elif command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
fi

# --- NVM (carrega só se existir) ---
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
source_if "$NVM_DIR/nvm.sh"
source_if "$NVM_DIR/bash_completion"

# --- Oh My Zsh ---
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="${ZSH_THEME:-spaceship}"

zstyle ':omz:update' mode auto

# Completion tweaks (uma vez só)
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' ignore-parents parent pwd directory

plugins=(
  git sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
  spaceship-react
)
source_if "$ZSH/oh-my-zsh.sh"

# Spaceship config
source_if "$HOME/.spaceshiprc.zsh"

# --- PATHs comuns ---
path_add "$HOME/.local/bin"
path_add "/snap/bin"

# pnpm
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
path_add "$PNPM_HOME"

# Android (só se existir)
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
path_add "$ANDROID_HOME/emulator"
path_add "$ANDROID_HOME/platform-tools"
path_add "$HOME/platform-tools"

# Deno
export DENO_INSTALL="${DENO_INSTALL:-$HOME/.deno}"
path_add "$DENO_INSTALL/bin"

# Bun
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
path_add "$BUN_INSTALL/bin"
source_if "$BUN_INSTALL/_bun"   # completions (se existir)

# Flutter
export FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
path_add "$FLUTTER_HOME/bin"
path_add "$HOME/.pub-cache/bin"

# Turso (genérico, sem hardcode)
path_add "$HOME/.turso"
# Se você usa o instalador que coloca em ~/.local/share, pode também:
path_add "$HOME/.local/share/turso"

# --- Aliases (evite caminhos redundantes) ---
alias claude-auto="claude --dangerously-skip-permissions"
alias split-pane="flatpak run org.wezfurlong.wezterm cli split-pane"
alias close-pane="flatpak run org.wezfurlong.wezterm cli kill-pane"

# Prefira atalho por variável base
DEV_HOME="${DEV_HOME:-$HOME/dev}"
alias dev-personal="cd '$DEV_HOME/personal'"
alias dev-oxian="cd '$DEV_HOME/oxian'"
alias dev-clients="cd '$DEV_HOME/clients'"
