#!/bin/bash

# Cloud Services CLI Tools Setup Script
# This script installs various cloud provider CLI tools

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting cloud services CLI setup..."

# AWS CLI
install_aws_cli() {
    if command_exists aws; then
        log_success "AWS CLI is already installed"
        aws --version
    else
        if confirm "Would you like to install AWS CLI?" "y"; then
            log_info "Installing AWS CLI v2..."
            
            # Download and install
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
            
            # Cleanup
            rm -rf awscliv2.zip aws/
            
            if command_exists aws; then
                log_success "AWS CLI installed successfully"
                
                if confirm "Would you like to configure AWS CLI now?" "y"; then
                    aws configure
                fi
            fi
        fi
    fi
}

# Google Cloud SDK
install_gcloud() {
    if command_exists gcloud; then
        log_success "Google Cloud SDK is already installed"
        gcloud version
    else
        if confirm "Would you like to install Google Cloud SDK?" "y"; then
            log_info "Installing Google Cloud SDK..."
            
            # Add Cloud SDK distribution URI as package source
            echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
            
            # Import Google Cloud public key
            curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.asc
            
            # Update and install
            sudo apt update
            sudo apt install -y google-cloud-cli
            
            if command_exists gcloud; then
                log_success "Google Cloud SDK installed successfully"
                
                if confirm "Would you like to initialize gcloud now?" "y"; then
                    gcloud init
                fi
            fi
        fi
    fi
}

# Azure CLI
install_azure_cli() {
    if command_exists az; then
        log_success "Azure CLI is already installed"
        az version
    else
        if confirm "Would you like to install Azure CLI?" "y"; then
            log_info "Installing Azure CLI..."
            
            # Install
            curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
            
            if command_exists az; then
                log_success "Azure CLI installed successfully"
                
                if confirm "Would you like to login to Azure now?" "y"; then
                    az login
                fi
            fi
        fi
    fi
}

# Heroku CLI
install_heroku_cli() {
    if command_exists heroku; then
        log_success "Heroku CLI is already installed"
        heroku version
    else
        if confirm "Would you like to install Heroku CLI?" "y"; then
            log_info "Installing Heroku CLI..."
            
            # Install via script
            curl https://cli-assets.heroku.com/install.sh | sh
            
            if command_exists heroku; then
                log_success "Heroku CLI installed successfully"
                
                if confirm "Would you like to login to Heroku now?" "y"; then
                    heroku login
                fi
            fi
        fi
    fi
}

# Digital Ocean CLI (doctl)
install_doctl() {
    if command_exists doctl; then
        log_success "DigitalOcean CLI (doctl) is already installed"
        doctl version
    else
        if confirm "Would you like to install DigitalOcean CLI (doctl)?" "y"; then
            log_info "Installing doctl..."
            
            # Download latest release
            DOCTL_VERSION=$(curl -s https://api.github.com/repos/digitalocean/doctl/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
            curl -sL "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz" | tar -xzv
            sudo mv doctl /usr/local/bin
            
            if command_exists doctl; then
                log_success "doctl installed successfully"
                
                if confirm "Would you like to authenticate doctl now?" "y"; then
                    doctl auth init
                fi
            fi
        fi
    fi
}

# Terraform
install_terraform() {
    if command_exists terraform; then
        log_success "Terraform is already installed"
        terraform version
    else
        if confirm "Would you like to install Terraform?" "y"; then
            log_info "Installing Terraform..."
            
            # Add HashiCorp GPG key
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            
            # Add HashiCorp repository
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            
            # Update and install
            sudo apt update
            sudo apt install -y terraform
            
            if command_exists terraform; then
                log_success "Terraform installed successfully"
            fi
        fi
    fi
}

# kubectl
install_kubectl() {
    if command_exists kubectl; then
        log_success "kubectl is already installed"
        kubectl version --client
    else
        if confirm "Would you like to install kubectl?" "y"; then
            log_info "Installing kubectl..."
            
            # Download latest stable version
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            
            # Make executable and move to PATH
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
            
            if command_exists kubectl; then
                log_success "kubectl installed successfully"
                
                # Install kubectl autocomplete
                if confirm "Would you like to enable kubectl autocomplete?" "y"; then
                    echo 'source <(kubectl completion bash)' >> $(get_shell_config)
                    log_success "kubectl autocomplete enabled"
                fi
            fi
        fi
    fi
}

# Helm
install_helm() {
    if command_exists helm; then
        log_success "Helm is already installed"
        helm version
    else
        if confirm "Would you like to install Helm?" "y"; then
            log_info "Installing Helm..."
            
            # Install via script
            curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
            
            if command_exists helm; then
                log_success "Helm installed successfully"
            fi
        fi
    fi
}

# Serverless Framework
install_serverless() {
    if command_exists serverless || command_exists sls; then
        log_success "Serverless Framework is already installed"
    else
        if confirm "Would you like to install Serverless Framework?" "y"; then
            log_info "Installing Serverless Framework..."
            
            npm install -g serverless
            
            if command_exists serverless; then
                log_success "Serverless Framework installed successfully"
            fi
        fi
    fi
}

# Stripe CLI
install_stripe_cli() {
    if command_exists stripe; then
        log_success "Stripe CLI is already installed"
        stripe version
    else
        if confirm "Would you like to install Stripe CLI?" "y"; then
            log_info "Installing Stripe CLI..."
            
            # Download and extract
            curl -s https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | gpg --dearmor | sudo tee /usr/share/keyrings/stripe.gpg
            echo "deb [signed-by=/usr/share/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" | sudo tee /etc/apt/sources.list.d/stripe.list
            
            # Update and install
            sudo apt update
            sudo apt install -y stripe
            
            if command_exists stripe; then
                log_success "Stripe CLI installed successfully"
                
                if confirm "Would you like to login to Stripe now?" "y"; then
                    stripe login
                fi
            fi
        fi
    fi
}

# Supabase CLI
install_supabase_cli() {
    if command_exists supabase; then
        log_success "Supabase CLI is already installed"
        supabase --version
    else
        if confirm "Would you like to install Supabase CLI?" "y"; then
            log_info "Installing Supabase CLI..."
            
            # Install via npm
            npm install -g supabase
            
            if command_exists supabase; then
                log_success "Supabase CLI installed successfully"
            fi
        fi
    fi
}

# Main installation
install_aws_cli
install_gcloud
install_azure_cli
install_heroku_cli
install_doctl
install_terraform
install_kubectl
install_helm
install_serverless
install_stripe_cli
install_supabase_cli

log_success "Cloud services CLI setup completed!"