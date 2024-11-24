#!/usr/bin/env bash

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install a package using apt if it's not already installed
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

# Install packages from apt repository
install_apt_tools() {
    log_section "Installing APT Tools"

    # Update package list
    log_info "Updating package lists..."
    sudo apt-get update

    # List of tools to install via apt
    local apt_tools=(
        "htop"
        "ripgrep"
        "fd-find"
        "tree"
        "ncdu"
        "jq"
        "neofetch"
    )

    for tool in "${apt_tools[@]}"; do
        install_apt_package "$tool"
    done
}


install_docker() {
    log_section "Installing Docker"
    if ! command_exists docker; then
        log_info "Installing Docker from official repository..."
        # Install prerequisites and set up Docker repository
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg lsb-release

        # Add Docker's official GPG key
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Set up the repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker Engine
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Add user to docker group
        sudo groupadd docker 2>/dev/null || true
        sudo usermod -aG docker $USER

        log_success "Docker installed successfully"
        log_info "Please log out and back in for the docker group changes to take effect"
    else
        log_info "Docker is already installed"
    fi

    # Docker Compose is now included in docker-compose-plugin
    if ! command_exists docker-compose; then
        log_info "Docker Compose is included in docker-compose-plugin"
    else
        log_info "Docker Compose is already installed"
    fi
}



# Cleanup function
cleanup() {
    log_section "Cleaning Up"

    # Remove any temporary files or downloaded packages
    sudo apt-get clean
    sudo apt-get autoremove -y

    log_success "Cleanup completed"
}

# Main function
main() {
    log_section "Starting Development Tools Installation"

    install_apt_tools
    install_docker
    cleanup

    log_success "Development tools installation completed!"
    log_info "Please restart your terminal or source your shell configuration to use the new tools"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi