#!/usr/bin/env bash

# Idempotency test script for dotfiles installation
# This script verifies that the installation can be run multiple times safely

set -euo pipefail

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${DOTFILES_DIR}/utils/logging.sh"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    log_info "Testing: $test_name"
    
    if eval "$test_command"; then
        log_success "$test_name passed"
        ((TESTS_PASSED++))
    else
        log_error "$test_name failed"
        ((TESTS_FAILED++))
    fi
}

# Test Homebrew installation idempotency
test_homebrew() {
    if command -v brew &>/dev/null; then
        local brew_version_before=$(brew --version | head -1)
        bash "$DOTFILES_DIR/user-install.sh" 2>&1 | grep -q "Homebrew is already installed"
        local brew_version_after=$(brew --version | head -1)
        [[ "$brew_version_before" == "$brew_version_after" ]]
    else
        log_warning "Homebrew not installed, skipping idempotency test"
        return 0
    fi
}

# Test bash configuration idempotency
test_bash_config() {
    local bashrc_backup="/tmp/bashrc_backup_$$"
    cp "$HOME/.bashrc" "$bashrc_backup" 2>/dev/null || touch "$bashrc_backup"
    
    # Run bash install twice
    bash "$DOTFILES_DIR/bash/install.sh" >/dev/null 2>&1
    local bashrc_first=$(md5sum "$HOME/.bashrc" 2>/dev/null | cut -d' ' -f1)
    
    bash "$DOTFILES_DIR/bash/install.sh" >/dev/null 2>&1
    local bashrc_second=$(md5sum "$HOME/.bashrc" 2>/dev/null | cut -d' ' -f1)
    
    # Restore backup
    mv "$bashrc_backup" "$HOME/.bashrc" 2>/dev/null || true
    
    [[ "$bashrc_first" == "$bashrc_second" ]]
}

# Test git configuration idempotency
test_git_config() {
    local git_name_before=$(git config --global user.name 2>/dev/null || echo "")
    local git_email_before=$(git config --global user.email 2>/dev/null || echo "")
    
    # Run git install in non-interactive mode
    bash "$DOTFILES_DIR/git/install.sh" </dev/null >/dev/null 2>&1
    
    local git_name_after=$(git config --global user.name 2>/dev/null || echo "")
    local git_email_after=$(git config --global user.email 2>/dev/null || echo "")
    
    [[ "$git_name_before" == "$git_name_after" ]] && [[ "$git_email_before" == "$git_email_after" ]]
}

# Test directory creation idempotency
test_directories() {
    local test_dir="$HOME/.config"
    local perms_before=$(stat -c %a "$test_dir" 2>/dev/null || echo "")
    
    # Create directories multiple times
    bash -c "source $DOTFILES_DIR/install.sh && create_directories" >/dev/null 2>&1
    
    local perms_after=$(stat -c %a "$test_dir" 2>/dev/null || echo "")
    
    [[ "$perms_before" == "$perms_after" ]]
}

# Test symlink creation idempotency
test_symlinks() {
    local test_link="$HOME/.gitconfig"
    
    if [ -L "$test_link" ]; then
        local target_before=$(readlink "$test_link")
        bash "$DOTFILES_DIR/git/install.sh" </dev/null >/dev/null 2>&1
        local target_after=$(readlink "$test_link")
        [[ "$target_before" == "$target_after" ]]
    else
        return 0
    fi
}

# Test environment.bash modifications
test_environment_bash() {
    local env_file="$DOTFILES_DIR/bash/environment.bash"
    local line_count_before=$(wc -l < "$env_file" 2>/dev/null || echo 0)
    
    # Run user-install which modifies environment.bash
    bash "$DOTFILES_DIR/user-install.sh" >/dev/null 2>&1
    
    local line_count_after=$(wc -l < "$env_file" 2>/dev/null || echo 0)
    
    # Should not add duplicate lines
    local brew_shellenv_count=$(grep -c "brew shellenv" "$env_file" 2>/dev/null || echo 0)
    
    [[ $brew_shellenv_count -le 1 ]]
}

# Main test execution
main() {
    log_section "Running Idempotency Tests"
    
    log_info "Testing if installation scripts can be run multiple times safely..."
    
    # Run tests
    run_test "Homebrew installation" test_homebrew
    run_test "Bash configuration" test_bash_config
    run_test "Git configuration" test_git_config
    run_test "Directory creation" test_directories
    run_test "Symlink creation" test_symlinks
    run_test "Environment.bash modifications" test_environment_bash
    
    # Summary
    log_section "Test Summary"
    log_success "Tests passed: $TESTS_PASSED"
    if [ $TESTS_FAILED -gt 0 ]; then
        log_error "Tests failed: $TESTS_FAILED"
        exit 1
    else
        log_success "All idempotency tests passed!"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi