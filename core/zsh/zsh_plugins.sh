#!/bin/bash

install_zsh_plugins() {
    if [ "$INSTALL_ZSH_PLUGINS" = true ] && [ "$INSTALL_OH_MY_ZSH" = true ]; then
        print_step "Installing Zsh Plugins & Spaceship"
        local ZSH_CUSTOM="${CONFIG_HOME}/.oh-my-zsh/custom"
        
        # Plugins
        [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && sudo -u "$CONFIG_USERNAME" git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
        [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && sudo -u "$CONFIG_USERNAME" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
        [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autocomplete" ] && sudo -u "$CONFIG_USERNAME" git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM}/plugins/zsh-autocomplete"
        
        # Spaceship
        if [ ! -d "${ZSH_CUSTOM}/themes/spaceship-prompt" ]; then
            sudo -u "$CONFIG_USERNAME" git clone https://github.com/spaceship-prompt/spaceship-prompt.git "${ZSH_CUSTOM}/themes/spaceship-prompt" --depth=1
            sudo -u "$CONFIG_USERNAME" ln -sf "${ZSH_CUSTOM}/themes/spaceship-prompt/spaceship.zsh-theme" "${ZSH_CUSTOM}/themes/spaceship.zsh-theme"
        fi
        
        print_success "Zsh plugins and theme installed"
    fi
}
