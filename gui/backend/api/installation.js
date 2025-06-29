const express = require('express');
const router = express.Router();
const { queries, logActivity } = require('../database/db');
const { startInstallation, getInstallationStatus, cancelInstallation } = require('../services/installer');
const { INSTALLATION_STATUS } = require('../../shared/constants');

// Install a single tool or multiple tools
router.post('/tool', async (req, res) => {
  try {
    const { toolId, toolIds } = req.body;
    const tools = toolIds || [toolId];
    
    if (!tools || tools.length === 0) {
      return res.status(400).json({ error: 'No tools specified' });
    }
    
    // Verify all tools exist
    const toolsToInstall = [];
    for (const id of tools) {
      const tool = queries.getToolById(id);
      if (!tool) {
        return res.status(404).json({ error: `Tool not found: ${id}` });
      }
      if (tool.installed) {
        return res.status(400).json({ error: `Tool already installed: ${tool.display_name}` });
      }
      toolsToInstall.push(tool);
    }
    
    // Start installation
    const installationId = await startInstallation(toolsToInstall);
    
    logActivity('install', `Started installation of ${toolsToInstall.length} tool(s)`, {
      tools: toolsToInstall.map(t => t.name)
    });
    
    res.json({
      success: true,
      installationId,
      tools: toolsToInstall
    });
  } catch (error) {
    console.error('Installation error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Install a tool set
router.post('/toolset', async (req, res) => {
  try {
    const { toolSetId } = req.body;
    
    if (!toolSetId) {
      return res.status(400).json({ error: 'No tool set specified' });
    }
    
    const toolSet = queries.getToolSet(toolSetId);
    if (!toolSet) {
      return res.status(404).json({ error: 'Tool set not found' });
    }
    
    const toolNames = JSON.parse(toolSet.tools);
    const toolsToInstall = [];
    
    // Get tool objects for each tool in the set
    for (const name of toolNames) {
      const tool = queries.getToolByName(name);
      if (tool && !tool.installed) {
        toolsToInstall.push(tool);
      }
    }
    
    if (toolsToInstall.length === 0) {
      return res.status(400).json({ 
        error: 'All tools in this set are already installed' 
      });
    }
    
    // Start installation
    const installationId = await startInstallation(toolsToInstall, toolSet);
    
    logActivity('install', `Started installation of tool set: ${toolSet.display_name}`, {
      toolSet: toolSet.name,
      tools: toolsToInstall.map(t => t.name)
    });
    
    res.json({
      success: true,
      installationId,
      toolSet,
      tools: toolsToInstall
    });
  } catch (error) {
    console.error('Tool set installation error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get installation progress
router.get('/progress/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const status = await getInstallationStatus(id);
    
    if (!status) {
      return res.status(404).json({ error: 'Installation not found' });
    }
    
    res.json(status);
  } catch (error) {
    console.error('Progress check error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Cancel an installation
router.delete('/cancel/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await cancelInstallation(id);
    
    if (!result) {
      return res.status(404).json({ error: 'Installation not found or already completed' });
    }
    
    logActivity('install', `Cancelled installation ${id}`);
    
    res.json({
      success: true,
      message: 'Installation cancelled'
    });
  } catch (error) {
    console.error('Cancel error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get all active installations
router.get('/active', async (req, res) => {
  try {
    const activeInstallations = queries.getActiveInstallations();
    
    res.json({
      installations: activeInstallations
    });
  } catch (error) {
    console.error('Active installations error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;