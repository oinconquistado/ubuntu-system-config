#!/bin/bash

brew_exec() {
    local brew_bin=""

    if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
    elif [ -x "${CONFIG_HOME}/.linuxbrew/Homebrew/bin/brew" ]; then
        brew_bin="${CONFIG_HOME}/.linuxbrew/Homebrew/bin/brew"
    elif command -v brew >/dev/null 2>&1; then
        brew_bin="$(command -v brew)"
    fi

    [ -n "$brew_bin" ] || return 1
    sudo -u "$CONFIG_USERNAME" bash -c "eval \"\$(${brew_bin} shellenv)\"; brew $*"
}

install_homebrew_packages() {
    if [ "$INSTALL_HOMEBREW" != true ]; then
        return 0
    fi

    print_step "Installing GCC via Homebrew"
    brew_exec install gcc

    if [ "$INSTALL_GH_CLI" = true ]; then
        print_step "Installing GitHub CLI"
        brew_exec install gh
    fi

    print_step "Installing MongoDB CLI (mongocli)"
    brew_exec install mongocli

    print_step "Installing Railway CLI"
    brew_exec install railway

    print_step "Installing Render CLI"
    brew_exec install render

    print_success "Homebrew packages installed"
}
