#!/usr/bin/env bash

set -euo pipefail
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

install_homebrew() {
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> "$DOTFILES_DIR/bash/environment.bash"
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
  setup_bash

  install_homebrew

  install_langs

  install_fzf
}



main