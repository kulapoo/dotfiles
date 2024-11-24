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

        # Install Rust without modifying path
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
            RUSTUP_UPDATE_ROOT="" sh -s -- -y --no-modify-path

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
# Install Python and tools
install_python() {
  log_section "Installing Python"

  # Install Python and pip using Homebrew
  if ! command_exists python3; then
    log_info "Installing Python and dependencies using Homebrew..."
    brew install python
    log_success "Python installed successfully"
  else
    log_info "Python is already installed"
  fi

  # Install pyenv for Python version management
  if ! command_exists pyenv; then
    log_info "Installing pyenv..."
    brew install pyenv

    # Add pyenv to PATH
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"

    log_success "pyenv installed successfully"
  else
    log_info "pyenv is already installed"
  fi

  # Install poetry for dependency management
  if ! command_exists poetry; then
    log_info "Installing Poetry..."
    curl -sSL https://install.python-poetry.org | python3 -
    export PATH="$HOME/.local/bin:$PATH"
    log_success "Poetry installed successfully"
  else
    log_info "Poetry is already installed"
  fi

  # Install common Python packages
  log_info "Installing common Python packages..."
  local python_packages=(
    "pipx"          # Install and run Python applications in isolated environments
    "black"         # Code formatter
    "flake8"        # Linter
    "mypy"          # Static type checker
    "pytest"        # Testing framework
    "ipython"       # Enhanced interactive Python shell
  )

  for package in "${python_packages[@]}"; do
    if ! pip3 show "$package" > /dev/null 2>&1; then
      pip3 install --user "$package"
      log_success "$package installed successfully"
    else
      log_info "$package is already installed"
    fi
  done
}

install_nodejs() {
    log_section "Installing Node.js"
    if ! command_exists node; then
        log_info "Installing Node.js using nvm..."

        # Set NVM environment variables
        export NVM_DIR="$HOME/.nvm"

        # Install nvm without automatic profile modifications
        PROFILE="/dev/null" curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

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
    log_info "Installing Composer..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === '$(curl -sS https://composer.github.io/installer.sig)') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
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