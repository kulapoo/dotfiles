#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SUDO_USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
REAL_USER=$SUDO_USER

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
        "$SUDO_USER_HOME/.config"
        "$SUDO_USER_HOME/.local/bin"
        "$SUDO_USER_HOME/.cache"
        "$SUDO_USER_HOME/Development"
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


# Install essential packages
install_essentials() {
    log_section "Installing Essential Packages"

    if [ -f "$DOTFILES_DIR/essentials/install.sh" ]; then
        log_info "Running essentials installation script"
        bash "$DOTFILES_DIR/essentials/install.sh"
        log_success "Essentials installation completed"
    else
        log_error "Essentials installation script not found"
        exit 1
    fi
}

# Install and configure components
install_apps() {
  log_section "Installing Applications"

  if [ -f "$DOTFILES_DIR/apps/install.sh" ]; then
    log_info "Installing applications..."
    bash "$DOTFILES_DIR/apps/install.sh"
    log_success "Applications installation completed"
  else
    log_debug "Apps installation script not found"
  fi
}

install_tooling() {
  log_section "Installing Tooling"

  if [ -f "$DOTFILES_DIR/tooling/install.sh" ]; then
    log_info "Installing tools..."
    bash "$DOTFILES_DIR/tooling/install.sh"
    log_success "Tools installation completed"
  else
    log_debug "Tooling installation script not found"
  fi
}


# Install Git


main() {
  log_section "Starting Dotfiles Installation"

  create_directories
  set_permissions

  install_essentials
  install_apps
  install_git

  su -c "$DOTFILES_DIR/user-install.sh" - $SUDO_USER

  log_success "Dotfiles installation completed successfully!"
}

# Set proper permissions
set_permissions() {
    log_section "Setting File Permissions"

    # Ensure .ssh directory has correct permissions
    if [ -d "$SUDO_USER_HOME/.ssh" ]; then
        chmod 700 "$SUDO_USER_HOME/.ssh"
        if [ -f "$SUDO_USER_HOME/.ssh/config" ]; then
            chmod 600 "$SUDO_USER_HOME/.ssh/config"
        fi
        log_success "SSH directory permissions set"
    fi

    # Ensure script files are executable
    find "$DOTFILES_DIR" -type f -name "*.sh" -exec chmod +x {} \;
    log_success "Script permissions set"
}


# Run main installation
main