// Shared constants between frontend and backend

const INSTALLATION_STATUS = {
  PENDING: 'pending',
  RUNNING: 'running',
  COMPLETED: 'completed',
  FAILED: 'failed',
  CANCELLED: 'cancelled'
};

const SERVICE_TYPES = {
  DOCKER: 'docker',
  SYSTEMD: 'systemd',
  PROCESS: 'process',
  MCP: 'mcp'
};

const SERVICE_STATUS = {
  RUNNING: 'running',
  STOPPED: 'stopped',
  UNKNOWN: 'unknown'
};

const TOOL_CATEGORIES = {
  SYSTEM: 'System & Build Tools',
  NODEJS: 'Node.js & JavaScript',
  PYTHON: 'Python Tools',
  DEV_TOOLS: 'Development Tools',
  DATABASES: 'Databases',
  CLOUD: 'Cloud Services',
  AI: 'AI/ML Tools'
};

const WEBSOCKET_EVENTS = {
  // Client -> Server
  INSTALL_START: 'install:start',
  INSTALL_CANCEL: 'install:cancel',
  MONITOR_SUBSCRIBE: 'monitor:subscribe',
  MONITOR_UNSUBSCRIBE: 'monitor:unsubscribe',
  SERVICE_ACTION: 'service:action',
  
  // Server -> Client
  INSTALL_PROGRESS: 'install:progress',
  INSTALL_COMPLETE: 'install:complete',
  INSTALL_ERROR: 'install:error',
  MONITOR_UPDATE: 'monitor:update',
  SERVICE_UPDATE: 'service:update',
  ALERT: 'alert',
  ACTIVITY: 'activity'
};

const PORT_RANGES = {
  SYSTEM: { min: 0, max: 1023, name: 'System Ports' },
  USER: { min: 1024, max: 49151, name: 'User Ports' },
  DYNAMIC: { min: 49152, max: 65535, name: 'Dynamic Ports' }
};

const API_ENDPOINTS = {
  // Installation
  INSTALL_TOOL: '/api/install/tool',
  INSTALL_TOOLSET: '/api/install/toolset',
  INSTALL_PROGRESS: '/api/install/progress',
  INSTALL_CANCEL: '/api/install/cancel',
  
  // Monitoring
  SYSTEM_STATS: '/api/monitor/system',
  ACTIVE_PORTS: '/api/monitor/ports',
  SERVICES: '/api/monitor/services',
  
  // Tools
  ALL_TOOLS: '/api/tools',
  INSTALLED_TOOLS: '/api/tools/installed',
  TOOL_DETAILS: '/api/tools/:id',
  UPDATE_TOOL: '/api/tools/:id/update',
  UNINSTALL_TOOL: '/api/tools/:id/uninstall',
  
  // Tool Sets
  TOOL_SETS: '/api/tools/sets',
  
  // Settings
  SETTINGS: '/api/settings',
  
  // Activity
  ACTIVITY_LOG: '/api/activity'
};

// Export for both Node.js and ES modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    INSTALLATION_STATUS,
    SERVICE_TYPES,
    SERVICE_STATUS,
    TOOL_CATEGORIES,
    WEBSOCKET_EVENTS,
    PORT_RANGES,
    API_ENDPOINTS
  };
} else {
  export {
    INSTALLATION_STATUS,
    SERVICE_TYPES,
    SERVICE_STATUS,
    TOOL_CATEGORIES,
    WEBSOCKET_EVENTS,
    PORT_RANGES,
    API_ENDPOINTS
  };
}