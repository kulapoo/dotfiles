#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${DOTFILES_DIR}/utils/logging.sh"


install_sublime_merge() {
  if ! command -v smerge &> /dev/null; then
    log_info "Installing Sublime Merge..."
    sudo snap install sublime-merge --classic
  else
    log_info "Sublime Merge is already installed"
  fi
}

install_sublime_merge