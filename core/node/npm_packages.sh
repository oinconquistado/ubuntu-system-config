#!/bin/bash

install_npm_packages() {
    if [ "$INSTALL_PNPM" = true ] && [ "$INSTALL_NVM_NODE" = true ]; then
        print_step "Installing pnpm"
        sudo -u "$CONFIG_USERNAME" bash -c "export NVM_DIR=\"${CONFIG_HOME}/.nvm\"; [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"; npm install -g pnpm"
        print_success "pnpm installed"
    fi
}
