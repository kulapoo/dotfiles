#!/bin/bash

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
SUDO_USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

source "${SCRIPT_DIR}/utils/logging.sh"


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

install_appimagelauncher() {
  log_section "Installing AppImageLauncher"
  if ! command_exists appimagelauncher; then
    log_info "Installing AppImageLauncher from PPA..."
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:appimagelauncher-team/stable
    sudo apt-get update
    sudo apt-get install -y appimagelauncher
    log_success "AppImageLauncher installed successfully"
  else
    log_info "AppImageLauncher is already installed"
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
        sudo snap install youtube-music-desktop-app
    else
        log_info "Youtube Music is already installed"
    fi
}

# Sublime Text
install_sublime() {
  if ! command -v subl &> /dev/null; then
    log_info "Installing Sublime Text..."
    sudo snap install sublime-text --classic
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
    else
        log_info "Yakuake is already installed"
    fi
}

install_sublime_merge() {
  if ! command -v smerge &> /dev/null; then
    log_info "Installing Sublime Merge..."
    sudo snap install sublime-merge --classic
  else
    log_info "Sublime Merge is already installed"
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

# VirtualBox
install_virtualbox() {
  if ! command -v virtualbox &> /dev/null; then
    log_info "Installing VirtualBox..."
    sudo apt-get install -y virtualbox
  else
    log_info "VirtualBox is already installed"
  fi
}


# Menulibre
install_menulibre() {
  if ! command -v menulibre &> /dev/null; then
    log_info "Installing Menulibre..."
    sudo apt-get install -y menulibre
  else
    log_info "Menulibre is already installed"
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
    install_yakuake
    install_konsole
    install_dconf
    install_stacer
    install_sublime
    install_sublime_merge
    install_appimagelauncher
    install_menulibre
    install_virtualbox



    log_info "Applications installation complete!"
}

# Run main installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi