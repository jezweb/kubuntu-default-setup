const netstat = require('node-netstat');
const { queries } = require('../database/db');

// Port monitoring service
class PortMonitor {
  constructor() {
    this.monitoringInterval = null;
    this.subscribers = new Set();
  }
  
  // Start monitoring ports
  startMonitoring(interval = 5000) {
    if (this.monitoringInterval) {
      return;
    }
    
    console.log(`Starting port monitoring with ${interval}ms interval`);
    
    this.monitoringInterval = setInterval(async () => {
      try {
        const ports = await this.scanPorts();
        this.notifySubscribers(ports);
      } catch (error) {
        console.error('Port monitoring error:', error);
      }
    }, interval);
    
    // Initial scan
    this.scanPorts().then(ports => this.notifySubscribers(ports));
  }
  
  // Stop monitoring
  stopMonitoring() {
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = null;
      console.log('Port monitoring stopped');
    }
  }
  
  // Subscribe to port updates
  subscribe(callback) {
    this.subscribers.add(callback);
  }
  
  // Unsubscribe from port updates
  unsubscribe(callback) {
    this.subscribers.delete(callback);
  }
  
  // Notify all subscribers
  notifySubscribers(ports) {
    for (const callback of this.subscribers) {
      try {
        callback(ports);
      } catch (error) {
        console.error('Subscriber notification error:', error);
      }
    }
  }
  
  // Scan ports
  scanPorts() {
    return new Promise((resolve, reject) => {
      const ports = [];
      const timeout = setTimeout(() => {
        resolve(this.processPortData(ports));
      }, 2000);
      
      try {
        netstat({
          filter: {
            state: ['LISTEN', 'ESTABLISHED']
          },
          sync: false
        }, (data) => {
          if (data.local && data.local.port) {
            ports.push({
              port: data.local.port,
              address: data.local.address || '0.0.0.0',
              state: data.state,
              protocol: data.protocol,
              pid: data.pid || null,
              process: data.process || 'Unknown'
            });
          }
        });
      } catch (error) {
        clearTimeout(timeout);
        reject(error);
      }
    });
  }
  
  // Process and deduplicate port data
  processPortData(ports) {
    // Remove duplicates
    const uniquePorts = Array.from(
      new Map(ports.map(p => [`${p.port}-${p.protocol}-${p.state}`, p])).values()
    );
    
    // Sort by port number
    uniquePorts.sort((a, b) => a.port - b.port);
    
    // Update database
    this.updatePortHistory(uniquePorts);
    
    return uniquePorts;
  }
  
  // Update port history in database
  updatePortHistory(ports) {
    try {
      // Mark old ports as inactive
      queries.deactivateOldPorts.run();
      
      // Update or insert current ports
      for (const port of ports) {
        queries.recordPort.run(
          port.port,
          port.process,
          port.process,
          port.pid || 0
        );
      }
    } catch (error) {
      console.error('Port history update error:', error);
    }
  }
  
  // Get well-known port information
  getWellKnownPort(port) {
    const wellKnownPorts = {
      20: 'FTP Data',
      21: 'FTP Control',
      22: 'SSH',
      23: 'Telnet',
      25: 'SMTP',
      53: 'DNS',
      80: 'HTTP',
      110: 'POP3',
      143: 'IMAP',
      443: 'HTTPS',
      445: 'SMB',
      3000: 'Node.js Dev',
      3306: 'MySQL',
      5173: 'Vite Dev',
      5432: 'PostgreSQL',
      5984: 'CouchDB',
      6379: 'Redis',
      7842: 'Kubuntu Setup GUI',
      8080: 'HTTP Proxy',
      8888: 'Jupyter',
      9000: 'PHP-FPM',
      9200: 'Elasticsearch',
      11211: 'Memcached',
      11434: 'Ollama',
      27017: 'MongoDB'
    };
    
    return wellKnownPorts[port] || null;
  }
}

// Singleton instance
const portMonitor = new PortMonitor();

// Helper functions for API
async function scanPorts() {
  return portMonitor.scanPorts();
}

async function getPortInfo(portNumber) {
  const ports = await scanPorts();
  const portInfo = ports.find(p => p.port === portNumber);
  
  if (portInfo) {
    const wellKnown = portMonitor.getWellKnownPort(portNumber);
    return {
      ...portInfo,
      wellKnownService: wellKnown
    };
  }
  
  return null;
}

// Start monitoring on module load
if (process.env.NODE_ENV !== 'test') {
  const monitorInterval = process.env.PORT_MONITOR_INTERVAL || 30000; // 30 seconds default
  portMonitor.startMonitoring(parseInt(monitorInterval));
}

module.exports = {
  portMonitor,
  scanPorts,
  getPortInfo
};