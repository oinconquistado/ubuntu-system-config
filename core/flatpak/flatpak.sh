#!/bin/bash

setup_flatpak() {
    if [ "$INSTALL_FLATPAK" = true ]; then
        print_step "Installing Flatpak"
        apt install -y flatpak gnome-software-plugin-flatpak
        sudo -u "$CONFIG_USERNAME" flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        print_success "Flatpak installed"
        
        # Mark that we need a reboot for Flatpak
        echo "FLATPAK_JUST_INSTALLED=true" >> "$STATE_FILE"
    fi
}
