#!/usr/bin/env bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

log_section "Loading Bash Configuration"

# =====================
# Basic Configuration
# =====================
log_info "Setting up basic shell configuration..."

# Shell Options
shopt -s checkwinsize  # Update window size after each command
shopt -s histappend    # Append to history instead of overwriting
shopt -s cmdhist       # Save multi-line commands in history as single line
shopt -s globstar      # Enable ** recursive glob
shopt -s autocd        # Enable auto cd when entering directory paths
shopt -s dirspell      # Attempt spell correction on directory names
shopt -s cdspell       # Attempt spell correction on cd
shopt -s dotglob       # Include dotfiles in pathname expansion
shopt -s nocaseglob    # Case-insensitive pathname expansion

# Disable ctrl-s and ctrl-q
stty -ixon

# =====================
# Bash-it Configuration
# =====================
log_info "Setting up Bash-it configuration..."

# Path to the bash it configuration
export BASH_IT="$HOME/.bash_it"


# Load Bash It if it exists
if [ -d "$BASH_IT" ]; then
    log_debug "Loading Bash-it..."
    source "$BASH_IT/bash_it.sh"
    source "$DOTFILES_DIR/bash/theme.sh"
    source "$DOTFILES_DIR/bash/environment.sh"
    source "$DOTFILES_DIR/bash/functions.sh"
    # Set up a basic prompt if bash-it is not available
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

# =====================
# Completion Configuration
# =====================
log_info "Setting up completion configuration..."

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
fi

# Load custom completions that are not part of bash-it
if [ -d "$DOTFILES_DIR/bash/completions.d" ]; then
    for completion in "$DOTFILES_DIR"/bash/completions.d/*; do
        if [ -f "$completion" ]; then
            log_debug "Loading completion: $completion"
            source "$completion"
        fi
    done
fi

# =====================
# Local Configuration
# =====================
log_info "Loading local configuration..."

# Load local customizations if they exist
if [ -f "$HOME/.bashrc.local" ]; then
    log_debug "Loading local bashrc customizations"
    source "$HOME/.bashrc.local"
fi

# =====================
# Terminal Configuration
# =====================
log_info "Setting up terminal configuration..."

# Set a fancy prompt if not using bash-it
if [ ! -d "$BASH_IT" ]; then
    case "$TERM" in
        xterm-color|*-256color)
            PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
            ;;
        *)
            PS1='\u@\h:\w\$ '
            ;;
    esac
fi

# Detect WSL for specific configurations
if grep -q Microsoft /proc/version 2>/dev/null; then
    log_debug "WSL environment detected"
    # Add WSL-specific configurations here
fi

log_success "Bashrc configuration loaded successfully"

# Print welcome message if this is a login shell
if shopt -q login_shell; then
    if command -v neofetch >/dev/null 2>&1; then
        neofetch
    else
        echo "Welcome, $USER!"
        date "+%A %d %B %Y, %T"
    fi
fi