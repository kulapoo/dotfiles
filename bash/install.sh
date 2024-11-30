#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

export BASH_IT="$HOME/.bash_it"


source_bashit() {
    echo "export BASH_IT_THEME='metal'" >> "$HOME/.bashrc"
    echo "export BASH_IT=\"$HOME/.bash_it\"" >> "$HOME/.bashrc"
    echo 'source $BASH_IT/bash_it.sh' >> "$HOME/.bashrc"
}

source_fzf() {
  if command -v fzf > /dev/null 2>&1; then
    echo 'eval "$(fzf --bash)"' >> "$HOME/.bashrc"
  fi
}

source_tools() {
  source_bashit
  source_fzf
}

# Install bash-it if not already installed
install_bashit() {
    log_section "Installing Bash-it"

    if [ ! -d "$HOME/.bash_it" ]; then
        log_info "Cloning bash-it repository..."
        git clone --depth=1 https://github.com/Bash-it/bash-it.git "$BASH_IT"
        "$HOME/.bash_it/install.sh" --silent --no-modify-config
        log_success "Bash-it installed successfully"
        source_tools
    else
        if ! grep -q "source $BASH_IT/bash_it.sh" "$HOME/.bashrc"; then
            source_tools
        fi
        log_info "Bash-it is already installed"
    fi
}

setup_custom_config() {
  log_section "Setting Up Custom Bash Configuration"

  ln -sf "$DOTFILES_DIR/bash/completion.bash" "$BASH_IT/custom/completion.bash"
  ln -sf "$DOTFILES_DIR/bash/environment.bash" "$BASH_IT/custom/environment.bash"
  ln -sf "$DOTFILES_DIR/bash/functions.bash" "$BASH_IT/custom/functions.bash"
  ln -sf "$DOTFILES_DIR/bash/theme.bash" "$BASH_IT/custom/theme.bash"
  log_success "Custom bash configuration files symlinked successfully"
}

# Enable bash-it components
setup_bashit_components() {
    log_section "Setting Up Bash-it Components"


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
        bash -c "$BASH_IT/bash_it.sh" enable completion "$completion"
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
        bash -c $BASH_IT/bash_it.sh enable plugin "$plugin"
    done

    log_info "Enabling aliases..."
    local aliases=(
        "general"
        "git"
        "docker"
    )

    for alias in "${aliases[@]}"; do
        bash -c $BASH_IT/bash_it.sh enable alias "$alias"
    done

    log_success "Bash-it components enabled successfully"
}

# Setup custom bash configuration

# Main setup function
main() {
    log_section "Starting Bash-it Installation and Setup"

    install_bashit
    setup_custom_config
    setup_bashit_components

    log_success "Bash-it setup completed successfully!"
    log_info "Please restart your terminal or source ~/.bashrc to apply changes"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi