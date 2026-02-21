# Ubuntu Development Environment Setup

Automated setup scripts to configure a complete Ubuntu development environment with all tools and configurations. **Now with interactive application selection and dynamic user configuration!**

## ✨ New Features

- 🎯 **Interactive Application Selection** - Choose which apps to install with a visual checklist
- 🔧 **Auto-Detection + Prompts** - Automatically detects system info and prompts for personal details
- 🚀 **Master Installer** - Single script (`install.sh`) that manages the entire flow
- ♻️ **Smart Reboot Management** - Automatic Part 2 execution after reboot (optional)
- 📦 **Added Applications**: gedit text editor and FUSE filesystem support
- 🛡️ **FUSE Safety Check** - Warns about Ubuntu > 24.04 compatibility issues
- 💾 **State Persistence** - Configuration saved between Part 1 and Part 2

## What Gets Installed

### System Utilities
- **build-essential** - Compilation tools (gcc, make, etc.) - *Optional*
- **gedit** - GNOME text editor - *Optional*
- **FUSE** - Filesystem in Userspace (version 2 or 3 based on Ubuntu version) - *Optional*

### Development Tools
- **Git** - Latest version from official PPA with custom configuration - *Optional*
- **Node.js** - LTS version via NVM - *Optional*
- **npm** - Node Package Manager (comes with Node.js) - *Optional*
- **pnpm** - Fast, disk space efficient package manager - *Optional*
- **Deno** - Modern JavaScript/TypeScript runtime - *Optional*
- **Bun** - Fast all-in-one JavaScript runtime - *Optional*
- **Flutter SDK** - UI toolkit and CLI (`flutter`, `dart`)
- **Homebrew** - Package manager for Linux - *Optional*
- **GitHub CLI (gh)** - Official GitHub command-line tool - *Optional*
- **VSCodium** - Open-source build of VS Code without telemetry - *Optional* (Recommended)
- **VS Code** - Visual Studio Code editor - *Optional* (Alternative to VSCodium)

### Shell & Terminal
- **Zsh** - Modern shell - *Optional*
- **Oh-My-Zsh** - Zsh framework - *Optional*
- **Spaceship Prompt** - Beautiful and powerful prompt - *Optional*
- **WezTerm** - GPU-accelerated terminal emulator (Flatpak) - *Optional*

### Zsh Plugins (installed with Oh-My-Zsh)
- `zsh-autosuggestions` - Fish-like autosuggestions
- `zsh-syntax-highlighting` - Syntax highlighting for commands
- `zsh-autocomplete` - Real-time type-ahead completion
- `spaceship-vi-mode` - Vi mode indicator
- `spaceship-react` - React project detection
- `spaceship-flutter` - Flutter project detection
- `spaceship-gradle` - Gradle project detection
- `spaceship-vue` - Vue.js project detection

### Applications (Flatpak)
- **Vivaldi Browser** - Feature-rich web browser - *Optional*
- **Bitwarden** - Password manager - *Optional*
- **Stimulator** - Productivity tool - *Optional*

**Note:** All items marked as *Optional* can be selected/deselected during the interactive installation process.

## Installation

### Prerequisites
- Fresh Ubuntu installation (tested on Ubuntu 22.04 and 24.04)
- Internet connection
- User with sudo privileges
- `whiptail` for interactive menus (usually pre-installed)

### Quick Start (Recommended)

```bash
cd ~/Documents/ubuntu-system-config
sudo ./install.sh
```

The master installer will:
1. Run the interactive configuration wizard
2. Execute Part 1 (pre-reboot setup)
3. Prompt for reboot with automatic Part 2 execution option
4. Handle the complete installation flow

### Command Line Options

You can also use `install.sh` with command line arguments:

```bash
# Interactive menu (default)
./install.sh

# Run full installation
./install.sh --post-reboot  # Used internally after reboot

# Verify installation
./verify.sh
```

