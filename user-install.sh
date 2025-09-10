#!/usr/bin/env bash

set -euo pipefail
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

install_homebrew() {
  log_section "Installing Homebrew"
  
  # Check if brew is already installed
  if ! command -v brew &>/dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null
    
    # Set up Homebrew environment for current session
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    log_success "Homebrew installed successfully"
  else
    log_info "Homebrew is already installed"
    # Still need to set up environment for current session
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  
  # Add Homebrew to PATH if not already there (idempotent)
  if ! grep -q "brew shellenv" "$DOTFILES_DIR/bash/environment.bash"; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$DOTFILES_DIR/bash/environment.bash"
  fi
}


install_langs() {
  log_section "Installing Programming Languages"

  if [ -f "$DOTFILES_DIR/langs/install.sh" ]; then
    log_info "Installing programming languages..."
    bash -c "$DOTFILES_DIR/langs/install.sh"
    log_success "Programming languages installation completed"
  else
    log_debug "Languages installation script not found"
  fi
}

install_git() {
  log_section "Installing Git"

  if [ -f "$DOTFILES_DIR/git/install.sh" ]; then
    log_info "Running Git installation script"
    bash -c "$DOTFILES_DIR/git/install.sh"
    log_success "Git installation completed"
  else
    log_error "Git installation script not found"
    exit 1
  fi
}

install_fzf() {
  log_section "Installing fzf"

  if command -v brew &>/dev/null; then
    log_info "Installing fzf using Homebrew"
    brew install fzf

    $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish --no-zsh
    log_success "fzf installation completed"
  else
    log_error "Homebrew is not installed"
    exit 1
  fi
}


setup_bash() {
    log_section "Setting Up Bash Environment"

    if [ -f "$DOTFILES_DIR/bash/install.sh" ]; then
        log_info "Setting up bash-it and shell configurations..."
        # Running bash/install.sh as the current user, not root
        bash -c "$DOTFILES_DIR/bash/install.sh"
        log_success "Bash environment setup completed"
    else
        log_error "bash/install.sh not found"
        exit 1
    fi
}

main() {
  # Install Homebrew first - it's needed by other installers
  install_homebrew
  
  # Setup bash environment (needs to be early for PATH setup)
  setup_bash

  # Install languages (some use brew)
  install_langs
  
  # Install git configuration
  install_git

  # Install fzf (uses brew)
  install_fzf
}



main