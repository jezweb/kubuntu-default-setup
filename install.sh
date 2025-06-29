#!/bin/bash

# Kubuntu Development Environment Setup Script
# Main installer that orchestrates all setup scripts

set -e  # Exit on error

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities
source "$SCRIPT_DIR/scripts/utils.sh"

# ASCII Art Banner
show_banner() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║     Kubuntu Development Environment Setup for Claude Code     ║
║                                                               ║
║  This script will install and configure development tools     ║
║  for your Ubuntu KDE virtual environment                      ║
╚═══════════════════════════════════════════════════════════════╝
EOF
}

# Show menu
show_menu() {
    echo ""
    echo "Installation Options:"
    echo "  1) Full Installation (Recommended for new setups)"
    echo "  2) Select Categories to Install"
    echo "  3) List All Available Scripts"
    echo "  4) Exit"
    echo ""
}

# Run a script with logging
run_script() {
    local script_path="$1"
    local script_name=$(basename "$script_path")
    
    if [[ -f "$script_path" ]]; then
        log_info "Running $script_name..."
        bash "$script_path"
        log_success "$script_name completed"
    else
        log_error "Script not found: $script_path"
        return 1
    fi
}

# Full installation
full_installation() {
    log_info "Starting full installation..."
    
    # Order matters for dependencies
    local scripts=(
        "$SCRIPT_DIR/scripts/system/01-essentials.sh"
        "$SCRIPT_DIR/scripts/system/02-homebrew.sh"
        "$SCRIPT_DIR/scripts/nodejs/01-nvm-node.sh"
        "$SCRIPT_DIR/scripts/nodejs/02-package-managers.sh"
        "$SCRIPT_DIR/scripts/nodejs/03-global-tools.sh"
        "$SCRIPT_DIR/scripts/nodejs/04-frontend-frameworks.sh"
        "$SCRIPT_DIR/scripts/python/01-python-pip.sh"
        "$SCRIPT_DIR/scripts/python/02-python-tools.sh"
        "$SCRIPT_DIR/scripts/dev-tools/01-vscode.sh"
        "$SCRIPT_DIR/scripts/dev-tools/02-github-cli.sh"
        "$SCRIPT_DIR/scripts/dev-tools/03-git-config.sh"
        "$SCRIPT_DIR/scripts/cloud-services/01-docker.sh"
        "$SCRIPT_DIR/scripts/cloud-services/02-databases.sh"
        "$SCRIPT_DIR/scripts/cloud-services/03-cloud-cli.sh"
        "$SCRIPT_DIR/scripts/ai-tools/01-ai-tools.sh"
    )
    
    for script in "${scripts[@]}"; do
        if confirm "Run $(basename "$script")?" "y"; then
            run_script "$script"
            echo ""
        else
            log_info "Skipping $(basename "$script")"
        fi
    done
    
    log_success "Full installation completed!"
}

# Category selection
category_installation() {
    echo ""
    echo "Select categories to install:"
    echo "  1) System Essentials (build tools, apt packages)"
    echo "  2) Node.js Ecosystem (nvm, npm, yarn, pnpm)"
    echo "  3) Python Ecosystem (python, pip, pipx, venv)"
    echo "  4) Development Tools (VS Code, Git, GitHub CLI)"
    echo "  5) Cloud Services (Docker, databases, cloud CLIs)"
    echo "  6) AI Tools (Claude Code, MCP servers, AI CLIs)"
    echo "  7) Back to main menu"
    echo ""
    
    read -p "Enter your choice (1-7): " category_choice
    
    case $category_choice in
        1)
            run_script "$SCRIPT_DIR/scripts/system/01-essentials.sh"
            run_script "$SCRIPT_DIR/scripts/system/02-homebrew.sh"
            ;;
        2)
            run_script "$SCRIPT_DIR/scripts/nodejs/01-nvm-node.sh"
            run_script "$SCRIPT_DIR/scripts/nodejs/02-package-managers.sh"
            run_script "$SCRIPT_DIR/scripts/nodejs/03-global-tools.sh"
            run_script "$SCRIPT_DIR/scripts/nodejs/04-frontend-frameworks.sh"
            ;;
        3)
            run_script "$SCRIPT_DIR/scripts/python/01-python-pip.sh"
            run_script "$SCRIPT_DIR/scripts/python/02-python-tools.sh"
            ;;
        4)
            run_script "$SCRIPT_DIR/scripts/dev-tools/01-vscode.sh"
            run_script "$SCRIPT_DIR/scripts/dev-tools/02-github-cli.sh"
            run_script "$SCRIPT_DIR/scripts/dev-tools/03-git-config.sh"
            ;;
        5)
            run_script "$SCRIPT_DIR/scripts/cloud-services/01-docker.sh"
            run_script "$SCRIPT_DIR/scripts/cloud-services/02-databases.sh"
            run_script "$SCRIPT_DIR/scripts/cloud-services/03-cloud-cli.sh"
            ;;
        6)
            run_script "$SCRIPT_DIR/scripts/ai-tools/01-ai-tools.sh"
            ;;
        7)
            return
            ;;
        *)
            log_error "Invalid choice"
            ;;
    esac
    
    category_installation  # Show menu again
}

