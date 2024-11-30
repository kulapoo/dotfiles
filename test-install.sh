#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${DOTFILES_DIR}/utils/logging.sh"


source_fzf() {
  if command -v fzf > /dev/null 2>&1; then
    echo 'eval "$(fzf --bash)"' >> "$HOME/.bashrc"
  fi
}


source_fzf