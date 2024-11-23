#!/usr/bin/env bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac



# =====================
# Basic Configuration
# =====================

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

# Path to the bash it configuration
export BASH_IT="$HOME/.bash_it"


source "$BASH_IT/bash_it.sh"

# Source the .bash_profile if it exists
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
fi

# =====================
# Completion Configuration
# =====================

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
fi


# =====================
# Local Configuration
# =====================

# Load local customizations if they exist
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi

# =====================
# Terminal Configuration
# =====================

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



# Print welcome message if this is a login shell
if shopt -q login_shell; then
    if command -v neofetch >/dev/null 2>&1; then
        neofetch
    else
        echo "Welcome, $USER!"
        date "+%A %d %B %Y, %T"
    fi
fi
. "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
