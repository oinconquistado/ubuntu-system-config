#!/bin/bash

# =============================================================================
# Configuration and Prompts Functions
# =============================================================================
# This file contains functions for auto-detecting system information and
# prompting users for configuration details.
# =============================================================================

# Color definitions
declare -g COLOR_RESET='\033[0m'
declare -g COLOR_BOLD='\033[1m'
declare -g COLOR_GREEN='\033[0;32m'
declare -g COLOR_BLUE='\033[0;34m'
declare -g COLOR_YELLOW='\033[0;33m'
declare -g COLOR_RED='\033[0;31m'
declare -g COLOR_CYAN='\033[0;36m'

# Global configuration variables
declare -g CONFIG_USERNAME=""
declare -g CONFIG_HOME=""
declare -g CONFIG_GIT_NAME=""
declare -g CONFIG_GIT_EMAIL=""
declare -g CONFIG_HOSTNAME=""
declare -g CONFIG_UBUNTU_VERSION=""

# Application selection flags
declare -g INSTALL_GIT=true
declare -g INSTALL_BUILD_ESSENTIAL=true
declare -g INSTALL_GEDIT=true
declare -g INSTALL_FUSE=true
declare -g INSTALL_NVM_NODE=true
declare -g INSTALL_PNPM=true
declare -g INSTALL_DENO=true
declare -g INSTALL_BUN=true
declare -g INSTALL_TURSO=true
declare -g INSTALL_RENDER=true
declare -g INSTALL_SENTRY=true
declare -g INSTALL_HOMEBREW=true
declare -g INSTALL_GH_CLI=true
declare -g INSTALL_ZSH=true
declare -g INSTALL_OH_MY_ZSH=true
declare -g INSTALL_ZSH_PLUGINS=true
declare -g INSTALL_VSCODIUM=true
declare -g INSTALL_VSCODE=false
declare -g INSTALL_FLATPAK=true
declare -g INSTALL_WEZTERM=true
declare -g INSTALL_VIVALDI=true
declare -g INSTALL_BITWARDEN=true
declare -g INSTALL_STIMULATOR=true

# Detection flags (used to display status in prompts)
declare -g DETECTED_GIT=false
declare -g DETECTED_BUILD_ESSENTIAL=false
declare -g DETECTED_GEDIT=false
declare -g DETECTED_FUSE=false
declare -g DETECTED_NVM_NODE=false
declare -g DETECTED_PNPM=false
declare -g DETECTED_DENO=false
declare -g DETECTED_BUN=false
declare -g DETECTED_TURSO=false
declare -g DETECTED_RENDER=false
declare -g DETECTED_SENTRY=false
declare -g DETECTED_HOMEBREW=false
declare -g DETECTED_GH_CLI=false
declare -g DETECTED_ZSH=false
declare -g DETECTED_OH_MY_ZSH=false
declare -g DETECTED_ZSH_PLUGINS=false
declare -g DETECTED_VSCODIUM=false
declare -g DETECTED_VSCODE=false
declare -g DETECTED_FLATPAK=false
declare -g DETECTED_WEZTERM=false
declare -g DETECTED_VIVALDI=false
declare -g DETECTED_BITWARDEN=false
declare -g DETECTED_STIMULATOR=false

# -----------------------------------------------------------------------------
# Auto-detection Functions
# -----------------------------------------------------------------------------

detect_system_info() {
    log_step "Detectando informações do sistema..."

    # Detect actual user (even when running with sudo)
    if [ -n "$SUDO_USER" ]; then
        CONFIG_USERNAME="$SUDO_USER"
        CONFIG_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    else
        CONFIG_USERNAME="$USER"
        CONFIG_HOME="$HOME"
    fi

    # Detect hostname
    CONFIG_HOSTNAME=$(hostname)

    # Detect Ubuntu version
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        CONFIG_UBUNTU_VERSION="$VERSION_ID"
    else
        CONFIG_UBUNTU_VERSION="unknown"
    fi

    log_success "Sistema detectado:"
    echo -e "  ${COLOR_CYAN}Usuário:${COLOR_RESET} $CONFIG_USERNAME"
    echo -e "  ${COLOR_CYAN}Home:${COLOR_RESET} $CONFIG_HOME"
    echo -e "  ${COLOR_CYAN}Hostname:${COLOR_RESET} $CONFIG_HOSTNAME"
    echo -e "  ${COLOR_CYAN}Ubuntu:${COLOR_RESET} $CONFIG_UBUNTU_VERSION"
    echo ""
}

status_label() {
    local label="$1"
    local detected="$2"

    if [ "$detected" = true ]; then
        echo "$label [ja instalado]"
    else
        echo "$label"
    fi
}

checkbox_default() {
    local detected="$1"
    if [ "$detected" = true ]; then
        echo "OFF"
    else
        echo "ON"
    fi
}

