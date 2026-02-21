#!/bin/bash

setup_node() {
    if [ "$INSTALL_NVM_NODE" != true ]; then
        return 0
    fi

    # Ensure NVM exists
    if [ ! -d "${CONFIG_HOME}/.nvm" ]; then
        print_step "Installing NVM"
        sudo -u "$CONFIG_USERNAME" bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
        print_success "NVM installed"
    fi

    # Ensure latest Node.js is installed and set as default
    print_step "Installing Node.js latest"
    sudo -u "$CONFIG_USERNAME" bash -c "export NVM_DIR=\"${CONFIG_HOME}/.nvm\"; [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"; nvm install node; nvm use node; nvm alias default node"
    print_success "Node.js latest installed"
}
