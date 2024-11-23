#!/usr/bin/env bash

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the logging helper
source "${DOTFILES_DIR}/utils/logging.sh"

# Bash-it theme configuration
export BASH_IT_THEME="powerline"

# Theme settings for powerline
export POWERLINE_LEFT_PROMPT="scm python_venv ruby node cwd"
export POWERLINE_RIGHT_PROMPT="in_vim clock battery user_info"

# Powerline specific configurations
export POWERLINE_PROMPT_CHAR="❯"
export POWERLINE_MULTILINE="false"
export POWERLINE_COMPACT="true"
export POWERLINE_SHOW_GIT_ON_RIGHT="false"

# Git status symbols
export SCM_GIT_SHOW_MINIMAL_INFO="true"
export SCM_GIT_SHOW_DETAILS="true"
export SCM_GIT_IGNORE_UNTRACKED="false"

# Custom symbols for powerline
export POWERLINE_SYMBOLS=(
    "$POWERLINE_PROMPT_CHAR"      # Normal prompt symbol
    "⚡"                          # When ran with sudo
    "✗"                          # Error occurred
    "⬆"                          # Git ahead
    "⬇"                          # Git behind
    "⭠"                          # Git staged
    "⭡"                          # Git modified
    "✚"                          # Git added
    "‒"                          # Git deleted
    "⚑"                          # Git renamed
    "⚇"                          # Git unmerged
)

# Load theme
load_theme() {
    log_section "Loading Bash Theme"

    if [ -n "$BASH_IT" ] && [ -d "$BASH_IT" ]; then
        log_info "Setting up Powerline theme..."

        # Reload bash-it theme
        if bash-it reload >/dev/null 2>&1; then
            log_success "Theme loaded successfully"
        else
            log_error "Failed to load theme"
        fi

        # Configure terminal title
        case "$TERM" in
            xterm*|rxvt*|screen*)
                export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
                log_debug "Terminal title configured"
                ;;
            *)
                log_debug "Terminal type $TERM doesn't support custom titles"
                ;;
        esac
    else
        log_warning "Bash-it is not installed. Theme configuration skipped."
    fi
}

# Load custom prompt if bash-it is not available
load_fallback_prompt() {
    log_section "Loading Fallback Prompt"

    if [ ! -d "$BASH_IT" ]; then
        log_info "Setting up fallback prompt..."

        # Custom prompt with git integration
        GIT_PS1_SHOWDIRTYSTATE=true
        GIT_PS1_SHOWSTASHSTATE=true
        GIT_PS1_SHOWUNTRACKEDFILES=true

        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)")\$ '

        log_success "Fallback prompt configured"
    fi
}

# Main function
main() {
    log_section "Configuring Bash Theme"

    # Try to load the main theme first
    load_theme

    # If main theme fails, load fallback
    if [ $? -ne 0 ]; then
        log_warning "Main theme loading failed, switching to fallback prompt"
        load_fallback_prompt
    fi

    log_success "Theme configuration completed"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi