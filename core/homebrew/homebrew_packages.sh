#!/bin/bash

install_homebrew_packages() {
    if [ "$INSTALL_HOMEBREW" = true ]; then
        # Install GCC
        print_step "Installing GCC via Homebrew"
        sudo -u "$CONFIG_USERNAME" bash -c "eval \"\$(${CONFIG_HOME}/.linuxbrew/Homebrew/bin/brew shellenv)\"; brew install gcc"
        
        # Install gh cli
        if [ "$INSTALL_GH_CLI" = true ]; then
            print_step "Installing GitHub CLI"
            sudo -u "$CONFIG_USERNAME" bash -c "eval \"\$(${CONFIG_HOME}/.linuxbrew/Homebrew/bin/brew shellenv)\"; brew install gh"
        fi
    fi
}
