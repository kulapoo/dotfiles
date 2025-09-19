#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Colors for interactive prompts
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print the banner
print_banner() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║                    DOTFILES INSTALLER                         ║"
    echo "║                                                                ║"
    echo "║   A modular installation system for development environment   ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if running with sudo
is_sudo() {
    [[ $EUID -eq 0 ]]
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Display installation menu
show_menu() {
    echo -e "\n${GREEN}Installation Options:${NC}\n"
    echo "  1) Full Installation (Recommended)"
    echo "     - System packages and applications (requires sudo)"
    echo "     - User tools and configurations"
    echo ""
    echo "  2) System Installation Only"
    echo "     - APT packages, Docker, Snap, Flatpak"
    echo "     - System applications (Chrome, VSCode, etc.)"
    echo "     - Requires sudo privileges"
    echo ""
    echo "  3) User Installation Only"
    echo "     - Homebrew and packages"
    echo "     - Programming languages (Rust, Python, Node.js, PHP)"
    echo "     - Development tools and configurations"
    echo "     - No sudo required"
    echo ""
    echo "  4) Check Installation Status"
    echo "     - View what's already installed"
    echo ""
    echo "  5) Exit"
    echo ""
}

# Check installation status
check_status() {
    log_section "Installation Status Check"

    echo -e "\n${GREEN}System Components:${NC}"

    # Check package managers
    echo -n "  • Docker: "
    command_exists docker && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -n "  • Snap: "
    command_exists snap && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -n "  • Flatpak: "
    command_exists flatpak && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -e "\n${GREEN}Applications:${NC}"

    echo -n "  • Google Chrome: "
    command_exists google-chrome && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -n "  • VS Code: "
    command_exists code && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -n "  • VLC: "
    command_exists vlc && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -e "\n${GREEN}User Tools:${NC}"

    echo -n "  • Homebrew: "
    command_exists brew && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -n "  • Rust: "
    command_exists rustc && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -n "  • Node.js: "
    command_exists node && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -n "  • Python (uv): "
    command_exists uv && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -n "  • PHP: "
    command_exists php && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -n "  • Git: "
    command_exists git && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo -n "  • fzf: "
    command_exists fzf && echo -e "${GREEN}✓ Installed${NC}" || echo -e "${YELLOW}✗ Not installed${NC}"

    echo ""
}

# Run system installation
run_system_install() {
    log_section "System Installation"

    if ! is_sudo; then
        log_info "System installation requires sudo privileges."
        log_info "Please run: sudo $DOTFILES_DIR/system-install.sh"
        echo ""
        read -p "Would you like to run it now? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo "$DOTFILES_DIR/system-install.sh"
        else
            log_info "Skipping system installation"
            return 1
        fi
    else
        # Already running with sudo
        "$DOTFILES_DIR/system-install.sh"
    fi
}

# Run user installation
run_user_install() {
    log_section "User Installation"

    if is_sudo; then
        log_info "Switching to user context for user installation..."
        REAL_USER="${SUDO_USER:-$(whoami)}"
        su -c "$DOTFILES_DIR/user-install.sh" - "$REAL_USER"
    else
        "$DOTFILES_DIR/user-install.sh"
    fi
}

# Run full installation
run_full_install() {
    log_section "Full Installation"
    log_info "This will install both system and user components."
    echo ""

    # First, ensure system components are installed
    if is_sudo; then
        # If already running with sudo, run system install directly
        "$DOTFILES_DIR/system-install.sh"

        # Then switch to user context for user installation
        log_info "Switching to user context for user installation..."
        REAL_USER="${SUDO_USER:-$(whoami)}"
        su -c "$DOTFILES_DIR/user-install.sh" - "$REAL_USER"
    else
        # Not running with sudo, need to request it for system install
        log_info "System installation requires sudo privileges."
        read -p "Continue with sudo for system installation? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo "$DOTFILES_DIR/system-install.sh"

            # After system install, run user install
            log_info "Continuing with user installation..."
            "$DOTFILES_DIR/user-install.sh"
        else
            log_warning "System installation skipped. Running user installation only..."
            "$DOTFILES_DIR/user-install.sh"
        fi
    fi
}

# Interactive mode
interactive_mode() {
    while true; do
        show_menu
        read -p "Select an option (1-5): " choice

        case $choice in
            1)
                run_full_install
                ;;
            2)
                run_system_install
                ;;
            3)
                run_user_install
                ;;
            4)
                check_status
                ;;
            5)
                log_info "Exiting installer"
                exit 0
                ;;
            *)
                log_error "Invalid option. Please select 1-5."
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..." -n 1 -r
        echo ""
    done
}

# Parse command line arguments
parse_args() {
    case "${1:-}" in
        --full|-f)
            run_full_install
            ;;
        --system|-s)
            run_system_install
            ;;
        --user|-u)
            run_user_install
            ;;
        --status)
            check_status
            ;;
        --help|-h)
            show_help
            ;;
        *)
            # No arguments or unknown argument - run interactive mode
            interactive_mode
            ;;
    esac
}

# Show help message
show_help() {
    print_banner
    echo "Usage: ./install.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  --full,   -f    Run full installation (system + user)"
    echo "  --system, -s    Run system installation only (requires sudo)"
    echo "  --user,   -u    Run user installation only"
    echo "  --status        Check installation status"
    echo "  --help,   -h    Show this help message"
    echo ""
    echo "Without options, runs in interactive mode."
    echo ""
    echo "Examples:"
    echo "  ./install.sh              # Interactive mode"
    echo "  ./install.sh --full       # Install everything"
    echo "  ./install.sh --user       # User tools only (no sudo)"
    echo "  sudo ./install.sh --system  # System packages only"
}

# Main execution
main() {
    print_banner

    # Make sure all scripts are executable
    chmod +x "$DOTFILES_DIR"/*.sh
    chmod +x "$DOTFILES_DIR"/**/*.sh 2>/dev/null || true

    # Check if script files exist
    if [[ ! -f "$DOTFILES_DIR/system-install.sh" ]]; then
        log_error "system-install.sh not found!"
        exit 1
    fi

    if [[ ! -f "$DOTFILES_DIR/user-install.sh" ]]; then
        log_error "user-install.sh not found!"
        exit 1
    fi

    # Parse arguments or run interactive mode
    parse_args "$@"
}

# Run main
main "$@"