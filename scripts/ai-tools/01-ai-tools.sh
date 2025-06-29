#!/bin/bash

# AI Tools and MCP Servers Setup Script
# This script installs AI-related tools and Model Context Protocol servers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting AI tools and MCP servers setup..."

# Ensure npm is available
if ! command_exists npm; then
    log_error "npm is not installed. Please run the Node.js setup script first."
    exit 1
fi

# Claude Code (already installed in nodejs tools, but check)
if command_exists claude-code; then
    log_success "Claude Code is already installed"
    claude-code --version
else
    log_info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
    log_success "Claude Code installed"
fi

# Gemini CLI (already installed in nodejs tools, but check)
if command_exists gemini; then
    log_success "Gemini CLI is already installed"
else
    log_info "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
    log_success "Gemini CLI installed"
fi

# Snowfort-AI Config
if command_exists sfconfig; then
    log_success "Snowfort-AI Config is already installed"
else
    if confirm "Would you like to install Snowfort-AI Config?" "y"; then
        log_info "Installing Snowfort-AI Config..."
        npm install -g sfconfig
        
        if command_exists sfconfig; then
            log_success "Snowfort-AI Config installed"
            log_info "Access Snowfort-AI at http://localhost:4040/"
        fi
    fi
fi

# OpenAI CLI (unofficial)
if confirm "Would you like to install OpenAI CLI tools?" "y"; then
    if ! command_exists openai; then
        log_info "Installing OpenAI Python package..."
        pipx install openai-cli
        
        if pipx list | grep -q openai-cli; then
            log_success "OpenAI CLI installed"
        fi
    fi
fi

# Ollama (local LLM runner)
install_ollama() {
    if command_exists ollama; then
        log_success "Ollama is already installed"
        ollama --version
    else
        if confirm "Would you like to install Ollama (run LLMs locally)?" "y"; then
            log_info "Installing Ollama..."
            curl -fsSL https://ollama.com/install.sh | sh
            
            if command_exists ollama; then
                log_success "Ollama installed successfully"
                
                if confirm "Would you like to start Ollama service?" "y"; then
                    sudo systemctl enable ollama
                    sudo systemctl start ollama
                    log_success "Ollama service started"
                    
                    if confirm "Would you like to pull a model (e.g., llama2)?" "y"; then
                        log_info "Available models: llama2, codellama, mistral, phi, neural-chat, etc."
                        read -p "Enter model name to pull: " model_name
                        ollama pull "$model_name"
                    fi
                fi
            fi
        fi
    fi
}

# LM Studio setup info
lm_studio_info() {
    if confirm "Would you like information about LM Studio?" "y"; then
        log_info "LM Studio - Local LLM GUI Application"
        log_info "Download from: https://lmstudio.ai/"
        log_info "LM Studio provides a GUI for running local LLMs with an OpenAI-compatible API"
        log_info "After installation, you can connect Claude Code to local models via LM Studio"
    fi
}

# MCP (Model Context Protocol) Servers
install_mcp_servers() {
    log_info "MCP servers have been moved to a dedicated installer..."
    
    # Run the dedicated MCP servers script
    if confirm "Would you like to install MCP servers?" "y"; then
        local mcp_script="$SCRIPT_DIR/02-mcp-servers.sh"
        if [[ -f "$mcp_script" ]]; then
            log_info "Launching MCP servers installer..."
            bash "$mcp_script"
        else
            log_error "MCP servers script not found at $mcp_script"
        fi
    fi
    
    # Install MCP manager
    if confirm "Would you like to install the MCP server manager?" "y"; then
        local manager_script="$SCRIPT_DIR/mcp-server-manager.sh"
        if [[ -f "$manager_script" ]]; then
            # Create symlink for easy access
            ln -sf "$manager_script" "$HOME/.local/bin/mcp-manager"
            chmod +x "$HOME/.local/bin/mcp-manager"
            log_success "MCP server manager installed. Run 'mcp-manager' to manage servers"
        fi
    fi
}

# LangChain CLI
install_langchain() {
    if command_exists langchain; then
        log_success "LangChain CLI is already installed"
    else
        if confirm "Would you like to install LangChain CLI?" "y"; then
            log_info "Installing LangChain CLI..."
            pipx install langchain-cli
            
            if command_exists langchain; then
                log_success "LangChain CLI installed"
            fi
        fi
    fi
}

# Hugging Face CLI
install_huggingface() {
    if command_exists huggingface-cli; then
        log_success "Hugging Face CLI is already installed"
    else
        if confirm "Would you like to install Hugging Face CLI?" "y"; then
            log_info "Installing Hugging Face CLI..."
            pipx install huggingface-hub[cli]
            
            if command_exists huggingface-cli; then
                log_success "Hugging Face CLI installed"
                
                if confirm "Would you like to login to Hugging Face?" "y"; then
                    huggingface-cli login
                fi
            fi
        fi
    fi
}

# Vector Database Tools
install_vector_db_tools() {
    log_info "Setting up vector database tools..."
    
    # Chroma
    if confirm "Would you like to install Chroma CLI?" "y"; then
        pipx install chromadb
        if pipx list | grep -q chromadb; then
            log_success "Chroma installed"
        fi
    fi
    
    # LanceDB (mentioned by user)
    if confirm "Would you like to create a LanceDB setup script?" "y"; then
        cat > "$HOME/setup-lancedb-project.sh" << 'EOF'
#!/bin/bash
# Setup script for LanceDB project

PROJECT_NAME="${1:-lancedb-project}"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install LanceDB
pip install lancedb

# Create example script
cat > example_lancedb.py << 'EOL'
import lancedb

# Connect to LanceDB
db = lancedb.connect("./lancedb")

# Create a table
data = [
    {"vector": [1.1, 2.3], "text": "hello world"},
    {"vector": [4.5, 6.7], "text": "goodbye world"}
]

table = db.create_table("my_table", data=data)

# Query the table
results = table.search([1.0, 2.0]).limit(1).to_list()
print(results)
EOL

echo "LanceDB project created in $PROJECT_NAME"
echo "Activate the virtual environment with: source venv/bin/activate"
echo "Run the example with: python example_lancedb.py"
EOF
        chmod +x "$HOME/setup-lancedb-project.sh"
        log_success "Created LanceDB setup script at ~/setup-lancedb-project.sh"
    fi
}

# AI Development Frameworks Info
show_ai_frameworks_info() {
    log_info "Popular AI/ML frameworks (install in project virtual environments):"
    log_info "  - TensorFlow: pip install tensorflow"
    log_info "  - PyTorch: pip install torch torchvision"
    log_info "  - Transformers: pip install transformers"
    log_info "  - LangChain: pip install langchain"
    log_info "  - OpenAI: pip install openai"
    log_info "  - Anthropic: pip install anthropic"
    log_info "  - Google Generative AI: pip install google-generativeai"
}

# Main installation
install_ollama
lm_studio_info
install_mcp_servers
install_langchain
install_huggingface
install_vector_db_tools
show_ai_frameworks_info

log_success "AI tools and MCP servers setup completed!"