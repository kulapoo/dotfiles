#!/usr/bin/env bash

set -euo pipefail
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}


install_langs() {
  log_section "Installing Programming Languages"

  if [ -f "$DOTFILES_DIR/langs/install.sh" ]; then
    log_info "Installing programming languages..."
    bash "$DOTFILES_DIR/langs/install.sh"
    log_success "Programming languages installation completed"
  else
    log_debug "Languages installation script not found"
  fi
}

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

main() {
  install_homebrew

  install_langs

  setup_bash

}



main