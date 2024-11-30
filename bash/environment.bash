#!/usr/bin/env bash



# ====================
# Basic Configuration
# ====================

# Default editor
export EDITOR='vim'
export VISUAL='vim'

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# History configuration
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

# ====================
# Path Configuration
# ====================

# Function to add to PATH if directory exists
add_to_path() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1:$PATH"
    fi
}

# Add custom paths
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/bin"
add_to_path "/usr/local/bin"
add_to_path "/usr/local/sbin"

# ====================
# Development Tools
# ====================

# Node.js Configuration
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
    source "$NVM_DIR/bash_completion"
fi

# Python Configuration
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export VIRTUAL_ENV_DISABLE_PROMPT=1
add_to_path "$HOME/.poetry/bin"

# Rust Configuration
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# PHP configuration
export PATH="/home/linuxbrew/.linuxbrew/opt/php/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/opt/php/sbin:$PATH"

# Go Configuration
export GOPATH="$HOME/go"
add_to_path "$GOPATH/bin"

# ====================
# Tool Configuration
# ====================




# ====================
# Application Settings
# ====================

# Docker Configuration
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

# GPG Configuration
export GPG_TTY=$(tty)

# Default applications
export BROWSER='google-chrome'

# ====================
# Aliases
# ====================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'

# List directory contents
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gl='git log --oneline'

# Docker shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'

# System commands
alias update='sudo apt update && sudo apt upgrade -y'
alias clean='sudo apt autoremove -y && sudo apt clean'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

alias python='python3'
alias pip='pip3'

# ====================
# Custom Functions
# ====================

# Quick directory switching with automatic ls
cd() {
    builtin cd "$@" && ls
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$@" && cd "$_"
}

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
