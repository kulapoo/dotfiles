#!/bin/bash

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
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
        log_info "Installing Google Chrome..."
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
        sudo apt-get update
        sudo apt-get install -y google-chrome-stable
    else
        log_info "Google Chrome is already installed"
    fi
}

# Flameshot
install_flameshot() {
    if ! command -v flameshot &> /dev/null; then
        log_info "Installing Flameshot..."
        sudo apt-get install -y flameshot
    else
        log_info "Flameshot is already installed"
    fi
}

# Bitwarden
install_bitwarden() {
    if ! command -v bitwarden &> /dev/null; then
        log_info "Installing Bitwarden..."
        sudo snap install bitwarden
    else
        log_info "Bitwarden is already installed"
    fi
}

# Obsidian
install_obsidian() {
    if ! command -v obsidian &> /dev/null; then
        log_info "Installing Obsidian..."
        sudo snap install obsidian --classic
    else
        log_info "Obsidian is already installed"
    fi
}

# Youtube Music
install_youtube_music() {
    if ! command -v youtube-music &> /dev/null; then
        log_info "Installing Youtube Music..."
        sudo snap install youtube-music-desktop-app
    else
        log_info "Youtube Music is already installed"
    fi
}

# Sublime Text
install_sublime() {
    if ! command -v subl &> /dev/null; then
        log_info "Installing Sublime Text..."
        wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
        sudo apt-get install -y apt-transport-https
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
        sudo apt-get update
        sudo apt-get install -y sublime-text

        # Sublime Text configuration
        mkdir -p "$HOME/.config/sublime-text-3/Packages/User/"
        cp "$SCRIPT_DIR/configs/sublime/Preferences.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/"
    else
        log_info "Sublime Text is already installed"
    fi
}

# VSCode
install_vscode() {
    if ! command -v code &> /dev/null; then
        log_info "Installing Visual Studio Code..."
        wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
        sudo apt-get update
        sudo apt-get install -y code
    else
        log_info "Visual Studio Code is already installed"
    fi
}

# Yakuake
install_yakuake() {
    if ! command -v yakuake &> /dev/null; then
        log_info "Installing Yakuake..."
        sudo apt-get install -y yakuake

        # Yakuake configuration
        mkdir -p "$HOME/.config/yakuake"
        cp "$SCRIPT_DIR/configs/yakuake/yakuakerc" "$HOME/.config/yakuake/"

        # Set up autostart
        mkdir -p "$HOME/.config/autostart"
        cp "/usr/share/applications/org.kde.yakuake.desktop" "$HOME/.config/autostart/"
    else
        log_info "Yakuake is already installed"
    fi
}

# Konsole
install_konsole() {
    if ! command -v konsole &> /dev/null; then
        log_info "Installing Konsole..."
        sudo apt-get install -y konsole
    else
        log_info "Konsole is already installed"
    fi
}

# Main installation function
main() {
    log_info "Starting applications installation..."

    # Update package lists
    log_info "Updating package lists..."
    sudo apt-get update

    # Install applications one by one
    install_vlc
    install_chrome
    install_flameshot
    install_bitwarden
    install_obsidian
    install_youtube_music
    install_sublime
    install_vscode
    install_yakuake
    install_konsole

    log_info "Applications installation complete!"
}

# Run main installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi