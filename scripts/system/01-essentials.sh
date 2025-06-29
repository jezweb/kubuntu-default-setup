#!/bin/bash

# System Essentials Setup Script
# This script installs basic system packages and build tools

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting system essentials setup..."

# Update package lists
log_info "Updating package lists..."
sudo apt update

# Essential build tools and libraries
ESSENTIAL_PACKAGES=(
    build-essential
    curl
    wget
    git
    unzip
    zip
    tar
    gzip
    ca-certificates
    gnupg
    lsb-release
    software-properties-common
    apt-transport-https
    libssl-dev
    libffi-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    libncurses5-dev
    libncursesw5-dev
    xz-utils
    tk-dev
    libxml2-dev
    libxmlsec1-dev
    liblzma-dev
    make
    cmake
    gcc
    g++
    pkg-config
    autoconf
    automake
    libtool
)

# Install essential packages
log_info "Installing essential system packages..."
for package in "${ESSENTIAL_PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        log_info "Installing $package..."
        sudo apt install -y "$package"
    else
        log_success "$package is already installed"
    fi
done

# Install additional useful utilities
UTILITY_PACKAGES=(
    htop
    tree
    jq
    ripgrep
    fd-find
    bat
    ncdu
    tmux
    screen
    nano
    vim
    neovim
    zsh
    fish
)

if confirm "Would you like to install additional utility packages (htop, tree, jq, etc.)?" "y"; then
    for package in "${UTILITY_PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            log_info "Installing $package..."
            sudo apt install -y "$package" || log_warning "Failed to install $package"
        else
            log_success "$package is already installed"
        fi
    done
fi

# Clean up
log_info "Cleaning up apt cache..."
sudo apt autoremove -y
sudo apt autoclean

log_success "System essentials setup completed!"