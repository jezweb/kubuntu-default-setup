const express = require('express');
const router = express.Router();
const { scanPorts, getPortInfo } = require('../services/portMonitor');
const { queries } = require('../database/db');

// Scan for active ports
router.get('/scan', async (req, res) => {
  try {
    const ports = await scanPorts();
    
    res.json({
      ports,
      total: ports.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Port scan error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get information about a specific port
router.get('/:port', async (req, res) => {
  try {
    const { port } = req.params;
    const portNum = parseInt(port);
    
    if (isNaN(portNum) || portNum < 0 || portNum > 65535) {
      return res.status(400).json({ error: 'Invalid port number' });
    }
    
    const info = await getPortInfo(portNum);
    
    // Get history for this port
    const history = queries.db.prepare(`
      SELECT * FROM port_history 
      WHERE port = ? 
      ORDER BY last_seen DESC 
      LIMIT 10
    `).all(portNum);
    
    res.json({
      port: portNum,
      current: info,
      history,
      range: portNum <= 1023 ? 'system' : 
             portNum <= 49151 ? 'user' : 'dynamic'
    });
  } catch (error) {
    console.error('Port info error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Check for port conflicts
router.post('/check-conflicts', async (req, res) => {
  try {
    const { ports } = req.body;
    
    if (!Array.isArray(ports)) {
      return res.status(400).json({ error: 'Ports must be an array' });
    }
    
    const conflicts = [];
    const activePorts = await scanPorts();
    const activePortNumbers = new Set(activePorts.map(p => p.port));
    
    for (const port of ports) {
      if (activePortNumbers.has(port)) {
        const portInfo = activePorts.find(p => p.port === port);
        conflicts.push({
          port,
          inUse: true,
          process: portInfo.process || 'Unknown',
          pid: portInfo.pid
        });
      }
    }
    
    res.json({
      conflicts,
      hasConflicts: conflicts.length > 0
    });
  } catch (error) {
    console.error('Check conflicts error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get common service ports
router.get('/common/services', (req, res) => {
  const commonPorts = [
    { port: 22, service: 'SSH', protocol: 'tcp' },
    { port: 80, service: 'HTTP', protocol: 'tcp' },
    { port: 443, service: 'HTTPS', protocol: 'tcp' },
    { port: 3000, service: 'Node.js Dev Server', protocol: 'tcp' },
    { port: 3306, service: 'MySQL', protocol: 'tcp' },
    { port: 5173, service: 'Vite Dev Server', protocol: 'tcp' },
    { port: 5432, service: 'PostgreSQL', protocol: 'tcp' },
    { port: 6379, service: 'Redis', protocol: 'tcp' },
    { port: 7842, service: 'Kubuntu Setup GUI', protocol: 'tcp' },
    { port: 8080, service: 'HTTP Alternative', protocol: 'tcp' },
    { port: 8888, service: 'Jupyter Notebook', protocol: 'tcp' },
    { port: 9000, service: 'PHP-FPM', protocol: 'tcp' },
    { port: 27017, service: 'MongoDB', protocol: 'tcp' },
    { port: 5984, service: 'CouchDB', protocol: 'tcp' },
    { port: 9200, service: 'Elasticsearch', protocol: 'tcp' },
    { port: 11434, service: 'Ollama', protocol: 'tcp' }
  ];
  
  res.json({ ports: commonPorts });
});

// Get port usage statistics
router.get('/stats/usage', async (req, res) => {
  try {
    const activePorts = await scanPorts();
    
    const stats = {
      total: activePorts.length,
      byRange: {
        system: activePorts.filter(p => p.port <= 1023).length,
        user: activePorts.filter(p => p.port > 1023 && p.port <= 49151).length,
        dynamic: activePorts.filter(p => p.port > 49151).length
      },
      byState: {},
      topProcesses: {}
    };
    
    // Count by state and process
    activePorts.forEach(port => {
      // By state
      stats.byState[port.state] = (stats.byState[port.state] || 0) + 1;
      
      // By process
      if (port.process) {
        stats.topProcesses[port.process] = (stats.topProcesses[port.process] || 0) + 1;
      }
    });
    
    // Convert topProcesses to array and sort
    stats.topProcesses = Object.entries(stats.topProcesses)
      .map(([process, count]) => ({ process, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 10);
    
    res.json(stats);
  } catch (error) {
    console.error('Port stats error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;