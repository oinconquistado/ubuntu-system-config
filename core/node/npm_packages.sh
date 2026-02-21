#!/bin/bash

install_npm_packages() {
    # Prefer Bun for global JS tooling whenever available
    if [ "$INSTALL_BUN" = true ]; then
        if [ ! -x "${CONFIG_HOME}/.bun/bin/bun" ]; then
            print_step "Installing Bun (required for global JS packages)"
            sudo -u "$CONFIG_USERNAME" bash -c 'curl -fsSL https://bun.sh/install | bash'
            print_success "Bun installed"
        fi

        if [ -x "${CONFIG_HOME}/.bun/bin/bun" ]; then
            print_step "Installing global JS packages with Bun"
            sudo -u "$CONFIG_USERNAME" bash -c "${CONFIG_HOME}/.bun/bin/bun install --global pnpm @biomejs/biome turbo"
            print_success "Global JS packages installed with Bun (pnpm, biome, turbo)"
            return 0
        fi
    fi

    # Fallback to npm when Bun is unavailable and Node/NVM are enabled
    if [ "$INSTALL_PNPM" = true ] && [ "$INSTALL_NVM_NODE" = true ]; then
        if [ ! -d "${CONFIG_HOME}/.nvm" ]; then
            print_step "Installing NVM (fallback for npm global installs)"
            sudo -u "$CONFIG_USERNAME" bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
            print_success "NVM installed"
        fi

        print_step "Ensuring Node.js latest for npm fallback"
        sudo -u "$CONFIG_USERNAME" bash -c "export NVM_DIR=\"${CONFIG_HOME}/.nvm\"; [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"; nvm install node; nvm use node; nvm alias default node; npm install -g pnpm"
        print_success "pnpm installed (fallback via npm)"
    fi
}
