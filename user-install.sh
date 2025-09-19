#!/usr/bin/env bash

set -euo pipefail
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Check that we're NOT running with sudo
if [[ $EUID -eq 0 ]]; then
   log_error "This script should NOT be run with sudo"
   log_info "Usage: ./user-install.sh"
   exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew
install_homebrew() {
    log_section "Installing Homebrew"

    if ! command_exists brew; then
        log_info "Installing Homebrew..."

        # Install Homebrew without sudo
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null 2>/dev/null || {
            log_error "Failed to install Homebrew"
            return 1
        }

        log_success "Homebrew installed successfully"
    else
        log_info "Homebrew is already installed"
    fi

    # Set up Homebrew environment for current session
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true

    # Verify brew is available
    if command_exists brew; then
        # Add Homebrew to PATH in bash environment if not already there
        if ! grep -q "brew shellenv" "$DOTFILES_DIR/bash/environment.bash" 2>/dev/null; then
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$DOTFILES_DIR/bash/environment.bash" || log_warning "Failed to add brew to environment.bash"
        fi
        return 0
    else
        log_warning "Homebrew not available in PATH"
        return 1
    fi
}

# Install programming languages
install_languages() {
    log_section "Installing Programming Languages"

    if [ -f "$DOTFILES_DIR/langs/install.sh" ]; then
        log_info "Installing programming languages..."
        bash "$DOTFILES_DIR/langs/install.sh" || log_warning "Some languages may have failed to install"
    else
        log_error "Languages installation script not found"
    fi
}

# Install Git configuration
install_git_config() {
    log_section "Installing Git Configuration"

    if [ -f "$DOTFILES_DIR/git/install.sh" ]; then
        log_info "Setting up Git configuration..."
        bash "$DOTFILES_DIR/git/install.sh" || log_warning "Git configuration may have failed"
    else
        log_error "Git installation script not found"
    fi
}

# Install fzf
install_fzf() {
    log_section "Installing fzf"

    if command_exists brew; then
        log_info "Installing fzf using Homebrew..."
        brew install fzf 2>/dev/null || log_warning "fzf may already be installed"

        # Run fzf install script
        if [ -d "$(brew --prefix)/opt/fzf" ]; then
            $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish --no-zsh 2>/dev/null || log_warning "fzf post-install script failed"
            log_success "fzf installation completed"
        fi
    else
        log_warning "Homebrew not available - skipping fzf installation"
        log_info "You can install fzf manually later"
    fi
}

# Setup bash environment
setup_bash() {
    log_section "Setting Up Bash Environment"

    if [ -f "$DOTFILES_DIR/bash/install.sh" ]; then
        log_info "Setting up bash-it and shell configurations..."
        bash "$DOTFILES_DIR/bash/install.sh" || log_warning "Bash setup may have encountered issues"
    else
        log_error "bash/install.sh not found"
    fi
}

# Install Homebrew packages
install_brew_packages() {
    log_section "Installing Homebrew Packages"

    if command_exists brew; then
        log_info "Installing common Homebrew packages..."

        # Development tools
        local brew_packages=(
            "gh"           # GitHub CLI
            "lazygit"      # Terminal UI for git
            "bat"          # Better cat
            "eza"          # Better ls
            "zoxide"       # Better cd
            "tldr"         # Simplified man pages
            "httpie"       # HTTP client
            "jq"           # JSON processor
            "yq"           # YAML processor
            "tmux"         # Terminal multiplexer
            "direnv"       # Directory-specific environment variables
        )

        for package in "${brew_packages[@]}"; do
            if ! brew list "$package" &>/dev/null; then
                log_info "Installing $package..."
                brew install "$package" || log_warning "Failed to install $package"
            else
                log_debug "$package is already installed"
            fi
        done

        log_success "Homebrew packages installed"
    else
        log_warning "Homebrew not available - skipping brew packages"
    fi
}

