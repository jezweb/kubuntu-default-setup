# Kubuntu Setup GUI - Development Plan

## Project Overview
A web-based graphical interface for managing development tool installations on Ubuntu KDE environments, designed to be intuitive for beginners while powerful for experienced developers.

## Default Port: 7842
Chosen for being unusual and unlikely to conflict with common services.

## Architecture Design

### Tech Stack
- **Backend**: Node.js + Express + Socket.io
- **Frontend**: Vue 3 + Vuetify 3 + Vite
- **Database**: SQLite (for configuration/state)
- **Process Management**: PM2
- **Port Scanner**: node-netstat
- **System Info**: systeminformation npm package

### Directory Structure
```
kubuntu-setup-gui/
├── backend/
│   ├── server.js                 # Main Express server
│   ├── config/
│   │   ├── defaults.js           # Default configurations
│   │   └── tool-sets.js          # Pre-configured tool sets
│   ├── api/
│   │   ├── installation.js       # Installation endpoints
│   │   ├── monitoring.js         # System monitoring
│   │   ├── tools.js              # Tool management
│   │   └── ports.js              # Port scanning
│   ├── services/
│   │   ├── installer.js          # Script execution service
│   │   ├── portMonitor.js        # Port monitoring service
│   │   ├── systemInfo.js         # System information
│   │   └── processManager.js     # Service management
│   ├── websocket/
│   │   └── handlers.js           # WebSocket event handlers
│   └── database/
│       ├── schema.sql            # SQLite schema
│       └── db.js                 # Database connection
├── frontend/
│   ├── src/
│   │   ├── main.js
│   │   ├── App.vue
│   │   ├── router/
│   │   ├── store/
│   │   │   ├── modules/
│   │   │   │   ├── installation.js
│   │   │   │   ├── monitoring.js
│   │   │   │   └── tools.js
│   │   │   └── index.js
│   │   ├── views/
│   │   │   ├── Dashboard.vue     # Main overview
│   │   │   ├── Installer.vue     # Installation wizard
│   │   │   ├── ToolSets.vue      # Pre-configured sets
│   │   │   ├── Monitoring.vue    # System/port monitor
│   │   │   ├── Services.vue      # Service management
│   │   │   └── Settings.vue      # Configuration
│   │   ├── components/
│   │   │   ├── ToolCard.vue
│   │   │   ├── InstallProgress.vue
│   │   │   ├── PortMonitor.vue
│   │   │   ├── ServiceCard.vue
│   │   │   └── SystemStats.vue
│   │   └── plugins/
│   │       └── vuetify.js
│   ├── public/
│   └── package.json
├── shared/
│   └── constants.js              # Shared constants
├── scripts/
│   └── setup-gui.sh              # GUI setup script
└── package.json
```

## Core Features

### 1. Dashboard
- **Overview Cards**:
  - Total tools installed
  - System resource usage
  - Active services count
  - Recent activity log
- **Quick Actions**:
  - One-click updates
  - Start/stop all services
  - System health check

### 2. Installation Wizard
- **Category View**:
  - System & Build Tools
  - Programming Languages
  - Databases
  - Cloud Tools
  - AI/ML Tools
  - Frontend Frameworks
- **Tool Selection**:
  - Checkbox selection with dependencies
  - Search/filter functionality
  - Detailed tool descriptions
- **Installation Progress**:
  - Real-time log streaming
  - Progress percentage
  - Error handling with retry

### 3. Pre-configured Tool Sets
```javascript
const toolSets = {
  "fullstack-react": {
    name: "React Full Stack Developer",
    description: "Everything for modern React development",
    tools: ["node", "npm", "yarn", "react", "vite", "docker", "postgresql", "redis"],
    icon: "mdi-react"
  },
  "python-data-science": {
    name: "Python Data Scientist",
    description: "Complete Python data science environment",
    tools: ["python", "pip", "jupyter", "pandas", "numpy", "matplotlib", "docker"],
    icon: "mdi-language-python"
  },
  "ai-engineer": {
    name: "AI/ML Engineer",
    description: "AI development with local LLMs",
    tools: ["python", "ollama", "mcp-servers", "docker", "cuda-toolkit"],
    icon: "mdi-robot"
  },
  "devops-pro": {
    name: "DevOps Professional",
    description: "Infrastructure and deployment tools",
    tools: ["docker", "kubernetes", "terraform", "aws-cli", "github-cli"],
    icon: "mdi-infinity"
  }
}
```

### 4. Port Monitor
- **Active Ports Table**:
  - Port number
  - Service name
  - Process ID
  - Status (listening/established)
- **Port History**:
  - New services detection
  - Port conflict warnings
  - Historical port usage
- **Port Ranges**:
  - System ports (0-1023)
  - User ports (1024-49151)
  - Dynamic ports (49152-65535)

### 5. Service Manager
- **Service Cards**:
  - Docker containers
  - Database servers
  - Development servers
  - MCP servers
- **Actions**:
  - Start/Stop/Restart
  - View logs
  - Edit configuration
  - Auto-start toggle

### 6. Quick Links Hub
- **Dynamic Links**:
  - Detected web services
  - Tool documentation
  - GitHub repos
  - Configuration files
