const express = require('express');
const router = express.Router();
const { getSystemStats, getActivePorts } = require('../services/systemInfo');
const { getRunningServices } = require('../services/processManager');
const { queries } = require('../database/db');

// Get system statistics
router.get('/system', async (req, res) => {
  try {
    const stats = await getSystemStats();
    res.json(stats);
  } catch (error) {
    console.error('System stats error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get active ports
router.get('/ports', async (req, res) => {
  try {
    const ports = await getActivePorts();
    
    // Categorize ports by range
    const categorized = {
      system: [],
      user: [],
      dynamic: [],
      total: ports.length
    };
    
    ports.forEach(port => {
      const portNum = port.port;
      if (portNum >= 0 && portNum <= 1023) {
        categorized.system.push(port);
      } else if (portNum >= 1024 && portNum <= 49151) {
        categorized.user.push(port);
      } else {
        categorized.dynamic.push(port);
      }
    });
    
    res.json({
      ports,
      categorized,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Port monitoring error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get running services
router.get('/services', async (req, res) => {
  try {
    const services = await getRunningServices();
    
    res.json({
      services,
      total: services.length,
      byType: services.reduce((acc, service) => {
        acc[service.type] = (acc[service.type] || 0) + 1;
        return acc;
      }, {})
    });
  } catch (error) {
    console.error('Services monitoring error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get system health summary
router.get('/health', async (req, res) => {
  try {
    const [systemStats, activePorts, services] = await Promise.all([
      getSystemStats(),
      getActivePorts(),
      getRunningServices()
    ]);
    
    const installedTools = queries.getInstalledTools();
    const activeInstallations = queries.getActiveInstallations();
    
    const health = {
      system: {
        cpu: systemStats.cpu.usage,
        memory: systemStats.memory.percent,
        disk: systemStats.disk.percent,
        uptime: systemStats.uptime
      },
      services: {
        total: services.length,
        running: services.filter(s => s.status === 'running').length,
        stopped: services.filter(s => s.status === 'stopped').length
      },
      ports: {
        total: activePorts.length,
        listening: activePorts.filter(p => p.state === 'LISTEN').length
      },
      tools: {
        installed: installedTools.length,
        installing: activeInstallations.length
      },
      status: 'healthy', // Could implement actual health checks
      timestamp: new Date().toISOString()
    };
    
    // Determine overall health status
    if (systemStats.cpu.usage > 90 || systemStats.memory.percent > 90) {
      health.status = 'warning';
    }
    if (systemStats.disk.percent > 95) {
      health.status = 'critical';
    }
    
    res.json(health);
  } catch (error) {
    console.error('Health check error:', error);
    res.status(500).json({ 
      error: error.message,
      status: 'error'
    });
  }
});

// Get port history
router.get('/ports/history', async (req, res) => {
  try {
    const { limit = 100 } = req.query;
    
    const history = queries.db.prepare(`
      SELECT * FROM port_history 
      ORDER BY last_seen DESC 
      LIMIT ?
    `).all(limit);
    
    res.json({
      history,
      total: history.length
    });
  } catch (error) {
    console.error('Port history error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get resource usage trends (last hour)
router.get('/trends', async (req, res) => {
  try {
    // For now, return current stats
    // In a real implementation, we'd store historical data
    const stats = await getSystemStats();
    
    res.json({
      current: stats,
      trends: {
        cpu: [stats.cpu.usage],
        memory: [stats.memory.percent],
        disk: [stats.disk.percent]
      },
      message: 'Historical trends not yet implemented'
    });
  } catch (error) {
    console.error('Trends error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;