prompt_default_from_detected() {
    local detected="$1"
    if [ "$detected" = true ]; then
        echo "N"
    else
        echo "Y"
    fi
}

detect_installed_apps() {
    local target_home="$CONFIG_HOME"
    if [ -z "$target_home" ]; then
        target_home="$HOME"
    fi

    command -v git &>/dev/null && DETECTED_GIT=true
    dpkg -s build-essential &>/dev/null && DETECTED_BUILD_ESSENTIAL=true
    dpkg -s gedit &>/dev/null && DETECTED_GEDIT=true
    (command -v fusermount3 &>/dev/null || dpkg -s fuse3 &>/dev/null || dpkg -s fuse &>/dev/null) && DETECTED_FUSE=true

    command -v node &>/dev/null && DETECTED_NVM_NODE=true
    command -v pnpm &>/dev/null && DETECTED_PNPM=true
    command -v deno &>/dev/null && DETECTED_DENO=true
    command -v bun &>/dev/null && DETECTED_BUN=true
    command -v turso &>/dev/null && DETECTED_TURSO=true
    command -v render &>/dev/null && DETECTED_RENDER=true
    command -v sentry-cli &>/dev/null && DETECTED_SENTRY=true
    command -v brew &>/dev/null && DETECTED_HOMEBREW=true
    command -v gh &>/dev/null && DETECTED_GH_CLI=true

    command -v zsh &>/dev/null && DETECTED_ZSH=true
    [ -d "$target_home/.oh-my-zsh" ] && DETECTED_OH_MY_ZSH=true
    if [ -d "$target_home/.oh-my-zsh/custom/plugins" ]; then
        DETECTED_ZSH_PLUGINS=true
    fi

    command -v codium &>/dev/null && DETECTED_VSCODIUM=true
    command -v code &>/dev/null && DETECTED_VSCODE=true

    command -v flatpak &>/dev/null && DETECTED_FLATPAK=true
    if [ "$DETECTED_FLATPAK" = true ]; then
        flatpak list --app | grep -q "org.wezfurlong.wezterm" && DETECTED_WEZTERM=true
        flatpak list --app | grep -q "com.bitwarden.desktop" && DETECTED_BITWARDEN=true
        flatpak list --app | grep -q "io.github.sigmasd.stimulator" && DETECTED_STIMULATOR=true
    fi

    (command -v vivaldi-stable &>/dev/null || dpkg -s vivaldi-stable &>/dev/null) && DETECTED_VIVALDI=true
}

detect_git_info() {
    # Try to get git config from existing global config
    local existing_name=$(su - "$CONFIG_USERNAME" -c "git config --global user.name 2>/dev/null" || echo "")
    local existing_email=$(su - "$CONFIG_USERNAME" -c "git config --global user.email 2>/dev/null" || echo "")

    # If not found, try to guess from system
    if [ -z "$existing_name" ]; then
        existing_name=$(getent passwd "$CONFIG_USERNAME" | cut -d: -f5 | cut -d, -f1)
    fi

    echo "$existing_name|$existing_email"
}

# -----------------------------------------------------------------------------
# Interactive Prompt Functions
# -----------------------------------------------------------------------------

