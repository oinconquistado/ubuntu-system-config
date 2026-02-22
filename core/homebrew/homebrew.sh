#!/bin/bash

setup_homebrew() {
    if [ "$INSTALL_HOMEBREW" = true ]; then
        print_step "Installing Homebrew"
        if [ ! -d "${CONFIG_HOME}/.linuxbrew" ]; then
            sudo -u "$CONFIG_USERNAME" bash -c 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
            print_success "Homebrew installed"
        else
            print_success "Homebrew already installed"
        fi
    fi
}
