# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Configure Git globally
configure_git() {
    log_section "Setting Up Git Configuration"

    # Link configuration files
    local git_files=(
        "gitconfig"
        "gitignore_global"
        "gitmessage"
    )

    for file in "${git_files[@]}"; do
        if [ -f "$DOTFILES_DIR/git/$file" ]; then
            log_info "Linking $file..."
            ln -sf "$DOTFILES_DIR/git/$file" "$HOME/.${file}"
            log_success "Linked $file"
        else
            log_warning "Source file $file not found"
        fi
    done

    # Setup git config to use our global gitignore
    git config --global core.excludesfile ~/.gitignore_global

    # Prompt for user information if not already configured
    if [ -z "$(git config --global user.name)" ]; then
        log_info "Git user name not set. Prompting for input..."
        read -p "Enter your Git name: " git_name
        git config --global user.name "$git_name"
        log_success "Git user name configured"
    else
        log_info "Git user name is already configured"
    fi

    if [ -z "$(git config --global user.email)" ]; then
        log_info "Git email not set. Prompting for input..."
        read -p "Enter your Git email: " git_email
        git config --global user.email "$git_email"
        log_success "Git email configured"
    else
        log_info "Git email is already configured"
    fi
}

# Main setup function
main() {
    configure_git
    log_success "Git configuration completed!"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi