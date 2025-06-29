#!/bin/bash

# Node.js Package Managers Setup Script
# This script installs Yarn, pnpm, and other package management tools

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting Node.js package managers setup..."

# Ensure NVM is loaded if available
if [[ -s "$HOME/.nvm/nvm.sh" ]] && ! command_exists npm; then
    log_info "Loading NVM environment..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Ensure npm is available
if ! command_exists npm; then
    log_error "npm is not installed. Please run the NVM/Node.js setup script first."
    exit 1
fi

# Install Yarn
install_yarn() {
    if command_exists yarn; then
        log_success "Yarn is already installed ($(yarn --version))"
        if confirm "Would you like to update Yarn?" "n"; then
            npm install -g yarn@latest
            log_success "Yarn updated to $(yarn --version)"
        fi
    else
        if confirm "Would you like to install Yarn?" "y"; then
            log_info "Installing Yarn..."
            npm install -g yarn@latest
            if command_exists yarn; then
                log_success "Yarn installed successfully ($(yarn --version))"
            else
                log_error "Yarn installation failed!"
            fi
        fi
    fi
}

# Install pnpm
install_pnpm() {
    if command_exists pnpm; then
        log_success "pnpm is already installed ($(pnpm --version))"
        if confirm "Would you like to update pnpm?" "n"; then
            npm install -g pnpm@latest
            log_success "pnpm updated to $(pnpm --version)"
        fi
    else
        if confirm "Would you like to install pnpm?" "y"; then
            log_info "Installing pnpm..."
            npm install -g pnpm@latest-10
            if command_exists pnpm; then
                log_success "pnpm installed successfully ($(pnpm --version))"
                
                # Set up pnpm
                pnpm setup
                source $(get_shell_config)
            else
                log_error "pnpm installation failed!"
            fi
        fi
    fi
}

# Install ni (package manager switcher)
install_ni() {
    if command_exists ni; then
        log_success "ni is already installed"
    else
        if confirm "Would you like to install ni (smart package manager switcher)?" "y"; then
            log_info "Installing ni..."
            npm install -g @antfu/ni
            if command_exists ni; then
                log_success "ni installed successfully"
                log_info "You can now use 'ni' to install packages with the correct package manager"
            fi
        fi
    fi
}

# Install npm-check-updates
install_ncu() {
    if command_exists ncu; then
        log_success "npm-check-updates is already installed"
    else
        if confirm "Would you like to install npm-check-updates?" "y"; then
            log_info "Installing npm-check-updates..."
            npm install -g npm-check-updates
            if command_exists ncu; then
                log_success "npm-check-updates installed successfully"
            fi
        fi
    fi
}

# Main installation
install_yarn
install_pnpm
install_ni
install_ncu

log_success "Node.js package managers setup completed!"