#!/usr/bin/env bash

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Docker and Docker Compose
install_docker() {
    log_section "Installing Docker"

    if ! command_exists docker; then
        log_info "Installing Docker..."

        # Add Docker's official GPG key
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Add the repository to Apt sources
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Add user to docker group
        sudo usermod -aG docker "$USER"

        log_success "Docker installed successfully"
    else
        log_info "Docker is already installed"
    fi

    # Install docker-compose if not already installed
    if ! command_exists docker-compose; then
        log_info "Installing Docker Compose..."
        sudo apt-get install -y docker-compose
        log_success "Docker Compose installed successfully"
    else
        log_info "Docker Compose is already installed"
    fi
}

# Install Rust and Cargo
install_rust() {
    log_section "Installing Rust"

    if ! command_exists rustc; then
        log_info "Installing Rust using rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

        # Source cargo environment
        source "$HOME/.cargo/env"

        # Install common Rust tools
        local rust_tools=(
            "cargo-edit"     # Add dependencies from command line
            "cargo-watch"    # Watch for changes
            "cargo-audit"    # Audit dependencies
            "cargo-update"   # Update installed binaries
        )

        for tool in "${rust_tools[@]}"; do
            log_info "Installing $tool..."
            cargo install "$tool"
        done

        log_success "Rust installed successfully"
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

    # Install Python and pip
    log_info "Installing Python and dependencies..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv

    # Install pyenv for Python version management
    if ! command_exists pyenv; then
        log_info "Installing pyenv..."
        curl https://pyenv.run | bash

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
        log_success "Poetry installed successfully"
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
        pip3 install --user "$package"
    done
}

# Install Node.js and npm
install_nodejs() {
    log_section "Installing Node.js"

    if ! command_exists node; then
        log_info "Installing Node.js using nvm..."

        # Install nvm
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

        # Source nvm
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        # Install latest LTS version of Node.js
        nvm install --lts
        nvm use --lts

        # Install global npm packages
        local npm_packages=(
            "npm@latest"     # Update npm itself
            "yarn"           # Alternative package manager
            "pnpm"          # Fast, disk space efficient package manager
            "typescript"     # TypeScript compiler
            "ts-node"       # TypeScript execution environment
            "eslint"        # Linter
            "prettier"      # Code formatter
        )

        for package in "${npm_packages[@]}"; do
            npm install -g "$package"
        done

        log_success "Node.js installed successfully"
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

    log_info "Installing PHP and common extensions..."
    sudo apt-get update
    sudo apt-get install -y \
        php \
        php-cli \
        php-fpm \
        php-json \
        php-common \
        php-mysql \
        php-zip \
        php-gd \
        php-mbstring \
        php-curl \
        php-xml \
        php-bcmath \
        php-json

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
    # install_docker
    install_rust
    # install_python
    install_nodejs
    # install_php

    log_success "Programming languages installation completed!"
    log_warning "Please log out and log back in for group changes to take effect"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi