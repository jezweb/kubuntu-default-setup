#!/bin/bash

# GitHub CLI Setup Script
# This script installs GitHub CLI (gh) on Linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting GitHub CLI setup..."

# Check if GitHub CLI is already installed
if command_exists gh; then
    log_success "GitHub CLI is already installed"
    gh --version
    
    # Check authentication status
    if gh auth status &>/dev/null; then
        log_success "GitHub CLI is authenticated"
    else
        if confirm "Would you like to authenticate with GitHub?" "y"; then
            log_info "Starting GitHub authentication..."
            gh auth login
        fi
    fi
    
    # Update check
    if confirm "Would you like to check for GitHub CLI updates?" "n"; then
        sudo apt update
        sudo apt upgrade gh -y
    fi
else
    if confirm "Would you like to install GitHub CLI?" "y"; then
        log_info "Installing GitHub CLI..."
        
        # Install dependencies
        (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
            && sudo mkdir -p -m 755 /etc/apt/keyrings \
            && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
            && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
            && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && sudo apt update \
            && sudo apt install gh -y
        
        # Clean up temp file
        rm -f $out
        
        # Verify installation
        if command_exists gh; then
            log_success "GitHub CLI installed successfully!"
            gh --version
            
            # Offer to authenticate
            if confirm "Would you like to authenticate with GitHub now?" "y"; then
                log_info "Starting GitHub authentication..."
                log_info "You'll be prompted to choose authentication method (browser or token)"
                gh auth login
            fi
        else
            log_error "GitHub CLI installation failed!"
            exit 1
        fi
    else
        log_info "Skipping GitHub CLI installation"
    fi
fi

# Configure GitHub CLI
if command_exists gh && gh auth status &>/dev/null; then
    if confirm "Would you like to configure GitHub CLI settings?" "y"; then
        log_info "Configuring GitHub CLI..."
        
        # Set default editor
        if command_exists code; then
            gh config set editor "code --wait"
            log_success "Set VS Code as default editor for GitHub CLI"
        fi
        
        # Set git protocol
        gh config set git_protocol https
        log_success "Set git protocol to HTTPS"
        
        # Enable gh CLI aliases
        if confirm "Would you like to set up useful gh aliases?" "y"; then
            # Create aliases
            gh alias set pv 'pr view --web'
            gh alias set prco 'pr checkout'
            gh alias set prc 'pr create --web'
            gh alias set iv 'issue view --web'
            gh alias set il 'issue list --limit 10'
            gh alias set rl 'release list --limit 5'
            
            log_success "GitHub CLI aliases configured"
            log_info "Available aliases:"
            log_info "  gh pv    - View PR in browser"
            log_info "  gh prco  - Checkout a PR"
            log_info "  gh prc   - Create PR in browser"
            log_info "  gh iv    - View issue in browser"
            log_info "  gh il    - List recent issues"
            log_info "  gh rl    - List recent releases"
        fi
    fi
fi

# Show useful GitHub CLI commands
if command_exists gh; then
    log_info "Useful GitHub CLI commands:"
    log_info "  gh repo create         - Create a new repository"
    log_info "  gh repo clone          - Clone a repository"
    log_info "  gh pr create           - Create a pull request"
    log_info "  gh pr list             - List pull requests"
    log_info "  gh issue create        - Create an issue"
    log_info "  gh workflow run        - Run a GitHub Action workflow"
    log_info "  gh api                 - Make API requests"
    log_info "  gh auth status         - Check authentication status"
fi

log_success "GitHub CLI setup completed!"