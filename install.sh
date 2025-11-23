#!/bin/bash

################################################################################
# Ubuntu System Configuration - Master Installer
# Description: Automated Ubuntu system configuration script with interactive
#              selection, dynamic configuration, and reboot handling.
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DIR="${SCRIPT_DIR}/configs"
LOG_DIR="${SCRIPT_DIR}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/install_$(date +%Y%m%d_%H%M%S).log"
STATE_FILE="${SCRIPT_DIR}/.install_state"

# Source configuration and prompts functions
if [ -f "${SCRIPT_DIR}/config_prompts.sh" ]; then
    source "${SCRIPT_DIR}/config_prompts.sh"
else
    echo -e "${RED}Error: config_prompts.sh not found!${NC}"
    exit 1
fi

# Source Core Modules
source "${SCRIPT_DIR}/core/apt/apt.sh"
source "${SCRIPT_DIR}/core/apt/apt_packages.sh"
source "${SCRIPT_DIR}/core/flatpak/flatpak.sh"
source "${SCRIPT_DIR}/core/flatpak/flatpak_packages.sh"
source "${SCRIPT_DIR}/core/homebrew/homebrew.sh"
source "${SCRIPT_DIR}/core/homebrew/homebrew_packages.sh"
source "${SCRIPT_DIR}/core/node/node.sh"
source "${SCRIPT_DIR}/core/node/npm_packages.sh"
source "${SCRIPT_DIR}/core/zsh/zsh.sh"
source "${SCRIPT_DIR}/core/zsh/zsh_plugins.sh"
source "${SCRIPT_DIR}/core/runtimes/runtimes.sh"
source "${SCRIPT_DIR}/core/editors/editors.sh"

################################################################################
# Helper Functions
################################################################################

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE" > /dev/null
}

print_step() {
    echo -e "\n${BLUE}==>${NC} ${BOLD}$1${NC}"
    log_msg "STEP: $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    log_msg "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    log_msg "ERROR: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    log_msg "WARNING: $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
    log_msg "INFO: $1"
}

ensure_sudo() {
    if [ "$EUID" -ne 0 ]; then
        print_warning "Esta operação requer privilégios de superusuário."
        echo -e "${CYAN}Por favor, digite sua senha quando solicitado.${NC}"
        if ! sudo -v; then
            print_error "Falha ao obter privilégios sudo"
            exit 1
        fi
        # Keep sudo alive
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
}

################################################################################
# Part 1: Pre-Reboot Installation Steps
################################################################################

run_part1() {
    print_step "Starting Part 1: Pre-Reboot Setup"
    
    # 1. APT Setup & Packages
    setup_apt
    install_apt_packages

    # 2. Node.js & NPM
    setup_node
    install_npm_packages

    # 3. Zsh Setup
    setup_zsh
    install_zsh_plugins

    # 4. Homebrew
    setup_homebrew
    install_homebrew_packages

    # 5. Runtimes (Deno/Bun)
    install_runtimes

    # 6. Editors
    install_editors

    # 7. Flatpak Setup (System)
    setup_flatpak

    # Save state
    echo "PART1_COMPLETED=true" >> "$STATE_FILE"
    echo "PART1_COMPLETION_DATE=$(date)" >> "$STATE_FILE"
    
    print_success "Part 1 completed successfully!"
}

################################################################################
# Part 2: Post-Reboot Installation Steps
################################################################################

