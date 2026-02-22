#!/bin/bash

user_has_command() {
    sudo -u "$CONFIG_USERNAME" bash -lc "command -v $1 >/dev/null 2>&1"
}

install_runtimes() {
    # Deno
    if [ "$INSTALL_DENO" = true ]; then
        print_step "Installing Deno"
        sudo -u "$CONFIG_USERNAME" bash -c 'curl -fsSL https://deno.land/install.sh | sh'
        print_success "Deno installed"
    fi

    # Bun
    if [ "$INSTALL_BUN" = true ]; then
        if [ -x "${CONFIG_HOME}/.bun/bin/bun" ]; then
            print_success "Bun already installed"
        else
            print_step "Installing Bun"
            sudo -u "$CONFIG_USERNAME" bash -c 'curl -fsSL https://bun.sh/install | bash'
            print_success "Bun installed"
        fi
    fi

    # Flutter SDK
    if [ ! -d "${CONFIG_HOME}/flutter/bin" ]; then
        print_step "Installing Flutter SDK"
        sudo -u "$CONFIG_USERNAME" bash -c 'git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"'
        print_success "Flutter SDK installed"
    else
        print_success "Flutter SDK already installed"
    fi

    # Turso CLI
    if [ "$INSTALL_TURSO" = true ]; then
        if user_has_command turso; then
            print_success "Turso CLI already installed"
        else
            print_step "Installing Turso CLI"
            sudo -u "$CONFIG_USERNAME" bash -c 'curl -sSfL https://get.tur.so/install.sh | bash'
            print_success "Turso CLI installed"
        fi
    fi

    # Sentry CLI
    if [ "$INSTALL_SENTRY" = true ]; then
        if user_has_command sentry-cli; then
            print_success "Sentry CLI already installed"
        else
            print_step "Installing Sentry CLI"
            sudo -u "$CONFIG_USERNAME" bash -c 'curl -sL https://sentry.io/get-cli/ | sh'
            print_success "Sentry CLI installed"
        fi
    fi

    # Render CLI (prefer official installer; Homebrew path is handled later)
    if [ "$INSTALL_RENDER" = true ]; then
        if user_has_command render; then
            print_success "Render CLI already installed"
        else
            print_step "Installing Render CLI"
            if sudo -u "$CONFIG_USERNAME" bash -c 'curl -fsSL https://raw.githubusercontent.com/render-oss/cli/main/bin/install.sh | bash'; then
                print_success "Render CLI installed via installer"
            else
                print_warning "Render installer unavailable now; will rely on Homebrew step when enabled."
            fi
        fi
    fi
}
