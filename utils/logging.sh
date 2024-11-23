#!/usr/bin/env bash

# utils/logging.sh
# Helper script for consistent logging across all installation scripts

# Reset
export COLOR_NC='\e[0m'

# Regular Colors
export COLOR_RED='\e[0;31m'
export COLOR_GREEN='\e[0;32m'
export COLOR_YELLOW='\e[0;33m'
export COLOR_BLUE='\e[0;34m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_CYAN='\e[0;36m'

# Bold Colors
export COLOR_BOLD_RED='\e[1;31m'
export COLOR_BOLD_GREEN='\e[1;32m'
export COLOR_BOLD_YELLOW='\e[1;33m'
export COLOR_BOLD_BLUE='\e[1;34m'
export COLOR_BOLD_PURPLE='\e[1;35m'
export COLOR_BOLD_CYAN='\e[1;36m'

# Logging functions
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} $1"
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_NC} $1"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1" >&2
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_NC} $1"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${COLOR_PURPLE}[DEBUG]${COLOR_NC} $1"
    fi
}

log_section() {
    echo -e "\n${COLOR_BOLD_CYAN}=== $1 ===${COLOR_NC}\n"
}

# Example usage:
# source utils/logging.sh
#
# log_info "Installing package..."
# log_success "Package installed successfully!"
# log_error "Failed to install package"
# log_warning "Package is outdated"
# log_debug "Checking package version..."
# log_section "Package Installation"