run_part2() {
    print_step "Starting Part 2: Post-Reboot Setup"
    
    # Load state if variables are missing
    if [ -z "$CONFIG_USERNAME" ] && [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    fi
    
    if [ -z "$CONFIG_USERNAME" ]; then
        print_error "Configuration missing. Cannot proceed with Part 2."
        exit 1
    fi

    # 1. Install Flatpak Apps
    install_flatpak_packages

    # 2. Copy Config Files
    print_step "Copying configuration files"
    if [ -d "$CONFIG_DIR" ]; then
        [ -f "$CONFIG_DIR/.zshrc" ] && sudo -u "$CONFIG_USERNAME" cp "$CONFIG_DIR/.zshrc" "${CONFIG_HOME}/.zshrc"
        [ -f "$CONFIG_DIR/.spaceshiprc.zsh" ] && sudo -u "$CONFIG_USERNAME" cp "$CONFIG_DIR/.spaceshiprc.zsh" "${CONFIG_HOME}/.spaceshiprc.zsh"
        [ -f "$CONFIG_DIR/wezterm.lua" ] && [ "$INSTALL_WEZTERM" = true ] && sudo -u "$CONFIG_USERNAME" cp "$CONFIG_DIR/wezterm.lua" "${CONFIG_HOME}/.wezterm.lua"
        print_success "Configuration files copied"
    fi

    # 3. Fix Zsh Permissions
    if [ "$INSTALL_ZSH" = true ]; then
        print_step "Fixing Zsh permissions"
        # Simple fix for common insecure directories
        sudo -u "$CONFIG_USERNAME" chmod 755 "${CONFIG_HOME}/.oh-my-zsh" "${CONFIG_HOME}/.oh-my-zsh/custom" 2>/dev/null
        print_success "Permissions fixed"
    fi

    # 4. Configure GNOME Favorites
    print_step "Configuring GNOME Favorites"
    local favorites="['org.gnome.Nautilus.desktop'"
    [ "$INSTALL_WEZTERM" = true ] && favorites+=", 'org.wezfurlong.wezterm.desktop'"
    [ "$INSTALL_VIVALDI" = true ] && favorites+=", 'com.vivaldi.Vivaldi.desktop'"
    [ "$INSTALL_VSCODIUM" = true ] && favorites+=", 'codium.desktop'"
    [ "$INSTALL_VSCODE" = true ] && favorites+=", 'code.desktop'"
    favorites+="]"
    
    sudo -u "$CONFIG_USERNAME" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$CONFIG_USERNAME")/bus" gsettings set org.gnome.shell favorite-apps "$favorites" 2>/dev/null
    print_success "Favorites configured"

    # 5. Configure WezTerm Default & Shortcuts
    if [ "$INSTALL_WEZTERM" = true ]; then
        print_step "Configuring WezTerm"
        sudo -u "$CONFIG_USERNAME" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$CONFIG_USERNAME")/bus" gsettings set org.gnome.desktop.default-applications.terminal exec 'flatpak run org.wezfurlong.wezterm' 2>/dev/null
        
        print_info "Note: Keyboard shortcuts configuration skipped in simplified installer. Please configure manually if needed."
    fi

    # Cleanup
    echo "PART2_COMPLETED=true" >> "$STATE_FILE"
    
    # Remove service if exists
    if [ -f "/etc/systemd/system/ubuntu-setup-part2.service" ]; then
        systemctl disable ubuntu-setup-part2.service 2>/dev/null
        rm -f "/etc/systemd/system/ubuntu-setup-part2.service"
        systemctl daemon-reload
    fi

    print_success "Part 2 completed successfully!"
    echo -e "\n${GREEN}${BOLD}Installation Complete! Please log out and log back in.${NC}\n"
}

################################################################################
# Reboot Handling
################################################################################

handle_reboot() {
    echo -e "\n${YELLOW}${BOLD}REBOOT REQUIRED${NC}"
    echo -e "${CYAN}A reboot is necessary to complete the installation (Flatpak setup).${NC}"
    
    read -p "Do you want to reboot now and continue automatically? (Y/n): " choice
    if [[ "$choice" =~ ^[Nn] ]]; then
        print_warning "Reboot skipped. Please run './install.sh --post-reboot' after you reboot manually."
    else
        # Create auto-run service
        local service_file="/etc/systemd/system/ubuntu-setup-part2.service"
        cat <<EOF > "$service_file"
[Unit]
Description=Ubuntu System Setup - Part 2
After=network.target graphical.target
Wants=graphical.target

[Service]
Type=oneshot
ExecStart=$(readlink -f "$0") --post-reboot
StandardOutput=journal
StandardError=journal
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
        systemctl enable ubuntu-setup-part2.service
        print_success "Auto-run service created."
        print_step "Rebooting in 5 seconds..."
        sleep 5
        reboot
    fi
}

################################################################################
# Main Entry Point
################################################################################

main() {
    ensure_sudo

    # Check for post-reboot flag
    if [ "$1" == "--post-reboot" ]; then
        run_part2
        exit 0
    fi

    # Interactive Setup
    run_configuration
    
    # Run Part 1
    run_part1
    
    # Check if reboot needed
    if grep -q "FLATPAK_JUST_INSTALLED=true" "$STATE_FILE" 2>/dev/null; then
        handle_reboot
    else
        # If no reboot needed, run Part 2 immediately
        run_part2
    fi
}

main "$@"