- **Custom Links**:
  - User-added bookmarks
  - Project links
  - Documentation

## API Endpoints

### Installation API
```
POST   /api/install/tool          # Install single tool
POST   /api/install/toolset       # Install tool set
GET    /api/install/progress/:id  # Get installation progress
DELETE /api/install/cancel/:id    # Cancel installation
```

### Monitoring API
```
GET    /api/monitor/system        # System stats
GET    /api/monitor/ports         # Active ports
GET    /api/monitor/services      # Running services
WS     /api/monitor/realtime      # WebSocket for real-time data
```

### Tools API
```
GET    /api/tools                 # List all tools
GET    /api/tools/installed       # List installed tools
GET    /api/tools/:id            # Get tool details
PUT    /api/tools/:id/update     # Update tool
DELETE /api/tools/:id            # Uninstall tool
```

## WebSocket Events

### Client → Server
```javascript
socket.emit('install:start', { tools: ['node', 'docker'] })
socket.emit('monitor:subscribe', { type: 'ports' })
socket.emit('service:action', { service: 'docker', action: 'restart' })
```

### Server → Client
```javascript
socket.emit('install:progress', { toolId, percentage, log })
socket.emit('install:complete', { toolId, success, message })
socket.emit('monitor:update', { type: 'ports', data })
socket.emit('alert', { type: 'warning', message })
```

## Database Schema

```sql
-- Tools table
CREATE TABLE tools (
    id INTEGER PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    category TEXT NOT NULL,
    version TEXT,
    installed BOOLEAN DEFAULT 0,
    install_date DATETIME,
    last_update DATETIME,
    config JSON
);

-- Installation history
CREATE TABLE installations (
    id INTEGER PRIMARY KEY,
    tool_id INTEGER,
    status TEXT,
    started_at DATETIME,
    completed_at DATETIME,
    log TEXT,
    FOREIGN KEY (tool_id) REFERENCES tools(id)
);

-- Port monitoring
CREATE TABLE port_history (
    id INTEGER PRIMARY KEY,
    port INTEGER,
    service TEXT,
    first_seen DATETIME,
    last_seen DATETIME,
    active BOOLEAN DEFAULT 1
);

-- User settings
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value JSON,
    updated_at DATETIME
);
```

## Security Considerations

1. **Authentication** (optional):
   - Basic auth for remote access
   - Token-based API access
   - Local-only mode by default

2. **Validation**:
   - Input sanitization
   - Command injection prevention
   - Path traversal protection

3. **Permissions**:
   - Run as non-root user
   - Sudo prompts for system changes
   - Read-only mode option

## UI/UX Design

### Theme
- Vuetify Material Design
- Dark/Light mode toggle
- Custom color scheme:
  - Primary: #1976D2 (Blue)
  - Secondary: #424242 (Grey)
  - Success: #4CAF50 (Green)
  - Warning: #FF9800 (Orange)
  - Error: #F44336 (Red)

### Responsive Design
- Mobile-first approach
- Tablet optimized
- Desktop full features
- PWA capabilities

### Accessibility
- ARIA labels
- Keyboard navigation
- Screen reader support
- High contrast mode

## Development Phases

### Phase 1: Core Infrastructure (Week 1)
- [ ] Backend server setup
- [ ] Database schema
- [ ] Basic API endpoints
- [ ] Frontend scaffolding

### Phase 2: Installation System (Week 2)
- [ ] Tool detection logic
- [ ] Installation service
- [ ] Progress tracking
- [ ] Error handling

### Phase 3: Monitoring Features (Week 3)
- [ ] Port scanner
- [ ] System monitor
- [ ] Service manager
- [ ] Real-time updates

### Phase 4: UI Polish (Week 4)
- [ ] Dashboard design
- [ ] Installation wizard
- [ ] Responsive layouts
- [ ] Testing & debugging

### Phase 5: Advanced Features (Week 5)
- [ ] Tool sets
- [ ] Backup/restore
- [ ] Auto-updates
- [ ] Documentation

## Testing Strategy

1. **Unit Tests**:
   - API endpoints
   - Service functions
   - Vue components

2. **Integration Tests**:
   - Installation flows
   - WebSocket communication
   - Database operations

3. **E2E Tests**:
   - User workflows
   - Error scenarios
   - Performance tests

## Deployment

### Development
```bash
# Backend
cd backend && npm run dev

# Frontend
cd frontend && npm run dev
```

### Production
```bash
# Build frontend
cd frontend && npm run build

# Start with PM2
pm2 start ecosystem.config.js
```

### Docker Option
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm install
RUN cd frontend && npm install && npm run build
EXPOSE 7842
CMD ["node", "backend/server.js"]
```

## Future Enhancements

1. **Plugin System**:
   - Custom tool definitions
   - Third-party integrations
   - Community scripts

2. **Cloud Sync**:
   - Configuration backup
   - Multi-machine sync
   - Team sharing

3. **AI Assistant**:
   - Tool recommendations
   - Configuration suggestions
   - Troubleshooting help

4. **Marketplace**:
   - Community tool sets
   - Configuration templates
   - Script sharing

## Notes

- Keep existing CLI scripts functional
- Maintain backwards compatibility
- Document all API changes
- Consider offline mode
- Plan for internationalization