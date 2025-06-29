#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root!"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ask for user confirmation
confirm() {
    local prompt="$1"
    local default="${2:-y}"
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    read -r -p "$prompt" response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    fi
}

# Add line to file if it doesn't exist
add_to_file_if_missing() {
    local line="$1"
    local file="$2"
    
    if ! grep -Fxq "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        log_info "Added to $file: $line"
    fi
}

# Source shell configuration based on current shell
source_shell_config() {
    local shell_name=$(basename "$SHELL")
    
    case "$shell_name" in
        bash)
            source ~/.bashrc
            ;;
        zsh)
            source ~/.zshrc
            ;;
        *)
            log_warning "Unknown shell: $shell_name. You may need to restart your shell."
            ;;
    esac
}

# Get the appropriate shell config file
get_shell_config() {
    local shell_name=$(basename "$SHELL")
    
    case "$shell_name" in
        bash)
            echo "$HOME/.bashrc"
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}