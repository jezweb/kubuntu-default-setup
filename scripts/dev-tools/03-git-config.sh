#!/bin/bash

# Git Configuration Setup Script
# This script configures Git with sensible defaults

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting Git configuration..."

# Check if Git is installed
if ! command_exists git; then
    log_error "Git is not installed. Installing..."
    sudo apt update
    sudo apt install -y git
fi

log_success "Git is installed: $(git --version)"

# Check if Git is already configured
if git config --global user.name &>/dev/null && git config --global user.email &>/dev/null; then
    log_info "Git is already configured:"
    log_info "  Name: $(git config --global user.name)"
    log_info "  Email: $(git config --global user.email)"
    
    if ! confirm "Would you like to reconfigure Git?" "n"; then
        log_info "Keeping existing Git configuration"
    else
        # Reconfigure
        read -p "Enter your name: " git_name
        read -p "Enter your email: " git_email
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        
        log_success "Git user configured"
    fi
else
    # Initial configuration
    log_info "Git needs to be configured with your name and email"
    read -p "Enter your name: " git_name
    read -p "Enter your email: " git_email
    
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    
    log_success "Git user configured"
fi

# Configure Git settings
if confirm "Would you like to configure recommended Git settings?" "y"; then
    log_info "Configuring Git settings..."
    
    # Core settings
    git config --global core.editor "${EDITOR:-vim}"
    git config --global core.autocrlf input
    git config --global core.whitespace trailing-space,space-before-tab
    
    # Color settings
    git config --global color.ui auto
    git config --global color.branch.current "yellow reverse"
    git config --global color.branch.local yellow
    git config --global color.branch.remote green
    git config --global color.status.added green
    git config --global color.status.changed yellow
    git config --global color.status.untracked red
    
    # Push settings
    git config --global push.default current
    git config --global push.autoSetupRemote true
    
    # Pull settings
    git config --global pull.rebase false
    
    # Merge settings
    git config --global merge.conflictstyle diff3
    
    # Diff settings
    git config --global diff.colorMoved zebra
    
    # Rebase settings
    git config --global rebase.autosquash true
    git config --global rebase.autostash true
    
    # Fetch settings
    git config --global fetch.prune true
    
    # Init settings (default branch name)
    git config --global init.defaultBranch main
    
    log_success "Git settings configured"
fi

# Configure Git aliases
if confirm "Would you like to set up useful Git aliases?" "y"; then
    log_info "Setting up Git aliases..."
    
    # Status and info aliases
    git config --global alias.st status
    git config --global alias.s "status -s"
    git config --global alias.co checkout
    git config --global alias.cob "checkout -b"
    git config --global alias.br branch
    git config --global alias.bra "branch -a"
    
    # Commit aliases
    git config --global alias.ci commit
    git config --global alias.cm "commit -m"
    git config --global alias.ca "commit -a"
    git config --global alias.cam "commit -am"
    git config --global alias.amend "commit --amend"
    git config --global alias.amendne "commit --amend --no-edit"
    
    # Diff aliases
    git config --global alias.d diff
    git config --global alias.dc "diff --cached"
    git config --global alias.dh "diff HEAD"
    
    # Log aliases
    git config --global alias.l "log --oneline --graph --decorate"
    git config --global alias.ll "log --oneline --graph --decorate --all"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.lga "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
    git config --global alias.last "log -1 HEAD"
    
    # Reset aliases
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.undo "reset HEAD~1 --mixed"
    git config --global alias.reset-hard "reset --hard HEAD"
    
    # Stash aliases
    git config --global alias.sl "stash list"
    git config --global alias.sa "stash apply"
    git config --global alias.ss "stash save"
    git config --global alias.sp "stash pop"
    
    # Remote aliases
    git config --global alias.rv "remote -v"
    git config --global alias.pu push
    git config --global alias.puf "push --force-with-lease"
    git config --global alias.pl pull
    
    # Other useful aliases
    git config --global alias.aliases "config --get-regexp alias"
    git config --global alias.whoami "config user.email"
    git config --global alias.contributors "shortlog --summary --numbered"
    git config --global alias.filehistory "log --follow -p --"
    
    log_success "Git aliases configured"
    log_info "Type 'git aliases' to see all configured aliases"
fi

# Global gitignore
if confirm "Would you like to set up a global .gitignore?" "y"; then
    GLOBAL_GITIGNORE="$HOME/.gitignore_global"
    
    cat > "$GLOBAL_GITIGNORE" << 'EOF'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
*~
*.swp
*.swo

# IDE files
.vscode/
.idea/
*.sublime-project
*.sublime-workspace
.project
.classpath
.settings/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Dependencies
node_modules/
vendor/
venv/
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
out/
target/
*.pyc
__pycache__/

# Temporary files
*.tmp
*.temp
.cache/
EOF
    
    git config --global core.excludesfile "$GLOBAL_GITIGNORE"
    log_success "Global .gitignore configured at $GLOBAL_GITIGNORE"
fi

# SSH key generation
if [[ ! -f "$HOME/.ssh/id_ed25519" ]] && [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
    if confirm "Would you like to generate an SSH key for Git?" "y"; then
        log_info "Generating SSH key..."
        ssh-keygen -t ed25519 -C "$(git config --global user.email)"
        
        # Start ssh-agent
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519
        
        log_success "SSH key generated"
        log_info "Your public key:"
        cat ~/.ssh/id_ed25519.pub
        log_info "Add this key to your GitHub/GitLab/Bitbucket account"
    fi
else
    log_info "SSH key already exists"
fi

# Show Git configuration
log_info "Current Git configuration:"
git config --global --list | head -10
log_info "..."

log_success "Git configuration completed!"