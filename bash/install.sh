#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

export BASH_IT="$HOME/.bash_it"

# Function to clean up duplicate entries in .bashrc
cleanup_bashrc() {
    log_info "Cleaning up .bashrc duplicates..."
    
    # Create a backup
    local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d%H%M%S)"
    cp "$HOME/.bashrc" "$backup_file"
    log_debug "Created backup: $backup_file"
    
    # Create a temporary file
    local temp_file="$HOME/.bashrc.tmp.$$"
    
    # Use awk to remove duplicates while preserving order and the first occurrence
    awk '
    # Track lines we want to deduplicate
    /^[[:space:]]*source.*bash_it\.sh/ { 
        if (!seen_bashit++) print; next 
    }
    /^[[:space:]]*export BASH_IT=/ { 
        if (!seen_bashit_export++) print; next 
    }
    /^[[:space:]]*export BASH_IT_THEME=/ { 
        if (!seen_theme++) print; next 
    }
    /^[[:space:]]*eval.*fzf --bash/ { 
        if (!seen_fzf++) print; next 
    }
    /^[[:space:]]*case \$- in/ { 
        # Skip duplicate interactive checks
        if (seen_case++) {
            # Skip until we find esac
            while (getline && !/^[[:space:]]*esac/) {}
            next
        }
    }
    # Print all other lines
    { print }
    ' "$HOME/.bashrc" > "$temp_file"
    
    # Replace the original file if the temp file was created successfully
    if [ -s "$temp_file" ]; then
        mv "$temp_file" "$HOME/.bashrc"
        log_success "Cleaned up duplicate entries in .bashrc"
    else
        log_error "Failed to clean .bashrc, restoring backup"
        mv "$backup_file" "$HOME/.bashrc"
        rm -f "$temp_file"
        return 1
    fi
}

source_bashit() {
    # Check if bash-it is already sourced in .bashrc
    if ! grep -q "source.*bash_it.sh" "$HOME/.bashrc" 2>/dev/null; then
        # Add a marker comment to identify our configuration block
        echo "" >> "$HOME/.bashrc"
        echo "# === Dotfiles Bash Configuration Start ===" >> "$HOME/.bashrc"
        echo "export BASH_IT_THEME='metal'" >> "$HOME/.bashrc"
        echo "export BASH_IT=\"$HOME/.bash_it\"" >> "$HOME/.bashrc"
        echo 'source "$BASH_IT"/bash_it.sh' >> "$HOME/.bashrc"
        echo "# === Dotfiles Bash Configuration End ===" >> "$HOME/.bashrc"
        log_info "Added bash-it to .bashrc"
    else
        log_debug "bash-it already configured in .bashrc"
    fi
}

source_fzf() {
  if command -v fzf > /dev/null 2>&1; then
    # Check if fzf is already configured in .bashrc
    if ! grep -q 'eval "$(fzf --bash)"' "$HOME/.bashrc" 2>/dev/null; then
        # Add fzf configuration before the dotfiles marker end
        if grep -q "# === Dotfiles Bash Configuration End ===" "$HOME/.bashrc"; then
            # Insert before the end marker
            sed -i '/# === Dotfiles Bash Configuration End ===/i eval "$(fzf --bash)"' "$HOME/.bashrc"
        else
            echo 'eval "$(fzf --bash)"' >> "$HOME/.bashrc"
        fi
        log_info "Added fzf to .bashrc"
    else
        log_debug "fzf already configured in .bashrc"
    fi
  fi
}

source_tools() {
  source_bashit
  source_fzf
}

# Install bash-it if not already installed
install_bashit() {
    log_section "Installing Bash-it"

    if [ ! -d "$HOME/.bash_it" ]; then
        log_info "Cloning bash-it repository..."
        git clone --depth=1 https://github.com/Bash-it/bash-it.git "$BASH_IT"
        "$HOME/.bash_it/install.sh" --silent --no-modify-config
        log_success "Bash-it installed successfully"
        source_tools
    else
        if ! grep -q "source $BASH_IT/bash_it.sh" "$HOME/.bashrc"; then
            source_tools
        fi
        log_info "Bash-it is already installed"
    fi
}

setup_custom_config() {
  log_section "Setting Up Custom Bash Configuration"

  # Ensure custom directory exists
  mkdir -p "$BASH_IT/custom"

  # Array of bash configuration files to symlink
  local config_files=("environment.bash" "functions.bash")
  
  for config_file in "${config_files[@]}"; do
    local source_file="$DOTFILES_DIR/bash/$config_file"
    local target_link="$BASH_IT/custom/$config_file"
    
    # Only process files that exist and have content
    if [ -f "$source_file" ] && [ -s "$source_file" ]; then
      # Remove existing symlink or file if it exists
      if [ -L "$target_link" ] || [ -f "$target_link" ]; then
        log_debug "Removing existing $config_file"
        rm -f "$target_link"
      fi
      
      # Create new symlink
      ln -sf "$source_file" "$target_link"
      
      # Verify the symlink works
      if [ -L "$target_link" ] && [ -e "$target_link" ]; then
        log_success "Symlinked $config_file successfully"
      else
        log_error "Failed to create valid symlink for $config_file"
        return 1
      fi
    else
      log_debug "Skipping $config_file (file doesn't exist or is empty)"
    fi
  done
  
  log_success "Custom bash configuration files setup completed"
}

# Enable bash-it components
setup_bashit_components() {
    log_section "Setting Up Bash-it Components"


    log_info "Enabling completion features..."
    local completions=(
        "git"
        "system"
        "bash-it"
        "pip"
        "pip3"
        "docker"
        "docker-compose"
        "ssh"
    )

    for completion in "${completions[@]}"; do
        bash -c "$BASH_IT/bash_it.sh" enable completion "$completion"
    done

    log_info "Enabling plugins..."
    local plugins=(
        "base"
        "dirs"
        "extract"
        "git"
        "history"
        "ssh"
    )

    for plugin in "${plugins[@]}"; do
        bash -c $BASH_IT/bash_it.sh enable plugin "$plugin"
    done

    log_info "Enabling aliases..."
    local aliases=(
        "general"
        "git"
        "docker"
    )

    for alias in "${aliases[@]}"; do
        bash -c $BASH_IT/bash_it.sh enable alias "$alias"
    done

    log_success "Bash-it components enabled successfully"
}

# Setup custom bash configuration

# Main setup function
main() {
    log_section "Starting Bash-it Installation and Setup"

    # Clean up any duplicate entries first
    cleanup_bashrc
    
    install_bashit
    setup_custom_config
    setup_bashit_components

    log_success "Bash-it setup completed successfully!"
    log_info "Please restart your terminal or source ~/.bashrc to apply changes"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi