# Kubuntu Default Setup for Claude Code Development Environment

A comprehensive setup script collection for configuring Ubuntu KDE (Kubuntu) as a virtual development environment optimized for use with Claude Code.

## Overview

This repository contains automated setup scripts to install and configure all the development tools needed for a productive coding environment in Ubuntu KDE running inside Webtop or similar containerized environments.

## Features

### System & Package Management
- **Essential build tools**: gcc, g++, make, cmake, etc.
- **Homebrew**: Package manager for Linux
- **System utilities**: htop, tree, jq, ripgrep, fd-find, bat, and more

### Node.js Ecosystem
- **NVM**: Node Version Manager for easy Node.js version switching
- **Node.js 22**: Latest LTS version
- **Package managers**: npm, yarn, pnpm
- **Global tools**: TypeScript, ESLint, Prettier, nodemon, PM2, and more
- **Frontend frameworks**: Tailwind CSS, Vuetify, Material-UI scaffolding tools

### Python Ecosystem
- **Python 3**: With pip and venv support
- **pipx**: Install Python applications in isolated environments
- **Development tools**: Black, Ruff, mypy, pytest, Poetry, and more
- **Virtual environment management**: Automated setup scripts

### Development Tools
- **VS Code**: With recommended extensions
- **Git**: Configured with useful aliases and settings
- **GitHub CLI**: For seamless GitHub integration

### Cloud & Backend Services
- **Docker & Docker Compose**: Container management
- **Database clients**: PostgreSQL, MySQL, MongoDB, Redis, SQLite
- **Cloud CLIs**: AWS, Google Cloud, Azure, Heroku, DigitalOcean
- **Infrastructure tools**: Terraform, kubectl, Helm

### AI & Machine Learning Tools
- **Claude Code**: Anthropic's official CLI
- **Gemini CLI**: Google's AI CLI tool
- **Ollama**: Run LLMs locally
- **MCP Servers**: Comprehensive Model Context Protocol server system
  - **Core**: filesystem, git, time servers
  - **Productivity**: Notion, Excel, Office Word integration
  - **Development**: GitHub, Cloudflare, Playwright automation
  - **Data/Research**: PubMed, Firecrawl, Jina neural search
  - **Commerce**: Square, Stripe payment processing
  - **18+ servers available** with interactive installer
  - **MCP Manager**: Tool to manage and test servers
- **Vector databases**: Chroma, LanceDB setup scripts
- **AI CLI tools**: LangChain, Hugging Face CLI, OpenAI tools

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/jezweb/kubuntu-default-setup.git
cd kubuntu-default-setup
```

2. Run the main installer:
```bash
./install.sh
```

3. Choose installation option:
   - **Full Installation** (recommended for new setups)
   - **Select Categories** (for partial installation)

## Web-Based GUI Installer (NEW!)

A modern web interface is now available for managing installations:

### Starting the GUI

```bash
# Quick start (installs dependencies and starts server)
./scripts/start-gui.sh setup

# Or navigate to the GUI directory
cd gui
./scripts/setup-gui.sh setup
```

The GUI will be available at: **http://localhost:7842**

### GUI Features

- **Visual Installation Wizard**: Select tools with checkboxes and see real-time progress
- **Pre-configured Tool Sets**: One-click installation for common developer profiles
- **System Monitoring**: View active ports, running services, and system resources
- **Service Management**: Start/stop Docker containers and other services
- **Port Monitor**: Track what's using which ports with conflict detection
- **Real-time Updates**: WebSocket-based live installation progress and system status

### Development Mode

For GUI development with hot-reload:
```bash
cd gui
npm run dev
```

## Installation Options

### Full Installation
Installs everything in the correct order, handling dependencies automatically. You'll be prompted before each major component.

### Category Installation
Choose specific categories:
1. System Essentials
2. Node.js Ecosystem
3. Python Ecosystem
4. Development Tools
5. Cloud Services
6. AI Tools (includes comprehensive MCP server installer)

### Individual Scripts
Run specific scripts directly:
```bash
# Example: Install only Docker
./scripts/cloud-services/01-docker.sh

# Example: Install only VS Code
./scripts/dev-tools/01-vscode.sh
```

## Directory Structure

```
kubuntu-default-setup/
├── install.sh                    # Main installer script
├── scripts/
│   ├── utils.sh                 # Shared utility functions
│   ├── start-gui.sh             # Quick start for web GUI
│   ├── system/                  # System essentials
│   ├── nodejs/                  # Node.js ecosystem
│   │   ├── 01-nvm-node.sh
│   │   ├── 02-package-managers.sh
│   │   ├── 03-global-tools.sh
│   │   └── 04-frontend-frameworks.sh
│   ├── python/                  # Python ecosystem
│   ├── dev-tools/               # Development tools
│   ├── cloud-services/          # Cloud and database tools
│   └── ai-tools/                # AI and ML tools
│       ├── 01-ai-tools.sh
│       ├── 02-mcp-servers.sh    # Comprehensive MCP installer
│       └── mcp-server-manager.sh
├── gui/                         # Web-based GUI installer
│   ├── backend/                 # Express.js server
│   ├── frontend/                # Vue.js/Vuetify app (to be created)
│   └── scripts/setup-gui.sh     # GUI setup script
├── docs/
│   ├── MCP_SERVERS.md           # Detailed MCP server guide
│   └── GUI_INSTALLER_PLAN.md    # GUI architecture documentation
```

## Post-Installation

After installation:

1. **Restart your terminal** or run:
   ```bash
   source ~/.bashrc
   ```

2. **Authenticate services**:
   ```bash
   gh auth login          # GitHub
   aws configure          # AWS
   gcloud init           # Google Cloud
   az login              # Azure
   ```

3. **Check installed tools**:
   ```bash
   node --version        # Node.js
   python3 --version     # Python
   docker --version      # Docker
   code --version        # VS Code
   ```

## Helper Scripts

The installation creates several helper scripts:

- `~/create-python-project.sh`: Create Python projects with virtual environments
- `~/setup-lancedb-project.sh`: Set up LanceDB vector database projects
- `~/docker-databases/*.sh`: Quick database container setup scripts
- `~/create-vuetify-project.sh`: Create Vue.js projects with Vuetify 3
- `~/create-tailwind-project.sh`: Create projects with Tailwind CSS
- `~/create-mui-project.sh`: Create React projects with Material-UI
- `mcp-manager`: Manage and test installed MCP servers

## Customization

### Adding New Tools

1. Create a new script in the appropriate category directory
2. Follow the existing script patterns using `utils.sh` functions
3. Add the script to the main installer's script list

### Modifying Defaults

Edit individual scripts to change:
- Installation options
- Default configurations
- Package selections

## Requirements

- Ubuntu 20.04+ or Debian-based distribution
- Non-root user with sudo privileges
- Internet connection

## Troubleshooting

### Common Issues

1. **Permission denied**: Make sure scripts are executable:
   ```bash
   chmod +x install.sh
   ```

2. **Command not found after installation**: Restart your terminal or source your shell configuration

3. **Docker requires logout**: After adding user to docker group, logout and login again

### Getting Help

- Check individual script logs for specific errors
- Each tool's official documentation
- Create an issue in the repository

## Contributing

Feel free to submit issues and pull requests for:
- New tools and services
- Bug fixes
- Documentation improvements
- Configuration enhancements

## License

This project is open source and available under the MIT License.

## Acknowledgments

This setup is designed specifically for use with Claude Code in containerized Ubuntu KDE environments like Webtop.