#!/bin/bash

setup_zsh() {
    if [ "$INSTALL_ZSH" = true ]; then
        if ! command -v zsh &>/dev/null; then
            print_step "Installing Zsh"
            apt install -y zsh
            print_success "Zsh installed"
        fi
        
        # Set default shell
        local current_shell=$(getent passwd "$CONFIG_USERNAME" | cut -d: -f7)
        if [[ "$current_shell" != *"/zsh" ]]; then
            print_step "Setting Zsh as default shell"
            chsh -s "$(which zsh)" "$CONFIG_USERNAME"
            print_success "Zsh set as default shell"
        fi
    fi

    if [ "$INSTALL_OH_MY_ZSH" = true ] && [ "$INSTALL_ZSH" = true ]; then
        print_step "Installing Oh-My-Zsh"
        if [ ! -d "${CONFIG_HOME}/.oh-my-zsh" ]; then
            sudo -u "$CONFIG_USERNAME" bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
            print_success "Oh-My-Zsh installed"
        else
            print_success "Oh-My-Zsh already installed"
        fi
    fi
}
