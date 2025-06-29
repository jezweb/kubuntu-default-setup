#!/bin/bash

# Docker Setup Script
# This script installs Docker Engine on Ubuntu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting Docker setup..."

# Check if Docker is already installed
if command_exists docker; then
    log_success "Docker is already installed"
    docker --version
    
    # Check if user can run Docker without sudo
    if docker ps &>/dev/null; then
        log_success "Docker is properly configured for current user"
    else
        if confirm "Would you like to add current user to docker group?" "y"; then
            sudo usermod -aG docker $USER
            log_warning "You need to log out and back in for group changes to take effect"
        fi
    fi
    
    # Check Docker Compose
    if command_exists docker-compose; then
        log_success "Docker Compose v1 is installed: $(docker-compose --version)"
    fi
    
    if docker compose version &>/dev/null; then
        log_success "Docker Compose v2 is installed: $(docker compose version)"
    fi
else
    if confirm "Would you like to install Docker?" "y"; then
        log_info "Installing Docker..."
        
        # Remove old versions
        log_info "Removing old Docker versions if any..."
        for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
            sudo apt-get remove -y $pkg 2>/dev/null || true
        done
        
        # Update package index
        sudo apt-get update
        
        # Install prerequisites
        sudo apt-get install -y \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
        
        # Add Docker's official GPG key
        sudo mkdir -m 0755 -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        # Set up repository
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Update package index with Docker packages
        sudo apt-get update
        
        # Install Docker Engine
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Verify installation
        if command_exists docker; then
            log_success "Docker installed successfully!"
            docker --version
            
            # Add user to docker group
            if confirm "Would you like to run Docker without sudo?" "y"; then
                sudo usermod -aG docker $USER
                log_warning "You need to log out and back in for group changes to take effect"
                log_info "Or run: newgrp docker"
            fi
            
            # Test Docker installation
            if confirm "Would you like to test Docker installation?" "y"; then
                log_info "Running Docker hello-world test..."
                sudo docker run hello-world
            fi
        else
            log_error "Docker installation failed!"
            exit 1
        fi
    else
        log_info "Skipping Docker installation"
    fi
fi

# Install Docker Compose standalone (v1) if requested
if ! command_exists docker-compose; then
    if confirm "Would you like to install Docker Compose v1 (standalone)?" "n"; then
        log_info "Installing Docker Compose v1..."
        
        # Download Docker Compose
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        
        # Make it executable
        sudo chmod +x /usr/local/bin/docker-compose
        
        # Create symlink
        sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
        
        # Verify installation
        if command_exists docker-compose; then
            log_success "Docker Compose v1 installed: $(docker-compose --version)"
        fi
    fi
fi

# Configure Docker
if command_exists docker && confirm "Would you like to configure Docker settings?" "y"; then
    # Create Docker config directory
    sudo mkdir -p /etc/docker
    
    # Create daemon.json with useful defaults
    if [[ ! -f /etc/docker/daemon.json ]]; then
        sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "features": {
    "buildkit": true
  }
}
EOF
        log_success "Docker daemon configured with sensible defaults"
        
        # Restart Docker to apply changes
        sudo systemctl restart docker
    else
        log_info "Docker daemon.json already exists"
    fi
fi

# Install lazydocker (Docker TUI)
if confirm "Would you like to install lazydocker (Docker terminal UI)?" "y"; then
    if command_exists brew; then
        brew install lazydocker
    else
        # Install via script
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
        
        # Add to PATH if needed
        if [[ -f "$HOME/.local/bin/lazydocker" ]]; then
            export PATH="$HOME/.local/bin:$PATH"
            add_to_file_if_missing 'export PATH="$HOME/.local/bin:$PATH"' "$(get_shell_config)"
        fi
    fi
    
    if command_exists lazydocker; then
        log_success "lazydocker installed successfully"
    fi
fi

# Docker shortcuts and aliases
if confirm "Would you like to add Docker aliases to your shell?" "y"; then
    SHELL_CONFIG=$(get_shell_config)
    
    cat >> "$SHELL_CONFIG" << 'EOF'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dco='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dl='docker logs'
alias dlf='docker logs -f'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop'
alias dstart='docker start'
alias drestart='docker restart'

# Docker cleanup functions
dclean() {
    docker system prune -af --volumes
}

dstopall() {
    docker stop $(docker ps -aq)
}

drmall() {
    docker rm $(docker ps -aq)
}
EOF
    
    log_success "Docker aliases added to $SHELL_CONFIG"
fi

log_success "Docker setup completed!"