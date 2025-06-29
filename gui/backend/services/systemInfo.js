const si = require('systeminformation');
const netstat = require('node-netstat');
const { queries } = require('../database/db');

// Get system statistics
async function getSystemStats() {
  try {
    const [cpu, memory, disk, network, time] = await Promise.all([
      si.currentLoad(),
      si.mem(),
      si.fsSize(),
      si.networkStats(),
      si.time()
    ]);
    
    // Get primary disk usage
    const primaryDisk = disk.find(d => d.mount === '/') || disk[0];
    
    return {
      cpu: {
        usage: Math.round(cpu.currentLoad),
        cores: cpu.cpus.length,
        speed: cpu.avgLoad
      },
      memory: {
        total: memory.total,
        used: memory.used,
        free: memory.free,
        percent: Math.round((memory.used / memory.total) * 100)
      },
      disk: {
        total: primaryDisk.size,
        used: primaryDisk.used,
        free: primaryDisk.available,
        percent: Math.round(primaryDisk.use)
      },
      network: {
        rx: network[0] ? network[0].rx_bytes : 0,
        tx: network[0] ? network[0].tx_bytes : 0,
        interface: network[0] ? network[0].iface : 'unknown'
      },
      uptime: time.uptime,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('System stats error:', error);
    throw error;
  }
}

// Scan for active ports
async function scanPorts() {
  return new Promise((resolve, reject) => {
    const ports = [];
    
    netstat({
      filter: {
        state: ['LISTEN', 'ESTABLISHED']
      }
    }, (data) => {
      if (data.local && data.local.port) {
        ports.push({
          port: data.local.port,
          address: data.local.address,
          state: data.state,
          protocol: data.protocol,
          pid: data.pid,
          process: data.process
        });
      }
    });
    
    // Wait a bit for all results
    setTimeout(() => {
      // Update database with current ports
      updatePortHistory(ports);
      
      // Remove duplicates and sort
      const uniquePorts = Array.from(
        new Map(ports.map(p => [`${p.port}-${p.protocol}`, p])).values()
      ).sort((a, b) => a.port - b.port);
      
      resolve(uniquePorts);
    }, 1000);
  });
}

// Get active ports from database with current scan
async function getActivePorts() {
  const ports = await scanPorts();
  return ports;
}

// Update port history in database
function updatePortHistory(ports) {
  try {
    // Mark old ports as inactive
    queries.deactivateOldPorts();
    
    // Update or insert current ports
    for (const port of ports) {
      queries.recordPort(
        port.port,
        port.process || 'Unknown',
        port.process,
        port.pid || 0
      );
    }
  } catch (error) {
    console.error('Port history update error:', error);
  }
}

// Get information about a specific port
async function getPortInfo(portNumber) {
  return new Promise((resolve, reject) => {
    let found = null;
    
    netstat({
      filter: {
        local: {
          port: portNumber
        }
      }
    }, (data) => {
      if (data.local && data.local.port === portNumber) {
        found = {
          port: data.local.port,
          address: data.local.address,
          state: data.state,
          protocol: data.protocol,
          pid: data.pid,
          process: data.process,
          remote: data.remote
        };
      }
    });
    
    setTimeout(() => {
      resolve(found);
    }, 500);
  });
}

// Get system information
async function getSystemInfo() {
  try {
    const [osInfo, cpu, graphics, networkInterfaces] = await Promise.all([
      si.osInfo(),
      si.cpu(),
      si.graphics(),
      si.networkInterfaces()
    ]);
    
    return {
      os: {
        platform: osInfo.platform,
        distro: osInfo.distro,
        release: osInfo.release,
        kernel: osInfo.kernel,
        arch: osInfo.arch,
        hostname: osInfo.hostname
      },
      cpu: {
        manufacturer: cpu.manufacturer,
        brand: cpu.brand,
        cores: cpu.cores,
        physicalCores: cpu.physicalCores,
        speed: cpu.speed
      },
      graphics: graphics.controllers.map(c => ({
        model: c.model,
        vendor: c.vendor,
        vram: c.vram
      })),
      network: networkInterfaces.map(iface => ({
        name: iface.iface,
        ip4: iface.ip4,
        ip6: iface.ip6,
        mac: iface.mac,
        type: iface.type,
        speed: iface.speed
      }))
    };
  } catch (error) {
    console.error('System info error:', error);
    throw error;
  }
}

module.exports = {
  getSystemStats,
  scanPorts,
  getActivePorts,
  getPortInfo,
  getSystemInfo
};