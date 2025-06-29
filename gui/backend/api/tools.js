const express = require('express');
const router = express.Router();
const { queries, logActivity } = require('../database/db');

// Get all tools
router.get('/', async (req, res) => {
  try {
    const tools = queries.getAllTools();
    
    // Group by category
    const toolsByCategory = tools.reduce((acc, tool) => {
      if (!acc[tool.category]) {
        acc[tool.category] = [];
      }
      acc[tool.category].push(tool);
      return acc;
    }, {});
    
    res.json({
      tools,
      categories: toolsByCategory,
      total: tools.length
    });
  } catch (error) {
    console.error('Get tools error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get installed tools
router.get('/installed', async (req, res) => {
  try {
    const tools = queries.getInstalledTools();
    
    res.json({
      tools,
      total: tools.length
    });
  } catch (error) {
    console.error('Get installed tools error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get tool sets
router.get('/sets', async (req, res) => {
  try {
    const toolSets = queries.getToolSets();
    
    // For each tool set, check how many tools are installed
    const setsWithStatus = toolSets.map(set => {
      const tools = JSON.parse(set.tools);
      let installedCount = 0;
      
      for (const toolName of tools) {
        const tool = queries.getToolByName(toolName);
        if (tool && tool.installed) {
          installedCount++;
        }
      }
      
      return {
        ...set,
        tools: tools,
        totalTools: tools.length,
        installedTools: installedCount,
        progress: Math.round((installedCount / tools.length) * 100)
      };
    });
    
    res.json({
      toolSets: setsWithStatus
    });
  } catch (error) {
    console.error('Get tool sets error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get specific tool details
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const tool = queries.getToolById(id);
    
    if (!tool) {
      return res.status(404).json({ error: 'Tool not found' });
    }
    
    // Get installation history for this tool
    const installations = queries.db.prepare(
      'SELECT * FROM installations WHERE tool_id = ? ORDER BY started_at DESC LIMIT 10'
    ).all(id);
    
    res.json({
      tool,
      installations
    });
  } catch (error) {
    console.error('Get tool details error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update tool (mark as installed/uninstalled)
router.put('/:id/update', async (req, res) => {
  try {
    const { id } = req.params;
    const { installed } = req.body;
    
    const tool = queries.getToolById(id);
    if (!tool) {
      return res.status(404).json({ error: 'Tool not found' });
    }
    
    queries.updateToolStatus.run(
      installed ? 1 : 0,
      installed ? new Date().toISOString() : null,
      id
    );
    
    logActivity('tool', `Tool ${installed ? 'marked as installed' : 'marked as uninstalled'}: ${tool.display_name}`);
    
    res.json({
      success: true,
      tool: queries.getToolById(id)
    });
  } catch (error) {
    console.error('Update tool error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Search tools
router.get('/search/:query', async (req, res) => {
  try {
    const { query } = req.params;
    const searchQuery = `%${query}%`;
    
    const tools = queries.db.prepare(`
      SELECT * FROM tools 
      WHERE name LIKE ? OR display_name LIKE ? OR description LIKE ?
      ORDER BY 
        CASE 
          WHEN name = ? THEN 0
          WHEN name LIKE ? THEN 1
          WHEN display_name = ? THEN 2
          WHEN display_name LIKE ? THEN 3
          ELSE 4
        END,
        display_name
    `).all(searchQuery, searchQuery, searchQuery, query, `${query}%`, query, `${query}%`);
    
    res.json({
      tools,
      query,
      total: tools.length
    });
  } catch (error) {
    console.error('Search tools error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get tool dependencies
router.get('/:id/dependencies', async (req, res) => {
  try {
    const { id } = req.params;
    const tool = queries.getToolById(id);
    
    if (!tool) {
      return res.status(404).json({ error: 'Tool not found' });
    }
    
    // Parse dependencies if they exist
    const dependencies = tool.dependencies ? JSON.parse(tool.dependencies) : [];
    const dependencyTools = [];
    
    for (const depName of dependencies) {
      const depTool = queries.getToolByName(depName);
      if (depTool) {
        dependencyTools.push(depTool);
      }
    }
    
    res.json({
      tool,
      dependencies: dependencyTools
    });
  } catch (error) {
    console.error('Get dependencies error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;