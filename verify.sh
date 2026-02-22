#!/bin/bash

################################################################################
# System Installation Test & Validation Script
# Description: Tests and validates all configurations from setup scripts
#              Provides detailed report of what works and what doesn't
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0
TESTS_TOTAL=0

# Log file
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_DIR="${SCRIPT_DIR}/logs"
mkdir -p "$LOG_DIR"
if [ ! -w "$LOG_DIR" ]; then
    LOG_DIR="/tmp/ubuntu-system-config-logs"
    mkdir -p "$LOG_DIR"
fi
LOG_FILE="${LOG_DIR}/verify_results_$(date +%Y%m%d_%H%M%S).log"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║        System Installation Test & Validation              ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

test_start() {
    ((TESTS_TOTAL++))
    echo -e "\n${CYAN}[TEST $TESTS_TOTAL]${NC} $1"
    log_msg "TEST $TESTS_TOTAL: $1"
}

test_pass() {
    ((TESTS_PASSED++))
    echo -e "${GREEN}  ✓ PASS${NC} $1"
    log_msg "  PASS: $1"
}

test_fail() {
    ((TESTS_FAILED++))
    echo -e "${RED}  ✗ FAIL${NC} $1"
    log_msg "  FAIL: $1"
}

test_skip() {
    ((TESTS_SKIPPED++))
    echo -e "${YELLOW}  ⊘ SKIP${NC} $1"
    log_msg "  SKIP: $1"
}

test_info() {
    echo -e "${BLUE}  ℹ INFO${NC} $1"
    log_msg "  INFO: $1"
}

ask_user() {
    local question="$1"
    echo -e "\n${YELLOW}USER TEST:${NC} $question"
    echo -e "${CYAN}Did this work correctly? (y/n/s to skip):${NC} "
    read -r response
    case "$response" in
        [Yy]* ) return 0 ;;
        [Nn]* ) return 1 ;;
        [Ss]* ) return 2 ;;
        * ) return 1 ;;
    esac
}

################################################################################
# Automated Tests
################################################################################

test_git() {
    test_start "Git Installation and Configuration"

    if command -v git &> /dev/null; then
        local version=$(git --version)
        test_pass "Git is installed: $version"

        local user_name=$(git config --global user.name)
        local user_email=$(git config --global user.email)
        local default_branch=$(git config --global init.defaultBranch)

        if [ -n "$user_name" ]; then
            test_pass "Git user.name configured: $user_name"
        else
            test_fail "Git user.name is not configured"
        fi

        if [ -n "$user_email" ]; then
            test_pass "Git user.email configured: $user_email"
        else
            test_fail "Git user.email is not configured"
        fi

        if [ "$default_branch" = "main" ]; then
            test_pass "Git default branch configured: $default_branch"
        else
            test_fail "Git default branch is '$default_branch', expected 'main'"
        fi
    else
        test_fail "Git is not installed"
    fi
}

test_nodejs() {
    test_start "Node.js, npm, and pnpm"

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        test_pass "Node.js is installed: $node_version"
    else
        test_fail "Node.js is not installed or not in PATH"
    fi

    if command -v npm &> /dev/null; then
        local npm_version=$(npm --version)
        test_pass "npm is installed: $npm_version"
    else
        test_fail "npm is not installed or not in PATH"
    fi

    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"

    if command -v pnpm &> /dev/null; then
        local pnpm_version=$(pnpm --version)
        test_pass "pnpm is installed: $pnpm_version"
    else
        test_fail "pnpm is not installed or not in PATH"
    fi
}

test_homebrew() {
    test_start "Homebrew and GitHub CLI"

    if [ -d "$HOME/.linuxbrew/Homebrew" ]; then
        test_pass "Homebrew directory exists"

        eval "$($HOME/.linuxbrew/Homebrew/bin/brew shellenv)"

        if command -v brew &> /dev/null; then
            local brew_version=$(brew --version | head -1)
            test_pass "Homebrew is accessible: $brew_version"
        else
            test_fail "Homebrew is not in PATH"
        fi

        if command -v gh &> /dev/null; then
            local gh_version=$(gh --version | head -1)
            test_pass "GitHub CLI is installed: $gh_version"
        else
            test_fail "GitHub CLI is not installed or not in PATH"
        fi
    else
        test_fail "Homebrew is not installed"
    fi
}