# Install user Flatpak applications
install_user_flatpaks() {
    log_section "Installing User Flatpak Applications"

    if command_exists flatpak; then
        # Check if flathub is configured for user
        if ! flatpak remote-list --user | grep -q flathub; then
            log_info "Adding Flathub repository for user..."
            flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi

        # Flatpak apps that can be installed at user level
        local flatpak_apps=(
            "org.flameshot.Flameshot"
            "com.bitwarden.desktop"
            "md.obsidian.Obsidian"
            "com.discordapp.Discord"
            "ca.desrt.dconf-editor"
        )

        for app in "${flatpak_apps[@]}"; do
            if ! flatpak list --user | grep -q "$app"; then
                log_info "Installing $app (flatpak)..."
                flatpak install --user -y flathub "$app" || log_warning "Failed to install $app"
            else
                log_debug "$app is already installed"
            fi
        done

        log_success "Flatpak applications installed"
    else
        log_warning "Flatpak not available - skipping flatpak apps"
    fi
}

# Install additional development tools via language package managers
install_dev_tools() {
    log_section "Installing Additional Development Tools"

    # Install tools via cargo if Rust is available
    if command_exists cargo; then
        log_info "Installing Rust-based tools..."

        local cargo_tools=(
            "ripgrep"      # Fast grep alternative
            "fd-find"      # Fast find alternative
            "bat"          # Better cat with syntax highlighting
            "eza"          # Modern ls replacement
            "zoxide"       # Smarter cd
            "tokei"        # Code statistics
            "bottom"       # System monitor
            "du-dust"      # Disk usage viewer
        )

        for tool in "${cargo_tools[@]}"; do
            if ! cargo install --list | grep -q "^$tool "; then
                log_info "Installing $tool via cargo..."
                cargo install "$tool" || log_warning "Failed to install $tool"
            else
                log_debug "$tool is already installed"
            fi
        done
    fi

    # Install Node.js global tools if npm is available
    if command_exists npm; then
        log_info "Installing Node.js global packages..."

        local npm_packages=(
            "npm@latest"
            "yarn"
            "pnpm"
            "typescript"
            "ts-node"
            "eslint"
            "prettier"
            "nodemon"
            "pm2"
        )

        for package in "${npm_packages[@]}"; do
            log_info "Installing $package globally..."
            npm install -g "$package" || log_warning "Failed to install $package"
        done
    fi

    # Install Python tools if pip/uv is available
    if command_exists uv; then
        log_info "Installing Python tools via uv..."

        local python_tools=(
            "ruff"
            "black"
            "mypy"
            "pytest"
            "ipython"
            "poetry"
            "pipx"
            "pre-commit"
            "httpie"
            "tldr"
        )

        for tool in "${python_tools[@]}"; do
            log_info "Installing $tool..."
            uv tool install "$tool" || log_warning "Failed to install $tool"
        done
    fi

    log_success "Development tools installed"
}

# Create user configuration files
create_config_files() {
    log_section "Creating User Configuration Files"

    # Create necessary directories
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.cache"
    mkdir -p "$HOME/Development"

    # Create language-specific config directories
    mkdir -p "$HOME/.config/pip"
    mkdir -p "$HOME/.npm-global"
    mkdir -p "$HOME/.composer"

    # Link configuration files if they exist
    if [ -d "$DOTFILES_DIR/config" ]; then
        log_info "Linking configuration files..."
        # Add your dotfile linking logic here
    fi

    log_success "Configuration files created"
}

# Main function
main() {
    log_section "Starting User Installation (No Sudo Required)"
    log_info "Installing user-level tools and configurations..."

    # Create user directories and configs first
    create_config_files

    # Install Homebrew first - many tools depend on it
    install_homebrew || log_warning "Continuing without Homebrew"

    # Setup bash environment early for PATH configuration
    setup_bash || log_warning "Bash setup encountered issues"

    # Install languages (Rust, Python, Node.js, PHP)
    install_languages || log_warning "Some languages may have failed"

    # Install package manager tools
    install_brew_packages || log_warning "Some Homebrew packages may have failed"

    # Install user-level applications
    install_user_flatpaks || log_warning "Some Flatpak apps may have failed"

    # Install additional development tools
    install_dev_tools || log_warning "Some development tools may have failed"

    # Install fzf
    install_fzf || log_warning "fzf installation may have failed"

    # Setup git configuration
    install_git_config || log_warning "Git configuration may have failed"

    log_success "User installation completed!"
    log_info ""
    log_info "Next steps:"
    log_info "1. Log out and log back in for all changes to take effect"
    log_info "2. Open a new terminal to load the updated shell configuration"
    log_info "3. Run 'brew doctor' to verify Homebrew installation"
    log_info "4. Run 'rustc --version', 'node --version', 'python --version' to verify language installations"
}

# Run main installation
main "$@"