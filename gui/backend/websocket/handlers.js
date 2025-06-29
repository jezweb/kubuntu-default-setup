const { WEBSOCKET_EVENTS } = require('../../shared/constants');
const { startInstallation, cancelInstallation } = require('../services/installer');
const { getSystemStats, getActivePorts } = require('../services/systemInfo');
const { performServiceAction } = require('../services/processManager');
const { logActivity } = require('../database/db');

// Active monitoring subscriptions
const subscriptions = new Map();

function setupWebSocketHandlers(io) {
  io.on('connection', (socket) => {
    console.log(`Client connected: ${socket.id}`);
    logActivity('connection', `Client connected: ${socket.id}`);
    
    // Send initial connection acknowledgment
    socket.emit('connected', { 
      id: socket.id,
      timestamp: new Date().toISOString()
    });
    
    // Installation handlers
    socket.on(WEBSOCKET_EVENTS.INSTALL_START, async (data) => {
      try {
        const { tools, toolSet } = data;
        console.log('Starting installation:', tools || toolSet);
        
        const installationId = await startInstallation(tools, toolSet, (progress) => {
          socket.emit(WEBSOCKET_EVENTS.INSTALL_PROGRESS, progress);
        });
        
        socket.emit(WEBSOCKET_EVENTS.INSTALL_PROGRESS, {
          installationId,
          status: 'started',
          message: 'Installation started'
        });
      } catch (error) {
        console.error('Installation error:', error);
        socket.emit(WEBSOCKET_EVENTS.INSTALL_ERROR, {
          error: error.message
        });
      }
    });
    
    socket.on(WEBSOCKET_EVENTS.INSTALL_CANCEL, async (data) => {
      try {
        const { installationId } = data;
        await cancelInstallation(installationId);
        socket.emit(WEBSOCKET_EVENTS.INSTALL_COMPLETE, {
          installationId,
          status: 'cancelled',
          message: 'Installation cancelled'
        });
      } catch (error) {
        console.error('Cancel error:', error);
        socket.emit(WEBSOCKET_EVENTS.INSTALL_ERROR, {
          error: error.message
        });
      }
    });
    
    // Monitoring subscriptions
    socket.on(WEBSOCKET_EVENTS.MONITOR_SUBSCRIBE, async (data) => {
      const { type, interval = 5000 } = data;
      console.log(`Client ${socket.id} subscribed to ${type} monitoring`);
      
      // Clear any existing subscription for this type
      if (subscriptions.has(`${socket.id}-${type}`)) {
        clearInterval(subscriptions.get(`${socket.id}-${type}`));
      }
      
      // Send initial data
      await sendMonitoringData(socket, type);
      
      // Set up periodic updates
      const intervalId = setInterval(async () => {
        await sendMonitoringData(socket, type);
      }, interval);
      
      subscriptions.set(`${socket.id}-${type}`, intervalId);
    });
    
    socket.on(WEBSOCKET_EVENTS.MONITOR_UNSUBSCRIBE, (data) => {
      const { type } = data;
      const key = `${socket.id}-${type}`;
      
      if (subscriptions.has(key)) {
        clearInterval(subscriptions.get(key));
        subscriptions.delete(key);
        console.log(`Client ${socket.id} unsubscribed from ${type} monitoring`);
      }
    });
    
    // Service management
    socket.on(WEBSOCKET_EVENTS.SERVICE_ACTION, async (data) => {
      try {
        const { service, action } = data;
        console.log(`Service action: ${action} on ${service}`);
        
        const result = await performServiceAction(service, action);
        
        socket.emit(WEBSOCKET_EVENTS.SERVICE_UPDATE, {
          service,
          action,
          result,
          success: true
        });
        
        // Broadcast to all clients
        io.emit(WEBSOCKET_EVENTS.SERVICE_UPDATE, {
          service,
          status: result.status
        });
      } catch (error) {
        console.error('Service action error:', error);
        socket.emit(WEBSOCKET_EVENTS.SERVICE_UPDATE, {
          service: data.service,
          action: data.action,
          success: false,
          error: error.message
        });
      }
    });
    
    // Cleanup on disconnect
    socket.on('disconnect', () => {
      console.log(`Client disconnected: ${socket.id}`);
      logActivity('disconnection', `Client disconnected: ${socket.id}`);
      
      // Clear all subscriptions for this client
      for (const [key, intervalId] of subscriptions.entries()) {
        if (key.startsWith(socket.id)) {
          clearInterval(intervalId);
          subscriptions.delete(key);
        }
      }
    });
  });
  
  // Broadcast activity to all connected clients
  io.broadcastActivity = (type, message, details) => {
    io.emit(WEBSOCKET_EVENTS.ACTIVITY, {
      type,
      message,
      details,
      timestamp: new Date().toISOString()
    });
  };
  
  return io;
}

// Send monitoring data based on type
async function sendMonitoringData(socket, type) {
  try {
    let data;
    
    switch (type) {
      case 'system':
        data = await getSystemStats();
        break;
      case 'ports':
        data = await getActivePorts();
        break;
      case 'services':
        // Implemented in processManager
        const { getRunningServices } = require('../services/processManager');
        data = await getRunningServices();
        break;
      default:
        console.warn(`Unknown monitoring type: ${type}`);
        return;
    }
    
    socket.emit(WEBSOCKET_EVENTS.MONITOR_UPDATE, {
      type,
      data,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Error getting ${type} data:`, error);
    socket.emit(WEBSOCKET_EVENTS.ALERT, {
      type: 'error',
      message: `Failed to get ${type} data`,
      error: error.message
    });
  }
}

module.exports = {
  setupWebSocketHandlers
};