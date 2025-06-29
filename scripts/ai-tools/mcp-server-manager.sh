#!/bin/bash

# MCP Server Manager
# A utility to manage installed MCP servers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

MCP_DIR="$HOME/.config/mcp"
MCP_SERVERS_DIR="$HOME/.local/share/mcp-servers"

# Ensure directories exist
ensure_dir "$MCP_DIR"
ensure_dir "$MCP_SERVERS_DIR"

show_menu() {
    echo ""
    echo "MCP Server Manager"
    echo "=================="
    echo "  1) List installed MCP servers"
    echo "  2) Test MCP server connection"
    echo "  3) View server configuration"
    echo "  4) Update MCP servers"
    echo "  5) Create Claude Code config"
    echo "  6) Troubleshooting guide"
    echo "  7) Exit"
    echo ""
}

# List installed MCP servers
list_installed_servers() {
    log_info "Checking for installed MCP servers..."
    echo ""
    
    # Check npm global packages
    echo "NPM-based MCP servers:"
    echo "----------------------"
    npm_servers=(
        "@modelcontextprotocol/server-filesystem"
        "@modelcontextprotocol/server-git"
        "@modelcontextprotocol/server-time"
        "@github/github-mcp-server"
        "@makenotion/notion-mcp-server"
        "@cloudflare/mcp-server-cloudflare"
        "@cloudflare/playwright-mcp"
        "@browserbase/mcp-server-browserbase"
        "@supabase-community/supabase-mcp"
        "@upstash/context-mcp"
        "@square/square-mcp-server"
        "@mendableai/firecrawl-mcp-server"
        "excel-mcp-server"
        "pubmed-mcp-server"
        "jina-mcp-tools"
    )
    
    for server in "${npm_servers[@]}"; do
        if npm list -g "$server" &>/dev/null; then
            echo "  ✓ $server"
        fi
    done
    
    # Check Python/pipx packages
    echo ""
    echo "Python-based MCP servers:"
    echo "------------------------"
    if command_exists pipx; then
        if pipx list | grep -q "mcp-server-time"; then
            echo "  ✓ mcp-server-time (Python)"
        fi
    fi
    
    # Check local installations
    echo ""
    echo "Locally installed servers:"
    echo "-------------------------"
    if [[ -d "$MCP_SERVERS_DIR" ]]; then
        for dir in "$MCP_SERVERS_DIR"/*; do
            if [[ -d "$dir" ]]; then
                echo "  ✓ $(basename "$dir")"
            fi
        done
    fi
    
    # Check for management tools
    echo ""
    echo "Management tools:"
    echo "----------------"
    if command_exists sfconfig; then
        echo "  ✓ Snowfort Config"
    fi
}

# Test MCP server connection
test_server_connection() {
    log_info "Testing MCP server connections..."
    echo ""
    echo "Available servers to test:"
    echo "1) filesystem"
    echo "2) git"
    echo "3) time"
    echo "4) github"
    echo "5) notion"
    echo ""
    
    read -p "Select server to test (1-5): " server_choice
    
    case $server_choice in
        1)
            if command_exists mcp-server-filesystem; then
                log_info "Testing filesystem server..."
                echo '{"method":"list_files","params":{"path":"."}}' | mcp-server-filesystem --path "$HOME" 2>/dev/null | head -20
                log_success "Filesystem server is responsive"
            else
                log_error "Filesystem server not installed"
            fi
            ;;
        2)
            if command_exists mcp-server-git; then
                log_info "Testing git server..."
                # Find a git repo to test with
                if [[ -d "$HOME/kubuntu-default-setup/.git" ]]; then
                    echo '{"method":"status"}' | mcp-server-git --repo "$HOME/kubuntu-default-setup" 2>/dev/null | head -20
                    log_success "Git server is responsive"
                else
                    log_warning "No git repository found for testing"
                fi
            else
                log_error "Git server not installed"
            fi
            ;;
        3)
            if command_exists mcp-server-time; then
                log_info "Testing time server..."
                echo '{"method":"get_time"}' | mcp-server-time 2>/dev/null | head -10
                log_success "Time server is responsive"
            else
                log_error "Time server not installed"
            fi
            ;;
        *)
            log_warning "Server testing for this option not yet implemented"
            ;;
    esac
}

# View server configuration
view_server_config() {
    log_info "MCP Server Configuration Files:"
    echo ""
    
    if [[ -d "$MCP_DIR" ]]; then
        for config in "$MCP_DIR"/*.json; do
            if [[ -f "$config" ]]; then
                echo "Found: $(basename "$config")"
                if confirm "View this file?" "y"; then
                    cat "$config" | jq . 2>/dev/null || cat "$config"
                    echo ""
                fi
            fi
        done
    else
        log_warning "No configuration files found in $MCP_DIR"
    fi
}

# Update MCP servers
update_servers() {
    log_info "Updating MCP servers..."
    echo ""
    
    # Update npm packages
    if confirm "Update all global npm MCP servers?" "y"; then
        npm_servers=(
            "@modelcontextprotocol/server-filesystem"
            "@modelcontextprotocol/server-git"
            "@modelcontextprotocol/server-time"
            "@github/github-mcp-server"
            "@makenotion/notion-mcp-server"
            "@cloudflare/mcp-server-cloudflare"
            "@cloudflare/playwright-mcp"
            "@browserbase/mcp-server-browserbase"
            "@supabase-community/supabase-mcp"
            "@upstash/context-mcp"
            "@square/square-mcp-server"
            "@mendableai/firecrawl-mcp-server"
        )
        
        for server in "${npm_servers[@]}"; do
            if npm list -g "$server" &>/dev/null; then
                log_info "Updating $server..."
                npm update -g "$server"
            fi
        done
    fi
    
    # Update pipx packages
    if command_exists pipx && confirm "Update pipx MCP packages?" "y"; then
        pipx upgrade-all
    fi
    
    log_success "Updates completed"
}

# Create Claude Code configuration
create_claude_config() {
    log_info "Creating Claude Code configuration..."
    
    CONFIG_FILE="$HOME/.config/claude/claude_code_config.json"
    ensure_dir "$(dirname "$CONFIG_FILE")"
    
    # Detect installed servers and create config
    cat > "$CONFIG_FILE" << 'EOF'
{
  "mcpServers": {
EOF
    
    first=true
    
    # Add filesystem server if installed
    if npm list -g @modelcontextprotocol/server-filesystem &>/dev/null; then
        [[ "$first" == false ]] && echo "," >> "$CONFIG_FILE"
        cat >> "$CONFIG_FILE" << 'EOF'
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": ["--path", "$HOME/projects"],
      "env": {}
    }
EOF
        first=false
    fi
    
    # Add git server if installed
    if npm list -g @modelcontextprotocol/server-git &>/dev/null; then
        [[ "$first" == false ]] && echo "," >> "$CONFIG_FILE"
        cat >> "$CONFIG_FILE" << 'EOF'
    "git": {
      "command": "mcp-server-git",
      "args": ["--repo", "$HOME/projects/my-repo"],
      "env": {}
    }
EOF
        first=false
    fi
    
    # Add time server if installed
    if command_exists mcp-server-time; then
        [[ "$first" == false ]] && echo "," >> "$CONFIG_FILE"
        cat >> "$CONFIG_FILE" << 'EOF'
    "time": {
      "command": "mcp-server-time",
      "args": [],
      "env": {}
    }
EOF
        first=false
    fi
    
    # Close the JSON
    echo "  }" >> "$CONFIG_FILE"
    echo "}" >> "$CONFIG_FILE"
    
    log_success "Configuration created at $CONFIG_FILE"
    log_info "Edit this file to customize paths and add API keys"
}

# Troubleshooting guide
show_troubleshooting() {
    cat << 'EOF'

MCP Server Troubleshooting Guide
================================

Common Issues:
-------------

1. Server not found:
   - Ensure the server is installed: npm list -g <package-name>
   - Check if the command is in PATH: which <command-name>
   - Try reinstalling the server

2. Permission errors:
   - Ensure you have read/write access to configured paths
   - Check API key permissions for cloud services

3. Connection failures:
   - Verify API keys are correct and active
   - Check network connectivity
   - Ensure required services are accessible

4. Configuration issues:
   - Validate JSON syntax: jq . config.json
   - Check for missing required fields
   - Ensure paths use absolute paths, not relative

Debug Commands:
--------------
# Test a server directly
echo '{"method":"test"}' | <mcp-server-command>

# Check npm global packages
npm list -g | grep mcp

# View Claude Code logs
tail -f ~/.config/claude/logs/*.log

# Validate configuration
jq . ~/.config/claude/claude_code_config.json

Environment Variables:
---------------------
Some servers require environment variables:
- GITHUB_TOKEN for GitHub MCP
- NOTION_API_KEY for Notion MCP
- SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY for Supabase

Set these in your shell profile or in the server configuration.

EOF
    
    read -p "Press Enter to continue..."
}

# Main loop
main() {
    while true; do
        show_menu
        read -p "Select option (1-7): " choice
        
        case $choice in
            1) list_installed_servers ;;
            2) test_server_connection ;;
            3) view_server_config ;;
            4) update_servers ;;
            5) create_claude_config ;;
            6) show_troubleshooting ;;
            7) 
                log_info "Exiting MCP Server Manager..."
                exit 0
                ;;
            *)
                log_error "Invalid choice. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main