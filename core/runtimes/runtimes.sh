#!/bin/bash

install_runtimes() {
    # Deno
    if [ "$INSTALL_DENO" = true ]; then
        print_step "Installing Deno"
        sudo -u "$CONFIG_USERNAME" bash -c 'curl -fsSL https://deno.land/install.sh | sh'
        print_success "Deno installed"
    fi
    
    # Bun
    if [ "$INSTALL_BUN" = true ]; then
        print_step "Installing Bun"
        sudo -u "$CONFIG_USERNAME" bash -c 'curl -fsSL https://bun.sh/install | bash'
        print_success "Bun installed"
    fi
}
