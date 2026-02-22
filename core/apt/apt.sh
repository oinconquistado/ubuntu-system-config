#!/bin/bash

setup_apt() {
    print_step "Updating system packages"
    apt update -y && apt upgrade -y
    print_success "System updated successfully"

    print_step "Installing system dependencies"
    local packages=(curl wget vim software-properties-common ca-certificates gnupg lsb-release apt-transport-https)
    apt install -y "${packages[@]}"
    print_success "Dependencies installed"
}
