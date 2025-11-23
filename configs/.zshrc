# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# NVM Config

export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"


# Homebrew (only if installed)
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -f "$HOME/.linuxbrew/Homebrew/bin/brew" ]; then
    eval "$($HOME/.linuxbrew/Homebrew/bin/brew shellenv)"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme

ZSH_THEME="spaceship"

# OMZ Config

zstyle ':omz:update' mode auto      # update automatically without asking

# ENABLE_CORRECTION="true"

plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete spaceship-vi-mode spaceship-react spaceship-flutter spaceship-gradle spaceship-vue)

source $ZSH/oh-my-zsh.sh

# Load Spaceship configuration
[ -f ~/.spaceshiprc.zsh ] && source ~/.spaceshiprc.zsh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# snap

export PATH=$PATH:/snap/bin

source "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

#alias

alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias idea="intellij-idea-ultimate"
alias c="claude --dangerously-skip-permissions"
alias wsplit="wezterm cli split-pane"
alias wclose="wezterm cli kill-pane"


#Android

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#Deno

export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
