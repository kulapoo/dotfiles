#!/usr/bin/env bash

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

log_section "Loading Bash Profile"

# Source .bashrc if it exists (this will handle all Bash-it related loading)
if [ -f "$HOME/.bashrc" ]; then
    log_info "Sourcing .bashrc..."
    source "$HOME/.bashrc"
else
    log_warning ".bashrc not found"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    log_debug "Adding $HOME/bin to PATH"
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    log_debug "Adding $HOME/.local/bin to PATH"
    PATH="$HOME/.local/bin:$PATH"
fi

# Load SSH agent if not already running
if [ -z "$SSH_AUTH_SOCK" ] ; then
    log_info "Starting SSH agent..."
    eval "$(ssh-agent -s)"
    log_debug "SSH agent started"
fi

# Load any SSH keys if not already loaded
if [ -f "$HOME/.ssh/id_rsa" ]; then
    if ! ssh-add -l >/dev/null 2>&1; then
        log_info "Loading SSH key..."
        ssh-add "$HOME/.ssh/id_rsa" >/dev/null 2>&1
        log_debug "SSH key loaded"
    fi
fi

# Load custom profile extensions if they exist
if [ -d "$HOME/.profile.d" ]; then
    for file in "$HOME"/.profile.d/*.sh; do
        if [ -r "$file" ]; then
            log_debug "Loading profile extension: $file"
            source "$file"
        fi
    done
fi

log_success "Bash profile loaded successfully"