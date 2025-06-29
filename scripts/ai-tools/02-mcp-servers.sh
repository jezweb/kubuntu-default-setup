#!/bin/bash

# MCP (Model Context Protocol) Servers Installation Script
# This script provides a comprehensive installer for various MCP servers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "MCP Servers Installation Menu"

# Create MCP directory
MCP_DIR="$HOME/.config/mcp"
ensure_dir "$MCP_DIR"

# Menu system for MCP servers
show_mcp_menu() {
    echo ""
    echo "MCP Server Categories:"
    echo "  1) Core MCP Servers (filesystem, git, time)"
    echo "  2) Database/Backend Services (Supabase, Upstash)"
    echo "  3) Productivity Tools (Notion, Office, Excel)"
    echo "  4) Development Tools (GitHub, Cloudflare, Playwright)"
    echo "  5) Research/Data Tools (PubMed, Firecrawl, Jina)"
    echo "  6) Commerce/Payment (Square, Stripe)"
    echo "  7) AI/ML Tools (Hugging Face)"
    echo "  8) Install All Recommended"
    echo "  9) Exit"
    echo ""
}

# Core MCP Servers (already in 01-ai-tools.sh, but kept here for completeness)
install_core_mcp() {
    log_info "Installing Core MCP Servers..."
    
    # MCP Server Time
    if ! command_exists mcp-server-time && ! pipx list | grep -q mcp-server-time; then
        if confirm "Install mcp-server-time?" "y"; then
            log_info "Installing mcp-server-time..."
            npm install -g @modelcontextprotocol/server-time || {
                # Fallback to Python installation
                log_info "Trying Python installation..."
                pipx install mcp-server-time
            }
        fi
    else
        log_success "mcp-server-time already installed"
    fi
    
    # MCP Server Filesystem
    if ! npm list -g @modelcontextprotocol/server-filesystem &>/dev/null; then
        if confirm "Install mcp-server-filesystem?" "y"; then
            npm install -g @modelcontextprotocol/server-filesystem
            log_success "mcp-server-filesystem installed"
        fi
    else
        log_success "mcp-server-filesystem already installed"
    fi
    
    # MCP Server Git
    if ! npm list -g @modelcontextprotocol/server-git &>/dev/null; then
        if confirm "Install mcp-server-git?" "y"; then
            npm install -g @modelcontextprotocol/server-git
            log_success "mcp-server-git installed"
        fi
    else
        log_success "mcp-server-git already installed"
    fi
}

# Database/Backend MCP Servers
install_database_mcp() {
    log_info "Installing Database/Backend MCP Servers..."
    
    # Supabase MCP
    if confirm "Install Supabase MCP server?" "y"; then
        log_info "Installing Supabase MCP..."
        npm install -g @supabase-community/supabase-mcp
        log_success "Supabase MCP installed"
        
        # Create config template
        cat > "$MCP_DIR/supabase-mcp-config.json" << 'EOF'
{
  "supabase": {
    "command": "supabase-mcp",
    "args": [],
    "env": {
      "SUPABASE_URL": "your-project-url",
      "SUPABASE_SERVICE_ROLE_KEY": "your-service-role-key"
    }
  }
}
EOF
        log_info "Supabase config template created at $MCP_DIR/supabase-mcp-config.json"
    fi
    
    # Upstash Context MCP
    if confirm "Install Upstash Context MCP?" "y"; then
        log_info "Installing Upstash Context MCP..."
        npm install -g @upstash/context-mcp
        log_success "Upstash Context MCP installed"
    fi
}

