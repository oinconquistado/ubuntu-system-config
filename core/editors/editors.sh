#!/bin/bash

install_editors() {
    # VSCodium
    if [ "$INSTALL_VSCODIUM" = true ]; then
        print_step "Installing VSCodium"
        wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg 2>/dev/null
        echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | tee /etc/apt/sources.list.d/vscodium.list
        apt update -y && apt install -y codium
        print_success "VSCodium installed"
    fi

    # VS Code
    if [ "$INSTALL_VSCODE" = true ]; then
        print_step "Installing VS Code"
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
        rm -f packages.microsoft.gpg
        apt update -y && apt install -y code
        print_success "VS Code installed"
    fi
}