test_runtimes() {
    test_start "Deno and Bun Runtimes"

    export DENO_INSTALL="$HOME/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"

    if command -v deno &> /dev/null; then
        local deno_version=$(deno --version | head -1)
        test_pass "Deno is installed: $deno_version"
    else
        test_fail "Deno is not installed or not in PATH"
    fi

    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    if command -v bun &> /dev/null; then
        local bun_version=$(bun --version)
        test_pass "Bun is installed: v$bun_version"
    else
        test_fail "Bun is not installed or not in PATH"
    fi
}

test_zsh_ohmyzsh() {
    test_start "Zsh and Oh-My-Zsh"

    if command -v zsh &> /dev/null; then
        local zsh_version=$(zsh --version)
        test_pass "Zsh is installed: $zsh_version"
    else
        test_fail "Zsh is not installed"
    fi

    if [ -d "$HOME/.oh-my-zsh" ]; then
        test_pass "Oh-My-Zsh is installed"
    else
        test_fail "Oh-My-Zsh is not installed"
    fi

    local current_shell=$(getent passwd $USER | cut -d: -f7)
    if [[ "$current_shell" == *"zsh"* ]]; then
        test_pass "Default shell is Zsh: $current_shell"
    else
        test_fail "Default shell is not Zsh: $current_shell"
    fi
}

test_spaceship() {
    test_start "Spaceship Prompt and Plugins"

    if [ -d "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" ]; then
        test_pass "Spaceship Prompt is installed"
    else
        test_fail "Spaceship Prompt is not installed"
    fi

    local plugins=("spaceship-vi-mode" "spaceship-react" "spaceship-flutter" "spaceship-gradle" "spaceship-vue")
    for plugin in "${plugins[@]}"; do
        if [ -d "$HOME/.oh-my-zsh/custom/plugins/$plugin" ]; then
            test_pass "$plugin is installed"
        else
            test_fail "$plugin is not installed"
        fi
    done

    local zsh_plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-autocomplete")
    for plugin in "${zsh_plugins[@]}"; do
        if [ -d "$HOME/.oh-my-zsh/custom/plugins/$plugin" ]; then
            test_pass "$plugin is installed"
        else
            test_fail "$plugin is not installed"
        fi
    done
}

test_flatpak_apps() {
    test_start "Flatpak Applications"

    if command -v flatpak &> /dev/null; then
        test_pass "Flatpak is installed"

        local apps=("org.wezfurlong.wezterm:WezTerm" "com.bitwarden.desktop:Bitwarden" "io.github.sigmasd.stimulator:Stimulator")

        for app_info in "${apps[@]}"; do
            IFS=':' read -r app_id app_name <<< "$app_info"
            if flatpak list --app | grep -q "$app_id"; then
                test_pass "$app_name is installed"
            else
                test_fail "$app_name is not installed"
            fi
        done
    else
        test_fail "Flatpak is not installed"
    fi
}

test_vivaldi_apt() {
    test_start "Vivaldi (APT .deb)"

    if command -v vivaldi-stable &> /dev/null || dpkg -s vivaldi-stable &> /dev/null; then
        local version=""
        version=$(dpkg-query -W -f='${Version}' vivaldi-stable 2>/dev/null || echo "")
        if [ -n "$version" ]; then
            test_pass "Vivaldi (APT) is installed: $version"
        else
            test_pass "Vivaldi (APT) is installed"
        fi
    else
        test_fail "Vivaldi (APT) is not installed"
    fi

    if command -v flatpak &> /dev/null; then
        if flatpak list --app | grep -q "com.vivaldi.Vivaldi"; then
            test_fail "Vivaldi Flatpak also installed (should be removed)"
        fi
    fi
}

test_vscode() {
    test_start "Visual Studio Code / VSCodium"

    local vscodium_found=false
    local vscode_found=false

    # Check for VSCodium
    if command -v codium &> /dev/null; then
        local codium_version=$(codium --version | head -1)
        test_pass "VSCodium is installed: $codium_version"
        vscodium_found=true
    fi

    # Check for VS Code
    if command -v code &> /dev/null; then
        local code_version=$(code --version | head -1)
        test_pass "VS Code is installed: $code_version"
        vscode_found=true
    fi

    # If neither is installed, fail
    if [ "$vscodium_found" = false ] && [ "$vscode_found" = false ]; then
        test_fail "Neither VSCodium nor VS Code is installed"
    fi
}

