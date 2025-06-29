#!/bin/bash

# Global Node.js Tools Setup Script
# This script installs commonly used global npm packages

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting global Node.js tools setup..."

# Ensure npm is available
if ! command_exists npm; then
    log_error "npm is not installed. Please run the NVM/Node.js setup script first."
    exit 1
fi

# Function to install global npm package
install_npm_global() {
    local package_name="$1"
    local command_name="${2:-$1}"
    local description="$3"
    
    if command_exists "$command_name"; then
        log_success "$package_name is already installed"
        if [[ -n "$description" ]]; then
            log_info "$description"
        fi
    else
        if confirm "Would you like to install $package_name?" "y"; then
            log_info "Installing $package_name..."
            npm install -g "$package_name"
            if command_exists "$command_name"; then
                log_success "$package_name installed successfully"
                if [[ -n "$description" ]]; then
                    log_info "$description"
                fi
            else
                log_warning "Failed to install $package_name"
            fi
        fi
    fi
}

# Claude Code
install_npm_global "@anthropic-ai/claude-code" "claude-code" "Claude Code - Anthropic's official CLI for Claude"

# Gemini CLI
install_npm_global "@google/gemini-cli" "gemini" "Gemini CLI - Google's AI CLI tool"

# Cloudflare Workers CLI (Wrangler)
install_npm_global "wrangler" "wrangler" "Cloudflare Workers CLI"

# Create React App
install_npm_global "create-react-app" "create-react-app" "Create React App - Bootstrap React applications"

# Vite
install_npm_global "create-vite" "create-vite" "Vite - Next generation frontend tooling"

# Vue CLI
install_npm_global "@vue/cli" "vue" "Vue CLI - Standard tooling for Vue.js development"

# Angular CLI
install_npm_global "@angular/cli" "ng" "Angular CLI - CLI tool for Angular"

# TypeScript
install_npm_global "typescript" "tsc" "TypeScript - JavaScript with syntax for types"

# ESLint
install_npm_global "eslint" "eslint" "ESLint - JavaScript linting utility"

# Prettier
install_npm_global "prettier" "prettier" "Prettier - Opinionated code formatter"

# Nodemon
install_npm_global "nodemon" "nodemon" "Nodemon - Monitor for changes and automatically restart server"

# PM2
install_npm_global "pm2" "pm2" "PM2 - Production process manager for Node.js"

# Serve
install_npm_global "serve" "serve" "Serve - Static file serving and directory listing"

# Vercel CLI
install_npm_global "vercel" "vercel" "Vercel CLI - Deploy with Vercel"

# Netlify CLI
install_npm_global "netlify-cli" "netlify" "Netlify CLI - Deploy with Netlify"

# Playwright
if confirm "Would you like to install Playwright for browser automation?" "y"; then
    log_info "Creating a test project for Playwright installation..."
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    npm init -y > /dev/null 2>&1
    npm init playwright@latest
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    log_success "Playwright installed successfully"
fi

# Firebase Tools
if confirm "Would you like to install Firebase CLI?" "y"; then
    log_info "Installing Firebase CLI..."
    curl -sL https://firebase.tools | bash
    if command_exists firebase; then
        log_success "Firebase CLI installed successfully"
    else
        log_warning "Firebase CLI installation may have failed"
    fi
fi

# Additional developer tools
log_info "Additional developer tools available:"
log_info "- npx: Execute packages without installing (comes with npm)"
log_info "- npm init: Initialize new projects with templates"
log_info "- Use 'npm search' to find more packages"

log_success "Global Node.js tools setup completed!"