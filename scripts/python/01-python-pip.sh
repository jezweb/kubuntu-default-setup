#!/bin/bash

# Python and pip Setup Script
# This script ensures Python 3 and pip are properly installed

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting Python and pip setup..."

# Check Python version
PYTHON_CMD=""
if command_exists python3; then
    PYTHON_CMD="python3"
elif command_exists python; then
    # Check if it's Python 3
    if python --version 2>&1 | grep -q "Python 3"; then
        PYTHON_CMD="python"
    fi
fi

if [[ -z "$PYTHON_CMD" ]]; then
    log_warning "Python 3 is not installed. Installing..."
    sudo apt update
    sudo apt install -y python3 python3-dev python3-setuptools
    PYTHON_CMD="python3"
fi

log_success "Python is installed: $($PYTHON_CMD --version)"

# Install pip
if ! command_exists pip3 && ! command_exists pip; then
    log_info "Installing pip..."
    sudo apt install -y python3-pip
fi

# Verify pip installation
PIP_CMD=""
if command_exists pip3; then
    PIP_CMD="pip3"
elif command_exists pip; then
    PIP_CMD="pip"
fi

if [[ -n "$PIP_CMD" ]]; then
    log_success "pip is installed: $($PIP_CMD --version)"
else
    log_error "Failed to install pip!"
    exit 1
fi

# Install Python venv module (required for virtual environments)
log_info "Installing Python venv module..."
sudo apt install -y python3-venv python3-full

# Install pipx
if ! command_exists pipx; then
    log_info "Installing pipx for isolated Python applications..."
    sudo apt update
    sudo apt install -y pipx
    pipx ensurepath
    
    # Source shell config to get pipx in PATH
    export PATH="$PATH:$HOME/.local/bin"
    
    if command_exists pipx; then
        log_success "pipx installed successfully"
        log_info "pipx allows you to install Python applications in isolated environments"
    else
        log_warning "pipx installation may require a shell restart"
    fi
else
    log_success "pipx is already installed"
fi

# Create a directory for virtual environments
VENV_DIR="$HOME/venvs"
if confirm "Would you like to create a directory for virtual environments at $VENV_DIR?" "y"; then
    ensure_dir "$VENV_DIR"
    log_info "You can create virtual environments with: $PYTHON_CMD -m venv $VENV_DIR/myproject"
fi

# Add useful Python aliases to shell config
if confirm "Would you like to add helpful Python aliases to your shell?" "y"; then
    SHELL_CONFIG=$(get_shell_config)
    
    cat >> "$SHELL_CONFIG" << 'EOF'

# Python aliases
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# Function to create and activate a virtual environment
mkvenv() {
    local name="${1:-venv}"
    python3 -m venv "$name" && source "$name/bin/activate"
}

# Function to create a virtual environment in ~/venvs
mkvenvg() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Usage: mkvenvg <name>"
        return 1
    fi
    python3 -m venv "$HOME/venvs/$name" && source "$HOME/venvs/$name/bin/activate"
}
EOF
    
    log_success "Python aliases added to $SHELL_CONFIG"
    log_info "New aliases: py, pip, venv, activate, mkvenv, mkvenvg"
fi

log_success "Python and pip setup completed!"