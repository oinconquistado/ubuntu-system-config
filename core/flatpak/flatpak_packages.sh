#!/bin/bash

install_flatpak_packages() {
    if [ "$INSTALL_FLATPAK" = true ]; then
        print_step "Installing Flatpak Applications"
        
        [ "$INSTALL_WEZTERM" = true ] && sudo -u "$CONFIG_USERNAME" flatpak install -y flathub org.wezfurlong.wezterm
        [ "$INSTALL_VIVALDI" = true ] && sudo -u "$CONFIG_USERNAME" flatpak install -y flathub com.vivaldi.Vivaldi
        [ "$INSTALL_BITWARDEN" = true ] && sudo -u "$CONFIG_USERNAME" flatpak install -y flathub com.bitwarden.desktop
        [ "$INSTALL_STIMULATOR" = true ] && sudo -u "$CONFIG_USERNAME" flatpak install -y flathub io.github.sigmasd.stimulator
        
        print_success "Flatpak apps installed"
    fi
}
