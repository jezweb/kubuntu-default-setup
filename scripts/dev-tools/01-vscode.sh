#!/bin/bash

# VS Code Setup Script
# This script installs Visual Studio Code on Linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting VS Code setup..."

# Check if VS Code is already installed
if command_exists code; then
    log_success "VS Code is already installed"
    code --version
    
    if confirm "Would you like to install useful VS Code extensions?" "y"; then
        log_info "Installing recommended VS Code extensions..."
        
        # List of recommended extensions
        EXTENSIONS=(
            "ms-python.python"
            "ms-python.vscode-pylance"
            "ms-python.debugpy"
            "dbaeumer.vscode-eslint"
            "esbenp.prettier-vscode"
            "ms-vscode.cpptools"
            "ms-azuretools.vscode-docker"
            "eamodio.gitlens"
            "GitHub.copilot"
            "GitHub.copilot-chat"
            "ritwickdey.LiveServer"
            "formulahendry.code-runner"
            "streetsidesoftware.code-spell-checker"
            "wayou.vscode-todo-highlight"
            "oderwat.indent-rainbow"
            "PKief.material-icon-theme"
            "zhuangtongfa.material-theme"
            "ms-vscode-remote.remote-containers"
            "ms-vscode-remote.remote-ssh"
            "ms-vscode.live-server"
            "Vue.volar"
            "bradlc.vscode-tailwindcss"
        )
        
        for ext in "${EXTENSIONS[@]}"; do
            log_info "Installing $ext..."
            code --install-extension "$ext" --force
        done
        
        log_success "VS Code extensions installed"
    fi
else
    if confirm "Would you like to install VS Code?" "y"; then
        log_info "Installing VS Code..."
        
        # Install dependencies
        sudo apt update
        sudo apt install -y wget gpg
        
        # Add Microsoft GPG key
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        
        # Add VS Code repository
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        
        # Update package cache
        sudo apt update
        
        # Install VS Code
        sudo apt install -y code
        
        # Clean up
        rm -f packages.microsoft.gpg
        
        # Verify installation
        if command_exists code; then
            log_success "VS Code installed successfully!"
            code --version
        else
            log_error "VS Code installation failed!"
            exit 1
        fi
    else
        log_info "Skipping VS Code installation"
    fi
fi

# Create VS Code settings directory
VSCODE_CONFIG="$HOME/.config/Code/User"
ensure_dir "$VSCODE_CONFIG"

# Create recommended settings.json if it doesn't exist
if [[ ! -f "$VSCODE_CONFIG/settings.json" ]]; then
    if confirm "Would you like to create recommended VS Code settings?" "y"; then
        cat > "$VSCODE_CONFIG/settings.json" << 'EOF'
{
    "editor.fontSize": 14,
    "editor.tabSize": 2,
    "editor.insertSpaces": true,
    "editor.detectIndentation": true,
    "editor.formatOnSave": true,
    "editor.formatOnPaste": true,
    "editor.minimap.enabled": true,
    "editor.suggestSelection": "first",
    "editor.snippetSuggestions": "top",
    "editor.multiCursorModifier": "ctrlCmd",
    "editor.rulers": [80, 120],
    "editor.bracketPairColorization.enabled": true,
    "editor.guides.bracketPairs": true,
    "terminal.integrated.fontSize": 14,
    "terminal.integrated.cursorStyle": "line",
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "workbench.startupEditor": "none",
    "workbench.iconTheme": "material-icon-theme",
    "git.autofetch": true,
    "git.confirmSync": false,
    "git.enableSmartCommit": true,
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "[python]": {
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.organizeImports": true
        }
    },
    "[javascript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[typescript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[json]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[html]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[css]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    }
}
EOF
        log_success "Created recommended VS Code settings"
    fi
fi

log_success "VS Code setup completed!"