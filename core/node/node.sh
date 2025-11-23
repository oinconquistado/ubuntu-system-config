#!/bin/bash

setup_node() {
    if [ "$INSTALL_NVM_NODE" = true ]; then
        if [ ! -d "${CONFIG_HOME}/.nvm" ]; then
            print_step "Installing NVM"
            sudo -u "$CONFIG_USERNAME" bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
            print_success "NVM installed"
        fi
        
        print_step "Installing Node.js LTS"
        sudo -u "$CONFIG_USERNAME" bash -c "export NVM_DIR=\"${CONFIG_HOME}/.nvm\"; [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"; nvm install --lts; nvm use --lts; nvm alias default lts/*"
        print_success "Node.js installed"
    fi
}
