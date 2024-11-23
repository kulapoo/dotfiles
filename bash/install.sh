#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Install bash-it if not already installed
install_bashit() {
    log_section "Installing Bash-it"

    if [ ! -d "$HOME/.bash_it" ]; then
        log_info "Cloning bash-it repository..."
        git clone --depth=1 https://github.com/Bash-it/bash-it.git "$HOME/.bash_it"
        "$HOME/.bash_it/install.sh" --silent --no-modify-config
        log_success "Bash-it installed successfully"
    else
        log_info "Bash-it is already installed"
    fi
}

# Enable bash-it components
setup_bashit_components() {
    log_section "Setting Up Bash-it Components"

    # Load bash-it
    source "$HOME/.bash_it/bash_it.sh"

    log_info "Enabling completion features..."
    local completions=(
        "git"
        "system"
        "bash-it"
        "pip"
        "pip3"
        "docker"
        "docker-compose"
        "ssh"
    )

    for completion in "${completions[@]}"; do
        bash-it enable completion "$completion"
    done

    log_info "Enabling plugins..."
    local plugins=(
        "base"
        "dirs"
        "extract"
        "git"
        "history"
        "ssh"
    )

    for plugin in "${plugins[@]}"; do
        bash-it enable plugin "$plugin"
    done

    log_info "Enabling aliases..."
    local aliases=(
        "general"
        "git"
        "docker"
    )

    for alias in "${aliases[@]}"; do
        bash-it enable alias "$alias"
    done

    log_success "Bash-it components enabled successfully"
}

# Setup custom bash configuration

# Main setup function
main() {
    log_section "Starting Bash-it Installation and Setup"

    install_bashit
    setup_bashit_components
    setup_custom_config

    log_success "Bash-it setup completed successfully!"
    log_info "Please restart your terminal or source ~/.bashrc to apply changes"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi