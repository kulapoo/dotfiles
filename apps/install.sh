#!/bin/bash

set -euo pipefail

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
SUDO_USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

source "${SCRIPT_DIR}/utils/logging.sh"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}


# VLC
install_vlc() {
    if ! command -v vlc &> /dev/null; then
        log_info "Installing VLC..."
        sudo apt-get install -y vlc
    else
        log_info "VLC is already installed"
    fi
}

# Google Chrome
install_chrome() {
    if ! command -v google-chrome &> /dev/null; then
        log_info "[install_chrome] Installing Google Chrome..."

        # Clean up any existing Chrome repository files
        sudo rm -f /etc/apt/sources.list.d/google-chrome.list
        sudo rm -f /etc/apt/sources.list.d/google-chrome*.list

        # Download and add the Google GPG key to the new location
        log_info "[install_chrome] Adding Google GPG key..."
        wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg > /dev/null

        # Add the repository with the signed-by option (modern approach)
        log_info "[install_chrome] Adding Chrome repository..."
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | \
            sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

        # Update and install
        sudo apt-get update
        if sudo apt-get install -y google-chrome-stable; then
            log_success "[install_chrome] Google Chrome installed successfully"
        else
            log_error "[install_chrome] Failed to install Google Chrome"
            return 1
        fi
    else
        log_info "[install_chrome] Google Chrome is already installed"
    fi
}

# Flameshot
install_flameshot() {
    if ! command -v flameshot &> /dev/null; then
        log_info "Installing Flameshot..."
        flatpak install -y flathub org.flameshot.Flameshot
    else
        log_info "Flameshot is already installed"
    fi
}

# Bitwarden
install_bitwarden() {
    if ! command -v bitwarden &> /dev/null; then
        log_info "Installing Bitwarden..."
        flatpak install -y flathub com.bitwarden.desktop
    else
        log_info "Bitwarden is already installed"
    fi
}

# Obsidian
install_obsidian() {
    if ! command -v obsidian &> /dev/null; then
        log_info "Installing Obsidian..."
        flatpak install -y flathub md.obsidian.Obsidian
    else
        log_info "Obsidian is already installed"
    fi
}

# Stacer
install_stacer() {
    if ! command -v stacer &> /dev/null; then
        log_info "Installing Stacer..."
        sudo apt-get install -y stacer || true
    else
        log_info "Stacer is already installed"
    fi
}

# Discord
install_discord() {
  if ! command -v discord &> /dev/null; then
    log_info "Installing Discord..."
    flatpak install -y flathub com.discordapp.Discord
  else
    log_info "Discord is already installed"
  fi
}

install_dconf() {
  if ! command -v dconf &> /dev/null; then
    log_info "Installing Dconf..."
    flatpak install -y flathub ca.desrt.dconf-editor
  else
    log_info "Dconf is already installed"
  fi
}

# Youtube Music
install_youtube_music() {
    if ! command -v youtube-music &> /dev/null; then
        log_info "Installing Youtube Music..."
        sudo snap install youtube-music-desktop-app --stable
    else
        log_info "Youtube Music is already installed"
    fi
}

# Sublime Text
install_sublime() {
  if ! command -v subl &> /dev/null; then
    log_info "Installing Sublime Text..."
    sudo snap install sublime-text --classic --stable
  else
    log_info "Sublime Text is already installed"
  fi
}

# VSCode
install_vscode() {
    if ! command -v code &> /dev/null; then
        log_info "[install_vscode] Installing Visual Studio Code..."

        # Clean up any existing VSCode repository files first
        log_info "[install_vscode] Cleaning up old VSCode repository files..."
        sudo rm -f /etc/apt/sources.list.d/vscode.list
        sudo rm -f /etc/apt/sources.list.d/vscode.sources
        sudo rm -f /etc/apt/sources.list.d/archive_uri-https_packages_microsoft_com_repos_vscode*.list

        # Download and add the Microsoft GPG key to the new location
        log_info "[install_vscode] Adding Microsoft GPG key..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-vscode.gpg > /dev/null

        # Add the repository with the signed-by option (modern approach)
        log_info "[install_vscode] Adding VSCode repository..."
        echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-vscode.gpg] https://packages.microsoft.com/repos/vscode stable main" | \
            sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

        # Update and install
        sudo apt-get update
        if sudo apt-get install -y code; then
            log_success "[install_vscode] Visual Studio Code installed successfully"
        else
            log_error "[install_vscode] Failed to install Visual Studio Code"
            return 1
        fi
    else
        log_info "[install_vscode] Visual Studio Code is already installed"

        # Clean up duplicate repository files if they exist
        if [ -f /etc/apt/sources.list.d/archive_uri-https_packages_microsoft_com_repos_vscode-jammy.list ] || \
           [ -f /etc/apt/sources.list.d/vscode.sources ]; then
            log_info "[install_vscode] Cleaning up duplicate VSCode repository files..."
            sudo rm -f /etc/apt/sources.list.d/archive_uri-https_packages_microsoft_com_repos_vscode*.list
            sudo rm -f /etc/apt/sources.list.d/vscode.sources
            log_success "[install_vscode] Duplicate repository files removed"
        fi
    fi
}

# Guake (drop-down terminal)
install_guake() {
    if ! command -v guake &> /dev/null; then
        log_info "Installing Guake..."
        sudo apt-get install -y guake
    else
        log_info "Guake is already installed"
    fi
}

install_sublime_merge() {
  if ! command -v smerge &> /dev/null; then
    log_info "Installing Sublime Merge..."
    sudo snap install sublime-merge --classic --stable
  else
    log_info "Sublime Merge is already installed"
  fi
}

# Main installation function
main() {
    log_info "Starting applications installation..."

    # Update package lists
    log_info "Updating package lists..."
    sudo apt-get update

    # Install applications one by one
    install_vscode
    install_chrome
    install_vlc
    install_discord
    install_youtube_music
    install_flameshot
    install_bitwarden
    install_obsidian
    install_guake
    install_dconf
    install_stacer
    install_sublime
    install_sublime_merge

    log_info "Applications installation complete!"
}

# Run main installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
