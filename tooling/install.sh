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
        "htop"            # Interactive process viewer
        "ripgrep"         # Fast grep alternative
        "fd-find"         # User-friendly find alternative
        "tree"            # Directory listing tool
        "ncdu"           # Disk usage analyzer
        "jq"             # JSON processor
        "tmux"           # Terminal multiplexer
        "neofetch"       # System info script
        "httpie"         # User-friendly curl alternative
    )

    for tool in "${apt_tools[@]}"; do
        install_apt_package "$tool"
    done
}

# Install and configure fzf
install_fzf() {
    log_section "Installing fzf"

    if ! command_exists fzf; then
        log_info "Cloning fzf repository..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

        log_info "Running fzf installer..."
        ~/.fzf/install --all --no-bash --no-fish

        # Create symbolic link
        if [ ! -L "$HOME/.local/bin/fzf" ]; then
            ln -s "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
        fi

        log_success "fzf installed successfully"
    else
        log_info "fzf is already installed"

        # Update fzf if it exists
        if [ -d "$HOME/.fzf" ]; then
            log_info "Updating fzf..."
            cd "$HOME/.fzf" && git pull && ./install --all --no-bash --no-fish
            log_success "fzf updated successfully"
        fi
    fi
}

# Install and configure bat
install_bat() {
    log_section "Installing bat"

    if ! command_exists bat; then
        log_info "Installing bat..."
        sudo apt-get install -y bat

        # On some distributions, bat is installed as batcat
        if command_exists batcat && ! command_exists bat; then
            mkdir -p "$HOME/.local/bin"
            ln -s "$(which batcat)" "$HOME/.local/bin/bat"
        fi

        # Create bat config directory
        mkdir -p "$HOME/.config/bat"

        # Configure bat
        if [ -f "$DOTFILES_DIR/dev_tools/config/bat.conf" ]; then
            log_info "Configuring bat..."
            ln -sf "$DOTFILES_DIR/dev_tools/config/bat.conf" "$HOME/.config/bat/config"
        fi

        log_success "bat installed successfully"
    else
        log_info "bat is already installed"
    fi
}

# Install and configure delta (git pager)
install_delta() {
    log_section "Installing delta"

    if ! command_exists delta; then
        log_info "Installing delta..."

        # Check architecture
        local arch=$(uname -m)
        local delta_version="0.16.5"  # Update this version as needed
        local delta_url

        case $arch in
            x86_64)
                delta_url="https://github.com/dandavison/delta/releases/download/${delta_version}/git-delta_${delta_version}_amd64.deb"
                ;;
            aarch64)
                delta_url="https://github.com/dandavison/delta/releases/download/${delta_version}/git-delta_${delta_version}_arm64.deb"
                ;;
            *)
                log_error "Unsupported architecture: $arch"
                return 1
                ;;
        esac

        # Download and install delta
        local temp_deb=$(mktemp)
        wget -O "$temp_deb" "$delta_url"
        sudo dpkg -i "$temp_deb"
        rm -f "$temp_deb"

        log_success "delta installed successfully"
    else
        log_info "delta is already installed"
    fi
}

# Configure tools
configure_tools() {
    log_section "Configuring Development Tools"

    # Create config directories
    mkdir -p "$HOME/.config/htop"

    # Link configurations if they exist
    if [ -f "$DOTFILES_DIR/dev_tools/config/htoprc" ]; then
        log_info "Configuring htop..."
        ln -sf "$DOTFILES_DIR/dev_tools/config/htoprc" "$HOME/.config/htop/htoprc"
    fi

    # Configure fzf
    if [ -f "$DOTFILES_DIR/dev_tools/config/fzf.conf" ]; then
        log_info "Configuring fzf..."
        ln -sf "$DOTFILES_DIR/dev_tools/config/fzf.conf" "$HOME/.fzf.conf"
    fi

    log_success "Tool configurations completed"
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
    install_fzf
    install_bat
    install_delta
    configure_tools
    cleanup

    log_success "Development tools installation completed!"
    log_info "Please restart your terminal or source your shell configuration to use the new tools"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi