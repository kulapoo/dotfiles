#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check and install apt package
install_apt_package() {
    local package_name="$1"
    if ! dpkg -l | grep -q "^ii  $package_name "; then
        log_info "Installing $package_name..."
        sudo apt-get install -y "$package_name"
        log_success "$package_name installed successfully"
    else
        log_info "$package_name is already installed"
    fi
}
# Function to check and install snap
install_snap() {
  if ! command_exists snap; then
    log_info "Installing snap..."
    sudo apt-get install -y snap
    log_success "snap installed successfully"
  else
    log_info "snap is already installed"
  fi
}


install_dev_tools() {
    log_section "Installing Development Tools"

    local dev_packages=(
        "build-essential"
        "pkg-config"
        "libtool"
        "autoconf"
        "make"
        "cmake"
        "git"
        "openssh-client"
        "libssl-dev"
    )

    for package in "${dev_packages[@]}"; do
        install_apt_package "$package"
    done
}

# Install system utilities
install_system_utils() {
    log_section "Installing System Utilities"

    local utils_packages=(
        "curl"
        "wget"
        "unzip"
        "zip"
        "tar"
        "htop"
        "net-tools"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
    )

    for package in "${utils_packages[@]}"; do
        install_apt_package "$package"
    done
}

# Install version control systems
install_vcs() {
    log_section "Installing Version Control Systems"

    local vcs_packages=(
        "git"
        "git-lfs"
    )

    for package in "${vcs_packages[@]}"; do
        install_apt_package "$package"
    done

    # Configure git-lfs
    if command_exists git-lfs; then
        git lfs install --skip-repo
    fi
}

# Main installation function
main() {
    log_section "Starting Essential Packages Installation"

    # Update package list
    log_info "Updating package list..."
    sudo apt-get update
    # Install snap
    install_snap
    # Install packages
    install_dev_tools
    install_system_utils


    log_success "Essential packages installation completed!"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi