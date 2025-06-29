# MCP (Model Context Protocol) Servers Guide

## Overview

Model Context Protocol (MCP) servers enable Claude Code and other AI assistants to interact with external systems and services. This guide covers all available MCP servers in our installation system.

## Quick Start

1. Install MCP servers:
   ```bash
   ./scripts/ai-tools/02-mcp-servers.sh
   ```

2. Manage installed servers:
   ```bash
   mcp-manager  # After installation
   ```

3. Configure in Claude Code by editing your configuration file with the templates provided.

## Available MCP Servers

### Core Servers

#### 1. **Filesystem Server** (`mcp-server-filesystem`)
- **Purpose**: File system operations (read, write, list files)
- **Installation**: `npm install -g @modelcontextprotocol/server-filesystem`
- **Configuration**:
  ```json
  {
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": ["--path", "/home/user/projects"],
      "env": {}
    }
  }
  ```

#### 2. **Git Server** (`mcp-server-git`)
- **Purpose**: Git repository operations
- **Installation**: `npm install -g @modelcontextprotocol/server-git`
- **Configuration**:
  ```json
  {
    "git": {
      "command": "mcp-server-git",
      "args": ["--repo", "/path/to/repo"],
      "env": {}
    }
  }
  ```

#### 3. **Time Server** (`mcp-server-time`)
- **Purpose**: Date and time information
- **Installation**: `npm install -g @modelcontextprotocol/server-time`
- **Configuration**:
  ```json
  {
    "time": {
      "command": "mcp-server-time",
      "args": [],
      "env": {}
    }
  }
  ```

### Database/Backend Services

#### 4. **Supabase MCP**
- **Purpose**: Interact with Supabase databases and services
- **Installation**: `npm install -g @supabase-community/supabase-mcp`
- **Configuration**:
  ```json
  {
    "supabase": {
      "command": "supabase-mcp",
      "args": [],
      "env": {
        "SUPABASE_URL": "https://your-project.supabase.co",
        "SUPABASE_SERVICE_ROLE_KEY": "your-service-role-key"
      }
    }
  }
  ```

#### 5. **Upstash Context MCP**
- **Purpose**: Serverless Redis and context storage
- **Installation**: `npm install -g @upstash/context-mcp`
- **Requirements**: Upstash account and API credentials

### Productivity Tools

#### 6. **Notion MCP**
- **Purpose**: Read and write Notion pages and databases
- **Installation**: `npm install -g @makenotion/notion-mcp-server`
- **Configuration**:
  ```json
  {
    "notion": {
      "command": "notion-mcp-server",
      "args": [],
      "env": {
        "NOTION_API_KEY": "secret_your_integration_token"
      }
    }
  }
  ```
- **Setup**: Create an integration at https://www.notion.so/my-integrations

#### 7. **Excel MCP**
- **Purpose**: Excel spreadsheet operations
- **Installation**: `npm install -g excel-mcp-server`
- **Use Cases**: Data analysis, report generation, spreadsheet automation

#### 8. **Office Word MCP**
- **Purpose**: Microsoft Word document operations
- **Installation**: Custom installation from GitHub
- **Features**: Document creation, editing, formatting

### Development Tools

#### 9. **GitHub MCP**
- **Purpose**: GitHub repository operations, issues, PRs
- **Installation**: `npm install -g @github/github-mcp-server`
- **Configuration**:
  ```json
  {
    "github": {
      "command": "github-mcp-server",
      "args": [],
      "env": {
        "GITHUB_TOKEN": "ghp_your_personal_access_token"
      }
    }
  }
  ```

#### 10. **Cloudflare MCP**
- **Purpose**: Manage Cloudflare services (Workers, KV, R2, DNS)
- **Installation**: `npm install -g @cloudflare/mcp-server-cloudflare`
- **Requirements**: Cloudflare API token

#### 11. **Playwright MCP**
- **Purpose**: Browser automation and testing
- **Installation**: `npm install -g @cloudflare/playwright-mcp`
- **Features**: Web scraping, automated testing, browser control

#### 12. **BrowserBase MCP**
- **Purpose**: Cloud-based headless browser operations
- **Installation**: `npm install -g @browserbase/mcp-server-browserbase`
- **Use Cases**: Web automation without local browser overhead

### Research/Data Tools

#### 13. **PubMed MCP**
- **Purpose**: Search medical and scientific literature
- **Installation**: `npm install -g pubmed-mcp-server`
- **Features**: Query PubMed database, retrieve abstracts

#### 14. **Firecrawl MCP**
- **Purpose**: Structured web data extraction
- **Installation**: `npm install -g @mendableai/firecrawl-mcp-server`
- **Configuration**:
  ```json
  {
    "firecrawl": {
      "command": "firecrawl-mcp-server",
      "args": [],
      "env": {
        "FIRECRAWL_API_KEY": "your-api-key"
      }
    }
  }
  ```

#### 15. **Jina MCP Tools**
- **Purpose**: Neural search and document processing
- **Installation**: `npm install -g jina-mcp-tools`
- **Features**: Semantic search, document embeddings

### Commerce/Payment

#### 16. **Square MCP**
- **Purpose**: Square payment processing and POS operations
- **Installation**: `npm install -g @square/square-mcp-server`
- **Configuration**:
  ```json
  {
    "square": {
      "command": "square-mcp-server",
      "args": [],
      "env": {
        "SQUARE_ACCESS_TOKEN": "your-access-token",
        "SQUARE_ENVIRONMENT": "sandbox"
      }
    }
  }
  ```

#### 17. **Stripe Agent Toolkit**
- **Purpose**: Stripe payment operations (Note: Python tool, not MCP)
- **Installation**: `pipx install stripe-agent-toolkit`
- **Features**: Payment processing, subscription management

### AI/ML Integration

#### 18. **Hugging Face MCP**
- **Purpose**: Access Hugging Face models and datasets
- **Setup**: Configure at https://huggingface.co/settings/mcp
- **Features**: Model inference, dataset access

## MCP Management Tools

### Snowfort Config
A web-based MCP server configuration manager.

- **Installation**: `npm install -g sfconfig`
- **Usage**: Run `sfconfig` and access http://localhost:4040/
- **Features**: Visual configuration, server testing, easy management

### MCP Server Manager (Included)
Our custom management script for MCP servers.

- **Location**: Available as `mcp-manager` after installation
- **Features**:
  - List installed servers
  - Test server connections
  - View configurations
  - Update servers
  - Troubleshooting guide

## Configuration Best Practices

1. **Security**:
   - Never commit API keys to version control
   - Use environment variables for sensitive data
   - Restrict file system access paths

2. **Paths**:
   - Use absolute paths in configurations
   - Ensure Claude Code has access to specified directories

3. **Testing**:
   - Test each server individually before adding to Claude Code
   - Use the MCP manager to verify installations

## Troubleshooting

### Common Issues

1. **Server not found**:
   ```bash
   # Check if installed
   npm list -g <package-name>
   
   # Verify in PATH
   which <command-name>
   ```

2. **Permission errors**:
   - Check file system permissions
   - Verify API key scopes

3. **Connection failures**:
   - Validate API keys
   - Check network connectivity
   - Review server logs

### Debug Commands

```bash
# Test a server directly
echo '{"method":"test"}' | mcp-server-name

# Check Claude Code logs
tail -f ~/.config/claude/logs/*.log

# Validate configuration
jq . ~/.config/claude/claude_code_config.json
```

## Adding Custom MCP Servers

To add a new MCP server to the installation system:

1. Edit `/scripts/ai-tools/02-mcp-servers.sh`
2. Add installation logic in the appropriate category
3. Update this documentation
4. Test the installation process

## Resources

- [MCP Specification](https://github.com/modelcontextprotocol/specification)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Community MCP Servers](https://github.com/topics/mcp-server)

## Future Servers

Upcoming MCP servers in development:
- Atlassian (Jira, Confluence)
- Additional database connectors
- More productivity tools
- Specialized domain servers