# Productivity MCP Servers
install_productivity_mcp() {
    log_info "Installing Productivity MCP Servers..."
    
    # Notion MCP
    if confirm "Install Notion MCP server?" "y"; then
        log_info "Installing Notion MCP..."
        npm install -g @makenotion/notion-mcp-server
        log_success "Notion MCP installed"
        
        cat > "$MCP_DIR/notion-mcp-config.json" << 'EOF'
{
  "notion": {
    "command": "notion-mcp-server",
    "args": [],
    "env": {
      "NOTION_API_KEY": "your-notion-integration-token"
    }
  }
}
EOF
        log_info "Notion config template created"
    fi
    
    # Excel MCP
    if confirm "Install Excel MCP server?" "y"; then
        log_info "Installing Excel MCP..."
        npm install -g excel-mcp-server
        log_success "Excel MCP installed"
    fi
    
    # Office Word MCP
    if confirm "Install Office Word MCP server?" "y"; then
        log_info "Cloning Office Word MCP..."
        git clone https://github.com/GongRzhe/Office-Word-MCP-Server.git "$HOME/.local/share/mcp-servers/office-word"
        cd "$HOME/.local/share/mcp-servers/office-word"
        npm install
        log_success "Office Word MCP installed"
        cd - > /dev/null
    fi
}

# Development Tools MCP Servers
install_development_mcp() {
    log_info "Installing Development MCP Servers..."
    
    # GitHub MCP
    if confirm "Install GitHub MCP server?" "y"; then
        log_info "Installing GitHub MCP..."
        npm install -g @github/github-mcp-server
        log_success "GitHub MCP installed"
        
        cat > "$MCP_DIR/github-mcp-config.json" << 'EOF'
{
  "github": {
    "command": "github-mcp-server",
    "args": [],
    "env": {
      "GITHUB_TOKEN": "your-github-token"
    }
  }
}
EOF
        log_info "GitHub MCP config template created"
    fi
    
    # Cloudflare MCP
    if confirm "Install Cloudflare MCP server?" "y"; then
        log_info "Installing Cloudflare MCP..."
        npm install -g @cloudflare/mcp-server-cloudflare
        log_success "Cloudflare MCP installed"
    fi
    
    # Playwright MCP
    if confirm "Install Playwright MCP server?" "y"; then
        log_info "Installing Playwright MCP..."
        npm install -g @cloudflare/playwright-mcp
        log_success "Playwright MCP installed"
    fi
    
    # BrowserBase MCP
    if confirm "Install BrowserBase MCP server?" "y"; then
        log_info "Installing BrowserBase MCP..."
        npm install -g @browserbase/mcp-server-browserbase
        log_success "BrowserBase MCP installed"
    fi
}

# Research/Data MCP Servers
install_research_mcp() {
    log_info "Installing Research/Data MCP Servers..."
    
    # PubMed MCP
    if confirm "Install PubMed MCP server?" "y"; then
        log_info "Installing PubMed MCP..."
        npm install -g pubmed-mcp-server
        log_success "PubMed MCP installed"
    fi
    
    # Firecrawl MCP
    if confirm "Install Firecrawl MCP server?" "y"; then
        log_info "Installing Firecrawl MCP..."
        npm install -g @mendableai/firecrawl-mcp-server
        log_success "Firecrawl MCP installed"
        
        cat > "$MCP_DIR/firecrawl-mcp-config.json" << 'EOF'
{
  "firecrawl": {
    "command": "firecrawl-mcp-server",
    "args": [],
    "env": {
      "FIRECRAWL_API_KEY": "your-firecrawl-api-key"
    }
  }
}
EOF
    fi
    
    # Jina MCP Tools
    if confirm "Install Jina MCP tools?" "y"; then
        log_info "Installing Jina MCP tools..."
        npm install -g jina-mcp-tools
        log_success "Jina MCP tools installed"
    fi
}

# Commerce/Payment MCP Servers
install_commerce_mcp() {
    log_info "Installing Commerce/Payment MCP Servers..."
    
    # Square MCP
    if confirm "Install Square MCP server?" "y"; then
        log_info "Installing Square MCP..."
        npm install -g @square/square-mcp-server
        log_success "Square MCP installed"
        
        cat > "$MCP_DIR/square-mcp-config.json" << 'EOF'
{
  "square": {
    "command": "square-mcp-server",
    "args": [],
    "env": {
      "SQUARE_ACCESS_TOKEN": "your-square-access-token",
      "SQUARE_ENVIRONMENT": "sandbox"
    }
  }
}
EOF
    fi
    
    # Note: Stripe Agent Toolkit is a Python package, not an MCP server
    if confirm "Install Stripe Agent Toolkit (Python)?" "y"; then
        log_info "Installing Stripe Agent Toolkit..."
        pipx install stripe-agent-toolkit
        log_success "Stripe Agent Toolkit installed"
    fi
}

# AI/ML MCP Servers
install_ai_mcp() {
    log_info "Installing AI/ML MCP Servers..."
    
    # Hugging Face MCP
    if confirm "Install Hugging Face MCP integration?" "y"; then
        log_info "Setting up Hugging Face MCP..."
        log_info "Visit https://huggingface.co/settings/mcp for configuration"
        log_info "You'll need to configure this in your Claude Code settings"
    fi
}

# Install recommended servers
install_recommended() {
    log_info "Installing recommended MCP servers..."
    
    # Core servers
    install_core_mcp
    
    # Most useful servers
    if confirm "Install GitHub MCP?" "y"; then
        npm install -g @github/github-mcp-server
    fi
    
    if confirm "Install Notion MCP?" "y"; then
        npm install -g @makenotion/notion-mcp-server
    fi
    
    if confirm "Install Cloudflare MCP?" "y"; then
        npm install -g @cloudflare/mcp-server-cloudflare
    fi
}

# MCP Configuration Management
install_mcp_manager() {
    log_info "Installing MCP management tools..."
    
    # Snowfort Config
    if confirm "Install Snowfort Config (MCP manager)?" "y"; then
        if ! command_exists sfconfig; then
            npm install -g sfconfig
            log_success "Snowfort Config installed"
            log_info "Access at http://localhost:4040/ after running: sfconfig"
        else
            log_success "Snowfort Config already installed"
        fi
    fi
}

# Create comprehensive MCP config template
create_mcp_config_template() {
    if confirm "Create comprehensive MCP configuration template?" "y"; then
        cat > "$MCP_DIR/claude-code-mcp-config.json" << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": ["--path", "/home/user/projects"],
      "env": {}
    },
    "git": {
      "command": "mcp-server-git",
      "args": ["--repo", "/home/user/projects/my-repo"],
      "env": {}
    },
    "time": {
      "command": "mcp-server-time",
      "args": [],
      "env": {}
    },
    "github": {
      "command": "github-mcp-server",
      "args": [],
      "env": {
        "GITHUB_TOKEN": "ghp_your_token_here"
      }
    },
    "notion": {
      "command": "notion-mcp-server",
      "args": [],
      "env": {
        "NOTION_API_KEY": "secret_your_key_here"
      }
    },
    "supabase": {
      "command": "supabase-mcp",
      "args": [],
      "env": {
        "SUPABASE_URL": "https://your-project.supabase.co",
        "SUPABASE_SERVICE_ROLE_KEY": "your-service-role-key"
      }
    }
  }
}
EOF
        log_success "Created comprehensive MCP config template at $MCP_DIR/claude-code-mcp-config.json"
        log_info "Copy relevant sections to your Claude Code configuration"
    fi
}

# Main menu loop
main() {
    while true; do
        show_mcp_menu
        read -p "Select option (1-9): " choice
        
        case $choice in
            1) install_core_mcp ;;
            2) install_database_mcp ;;
            3) install_productivity_mcp ;;
            4) install_development_mcp ;;
            5) install_research_mcp ;;
            6) install_commerce_mcp ;;
            7) install_ai_mcp ;;
            8) install_recommended ;;
            9) 
                log_info "Exiting MCP installer..."
                break
                ;;
            *)
                log_error "Invalid choice. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
    
    # Final steps
    install_mcp_manager
    create_mcp_config_template
    
    log_success "MCP servers installation completed!"
    log_info "Remember to configure each server with your API keys"
    log_info "Check $MCP_DIR for configuration templates"
}

# Run main function
main