test_gnome_favorites() {
    test_start "GNOME Shell Favorites (Pinned Apps)"

    local favorites=$(gsettings get org.gnome.shell favorite-apps 2>/dev/null)

    if [ $? -eq 0 ]; then
        test_pass "GNOME favorites are configured"
        test_info "Favorites: $favorites"

        if echo "$favorites" | grep -q "wezterm"; then
            test_pass "WezTerm is in favorites"
        else
            test_fail "WezTerm is not in favorites"
        fi

        if echo "$favorites" | grep -q "vivaldi"; then
            test_pass "Vivaldi is in favorites"
        else
            test_fail "Vivaldi is not in favorites"
        fi
    else
        test_skip "Unable to check GNOME favorites (not in GNOME session?)"
    fi
}

test_default_terminal() {
    test_start "Default Terminal Configuration"

    local terminal_exec=$(gsettings get org.gnome.desktop.default-applications.terminal exec 2>/dev/null)

    if [ $? -eq 0 ]; then
        if echo "$terminal_exec" | grep -q "wezterm"; then
            test_pass "WezTerm is set as default terminal: $terminal_exec"
        else
            test_fail "WezTerm is not the default terminal: $terminal_exec"
        fi
    else
        test_skip "Unable to check default terminal (not in GNOME session?)"
    fi
}

test_keyboard_shortcuts() {
    test_start "Keyboard Shortcuts Configuration"

    local custom_keys=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null)

    if [ $? -eq 0 ]; then
        if [ "$custom_keys" != "@as []" ]; then
            test_pass "Custom keybindings are configured"

            local binding0=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding 2>/dev/null)
            local binding1=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding 2>/dev/null)

            if echo "$binding0" | grep -q "Super"; then
                test_pass "Super+T shortcut is configured: $binding0"
            else
                test_fail "Super+T shortcut is not configured"
            fi

            if echo "$binding1" | grep -q "Primary.*Alt"; then
                test_pass "Ctrl+Alt+P shortcut is configured: $binding1"
            else
                test_fail "Ctrl+Alt+P shortcut is not configured"
            fi
        else
            test_fail "No custom keybindings configured"
        fi

        local terminal_key=$(gsettings get org.gnome.settings-daemon.plugins.media-keys terminal 2>/dev/null)
        if echo "$terminal_key" | grep -q "disabled"; then
            test_pass "GNOME Terminal shortcut (Ctrl+Alt+T) is disabled"
        else
            test_fail "GNOME Terminal shortcut is not disabled: $terminal_key"
        fi
    else
        test_skip "Unable to check keyboard shortcuts (not in GNOME session?)"
    fi
}

test_config_files() {
    test_start "Configuration Files"

    if [ -f "$HOME/.zshrc" ]; then
        test_pass ".zshrc exists"

        if grep -q "spaceship" "$HOME/.zshrc"; then
            test_pass ".zshrc contains Spaceship theme"
        else
            test_fail ".zshrc does not contain Spaceship theme"
        fi
    else
        test_fail ".zshrc does not exist"
    fi

    if [ -f "$HOME/.spaceshiprc.zsh" ]; then
        test_pass ".spaceshiprc.zsh exists"
    else
        test_fail ".spaceshiprc.zsh does not exist"
    fi

    if [ -f "$HOME/.config/wezterm/wezterm.lua" ]; then
        test_pass "WezTerm configuration exists"
    else
        test_fail "WezTerm configuration does not exist"
    fi
}

################################################################################
# Interactive User Tests
################################################################################

