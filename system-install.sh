#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Check if script is run with sudo
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run with sudo"
   log_info "Usage: sudo ./system-install.sh"
   exit 1
fi

# Get the actual user who invoked sudo
REAL_USER="${SUDO_USER:-$(whoami)}"
REAL_USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install essential system packages
install_system_essentials() {
    log_section "Installing System Essentials"

    # Update package lists
    log_info "Updating package lists..."
    apt-get update

    # Essential packages that require sudo
    local system_packages=(
        # Build tools
        "build-essential"
        "pkg-config"
        "libtool"
        "autoconf"
        "make"
        "cmake"

        # System utilities
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
        "fonts-powerline"

        # Version control
        "git"
        "git-lfs"

        # Development libraries
        "openssh-client"
        "libssl-dev"

        # Search and file tools
        "ripgrep"
        "fd-find"
        "tree"
        "ncdu"
        "jq"
        "neofetch"

        # PHP and extensions (if needed at system level)
        "php"
        "php-cli"
        "php-mbstring"
        "php-xml"
        "php-curl"
        "php-zip"
        "php-gd"
    )

    for package in "${system_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            log_info "Installing $package..."
            apt-get install -y "$package" || log_warning "Failed to install $package"
        else
            log_debug "$package is already installed"
        fi
    done

    # Configure git-lfs if installed
    if command_exists git-lfs; then
        su -c "git lfs install --skip-repo" - "$REAL_USER"
    fi

    log_success "System essentials installed"
}

# Install and configure snap
install_snap() {
    log_section "Installing Snap Package Manager"

    if ! command_exists snap; then
        log_info "Installing snap..."
        apt-get install -y snapd
        systemctl enable --now snapd.socket
        log_success "Snap installed successfully"
    else
        log_info "Snap is already installed"
    fi
}

# Install and configure flatpak
install_flatpak() {
    log_section "Installing Flatpak Package Manager"

    if ! command_exists flatpak; then
        log_info "Installing flatpak..."
        apt-get install -y flatpak
        log_success "Flatpak installed successfully"
    else
        log_info "Flatpak is already installed"
    fi

    # Add flathub repository as the actual user
    if ! flatpak remote-list | grep -q flathub; then
        log_info "Adding Flathub repository..."
        su -c "flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" - "$REAL_USER"
        log_success "Flathub repository added"
    fi

    # Install GNOME Software plugin for Flatpak
    if ! dpkg -l | grep -q "^ii  gnome-software-plugin-flatpak "; then
        log_info "Installing GNOME Software plugin for Flatpak..."
        apt-get install -y gnome-software-plugin-flatpak
        log_success "GNOME Software plugin installed"
    fi
}

# Install Docker
install_docker() {
    log_section "Installing Docker"

    if ! command_exists docker; then
        log_info "Installing Docker from official repository..."

        # Install prerequisites
        apt-get install -y ca-certificates curl gnupg lsb-release

        # Add Docker's official GPG key
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg

        # Set up the repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker Engine
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Add user to docker group
        groupadd docker 2>/dev/null || true
        usermod -aG docker "$REAL_USER"

        log_success "Docker installed successfully"
        log_warning "User added to docker group - logout required for changes to take effect"
    else
        log_info "Docker is already installed"
    fi
}

