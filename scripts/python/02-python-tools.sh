#!/bin/bash

# Python Development Tools Setup Script
# This script installs common Python development tools using pipx

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting Python development tools setup..."

# Ensure pipx is available
if ! command_exists pipx; then
    log_error "pipx is not installed. Please run the Python/pip setup script first."
    exit 1
fi

# Ensure PATH includes pipx bin directory
export PATH="$PATH:$HOME/.local/bin"

# Function to install tool with pipx
install_with_pipx() {
    local package="$1"
    local command="${2:-$1}"
    local description="$3"
    
    if command_exists "$command"; then
        log_success "$package is already installed"
    else
        if confirm "Would you like to install $package?" "y"; then
            log_info "Installing $package..."
            if [[ -n "$description" ]]; then
                log_info "$description"
            fi
            pipx install "$package"
            if command_exists "$command"; then
                log_success "$package installed successfully"
            else
                log_warning "Failed to install $package"
            fi
        fi
    fi
}

# Install Python development tools
install_with_pipx "black" "black" "Black - The uncompromising Python code formatter"
install_with_pipx "ruff" "ruff" "Ruff - An extremely fast Python linter and formatter"
install_with_pipx "mypy" "mypy" "Mypy - Optional static typing for Python"
install_with_pipx "pytest" "pytest" "Pytest - Python testing framework"
install_with_pipx "poetry" "poetry" "Poetry - Python packaging and dependency management"
install_with_pipx "pipenv" "pipenv" "Pipenv - Python development workflow tool"
install_with_pipx "virtualenv" "virtualenv" "Virtualenv - Virtual environment creator"
install_with_pipx "ipython" "ipython" "IPython - Enhanced interactive Python shell"
install_with_pipx "jupyter" "jupyter" "Jupyter - Interactive computing environment"
install_with_pipx "httpie" "http" "HTTPie - Modern command-line HTTP client"
install_with_pipx "glances" "glances" "Glances - System monitoring tool"
install_with_pipx "cookiecutter" "cookiecutter" "Cookiecutter - Create projects from templates"
install_with_pipx "pre-commit" "pre-commit" "Pre-commit - Git hook framework"

# Special handling for packages mentioned by the user
log_info "Installing special Python packages..."

# Crawl4AI
if confirm "Would you like to install crawl4ai (web crawling framework)?" "y"; then
    log_info "Installing crawl4ai in an isolated environment..."
    pipx install crawl4ai
    if pipx list | grep -q crawl4ai; then
        log_success "crawl4ai installed successfully with pipx"
        log_info "You can use crawl4ai commands directly from the terminal"
    else
        log_warning "crawl4ai installation failed. You may need to install it in a virtual environment."
    fi
fi

# MCP Server Time
if confirm "Would you like to install mcp-server-time?" "y"; then
    log_info "Installing mcp-server-time in an isolated environment..."
    pipx install mcp-server-time
    if pipx list | grep -q mcp-server-time; then
        log_success "mcp-server-time installed successfully with pipx"
    else
        log_warning "mcp-server-time installation failed. You may need to install it in a virtual environment."
    fi
fi

# Stripe Agent Toolkit
if confirm "Would you like to install stripe-agent-toolkit?" "y"; then
    log_info "Installing stripe-agent-toolkit in an isolated environment..."
    pipx install stripe-agent-toolkit
    if pipx list | grep -q stripe-agent-toolkit; then
        log_success "stripe-agent-toolkit installed successfully with pipx"
    else
        log_warning "stripe-agent-toolkit installation failed. You may need to install it in a virtual environment."
    fi
fi

# Create example virtual environment setup script
if confirm "Would you like to create an example script for setting up project virtual environments?" "y"; then
    cat > "$HOME/create-python-project.sh" << 'EOF'
#!/bin/bash
# Example script to create a Python project with virtual environment

PROJECT_NAME="$1"
if [[ -z "$PROJECT_NAME" ]]; then
    echo "Usage: $0 <project-name>"
    exit 1
fi

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Create requirements.txt
cat > requirements.txt << EOL
# Add your project dependencies here
# Examples:
# requests
# pandas
# numpy
# crawl4ai
# lancedb
EOL

# Create .gitignore
cat > .gitignore << EOL
# Python
venv/
*.pyc
__pycache__/
.pytest_cache/
*.egg-info/
dist/
build/
.mypy_cache/
.ruff_cache/

# IDE
.vscode/
.idea/
*.swp
*.swo

# Environment
.env
.env.local
EOL

# Create main.py
cat > main.py << EOL
#!/usr/bin/env python3
"""
$PROJECT_NAME - Main module
"""

def main():
    print("Hello from $PROJECT_NAME!")

if __name__ == "__main__":
    main()
EOL

chmod +x main.py

echo "Project $PROJECT_NAME created successfully!"
echo "Virtual environment activated. Install dependencies with: pip install -r requirements.txt"
EOF
    
    chmod +x "$HOME/create-python-project.sh"
    log_success "Created $HOME/create-python-project.sh"
    log_info "Usage: ~/create-python-project.sh <project-name>"
fi

# Show pipx list
log_info "Installed Python tools:"
pipx list

log_success "Python development tools setup completed!"