# List all scripts
list_scripts() {
    echo ""
    log_info "Available setup scripts:"
    echo ""
    
    echo "System:"
    ls -1 "$SCRIPT_DIR/scripts/system/"*.sh 2>/dev/null | sed 's/.*\//  - /'
    
    echo ""
    echo "Node.js:"
    ls -1 "$SCRIPT_DIR/scripts/nodejs/"*.sh 2>/dev/null | sed 's/.*\//  - /'
    
    echo ""
    echo "Python:"
    ls -1 "$SCRIPT_DIR/scripts/python/"*.sh 2>/dev/null | sed 's/.*\//  - /'
    
    echo ""
    echo "Development Tools:"
    ls -1 "$SCRIPT_DIR/scripts/dev-tools/"*.sh 2>/dev/null | sed 's/.*\//  - /'
    
    echo ""
    echo "Cloud Services:"
    ls -1 "$SCRIPT_DIR/scripts/cloud-services/"*.sh 2>/dev/null | sed 's/.*\//  - /'
    
    echo ""
    echo "AI Tools:"
    ls -1 "$SCRIPT_DIR/scripts/ai-tools/"*.sh 2>/dev/null | sed 's/.*\//  - /'
    
    echo ""
    log_info "You can run individual scripts directly from their paths"
}

# Post-installation summary
show_summary() {
    echo ""
    log_info "Installation Summary:"
    echo ""
    
    # Check what's installed
    echo "Installed Tools:"
    command_exists node && echo "  ✓ Node.js $(node --version)"
    command_exists npm && echo "  ✓ npm $(npm --version)"
    command_exists yarn && echo "  ✓ Yarn $(yarn --version 2>/dev/null || echo 'installed')"
    command_exists pnpm && echo "  ✓ pnpm $(pnpm --version 2>/dev/null || echo 'installed')"
    command_exists python3 && echo "  ✓ Python $(python3 --version)"
    command_exists pip3 && echo "  ✓ pip $(pip3 --version | cut -d' ' -f2)"
    command_exists pipx && echo "  ✓ pipx installed"
    command_exists docker && echo "  ✓ Docker $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
    command_exists code && echo "  ✓ VS Code installed"
    command_exists gh && echo "  ✓ GitHub CLI $(gh --version | head -1)"
    command_exists claude-code && echo "  ✓ Claude Code installed"
    command_exists brew && echo "  ✓ Homebrew installed"
    
    echo ""
    log_info "Next Steps:"
    echo "  1. Restart your terminal or run: source ~/.bashrc"
    echo "  2. Configure tools that need authentication:"
    echo "     - GitHub CLI: gh auth login"
    echo "     - Cloud CLIs: aws configure, gcloud init, etc."
    echo "  3. Set up your projects and start coding!"
    
    echo ""
    log_info "Helper scripts created:"
    [[ -f "$HOME/create-python-project.sh" ]] && echo "  - ~/create-python-project.sh"
    [[ -f "$HOME/setup-lancedb-project.sh" ]] && echo "  - ~/setup-lancedb-project.sh"
    [[ -d "$HOME/docker-databases" ]] && echo "  - ~/docker-databases/*.sh"
}

# Main script
main() {
    clear
    show_banner
    
    # Check if running as root
    check_not_root
    
    # Check Ubuntu/Debian
    if [[ ! -f /etc/debian_version ]]; then
        log_error "This script is designed for Ubuntu/Debian systems"
        exit 1
    fi
    
    # Make all scripts executable
    find "$SCRIPT_DIR/scripts" -name "*.sh" -exec chmod +x {} \;
    
    while true; do
        show_menu
        read -p "Enter your choice (1-4): " choice
        
        case $choice in
            1)
                full_installation
                show_summary
                break
                ;;
            2)
                category_installation
                ;;
            3)
                list_scripts
                ;;
            4)
                log_info "Exiting..."
                exit 0
                ;;
            *)
                log_error "Invalid choice. Please try again."
                ;;
        esac
    done
}

# Run main function
main "$@"