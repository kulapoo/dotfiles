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

# Node.js Configuration (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Python Configuration (using uv)
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export VIRTUAL_ENV_DISABLE_PROMPT=1

# UV Python manager
export UV_CACHE_DIR="$HOME/.cache/uv"
export UV_TOOL_DIR="$HOME/.local/share/uv/tools"
add_to_path "$HOME/.local/share/uv/tools/bin"
add_to_path "$HOME/.cargo/bin"  # uv is installed via cargo

# Legacy poetry support (if still needed)
add_to_path "$HOME/.poetry/bin"

# Rust Configuration
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# PHP configuration (only if linuxbrew is installed)
if [ -d "/home/linuxbrew/.linuxbrew/opt/php/bin" ]; then
  export PATH="/home/linuxbrew/.linuxbrew/opt/php/bin:$PATH"
fi
if [ -d "/home/linuxbrew/.linuxbrew/opt/php/sbin" ]; then
  export PATH="/home/linuxbrew/.linuxbrew/opt/php/sbin:$PATH"
fi

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

# Python aliases (using uv)
alias python='uv run python'
alias pip='uv pip'
alias python3='uv run python'
alias pip3='uv pip'

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

# Generate a new file with full path, creating directories as needed
touchp() { mkdir -p "$(dirname "$1")" && touch "$1"; }

# Show all open ports
alias ports='netstat -tulanp'

# IP address info
alias myip='curl -s https://api.ipify.org'
alias localip='ifconfig | grep -Eo "inet (addr:)?([0-9]*\.){3}[0-9]*" | grep -Eo "([0-9]*\.){3}[0-9]*" | grep -v "127.0.0.1"'

# Resource monitoring
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'
alias topproc='ps aux | sort -rk 3,3 | head -n 10'  # Top 10 CPU consuming processes

# Disk usage in human readable format
alias duh='du -h'
alias dfh='df -h'

# Show directory sizes
dsize() { du -sh "$@" | sort -h; }


# File searching and content searching
ff() { find . -type f -name "$1"; }         # Find files by name
ftext() { grep -r "$1" .; }                 # Find text in files



# Initialize Homebrew if installed
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
fi


[ -f ~/.fzf.bash ] && source ~/.fzf.bash