interactive_tests() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                            ║${NC}"
    echo -e "${BLUE}║              Interactive User Tests                        ║${NC}"
    echo -e "${BLUE}║                                                            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

    test_start "Keyboard Shortcut: Super+T"
    log_msg "Interactive test: Super+T"
    ask_user "Press Super+T (Windows key + T). Did WezTerm open?"
    result=$?
    if [ $result -eq 0 ]; then
        test_pass "Super+T opens WezTerm"
    elif [ $result -eq 2 ]; then
        test_skip "User skipped Super+T test"
    else
        test_fail "Super+T does not open WezTerm"
    fi

    test_start "Keyboard Shortcut: Ctrl+Alt+P"
    log_msg "Interactive test: Ctrl+Alt+P"
    ask_user "Press Ctrl+Alt+P. Did WezTerm open?"
    result=$?
    if [ $result -eq 0 ]; then
        test_pass "Ctrl+Alt+P opens WezTerm"
    elif [ $result -eq 2 ]; then
        test_skip "User skipped Ctrl+Alt+P test"
    else
        test_fail "Ctrl+Alt+P does not open WezTerm"
    fi

    test_start "Keyboard Shortcut: Ctrl+Alt+T (should do nothing)"
    log_msg "Interactive test: Ctrl+Alt+T"
    ask_user "Press Ctrl+Alt+T. Did NOTHING happen? (expected behavior)"
    result=$?
    if [ $result -eq 0 ]; then
        test_pass "Ctrl+Alt+T is disabled (correct)"
    elif [ $result -eq 2 ]; then
        test_skip "User skipped Ctrl+Alt+T test"
    else
        test_fail "Ctrl+Alt+T still opens something (should be disabled)"
    fi

    test_start "Nautilus 'Open in Terminal'"
    log_msg "Interactive test: Nautilus Open in Terminal"
    echo -e "\n${CYAN}Instructions:${NC}"
    echo "1. Open Nautilus (Files)"
    echo "2. Navigate to any folder"
    echo "3. Right-click and select 'Open in Terminal'"
    ask_user "Did WezTerm open in that folder?"
    result=$?
    if [ $result -eq 0 ]; then
        test_pass "Nautilus opens WezTerm correctly"
    elif [ $result -eq 2 ]; then
        test_skip "User skipped Nautilus test"
    else
        test_fail "Nautilus does not open WezTerm (may need logout/reboot)"
        test_info "Try logging out and back in, or restarting GNOME Shell (Alt+F2, type 'r')"
    fi
}

################################################################################
# Generate Report
################################################################################

generate_report() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                            ║${NC}"
    echo -e "${BLUE}║                    Test Summary                            ║${NC}"
    echo -e "${BLUE}║                                                            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

    local assertions_total=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))

    echo -e "Test Groups:    ${CYAN}$TESTS_TOTAL${NC}"
    echo -e "Assertions:     ${CYAN}$assertions_total${NC}"
    echo -e "Passed:         ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:         ${RED}$TESTS_FAILED${NC}"
    echo -e "Skipped:        ${YELLOW}$TESTS_SKIPPED${NC}"

    local pass_rate=0
    if [ $assertions_total -gt 0 ]; then
        pass_rate=$((TESTS_PASSED * 100 / assertions_total))
    fi

    echo -e "\nPass Rate:      ${CYAN}${pass_rate}%${NC}"

    log_msg "========================================="
    log_msg "TEST SUMMARY"
    log_msg "Test Groups: $TESTS_TOTAL | Assertions: $assertions_total | Passed: $TESTS_PASSED | Failed: $TESTS_FAILED | Skipped: $TESTS_SKIPPED"
    log_msg "Pass Rate: ${pass_rate}%"
    log_msg "========================================="
    
    echo -e "\n${BLUE}Detailed log saved to:${NC} $LOG_FILE"

    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "\n${YELLOW}⚠ Some tests failed. Check the log file for details.${NC}"
        echo -e "${YELLOW}Common issues:${NC}"
        echo -e "  - Nautilus integration may require logout/reboot"
        echo -e "  - PATH issues may require new shell session"
        echo -e "  - Flatpak apps may need to be installed manually"
    else
        echo -e "\n${GREEN}✓ All tests passed! Your system is configured correctly.${NC}"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header
    log_msg "========================================="
    log_msg "Starting System Installation Test"
    log_msg "Date: $(date)"
    log_msg "User: $USER"
    log_msg "Shell: $SHELL"
    log_msg "========================================="

    echo -e "${CYAN}Running automated tests...${NC}\n"

    # Automated tests
    test_git
    test_nodejs
    test_homebrew
    test_runtimes
    test_zsh_ohmyzsh
    test_spaceship
    test_flatpak_apps
    test_vivaldi_apt
    test_vscode
    test_gnome_favorites
    test_default_terminal
    test_keyboard_shortcuts
    test_config_files

    # Interactive tests
    echo -e "\n${CYAN}Would you like to run interactive tests? (y/n):${NC} "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        interactive_tests
    else
        log_msg "User skipped interactive tests"
    fi

    # Generate report
    generate_report

    log_msg "Test completed"
}

main
