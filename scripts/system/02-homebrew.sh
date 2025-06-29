#!/bin/bash

# Homebrew Setup Script
# This script installs Homebrew package manager on Linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting Homebrew setup..."

# Check if Homebrew is already installed
if command_exists brew; then
    log_success "Homebrew is already installed"
    brew --version
    
    if confirm "Would you like to update Homebrew?" "y"; then
        log_info "Updating Homebrew..."
        brew update
    fi
    exit 0
fi

# Install Homebrew
if confirm "Would you like to install Homebrew?" "y"; then
    log_info "Installing Homebrew..."
    
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Linux
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
        BREW_PREFIX="/home/linuxbrew/.linuxbrew"
    else
        BREW_PREFIX="$HOME/.linuxbrew"
    fi
    
    # Get shell config file
    SHELL_CONFIG=$(get_shell_config)
    
    # Add Homebrew to PATH
    log_info "Adding Homebrew to PATH..."
    add_to_file_if_missing 'eval "$('$BREW_PREFIX'/bin/brew shellenv)"' "$SHELL_CONFIG"
    
    # Source the shell config
    eval "$($BREW_PREFIX/bin/brew shellenv)"
    
    # Verify installation
    if command_exists brew; then
        log_success "Homebrew installed successfully!"
        brew --version
        
        # Install recommended packages
        log_info "Installing Homebrew's recommended packages..."
        brew install gcc
    else
        log_error "Homebrew installation failed!"
        exit 1
    fi
else
    log_info "Skipping Homebrew installation"
fi