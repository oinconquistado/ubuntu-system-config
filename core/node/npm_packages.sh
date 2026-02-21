#!/bin/bash

install_npm_packages() {
    if [ "$INSTALL_NVM_NODE" != true ]; then
        return 0
    fi

    # Prefer Bun for global JS tooling whenever available
    if [ "$INSTALL_BUN" = true ] && [ -x "${CONFIG_HOME}/.bun/bin/bun" ]; then
        print_step "Installing global JS packages with Bun"
        sudo -u "$CONFIG_USERNAME" bash -c "${CONFIG_HOME}/.bun/bin/bun install --global pnpm @biomejs/biome turbo"
        print_success "Global JS packages installed with Bun (pnpm, biome, turbo)"
        return 0
    fi

    # Fallback when Bun is not selected/available
    if [ "$INSTALL_PNPM" = true ]; then
        print_step "Installing pnpm (fallback: npm)"
        sudo -u "$CONFIG_USERNAME" bash -c "export NVM_DIR=\"${CONFIG_HOME}/.nvm\"; [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"; npm install -g pnpm"
        print_success "pnpm installed"
    fi
}
