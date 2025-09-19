#!/usr/bin/env bash

# Verification script for dotfiles installation
# This script checks if all components are properly installed

set -euo pipefail

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${DOTFILES_DIR}/utils/logging.sh"

# Verification results
CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS=0

# Check function
check() {
    local check_name="$1"
    local check_command="$2"
    local severity="${3:-error}"  # error, warning, or optional
    
    if eval "$check_command" 2>/dev/null; then
        log_success "✓ $check_name"
        ((CHECKS_PASSED++))
        return 0
    else
        if [ "$severity" == "optional" ]; then
            log_info "○ $check_name (optional)"
            return 0
        elif [ "$severity" == "warning" ]; then
            log_warning "⚠ $check_name"
            ((WARNINGS++))
            return 0
        else
            log_error "✗ $check_name"
            ((CHECKS_FAILED++))
            return 1
        fi
    fi
}

# System checks
check_system() {
    log_section "System Dependencies"
    
    check "curl installed" "command -v curl"
    check "wget installed" "command -v wget"
    check "git installed" "command -v git"
    check "build-essential installed" "dpkg -l | grep -q '^ii  build-essential'"
}

# Package managers
check_package_managers() {
    log_section "Package Managers"
    
    check "Homebrew installed" "command -v brew" "optional"
    check "snap installed" "command -v snap"
    check "flatpak installed" "command -v flatpak"
    check "Flathub repository configured" "flatpak remote-list | grep -q flathub" "warning"
}

# Shell environment
check_shell() {
    log_section "Shell Environment"
    
    check "Bash-it installed" "[ -d $HOME/.bash_it ]"
    check "Bash-it sourced in .bashrc" "grep -q 'source.*bash_it.sh' $HOME/.bashrc" "warning"
    check "fzf installed" "command -v fzf" "warning"
    check "Custom functions loaded" "[ -f $DOTFILES_DIR/bash/functions.bash ]"
    check "Environment configured" "[ -f $DOTFILES_DIR/bash/environment.bash ]"
}

# Development tools
check_dev_tools() {
    log_section "Development Tools"
    
    # Version control
    check "Git configured with user.name" "git config --global user.name" "warning"
    check "Git configured with user.email" "git config --global user.email" "warning"
    check "Global gitignore configured" "[ -f $HOME/.gitignore_global ]" "warning"
    
    # Docker
    check "Docker installed" "command -v docker" "warning"
    check "Docker Compose installed" "docker compose version" "warning"
    
    # Editors
    check "vim installed" "command -v vim"
}

# Programming languages
check_languages() {
    log_section "Programming Languages"
    
    # Python with uv
    check "uv installed" "command -v uv" "warning"
    check "Python accessible via uv" "uv run python --version" "warning"
    
    # Node.js
    check "NVM installed" "[ -s $HOME/.nvm/nvm.sh ]" "warning"
    check "Node.js installed" "command -v node" "warning"
    check "npm installed" "command -v npm" "warning"
    
    # Rust
    check "Rust installed" "command -v rustc" "warning"
    check "Cargo installed" "command -v cargo" "warning"
    
    # PHP
    check "PHP installed" "command -v php" "warning"
    check "Composer installed" "command -v composer" "warning"
}

# Applications
check_applications() {
    log_section "Applications"
    
    check "VS Code installed" "command -v code" "warning"
    check "Google Chrome installed" "command -v google-chrome" "warning"
    check "Guake terminal installed" "command -v guake" "warning"
}

# Directory structure
check_directories() {
    log_section "Directory Structure"
    
    check "~/.config exists" "[ -d $HOME/.config ]"
    check "~/.local/bin exists" "[ -d $HOME/.local/bin ]"
    check "~/.cache exists" "[ -d $HOME/.cache ]"
    check "~/Development exists" "[ -d $HOME/Development ]" "warning"
}

# PATH configuration
check_path() {
    log_section "PATH Configuration"
    
    check "~/.local/bin in PATH" "echo \$PATH | grep -q '$HOME/.local/bin'" "warning"
    check "Homebrew in PATH" "echo \$PATH | grep -q 'linuxbrew'" "optional"
    check "Cargo bin in PATH" "echo \$PATH | grep -q '.cargo/bin'" "warning"
}

# File permissions
check_permissions() {
    log_section "File Permissions"
    
    if [ -d "$HOME/.ssh" ]; then
        check "~/.ssh has correct permissions (700)" "[ $(stat -c %a $HOME/.ssh) = '700' ]" "warning"
    fi
    
    check "Scripts are executable" "[ -x $DOTFILES_DIR/install.sh ]"
}

# Summary report
print_summary() {
    log_section "Installation Verification Summary"
    
    local total=$((CHECKS_PASSED + CHECKS_FAILED + WARNINGS))
    
    echo -e "${COLOR_GREEN}Passed:${COLOR_NC} $CHECKS_PASSED/$total"
    
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${COLOR_YELLOW}Warnings:${COLOR_NC} $WARNINGS (optional components)"
    fi
    
    if [ $CHECKS_FAILED -gt 0 ]; then
        echo -e "${COLOR_RED}Failed:${COLOR_NC} $CHECKS_FAILED (required components)"
        log_error "Some required components are missing!"
        log_info "Run 'sudo ./install.sh' to complete the installation"
        return 1
    else
        log_success "All required components are properly installed!"
        
        if [ $WARNINGS -gt 0 ]; then
            log_info "Some optional components are missing. This is normal if you haven't installed everything."
        fi
    fi
}

# Main verification
main() {
    log_section "Dotfiles Installation Verification"
    log_info "Checking installation status..."
    
    check_system
    check_package_managers
    check_shell
    check_dev_tools
    check_languages
    check_applications
    check_directories
    check_path
    check_permissions
    
    print_summary
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi