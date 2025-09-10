#!/usr/bin/env bash

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}


# Install Rust and Cargo
install_rust() {
    log_section "Installing Rust"
    if ! command_exists rustc; then
        log_info "Installing Rust using rustup..."

        # Set Rust environment variables
        export RUSTUP_HOME="$HOME/.rustup"
        export CARGO_HOME="$HOME/.cargo"

        # Install Rust without modifying path (latest stable)
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
            sh -s -- -y --no-modify-path --default-toolchain stable

        # Manually set up the environment
        export PATH="$HOME/.cargo/bin:$PATH"

        # Source cargo environment if it exists
        if [ -f "$HOME/.cargo/env" ]; then
            source "$HOME/.cargo/env"
        fi

        # Install common Rust tools
        local rust_tools=(
            "cargo-edit"    # Add dependencies from command line
            "cargo-watch"   # Watch for changes
            "cargo-audit"   # Audit dependencies
            "cargo-update"  # Update installed binaries
        )

        for tool in "${rust_tools[@]}"; do
            log_info "Installing $tool..."
            cargo install "$tool"
        done

        log_success "Rust installed successfully"

        # Optional: Inform user about PATH configuration
        log_info "Note: Add the following line to your shell configuration file:"
        log_info "export PATH=\"\$HOME/.cargo/bin:\$PATH\""

    else
        log_info "Rust is already installed"
        # Update Rust
        log_info "Updating Rust..."
        rustup update
    fi
}
# Install Python and tools using uv
install_python() {
  log_section "Installing Python with uv"

  # Install uv if not already installed
  if ! command_exists uv; then
    log_info "Installing uv (Python package and project manager)..."
    
    # Install uv using the official installer
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add uv to PATH for current session (uv installs to .cargo/bin)
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Source the uv completions if available
    if [ -f "$HOME/.cargo/bin/uv" ]; then
      eval "$($HOME/.cargo/bin/uv generate-shell-completion bash)"
    fi
    
    log_success "uv installed successfully"
  else
    log_info "uv is already installed"
    # Self-update uv
    log_info "Updating uv..."
    uv self-update || log_info "uv is already at the latest version"
  fi

  # Install Python using uv
  log_info "Installing Python using uv..."
  
  # Install the latest stable Python version
  uv python install
  
  # List available Python versions
  log_info "Available Python versions:"
  uv python list
  
  # Install commonly used Python tools globally
  log_info "Installing common Python tools..."
  
  # Create a tools directory for global installations
  mkdir -p "$HOME/.local/share/uv-tools"
  
  # Install essential Python tools
  local python_tools=(
    "ruff"          # Fast Python linter and formatter
    "mypy"          # Static type checker
    "black"         # Code formatter
    "pytest"        # Testing framework
    "ipython"       # Enhanced Python REPL
    "poetry"        # Dependency management
    "pipx"          # Install Python apps in isolated environments
    "pre-commit"    # Git hook framework
  )
  
  for tool in "${python_tools[@]}"; do
    log_info "Installing $tool..."
    uv tool install "$tool" || log_warning "Failed to install $tool"
  done
  
  log_success "Python and tools installed successfully"
  
  # Inform user about environment setup
  log_info "Note: uv manages Python versions similar to nvm for Node.js"
  log_info "Use 'uv python list' to see available versions"
  log_info "Use 'uv python install <version>' to install a specific version"
  log_info "Use 'uv venv' to create virtual environments"
}

install_nodejs() {
    log_section "Installing Node.js"
    if ! command_exists node; then
        log_info "Installing Node.js using nvm..."

        # Set NVM environment variables
        export NVM_DIR="$HOME/.nvm"

        # Get the latest NVM version
        NVM_LATEST=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep -oP '"tag_name": "\K[^"]*')
        
        # Install nvm without automatic profile modifications
        log_info "Installing NVM ${NVM_LATEST}..."
        PROFILE="/dev/null" curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_LATEST}/install.sh" | bash

        # Create NVM directory if it doesn't exist
        mkdir -p "$NVM_DIR"

        # Source nvm manually
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

        if ! command_exists nvm; then
            log_error "NVM installation failed. Please check your internet connection and try again."
            return 1
        fi

        # Install latest LTS version of Node.js
        log_info "Installing Node.js LTS version..."
        nvm install --lts
        nvm use --lts

        # Install global npm packages
        local npm_packages=(
            "npm@latest"    # Update npm itself
            "yarn"          # Alternative package manager
            "pnpm"         # Fast, disk space efficient package manager
            "typescript"    # TypeScript compiler
            "ts-node"      # TypeScript execution environment
            "eslint"       # Linter
            "prettier"     # Code formatter
        )

        log_info "Installing global npm packages..."
        for package in "${npm_packages[@]}"; do
            log_info "Installing $package..."
            npm install -g "$package"
        done

        log_success "Node.js installed successfully"

        # Inform user about required environment setup
        log_info "Note: Add the following lines to your shell configuration file:"
        log_info 'export NVM_DIR="$HOME/.nvm"'
        log_info '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
        log_info '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'

    else
        log_info "Node.js is already installed"
        # Update npm
        log_info "Updating npm..."
        npm install -g npm@latest
    fi
}

# Install PHP and Composer
install_php() {
  log_section "Installing PHP"

  if ! command_exists php; then
    log_info "Installing PHP and common extensions using Homebrew..."
    brew install php
    log_success "PHP installed successfully"
  else
    log_info "PHP is already installed"
  fi

  # Install Composer
  if ! command_exists composer; then
    log_info "Installing Composer (latest version)..."
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
    
    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        log_error "Composer installer checksum mismatch"
        rm composer-setup.php
        return 1
    fi
    
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    php -r "unlink('composer-setup.php');"
    log_success "Composer installed successfully"
  else
    log_info "Composer is already installed"

    # Update Composer
    log_info "Updating Composer..."
    composer self-update
  fi
}

# Create configuration files
create_config_files() {
    log_section "Creating Configuration Files"

    # Create necessary directories
    mkdir -p "$HOME/.config/pip"
    mkdir -p "$HOME/.npm-global"
    mkdir -p "$HOME/.composer"

    # Link configuration files if they exist in dotfiles
    local configs=(
        "pip.conf:$HOME/.config/pip/pip.conf"
        "npmrc:$HOME/.npmrc"
        "cargo-config.toml:$HOME/.cargo/config.toml"
    )

    for config in "${configs[@]}"; do
        local src="${config%%:*}"
        local dest="${config#*:}"
        if [ -f "$DOTFILES_DIR/langs/config/$src" ]; then
            log_info "Linking $src..."
            ln -sf "$DOTFILES_DIR/langs/config/$src" "$dest"
        fi
    done
}

# Main function
main() {
    log_section "Starting Programming Languages Installation"

    # Create directories
    mkdir -p "$HOME/.local/bin"

    # Add local bin to PATH
    export PATH="$HOME/.local/bin:$PATH"

    # Install languages
    install_rust
    install_python
    install_nodejs
    install_php

    log_success "Programming languages installation completed!"
    log_warning "Please log out and log back in for group changes to take effect"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi