#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Check if script is run with sudo
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run with sudo"
   exit 1
fi

# Create essential directories
create_directories() {
    log_section "Creating Essential Directories"

    local directories=(
        "$HOME/.config"
        "$HOME/.local/bin"
        "$HOME/.cache"
        "$HOME/Development"
        "$HOME/.ssh"
    )

    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            log_info "Creating directory: $dir"
            mkdir -p "$dir"
            log_success "Created $dir"
        else
            log_debug "Directory already exists: $dir"
        fi
    done
}

# Link dotfiles
link_dotfiles() {
    log_section "Linking Dotfiles"

    local dotfiles=(
        ".bashrc"
        ".bash_profile"
    )

    local timestamp=$(date +%Y%m%d_%H%M%S)

    for file in "${dotfiles[@]}"; do
        if [ -f "$HOME/$file" ]; then
            if [ ! -L "$HOME/$file" ]; then  # If it's not already a symlink
                log_info "Backing up existing $file"
                mv "$HOME/$file" "$HOME/${file}.backup_${timestamp}"
            else
                log_debug "$file is already a symlink"
                continue
            fi
        fi

        if [ -f "$DOTFILES_DIR/$file" ]; then
            log_info "Linking $file"
            ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
            log_success "Linked $file"
        else
            log_warning "Source file $file not found in dotfiles"
        fi
    done
}

# Install essential packages
install_essentials() {
    log_section "Installing Essential Packages"

    if [ -f "$DOTFILES_DIR/scripts/essentials.sh" ]; then
        log_info "Running essentials installation script"
        bash "$DOTFILES_DIR/scripts/essentials.sh"
        log_success "Essentials installation completed"
    else
        log_error "Essentials installation script not found"
        exit 1
    fi
}

# Install and configure components
install_components() {
    log_section "Installing Components"

    # Apps installation
    if [ -f "$DOTFILES_DIR/apps/install.sh" ]; then
        log_info "Installing applications..."
        bash "$DOTFILES_DIR/apps/install.sh"
        log_success "Applications installation completed"
    else
        log_debug "Apps installation script not found"
    fi

    # Tooling installation
    if [ -f "$DOTFILES_DIR/tooling/install.sh" ]; then
        log_info "Installing tools..."
        bash "$DOTFILES_DIR/tooling/install.sh"
        log_success "Tools installation completed"
    else
        log_debug "Tooling installation script not found"
    fi

    # Programming languages installation
    if [ -f "$DOTFILES_DIR/langs/install.sh" ]; then
        log_info "Installing programming languages..."
        bash "$DOTFILES_DIR/langs/install.sh"
        log_success "Programming languages installation completed"
    else
        log_debug "Languages installation script not found"
    fi
}

# Configure bash environment
setup_bash() {
    log_section "Setting Up Bash Environment"

    if [ -f "$DOTFILES_DIR/bash/install.sh" ]; then
        log_info "Setting up bash-it and shell configurations..."
        # Running bash/install.sh as the current user, not root
        sudo -u "$SUDO_USER" bash "$DOTFILES_DIR/bash/install.sh"
        log_success "Bash environment setup completed"
    else
        log_error "bash/install.sh not found"
        exit 1
    fi
}

# Install Git
install_git() {
  log_section "Installing Git"

  if [ -f "$DOTFILES_DIR/git/install.sh" ]; then
    log_info "Running Git installation script"
    bash "$DOTFILES_DIR/git/install.sh"
    log_success "Git installation completed"
  else
    log_error "Git installation script not found"
    exit 1
  fi
}

main() {
  log_section "Starting Dotfiles Installation"

  # Create directories
  create_directories

  # Install essential packages first
  install_essentials

  # Install Git
  install_git

  # Link dotfiles
  link_dotfiles

  # Install and configure components
  install_components

  # Setup bash environment
  setup_bash

  # Set proper permissions
  set_permissions

  log_success "Dotfiles installation completed successfully!"
  log_info "Please restart your terminal or run 'source ~/.bashrc' to apply changes"
}

# Set proper permissions
set_permissions() {
    log_section "Setting File Permissions"

    # Ensure .ssh directory has correct permissions
    if [ -d "$HOME/.ssh" ]; then
        chmod 700 "$HOME/.ssh"
        if [ -f "$HOME/.ssh/config" ]; then
            chmod 600 "$HOME/.ssh/config"
        fi
        log_success "SSH directory permissions set"
    fi

    # Ensure script files are executable
    find "$DOTFILES_DIR" -type f -name "*.sh" -exec chmod +x {} \;
    log_success "Script permissions set"
}

# Main installation flow
main() {
    log_section "Starting Dotfiles Installation"

    # Create directories
    create_directories

    # Install essential packages first
    install_essentials

    # Link dotfiles
    link_dotfiles

    # Install and configure components
    install_components

    # Setup bash environment
    setup_bash

    # Set proper permissions
    set_permissions

    log_success "Dotfiles installation completed successfully!"
    log_info "Please restart your terminal or run 'source ~/.bashrc' to apply changes"
}

# Run main installation
main