prompt_user_info() {
    log_step "Configuração de Informações Pessoais"
    echo ""

    # Detect git info
    local git_info=$(detect_git_info)
    local suggested_name=$(echo "$git_info" | cut -d'|' -f1)
    local suggested_email=$(echo "$git_info" | cut -d'|' -f2)

    # Prompt for Git name
    echo -e "${COLOR_BOLD}Nome completo para Git:${COLOR_RESET}"
    if [ -n "$suggested_name" ]; then
        echo -e "${COLOR_CYAN}Sugestão detectada: $suggested_name${COLOR_RESET}"
        read -p "Pressione Enter para aceitar ou digite um novo nome: " input_name
        if [ -z "$input_name" ]; then
            CONFIG_GIT_NAME="$suggested_name"
        else
            CONFIG_GIT_NAME="$input_name"
        fi
    else
        read -p "Digite seu nome completo: " CONFIG_GIT_NAME
        while [ -z "$CONFIG_GIT_NAME" ]; do
            echo -e "${COLOR_YELLOW}Nome não pode ser vazio!${COLOR_RESET}"
            read -p "Digite seu nome completo: " CONFIG_GIT_NAME
        done
    fi

    # Prompt for Git email
    echo ""
    echo -e "${COLOR_BOLD}Email para Git:${COLOR_RESET}"
    if [ -n "$suggested_email" ]; then
        echo -e "${COLOR_CYAN}Sugestão detectada: $suggested_email${COLOR_RESET}"
        read -p "Pressione Enter para aceitar ou digite um novo email: " input_email
        if [ -z "$input_email" ]; then
            CONFIG_GIT_EMAIL="$suggested_email"
        else
            CONFIG_GIT_EMAIL="$input_email"
        fi
    else
        read -p "Digite seu email: " CONFIG_GIT_EMAIL
        while [ -z "$CONFIG_GIT_EMAIL" ] || ! [[ "$CONFIG_GIT_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; do
            echo -e "${COLOR_YELLOW}Email inválido!${COLOR_RESET}"
            read -p "Digite seu email: " CONFIG_GIT_EMAIL
        done
    fi

    # Confirm detected system info
    echo ""
    echo -e "${COLOR_BOLD}Confirmação das Informações:${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}Usuário do Sistema:${COLOR_RESET} $CONFIG_USERNAME"
    echo -e "  ${COLOR_CYAN}Diretório Home:${COLOR_RESET} $CONFIG_HOME"
    echo -e "  ${COLOR_CYAN}Nome para Git:${COLOR_RESET} $CONFIG_GIT_NAME"
    echo -e "  ${COLOR_CYAN}Email para Git:${COLOR_RESET} $CONFIG_GIT_EMAIL"
    echo ""

    read -p "As informações estão corretas? (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn] ]]; then
        echo -e "${COLOR_YELLOW}Reiniciando configuração...${COLOR_RESET}"
        echo ""
        prompt_user_info
        return
    fi

    log_success "Informações configuradas com sucesso!"
    echo ""
}

# -----------------------------------------------------------------------------
# Interactive Application Selection
# -----------------------------------------------------------------------------

prompt_application_selection() {
    log_step "Seleção de Aplicações a Instalar"
    echo ""
    echo -e "${COLOR_BOLD}Use espaço para marcar/desmarcar, Enter para confirmar${COLOR_RESET}"
    echo -e "${COLOR_CYAN}Itens ja instalados iniciam desmarcados por padrao${COLOR_RESET}"
    echo ""

    detect_installed_apps

    # Check if whiptail or dialog is available
    if command -v whiptail &> /dev/null; then
        use_whiptail_selection
    elif command -v dialog &> /dev/null; then
        use_dialog_selection
    else
        # Fallback to manual selection
        use_manual_selection
    fi
}

use_whiptail_selection() {
    local height=30
    local width=80
    local list_height=20

    local git_label
    local build_label
    local gedit_label
    local fuse_label
    local nvm_label
    local pnpm_label
    local deno_label
    local bun_label
    local turso_label
    local render_label
    local sentry_label
    local brew_label
    local gh_label
    local zsh_label
    local ohmyzsh_label
    local zsh_plugins_label
    local vscodium_label
    local vscode_label
    local vivaldi_label
    local flatpak_label
    local wezterm_label
    local bitwarden_label
    local stimulator_label

    git_label=$(status_label "Git version control" "$DETECTED_GIT")
    build_label=$(status_label "Ferramentas de compilacao (gcc, make, etc.)" "$DETECTED_BUILD_ESSENTIAL")
    gedit_label=$(status_label "Editor de texto GNOME" "$DETECTED_GEDIT")
    fuse_label=$(status_label "Filesystem in Userspace (FUSE 2 ou 3)" "$DETECTED_FUSE")
    nvm_label=$(status_label "Node.js via NVM (gerenciador de versoes)" "$DETECTED_NVM_NODE")
    pnpm_label=$(status_label "Gerenciador de pacotes Node.js rapido" "$DETECTED_PNPM")
    deno_label=$(status_label "Runtime JavaScript/TypeScript moderno" "$DETECTED_DENO")
    bun_label=$(status_label "Runtime JavaScript ultra-rapido" "$DETECTED_BUN")
    turso_label=$(status_label "Turso CLI" "$DETECTED_TURSO")
    render_label=$(status_label "Render CLI" "$DETECTED_RENDER")
    sentry_label=$(status_label "Sentry CLI" "$DETECTED_SENTRY")
    brew_label=$(status_label "Gerenciador de pacotes Homebrew (Linux)" "$DETECTED_HOMEBREW")
    gh_label=$(status_label "GitHub CLI (gh) - requer Homebrew" "$DETECTED_GH_CLI")
    zsh_label=$(status_label "Zsh shell" "$DETECTED_ZSH")
    ohmyzsh_label=$(status_label "Framework Oh-My-Zsh" "$DETECTED_OH_MY_ZSH")
    zsh_plugins_label=$(status_label "Plugins Zsh (autosuggestions, syntax-highlighting, etc.)" "$DETECTED_ZSH_PLUGINS")
    vscodium_label=$(status_label "VSCodium (VS Code open-source) - Recomendado" "$DETECTED_VSCODIUM")
    vscode_label=$(status_label "Visual Studio Code (Microsoft)" "$DETECTED_VSCODE")
    vivaldi_label=$(status_label "Navegador Vivaldi (APT .deb - estavel)" "$DETECTED_VIVALDI")
    flatpak_label=$(status_label "Sistema Flatpak + Flathub" "$DETECTED_FLATPAK")
    wezterm_label=$(status_label "Terminal WezTerm (via Flatpak)" "$DETECTED_WEZTERM")
    bitwarden_label=$(status_label "Gerenciador de senhas Bitwarden (via Flatpak)" "$DETECTED_BITWARDEN")
    stimulator_label=$(status_label "Ferramenta de produtividade Stimulator (via Flatpak)" "$DETECTED_STIMULATOR")

    # Build checklist options (all ON by default)
    local options=(
        "SECTION_BASE" "=== SISTEMA BASE ===" OFF
        "git" "$git_label" "$(checkbox_default "$DETECTED_GIT")"
        "build-essential" "$build_label" "$(checkbox_default "$DETECTED_BUILD_ESSENTIAL")"
        "gedit" "$gedit_label" "$(checkbox_default "$DETECTED_GEDIT")"
        "fuse" "$fuse_label" "$(checkbox_default "$DETECTED_FUSE")"
        "" "" OFF
        "SECTION_DEV" "=== DESENVOLVIMENTO ===" OFF
        "nvm-node" "$nvm_label" "$(checkbox_default "$DETECTED_NVM_NODE")"
        "pnpm" "$pnpm_label" "$(checkbox_default "$DETECTED_PNPM")"
        "deno" "$deno_label" "$(checkbox_default "$DETECTED_DENO")"
        "bun" "$bun_label" "$(checkbox_default "$DETECTED_BUN")"
        "turso" "$turso_label" "$(checkbox_default "$DETECTED_TURSO")"
        "render" "$render_label" "$(checkbox_default "$DETECTED_RENDER")"
        "sentry" "$sentry_label" "$(checkbox_default "$DETECTED_SENTRY")"
        "homebrew" "$brew_label" "$(checkbox_default "$DETECTED_HOMEBREW")"
        "gh-cli" "$gh_label" "$(checkbox_default "$DETECTED_GH_CLI")"
        "" "" OFF
        "SECTION_SHELL" "=== SHELL E TERMINAL ===" OFF
        "zsh" "$zsh_label" "$(checkbox_default "$DETECTED_ZSH")"
        "oh-my-zsh" "$ohmyzsh_label" "$(checkbox_default "$DETECTED_OH_MY_ZSH")"
        "zsh-plugins" "$zsh_plugins_label" "$(checkbox_default "$DETECTED_ZSH_PLUGINS")"
        "" "" OFF
        "SECTION_EDITORS" "=== EDITORES ===" OFF
        "vscodium" "$vscodium_label" "$(checkbox_default "$DETECTED_VSCODIUM")"
        "vscode" "$vscode_label" "$(checkbox_default "$DETECTED_VSCODE")"
        "" "" OFF
        "SECTION_BROWSERS" "=== NAVEGADORES ===" OFF
        "vivaldi" "$vivaldi_label" "$(checkbox_default "$DETECTED_VIVALDI")"
        "" "" OFF
        "SECTION_FLATPAK" "=== FLATPAK E APLICAÇÕES ===" OFF
        "flatpak" "$flatpak_label" "$(checkbox_default "$DETECTED_FLATPAK")"
        "wezterm" "$wezterm_label" "$(checkbox_default "$DETECTED_WEZTERM")"
        "bitwarden" "$bitwarden_label" "$(checkbox_default "$DETECTED_BITWARDEN")"
        "stimulator" "$stimulator_label" "$(checkbox_default "$DETECTED_STIMULATOR")"
    )

    # Run whiptail
    local choices=$(whiptail --title "Seleção de Aplicações" \
        --checklist "Escolha as aplicações para instalar:" \
        $height $width $list_height \
        "${options[@]}" \
        3>&1 1>&2 2>&3)

    # Parse results
    if [ $? -eq 0 ]; then
        parse_application_choices "$choices"
    else
        log_warning "Seleção cancelada. Usando configuração padrão (tudo marcado)."
    fi
}

use_dialog_selection() {
    # Similar implementation with dialog instead of whiptail
    log_warning "Dialog não está implementado ainda. Usando seleção manual."
    use_manual_selection
}

use_manual_selection() {
    echo -e "${COLOR_YELLOW}whiptail/dialog não disponível. Usando seleção manual.${COLOR_RESET}"
    echo ""

    echo -e "${COLOR_BOLD}=== SISTEMA BASE ===${COLOR_RESET}"
    ask_yes_no "Instalar Git? $(status_label \"\" \"$DETECTED_GIT\")" INSTALL_GIT "$(prompt_default_from_detected "$DETECTED_GIT")"
    ask_yes_no "Instalar build-essential? $(status_label \"\" \"$DETECTED_BUILD_ESSENTIAL\")" INSTALL_BUILD_ESSENTIAL "$(prompt_default_from_detected "$DETECTED_BUILD_ESSENTIAL")"
    ask_yes_no "Instalar gedit? $(status_label \"\" \"$DETECTED_GEDIT\")" INSTALL_GEDIT "$(prompt_default_from_detected "$DETECTED_GEDIT")"
    ask_yes_no "Instalar FUSE? $(status_label \"\" \"$DETECTED_FUSE\")" INSTALL_FUSE "$(prompt_default_from_detected "$DETECTED_FUSE")"

    echo ""
    echo -e "${COLOR_BOLD}=== DESENVOLVIMENTO ===${COLOR_RESET}"
    ask_yes_no "Instalar Node.js via NVM? $(status_label \"\" \"$DETECTED_NVM_NODE\")" INSTALL_NVM_NODE "$(prompt_default_from_detected "$DETECTED_NVM_NODE")"
    ask_yes_no "Instalar pnpm? $(status_label \"\" \"$DETECTED_PNPM\")" INSTALL_PNPM "$(prompt_default_from_detected "$DETECTED_PNPM")"
    ask_yes_no "Instalar Deno? $(status_label \"\" \"$DETECTED_DENO\")" INSTALL_DENO "$(prompt_default_from_detected "$DETECTED_DENO")"
    ask_yes_no "Instalar Bun? $(status_label \"\" \"$DETECTED_BUN\")" INSTALL_BUN "$(prompt_default_from_detected "$DETECTED_BUN")"
    ask_yes_no "Instalar Turso CLI? $(status_label \"\" \"$DETECTED_TURSO\")" INSTALL_TURSO "$(prompt_default_from_detected "$DETECTED_TURSO")"
    ask_yes_no "Instalar Render CLI? $(status_label \"\" \"$DETECTED_RENDER\")" INSTALL_RENDER "$(prompt_default_from_detected "$DETECTED_RENDER")"
    ask_yes_no "Instalar Sentry CLI? $(status_label \"\" \"$DETECTED_SENTRY\")" INSTALL_SENTRY "$(prompt_default_from_detected "$DETECTED_SENTRY")"
    ask_yes_no "Instalar Homebrew? $(status_label \"\" \"$DETECTED_HOMEBREW\")" INSTALL_HOMEBREW "$(prompt_default_from_detected "$DETECTED_HOMEBREW")"
    if [ "$INSTALL_HOMEBREW" = true ]; then
        ask_yes_no "Instalar GitHub CLI (gh)? $(status_label \"\" \"$DETECTED_GH_CLI\")" INSTALL_GH_CLI "$(prompt_default_from_detected "$DETECTED_GH_CLI")"
    else
        INSTALL_GH_CLI=false
    fi

    echo ""
    echo -e "${COLOR_BOLD}=== SHELL E TERMINAL ===${COLOR_RESET}"
    ask_yes_no "Instalar Zsh? $(status_label \"\" \"$DETECTED_ZSH\")" INSTALL_ZSH "$(prompt_default_from_detected "$DETECTED_ZSH")"
    ask_yes_no "Instalar Oh-My-Zsh? $(status_label \"\" \"$DETECTED_OH_MY_ZSH\")" INSTALL_OH_MY_ZSH "$(prompt_default_from_detected "$DETECTED_OH_MY_ZSH")"
    ask_yes_no "Instalar plugins Zsh? $(status_label \"\" \"$DETECTED_ZSH_PLUGINS\")" INSTALL_ZSH_PLUGINS "$(prompt_default_from_detected "$DETECTED_ZSH_PLUGINS")"

    echo ""
    echo -e "${COLOR_BOLD}=== EDITORES ===${COLOR_RESET}"
    ask_yes_no "Instalar VSCodium (VS Code open-source)? $(status_label \"\" \"$DETECTED_VSCODIUM\")" INSTALL_VSCODIUM "$(prompt_default_from_detected "$DETECTED_VSCODIUM")"
    ask_yes_no "Instalar VS Code (Microsoft)? $(status_label \"\" \"$DETECTED_VSCODE\")" INSTALL_VSCODE "$(prompt_default_from_detected "$DETECTED_VSCODE")"

    echo ""
    echo -e "${COLOR_BOLD}=== NAVEGADORES ===${COLOR_RESET}"
    ask_yes_no "Instalar Vivaldi (APT .deb - estavel)? $(status_label \"\" \"$DETECTED_VIVALDI\")" INSTALL_VIVALDI "$(prompt_default_from_detected "$DETECTED_VIVALDI")"

    echo ""
    echo -e "${COLOR_BOLD}=== FLATPAK E APLICAÇÕES ===${COLOR_RESET}"
    ask_yes_no "Instalar Flatpak? $(status_label \"\" \"$DETECTED_FLATPAK\")" INSTALL_FLATPAK "$(prompt_default_from_detected "$DETECTED_FLATPAK")"
    if [ "$INSTALL_FLATPAK" = true ]; then
        ask_yes_no "Instalar WezTerm (Flatpak)? $(status_label \"\" \"$DETECTED_WEZTERM\")" INSTALL_WEZTERM "$(prompt_default_from_detected "$DETECTED_WEZTERM")"
        ask_yes_no "Instalar Bitwarden (Flatpak)? $(status_label \"\" \"$DETECTED_BITWARDEN\")" INSTALL_BITWARDEN "$(prompt_default_from_detected "$DETECTED_BITWARDEN")"
        ask_yes_no "Instalar Stimulator (Flatpak)? $(status_label \"\" \"$DETECTED_STIMULATOR\")" INSTALL_STIMULATOR "$(prompt_default_from_detected "$DETECTED_STIMULATOR")"
    else
        INSTALL_WEZTERM=false
        INSTALL_BITWARDEN=false
        INSTALL_STIMULATOR=false
        log_warning "Aplicações Flatpak desativadas (Flatpak não selecionado)"
    fi

    echo ""
    log_success "Seleção concluída!"
}

parse_application_choices() {
    local choices="$1"

    # Reset all to false
    INSTALL_GIT=false
    INSTALL_BUILD_ESSENTIAL=false
    INSTALL_GEDIT=false
    INSTALL_FUSE=false
    INSTALL_NVM_NODE=false
    INSTALL_PNPM=false
    INSTALL_DENO=false
    INSTALL_BUN=false
    INSTALL_TURSO=false
    INSTALL_RENDER=false
    INSTALL_SENTRY=false
    INSTALL_HOMEBREW=false
    INSTALL_GH_CLI=false
    INSTALL_ZSH=false
    INSTALL_OH_MY_ZSH=false
    INSTALL_ZSH_PLUGINS=false
    INSTALL_VSCODIUM=false
    INSTALL_VSCODE=false
    INSTALL_FLATPAK=false
    INSTALL_WEZTERM=false
    INSTALL_VIVALDI=false
    INSTALL_BITWARDEN=false
    INSTALL_STIMULATOR=false

    # Set selected to true
    [[ "$choices" =~ "git" ]] && INSTALL_GIT=true
    [[ "$choices" =~ "build-essential" ]] && INSTALL_BUILD_ESSENTIAL=true
    [[ "$choices" =~ "gedit" ]] && INSTALL_GEDIT=true
    [[ "$choices" =~ "fuse" ]] && INSTALL_FUSE=true
    [[ "$choices" =~ "nvm-node" ]] && INSTALL_NVM_NODE=true
    [[ "$choices" =~ "pnpm" ]] && INSTALL_PNPM=true
    [[ "$choices" =~ "deno" ]] && INSTALL_DENO=true
    [[ "$choices" =~ "bun" ]] && INSTALL_BUN=true
    [[ "$choices" =~ "turso" ]] && INSTALL_TURSO=true
    [[ "$choices" =~ "render" ]] && INSTALL_RENDER=true
    [[ "$choices" =~ "sentry" ]] && INSTALL_SENTRY=true
    [[ "$choices" =~ "homebrew" ]] && INSTALL_HOMEBREW=true
    [[ "$choices" =~ "gh-cli" ]] && INSTALL_GH_CLI=true
    [[ "$choices" =~ "zsh" ]] && INSTALL_ZSH=true
    [[ "$choices" =~ "oh-my-zsh" ]] && INSTALL_OH_MY_ZSH=true
    [[ "$choices" =~ "zsh-plugins" ]] && INSTALL_ZSH_PLUGINS=true
    [[ "$choices" =~ "vscodium" ]] && INSTALL_VSCODIUM=true
    [[ "$choices" =~ "vscode" ]] && INSTALL_VSCODE=true
    [[ "$choices" =~ "flatpak" ]] && INSTALL_FLATPAK=true
    [[ "$choices" =~ "wezterm" ]] && INSTALL_WEZTERM=true
    [[ "$choices" =~ "vivaldi" ]] && INSTALL_VIVALDI=true
    [[ "$choices" =~ "bitwarden" ]] && INSTALL_BITWARDEN=true
    [[ "$choices" =~ "stimulator" ]] && INSTALL_STIMULATOR=true

    # Dependency checks
    if [ "$INSTALL_GH_CLI" = true ] && [ "$INSTALL_HOMEBREW" != true ]; then
        log_warning "GitHub CLI requer Homebrew. Desativando instalação do gh CLI."
        INSTALL_GH_CLI=false
    fi

    # Check Flatpak dependencies
    local flatpak_apps_selected=false
    [[ "$INSTALL_WEZTERM" = true || "$INSTALL_BITWARDEN" = true || "$INSTALL_STIMULATOR" = true ]] && flatpak_apps_selected=true

    if [ "$flatpak_apps_selected" = true ] && [ "$INSTALL_FLATPAK" != true ]; then
        log_warning "Aplicações Flatpak selecionadas mas Flatpak não foi ativado. Ativando Flatpak..."
        INSTALL_FLATPAK=true
    fi

    # Check Homebrew dependencies
    if [ "$INSTALL_HOMEBREW" = true ]; then
        # Homebrew requires build-essential
        log_info "Homebrew requer build-essential. Ativando build-essential..."
        INSTALL_BUILD_ESSENTIAL=true
    fi
}

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

ask_yes_no() {
    local prompt="$1"
    local var_name="$2"
    local default="${3:-Y}"

    if [ "$default" = "Y" ]; then
        read -p "$prompt (Y/n): " response
        response=${response:-Y}
    else
        read -p "$prompt (y/N): " response
        response=${response:-N}
    fi

    if [[ "$response" =~ ^[Yy] ]]; then
        eval "$var_name=true"
    else
        eval "$var_name=false"
    fi
}

# -----------------------------------------------------------------------------
# Logging Functions (compatible with main scripts)
# -----------------------------------------------------------------------------

log_step() {
    echo -e "${COLOR_BOLD}${COLOR_BLUE}==>${COLOR_RESET} ${COLOR_BOLD}$1${COLOR_RESET}"
}

log_success() {
    echo -e "${COLOR_BOLD}${COLOR_GREEN}✓${COLOR_RESET} $1"
}

log_error() {
    echo -e "${COLOR_BOLD}${COLOR_RED}✗${COLOR_RESET} $1"
}

log_warning() {
    echo -e "${COLOR_BOLD}${COLOR_YELLOW}⚠${COLOR_RESET} $1"
}

log_info() {
    echo -e "${COLOR_CYAN}ℹ${COLOR_RESET} $1"
}

# -----------------------------------------------------------------------------
# FUSE Version Check
# -----------------------------------------------------------------------------

check_fuse_compatibility() {
    if [ "$INSTALL_FUSE" = false ]; then
        return 0
    fi

    log_step "Verificando compatibilidade do FUSE..."

    # Parse Ubuntu version
    local major_version=$(echo "$CONFIG_UBUNTU_VERSION" | cut -d'.' -f1)
    local minor_version=$(echo "$CONFIG_UBUNTU_VERSION" | cut -d'.' -f2)

    # Check if Ubuntu > 24.04
    if [ "$major_version" -gt 24 ] || ([ "$major_version" -eq 24 ] && [ "$minor_version" -gt 4 ]); then
        log_warning "AVISO: Você está usando Ubuntu $CONFIG_UBUNTU_VERSION"
        log_warning "Instalar FUSE em versões > 24.04 pode causar problemas no sistema!"
        echo ""
        echo -e "${COLOR_YELLOW}Recomendação: Não instalar FUSE nesta versão do Ubuntu${COLOR_RESET}"
        echo ""

        ask_yes_no "Deseja continuar com a instalação do FUSE mesmo assim?" INSTALL_FUSE N

        if [ "$INSTALL_FUSE" = false ]; then
            log_info "FUSE não será instalado."
        else
            log_warning "Prosseguindo com instalação do FUSE por sua conta e risco!"
        fi
    else
        log_success "Ubuntu $CONFIG_UBUNTU_VERSION é compatível com FUSE"
    fi

    echo ""
}

# -----------------------------------------------------------------------------
# Configuration Summary
# -----------------------------------------------------------------------------

show_configuration_summary() {
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_CYAN}╔════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_BOLD}${COLOR_CYAN}║         RESUMO DA CONFIGURAÇÃO                             ║${COLOR_RESET}"
    echo -e "${COLOR_BOLD}${COLOR_CYAN}╚════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo ""

    echo -e "${COLOR_BOLD}Informações do Sistema:${COLOR_RESET}"
    echo -e "  Usuário: $CONFIG_USERNAME"
    echo -e "  Home: $CONFIG_HOME"
    echo -e "  Git Nome: $CONFIG_GIT_NAME"
    echo -e "  Git Email: $CONFIG_GIT_EMAIL"
    echo -e "  Ubuntu: $CONFIG_UBUNTU_VERSION"
    echo ""

    echo -e "${COLOR_BOLD}Aplicações Selecionadas:${COLOR_RESET}"

    echo -e "${COLOR_CYAN}Sistema Base:${COLOR_RESET}"
    [ "$INSTALL_GIT" = true ] && echo "  ✓ Git" || echo "  ✗ Git"
    [ "$INSTALL_BUILD_ESSENTIAL" = true ] && echo "  ✓ build-essential" || echo "  ✗ build-essential"
    [ "$INSTALL_GEDIT" = true ] && echo "  ✓ gedit" || echo "  ✗ gedit"
    [ "$INSTALL_FUSE" = true ] && echo "  ✓ FUSE" || echo "  ✗ FUSE"

    echo ""
    echo -e "${COLOR_CYAN}Desenvolvimento:${COLOR_RESET}"
    [ "$INSTALL_NVM_NODE" = true ] && echo "  ✓ Node.js/NVM" || echo "  ✗ Node.js/NVM"
    [ "$INSTALL_PNPM" = true ] && echo "  ✓ pnpm" || echo "  ✗ pnpm"
    [ "$INSTALL_DENO" = true ] && echo "  ✓ Deno" || echo "  ✗ Deno"
    [ "$INSTALL_BUN" = true ] && echo "  ✓ Bun" || echo "  ✗ Bun"
    [ "$INSTALL_TURSO" = true ] && echo "  ✓ Turso CLI" || echo "  ✗ Turso CLI"
    [ "$INSTALL_RENDER" = true ] && echo "  ✓ Render CLI" || echo "  ✗ Render CLI"
    [ "$INSTALL_SENTRY" = true ] && echo "  ✓ Sentry CLI" || echo "  ✗ Sentry CLI"
    [ "$INSTALL_HOMEBREW" = true ] && echo "  ✓ Homebrew" || echo "  ✗ Homebrew"
    [ "$INSTALL_GH_CLI" = true ] && echo "  ✓ GitHub CLI (gh)" || echo "  ✗ GitHub CLI (gh)"

    echo ""
    echo -e "${COLOR_CYAN}Shell:${COLOR_RESET}"
    [ "$INSTALL_ZSH" = true ] && echo "  ✓ Zsh" || echo "  ✗ Zsh"
    [ "$INSTALL_OH_MY_ZSH" = true ] && echo "  ✓ Oh-My-Zsh" || echo "  ✗ Oh-My-Zsh"
    [ "$INSTALL_ZSH_PLUGINS" = true ] && echo "  ✓ Plugins Zsh" || echo "  ✗ Plugins Zsh"

    echo ""
    echo -e "${COLOR_CYAN}Editores:${COLOR_RESET}"
    [ "$INSTALL_VSCODIUM" = true ] && echo "  ✓ VSCodium" || echo "  ✗ VSCodium"
    [ "$INSTALL_VSCODE" = true ] && echo "  ✓ VS Code" || echo "  ✗ VS Code"

    echo ""
    echo -e "${COLOR_CYAN}Navegadores:${COLOR_RESET}"
    [ "$INSTALL_VIVALDI" = true ] && echo "  ✓ Vivaldi (APT .deb)" || echo "  ✗ Vivaldi (APT .deb)"

    echo ""
    echo -e "${COLOR_CYAN}Flatpak:${COLOR_RESET}"
    [ "$INSTALL_FLATPAK" = true ] && echo "  ✓ Flatpak" || echo "  ✗ Flatpak"
    [ "$INSTALL_WEZTERM" = true ] && echo "  ✓ WezTerm" || echo "  ✗ WezTerm"
    [ "$INSTALL_BITWARDEN" = true ] && echo "  ✓ Bitwarden" || echo "  ✗ Bitwarden"
    [ "$INSTALL_STIMULATOR" = true ] && echo "  ✓ Stimulator" || echo "  ✗ Stimulator"

    echo ""
}

# -----------------------------------------------------------------------------
# Main Configuration Flow
# -----------------------------------------------------------------------------

run_configuration() {
    echo -e "${COLOR_BOLD}${COLOR_GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║   Ubuntu System Configuration - Setup Interativo           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""

    # Step 1: Detect system
    detect_system_info

    # Step 2: Prompt for user info
    prompt_user_info

    # Step 3: Select applications
    prompt_application_selection

    # Step 4: Check FUSE compatibility
    check_fuse_compatibility

    # Step 5: Show summary
    show_configuration_summary

    # Step 6: Final confirmation
    echo ""
    read -p "Deseja prosseguir com a instalação? (Y/n): " final_confirm
    if [[ "$final_confirm" =~ ^[Nn] ]]; then
        log_error "Instalação cancelada pelo usuário."
        exit 0
    fi

    log_success "Configuração concluída! Iniciando instalação..."
    echo ""
}

# Export all configuration variables
export CONFIG_USERNAME CONFIG_HOME CONFIG_GIT_NAME CONFIG_GIT_EMAIL CONFIG_HOSTNAME CONFIG_UBUNTU_VERSION
export INSTALL_GIT INSTALL_BUILD_ESSENTIAL INSTALL_GEDIT INSTALL_FUSE
export INSTALL_NVM_NODE INSTALL_PNPM INSTALL_DENO INSTALL_BUN INSTALL_TURSO INSTALL_RENDER INSTALL_SENTRY INSTALL_HOMEBREW INSTALL_GH_CLI
export INSTALL_ZSH INSTALL_OH_MY_ZSH INSTALL_ZSH_PLUGINS
export INSTALL_VSCODIUM INSTALL_VSCODE INSTALL_FLATPAK
export INSTALL_WEZTERM INSTALL_VIVALDI INSTALL_BITWARDEN INSTALL_STIMULATOR
