#!/bin/bash

# Node.js and NVM Setup Script
# This script installs NVM (Node Version Manager) and Node.js

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting Node.js and NVM setup..."

# NVM version
NVM_VERSION="v0.40.3"
NODE_VERSION="22"

# Check if NVM is already installed
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    log_success "NVM is already installed"
    source "$HOME/.nvm/nvm.sh"
    nvm --version
    
    # Check if Node.js is installed
    if command_exists node; then
        log_success "Node.js is already installed"
        node --version
        npm --version
    else
        log_info "Installing Node.js $NODE_VERSION..."
        nvm install $NODE_VERSION
        nvm use $NODE_VERSION
        nvm alias default $NODE_VERSION
    fi
else
    # Install NVM
    log_info "Installing NVM $NVM_VERSION..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
    
    # Source NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # Verify NVM installation
    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        log_success "NVM installed successfully!"
        
        # Install Node.js
        log_info "Installing Node.js $NODE_VERSION..."
        nvm install $NODE_VERSION
        nvm use $NODE_VERSION
        nvm alias default $NODE_VERSION
        
        # Verify Node.js installation
        if command_exists node; then
            log_success "Node.js installed successfully!"
            log_info "Node.js version: $(node --version)"
            log_info "npm version: $(npm --version)"
        else
            log_error "Node.js installation failed!"
            exit 1
        fi
    else
        log_error "NVM installation failed!"
        exit 1
    fi
fi

# Update npm to latest version
if confirm "Would you like to update npm to the latest version?" "y"; then
    log_info "Updating npm..."
    npm install -g npm@latest
    log_success "npm updated to $(npm --version)"
fi

# Set up npm completion
if confirm "Would you like to enable npm command completion?" "y"; then
    # Capture npm completion output first
    NPM_COMPLETION=$(npm completion 2>/dev/null)
    if [[ -n "$NPM_COMPLETION" ]]; then
        echo "$NPM_COMPLETION" >> $(get_shell_config)
        log_success "npm completion enabled"
    else
        log_warning "Could not generate npm completion"
    fi
fi

# Ensure NVM is properly loaded for subsequent scripts
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

log_success "Node.js and NVM setup completed!"