**Tip:** Use `repair --auto` in scripts or CI/CD to check installation status without interaction.

### Manual Installation

The `install.sh` script handles both parts of the installation automatically. If you need to run Part 2 manually (e.g., if auto-reboot didn't work), you can run:

```bash
sudo ./install.sh --post-reboot
```

#### Step 4: Verify Installation (Optional but Recommended)

Run the test script to verify everything was installed correctly:

```bash
cd ~/Documents/ubuntu-system-config
./verify.sh
```

This will:
- Run automated tests for all installed tools
- Test keyboard shortcuts (interactive)
- Test Nautilus integration (interactive)
- Generate a detailed report with pass/fail status
- Save results to a timestamped log file

**Note:** Tests now validate that Git is configured (any values), not expecting specific hardcoded values.

#### Step 5: Log Out and Log Back In

For the shell change to take effect, log out and log back in.

## Interactive Configuration

### Application Selection

When you run `install.sh` or `setup.sh`, you'll see an interactive menu with checkboxes:

```
┌─────────── Selection of Applications ───────────┐
│ Use space to select/deselect, Enter to confirm │
│ All options are selected by default            │
│                                                 │
│ === SYSTEM BASE ===                            │
│ [X] git                                        │
│ [X] build-essential                            │
│ [X] gedit                                      │
│ [X] fuse                                       │
│                                                │
│ === DEVELOPMENT ===                            │
│ [X] nvm-node                                   │
│ [X] pnpm                                       │
│ ... and more ...                               │
└────────────────────────────────────────────────┘
```

**Note:** If `whiptail` is not available, the script will fall back to manual yes/no prompts for each application.

### Personal Information Prompts

The script will ask for your personal information with auto-detection:

```
Name for Git:
Detected suggestion: John Doe
Press Enter to accept or type a new name: _

Email for Git:
Detected suggestion: john.doe@example.com
Press Enter to accept or type a new email: _
```

The script automatically:
- Detects your username and home directory
- Checks existing Git configuration
- Suggests values based on system information
- Validates email format

### FUSE Compatibility Check

For Ubuntu > 24.04, the script will warn about FUSE compatibility:

```
⚠ WARNING: You are using Ubuntu 24.10
⚠ WARNING: Installing FUSE on versions > 24.04 may cause system problems!

Recommendation: Do not install FUSE on this Ubuntu version

Do you want to continue with FUSE installation anyway? (y/N): _
```

## Configuration Files

All configuration files are stored in the `configs/` directory:

- `.zshrc` - Zsh configuration (**now with dynamic $HOME paths**)
- `.spaceshiprc.zsh` - Spaceship prompt configuration
- `wezterm.lua` - WezTerm terminal configuration

These files are automatically copied to your home directory during Part 2.

**Important:** `.zshrc` now uses `$HOME` variable instead of hardcoded paths like `/home/neto/`, making it work for any user.

## Pinned Applications (GNOME Favorites)

The setup automatically pins applications to your dash **based on what you selected**:

- **Nautilus** (Files) - Always pinned
- **WezTerm** - If selected
- **Vivaldi Browser** - If selected
- **VSCodium** - If selected (recommended)
- **VS Code** - If selected (alternative)
- **Bitwarden** - If selected
- **Stimulator** - If selected

Apps not selected will not appear in favorites (no more empty slots!).

## Keyboard Shortcuts

If WezTerm is selected, these keyboard shortcuts are configured:

- **Super + T** (Windows key + T) - Opens WezTerm
- **Ctrl + Alt + P** - Opens WezTerm (alternative shortcut)
- **Ctrl + Alt + T** - Disabled (was GNOME Terminal, now does nothing)

### Nautilus Integration

When you right-click a folder in Nautilus (Files) and select **"Open in Terminal"**, it will now open **WezTerm** instead of GNOME Terminal, and automatically navigate to that folder.

## Custom Aliases

The setup includes these useful aliases (in `.zshrc`):

- `zshconfig` - Edit .zshrc in VSCodium/VS Code
- `ohmyzsh` - Edit Oh-My-Zsh directory in VSCodium/VS Code
- `idea` - Launch IntelliJ IDEA Ultimate (if installed)
- `c` - Launch Claude Code with permissions skip
- `wsplit` - Split WezTerm pane
- `wclose` - Close WezTerm pane

## Git Configuration

Git is configured with the information **you provide during installation**:
- **Default Branch:** `main`
- **User Name:** From your input (detected from system or manually entered)
- **User Email:** From your input (detected from git config or manually entered)

## Paths

After installation, tools are located at:

- **NVM:** `~/.nvm`
- **Node.js:** Managed by NVM
- **pnpm:** `~/.local/share/pnpm`
- **Deno:** `~/.deno`
- **Bun:** `~/.bun`
- **Homebrew:** `~/.linuxbrew`
- **Oh-My-Zsh:** `~/.oh-my-zsh`
- **WezTerm Config:** `~/.config/wezterm/wezterm.lua`

All paths use `$HOME` and work for any user.

## Troubleshooting

### PATH Issues (Node, Bun, Deno, Homebrew not found)

The setup script automatically configures all PATHs and verifies each installation. If you still encounter PATH issues:

1. **Make sure you're using Zsh:**
   ```bash
   echo $SHELL
   # Should output: /usr/bin/zsh or /bin/zsh
   ```

2. **Reload your shell configuration:**
   ```bash
   source ~/.zshrc
   ```

3. **Check if tools are installed:**
   ```bash
   # For NVM and Node.js
   [ -s "$HOME/.nvm/nvm.sh" ] && source "$HOME/.nvm/nvm.sh"
   node --version

   # For Homebrew
   eval "$($HOME/.linuxbrew/Homebrew/bin/brew shellenv)"
   brew --version

   # For Deno
   export DENO_INSTALL="$HOME/.deno"
   export PATH="$DENO_INSTALL/bin:$PATH"
   deno --version

   # For Bun
   export BUN_INSTALL="$HOME/.bun"
   export PATH="$BUN_INSTALL/bin:$PATH"
   bun --version
   ```

### Flatpak not working after Part 1

**Solution:** You must reboot after Part 1. Flatpak requires a system restart to initialize properly.

### Part 2 can't find configuration

**Error:** `Configuration file not found: .setup_state`

**Solution:** Run Part 1 (`setup.sh`) first. It creates the `.setup_state` file that Part 2 needs.

### Homebrew installation failed

**What the script does:**
1. Ensures `build-essential` is installed (GCC and build tools)
2. Installs Homebrew to `~/.linuxbrew/`
3. Installs GCC via Homebrew (recommended for Linux)
4. Installs selected packages (like GitHub CLI)

**Checking the installation:**
```bash
# Check if Homebrew directory exists
ls -la ~/.linuxbrew/Homebrew/bin/brew

# Check logs for errors
grep -A 5 "Homebrew" setup_*.log

# Test Homebrew manually
eval "$($HOME/.linuxbrew/Homebrew/bin/brew shellenv)"
brew --version
```

**Common issues:**
- Missing build-essential (should be auto-installed)
- Network issues during download
- Insufficient disk space
- Installation took too long and timed out

**Note:** The `.zshrc` file will only load Homebrew if it's actually installed, preventing errors when Homebrew is not selected.

### FUSE installation issues

If you see errors about FUSE on Ubuntu > 24.04:
- The script should have warned you during installation
- You can skip FUSE during the interactive selection
- If already installed and causing issues, remove it:
  ```bash
  sudo apt remove fuse fuse3
  ```

### gsettings errors in Part 2

If you see errors about `gsettings` or DBUS:
- This is normal if running Part 2 from a non-graphical session (SSH, recovery mode)
- These errors don't affect the main installation
- GNOME settings (favorites, shortcuts) won't be configured, but you can set them manually

## Advanced Usage

### Re-running Parts

You can safely re-run either part:
- **Part 1:** Will skip already-installed software and update `.setup_state`
- **Part 2:** Will load configuration from `.setup_state` and re-apply settings

### Customizing Before Installation

Edit `config_prompts.sh` to change default selections or modify prompts.

### Installing on Different Users

The scripts now automatically detect and use the correct user and home directory. No manual editing required!

### Viewing Configuration State

```bash
cat .setup_state
```

This shows what was selected and installed in Part 1.

## System Requirements

- Ubuntu 22.04 or later (24.04 recommended)
- At least 5GB free disk space
- Stable internet connection
- ~30-45 minutes for complete installation

## What Requires Sudo Password

The scripts run with sudo and handle all privileged operations, so you only need to enter your password once at the start. The scripts properly execute user-level installations (NVM, Deno, Bun, etc.) as your actual user, not as root.

## Logging and Debugging

All scripts generate detailed log files with timestamps:

- **`logs/install_YYYYMMDD_HHMMSS.log`** - Installation log (Part 1 & 2)
- **`logs/verify_results_YYYYMMDD_HHMMSS.log`** - Verification results

Logs include:
- Timestamp for each operation
- Success/failure status
- Error messages
- Warnings
- All configuration changes
- User configuration details

**Viewing logs:**
```bash
# View latest setup log
cat setup_*.log | tail -50

# Search for errors
grep ERROR setup_*.log

# Search for warnings
grep WARNING setup_*.log

# Check what user configuration was used
grep "CONFIG_" .setup_state
```

**Logs are saved automatically** in the working directory and can be used for:
- Debugging installation issues
- Verifying what was installed
- Troubleshooting configuration problems
- Reporting issues

## Testing and Validation

The `verify.sh` script provides comprehensive testing:

### Automated Tests
- Git installation and configuration (validates any user, not hardcoded)
- Node.js, npm, pnpm installation
- Homebrew and GitHub CLI
- Deno and Bun runtimes
- Zsh and Oh-My-Zsh
- Spaceship Prompt and plugins
- Flatpak applications
- VSCodium / VS Code
- gedit (if installed)
- GNOME favorites configuration
- Default terminal settings
- Keyboard shortcuts configuration
- Configuration files

### Interactive Tests
- **Super+T** keyboard shortcut
- **Ctrl+Alt+P** keyboard shortcut
- **Ctrl+Alt+T** disabled (should do nothing)
- Nautilus "Open in Terminal" integration

### Running Tests
```bash
./verify.sh
```

The script will:
1. Run all automated tests
2. Ask if you want to run interactive tests
3. Generate a pass/fail summary
4. Save detailed results to a log file
5. Show pass rate percentage

## Files in This Directory

```
ubuntu-system-config/
├── README.md                  # This file
├── install.sh                 # Master installer (recommended)
├── config_prompts.sh          # Interactive configuration functions
├── verify.sh                  # Verification script
├── .install_state             # Configuration state (generated)
├── install_*.log              # Installation logs (generated)
├── verify_results_*.log       # Verification results logs (generated)
└── configs/                   # Configuration files
    ├── .zshrc                 # Zsh configuration (dynamic paths)
    ├── .spaceshiprc.zsh       # Spaceship prompt configuration
    └── wezterm.lua            # WezTerm configuration
```

## Migration from Old Version

If you previously used this setup with hardcoded "Neto" user:

1. Delete old `.zshrc` in your home directory:
   ```bash
   rm ~/.zshrc
   ```

2. Run the new installation:
   ```bash
   sudo ./install.sh
   ```

3. The new `.zshrc` will use `$HOME` and work for your user.

## License

These scripts are provided as-is for personal use. Modify as needed for your setup.

---

**Note:** These scripts will modify your system configuration. It's recommended to run them on a fresh Ubuntu installation or backup your existing configurations before running.