# Install system-wide applications that require special repositories
install_system_apps() {
    log_section "Installing System Applications"

    # Google Chrome
    if ! command_exists google-chrome; then
        log_info "Installing Google Chrome..."

        # Clean up old repository files
        rm -f /etc/apt/sources.list.d/google-chrome*.list

        # Add Google GPG key
        wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee /usr/share/keyrings/google-chrome.gpg > /dev/null

        # Add repository
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | \
            tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

        # Install Chrome
        apt-get update
        apt-get install -y google-chrome-stable || log_warning "Failed to install Chrome"
    else
        log_debug "Chrome is already installed"
    fi

    # Visual Studio Code
    if ! command_exists code; then
        log_info "Installing Visual Studio Code..."

        # Clean up old repository files
        rm -f /etc/apt/sources.list.d/vscode*.list
        rm -f /etc/apt/sources.list.d/archive_uri-https_packages_microsoft_com_repos_vscode*.list

        # Add Microsoft GPG key
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /usr/share/keyrings/microsoft-vscode.gpg > /dev/null

        # Add repository
        echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-vscode.gpg] https://packages.microsoft.com/repos/vscode stable main" | \
            tee /etc/apt/sources.list.d/vscode.list > /dev/null

        # Install VSCode
        apt-get update
        apt-get install -y code || log_warning "Failed to install VSCode"
    else
        log_debug "VSCode is already installed"
    fi

    # APT-based GUI applications
    local apt_apps=(
        "vlc"
        "guake"
        "stacer"
        "menulibre"
    )

    for app in "${apt_apps[@]}"; do
        if ! command_exists "$app"; then
            log_info "Installing $app..."
            apt-get install -y "$app" || log_warning "Failed to install $app"
        else
            log_debug "$app is already installed"
        fi
    done

    # AppImageLauncher
    if ! command_exists appimagelauncher; then
        log_info "Installing AppImageLauncher..."
        add-apt-repository -y ppa:appimagelauncher-team/stable 2>/dev/null || true
        apt-get update
        apt-get install -y appimagelauncher || log_warning "Failed to install AppImageLauncher"
    fi
}

# Install snap packages
install_snap_packages() {
    log_section "Installing Snap Packages"

    if command_exists snap; then
        # Snap packages that need --classic flag
        local snap_classic=(
            "sublime-text"
            "sublime-merge"
        )

        for app in "${snap_classic[@]}"; do
            if ! snap list | grep -q "$app"; then
                log_info "Installing $app (snap)..."
                snap install "$app" --classic || log_warning "Failed to install $app"
            else
                log_debug "$app is already installed"
            fi
        done

        # Regular snap packages
        if ! snap list | grep -q "youtube-music"; then
            log_info "Installing YouTube Music (snap)..."
            snap install youtube-music-desktop-app --stable || log_warning "Failed to install YouTube Music"
        fi
    else
        log_warning "Snap not available - skipping snap packages"
    fi
}

# Create essential directories with proper permissions
create_system_directories() {
    log_section "Creating System Directories"

    # Create user directories
    local user_dirs=(
        "$REAL_USER_HOME/.config"
        "$REAL_USER_HOME/.local/bin"
        "$REAL_USER_HOME/.cache"
        "$REAL_USER_HOME/Development"
    )

    for dir in "${user_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log_info "Creating directory: $dir"
            mkdir -p "$dir"
            chown "$REAL_USER:$REAL_USER" "$dir"
            log_success "Created $dir"
        fi
    done
}

# Set proper file permissions
set_permissions() {
    log_section "Setting File Permissions"

    # Ensure .ssh directory has correct permissions
    if [ -d "$REAL_USER_HOME/.ssh" ]; then
        chmod 700 "$REAL_USER_HOME/.ssh"
        chown -R "$REAL_USER:$REAL_USER" "$REAL_USER_HOME/.ssh"
        if [ -f "$REAL_USER_HOME/.ssh/config" ]; then
            chmod 600 "$REAL_USER_HOME/.ssh/config"
        fi
        log_success "SSH directory permissions set"
    fi

    # Ensure script files are executable
    find "$DOTFILES_DIR" -type f -name "*.sh" -exec chmod +x {} \;
    log_success "Script permissions set"
}

# Cleanup
cleanup() {
    log_section "Cleaning Up"

    apt-get clean
    apt-get autoremove -y

    log_success "Cleanup completed"
}

# Main function
main() {
    log_section "Starting System Installation (Requires Sudo)"
    log_info "Installing components that require administrative privileges..."

    # Create directories first
    create_system_directories
    set_permissions

    # Install package managers
    install_system_essentials
    install_snap
    install_flatpak

    # Install Docker and system tools
    install_docker

    # Install system-wide applications
    install_system_apps
    install_snap_packages

    # Clean up
    cleanup

    log_success "System installation completed!"
    log_info "You can now run user-install.sh without sudo for user-level installations"

    # Check if we should continue with user installation
    if [ -f "$DOTFILES_DIR/user-install.sh" ]; then
        log_info ""
        log_info "To continue with user-level installations, run:"
        log_info "  ./user-install.sh"
    fi
}

# Run main installation
main "$@"