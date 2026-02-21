#!/bin/bash

install_apt_packages() {
    # Git
    if [ "$INSTALL_GIT" = true ]; then
        if ! command -v git &>/dev/null; then
            print_step "Installing Git"
            add-apt-repository -y ppa:git-core/ppa
            apt update -y
            apt install -y git
            print_success "Git installed"
        else
            print_success "Git already installed"
        fi
        
        print_step "Configuring Git"
        sudo -u "$CONFIG_USERNAME" git config --global init.defaultBranch main
        sudo -u "$CONFIG_USERNAME" git config --global user.name "$CONFIG_GIT_NAME"
        sudo -u "$CONFIG_USERNAME" git config --global user.email "$CONFIG_GIT_EMAIL"
        print_success "Git configured"
    fi

    # Build Essential & Gedit
    local optional_packages=()
    [ "$INSTALL_BUILD_ESSENTIAL" = true ] && optional_packages+=(build-essential)
    [ "$INSTALL_GEDIT" = true ] && optional_packages+=(gedit)
    
    if [ ${#optional_packages[@]} -gt 0 ]; then
        print_step "Installing optional APT packages"
        apt install -y "${optional_packages[@]}"
        print_success "Optional packages installed"
    fi


    # Android platform-tools (adb/fastboot)
    if ! command -v adb &>/dev/null; then
        print_step "Installing Android platform-tools"
        apt install -y android-sdk-platform-tools
        print_success "Android platform-tools installed"
    else
        print_success "Android platform-tools already installed"
    fi

    # FUSE
    if [ "$INSTALL_FUSE" = true ]; then
        local major_version=$(echo "$CONFIG_UBUNTU_VERSION" | cut -d'.' -f1)
        if [ "$major_version" -ge 22 ]; then
            apt install -y fuse3
            print_success "FUSE 3 installed"
        else
            apt install -y fuse
            print_success "FUSE 2 installed"
        fi
    fi
}
