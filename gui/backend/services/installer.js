const { spawn } = require('child_process');
const path = require('path');
const { queries, logActivity } = require('../database/db');
const { INSTALLATION_STATUS } = require('../../shared/constants');

// Active installations
const activeInstallations = new Map();

// Start installation of tools
async function startInstallation(tools, toolSet = null, progressCallback = null) {
  // Create installation records
  const installationIds = [];
  
  for (const tool of tools) {
    const result = queries.createInstallation.run(tool.id, INSTALLATION_STATUS.PENDING);
    installationIds.push(result.lastInsertRowid);
  }
  
  // Process installations sequentially
  const mainInstallationId = installationIds[0];
  activeInstallations.set(mainInstallationId, {
    tools,
    toolSet,
    installationIds,
    cancelled: false,
    progressCallback
  });
  
  // Start installation in background
  processInstallations(mainInstallationId, tools, installationIds, progressCallback);
  
  return mainInstallationId;
}

// Process installations
async function processInstallations(mainId, tools, installationIds, progressCallback) {
  const installation = activeInstallations.get(mainId);
  
  for (let i = 0; i < tools.length; i++) {
    if (installation.cancelled) {
      break;
    }
    
    const tool = tools[i];
    const installationId = installationIds[i];
    
    // Update status to running
    queries.updateInstallation.run(
      INSTALLATION_STATUS.RUNNING,
      null,
      null,
      null,
      installationId
    );
    
    if (progressCallback) {
      progressCallback({
        installationId: mainId,
        currentTool: tool.name,
        toolProgress: (i / tools.length) * 100,
        status: 'running',
        message: `Installing ${tool.display_name}...`
      });
    }
    
    try {
      // Run the installation script
      const scriptPath = path.join(__dirname, '../../../scripts', tool.script_path);
      const success = await runInstallScript(scriptPath, tool, installationId, progressCallback, mainId);
      
      if (success) {
        // Mark tool as installed
        queries.updateToolStatus.run(1, new Date().toISOString(), tool.id);
        queries.updateInstallation.run(
          INSTALLATION_STATUS.COMPLETED,
          new Date().toISOString(),
          'Installation completed successfully',
          null,
          installationId
        );
        
        logActivity('install', `Successfully installed ${tool.display_name}`);
      } else {
        throw new Error('Installation script failed');
      }
    } catch (error) {
      console.error(`Installation error for ${tool.name}:`, error);
      
      queries.updateInstallation.run(
        INSTALLATION_STATUS.FAILED,
        new Date().toISOString(),
        null,
        error.message,
        installationId
      );
      
      logActivity('install', `Failed to install ${tool.display_name}`, { error: error.message });
      
      if (progressCallback) {
        progressCallback({
          installationId: mainId,
          currentTool: tool.name,
          status: 'error',
          error: error.message,
          message: `Failed to install ${tool.display_name}: ${error.message}`
        });
      }
    }
  }
  
  // Clean up
  activeInstallations.delete(mainId);
  
  if (progressCallback) {
    progressCallback({
      installationId: mainId,
      status: 'complete',
      message: 'Installation process completed'
    });
  }
}

// Run installation script
function runInstallScript(scriptPath, tool, installationId, progressCallback, mainId) {
  return new Promise((resolve, reject) => {
    let output = '';
    let errorOutput = '';
    
    // Use bash to run the script with automatic 'yes' responses
    const child = spawn('bash', [scriptPath], {
      env: {
        ...process.env,
        DEBIAN_FRONTEND: 'noninteractive',
        CI: 'true' // Many installers respect this
      }
    });
    
    // Automatically respond 'y' to prompts
    child.stdin.write('y\n');
    
    child.stdout.on('data', (data) => {
      const text = data.toString();
      output += text;
      
      // Send progress updates
      if (progressCallback) {
        const lines = text.split('\n').filter(line => line.trim());
        for (const line of lines) {
          progressCallback({
            installationId: mainId,
            currentTool: tool.name,
            status: 'running',
            log: line,
            message: line
          });
        }
      }
      
      // Auto-respond to common prompts
      if (text.includes('?') || text.includes('[Y/n]') || text.includes('[y/N]')) {
        child.stdin.write('y\n');
      }
    });
    
    child.stderr.on('data', (data) => {
      errorOutput += data.toString();
    });
    
    child.on('close', (code) => {
      // Update installation log
      queries.updateInstallation.run(
        code === 0 ? INSTALLATION_STATUS.COMPLETED : INSTALLATION_STATUS.FAILED,
        new Date().toISOString(),
        output,
        code !== 0 ? errorOutput : null,
        installationId
      );
      
      if (code === 0) {
        resolve(true);
      } else {
        reject(new Error(`Script exited with code ${code}: ${errorOutput}`));
      }
    });
    
    child.on('error', (error) => {
      reject(error);
    });
  });
}

// Get installation status
async function getInstallationStatus(installationId) {
  const installation = queries.getInstallation(installationId);
  if (!installation) {
    return null;
  }
  
  // Get tool info
  const tool = queries.getToolById(installation.tool_id);
  
  return {
    ...installation,
    tool
  };
}

// Cancel installation
async function cancelInstallation(installationId) {
  const installation = activeInstallations.get(installationId);
  if (!installation) {
    return false;
  }
  
  installation.cancelled = true;
  
  // Update all pending installations to cancelled
  for (const id of installation.installationIds) {
    const inst = queries.getInstallation(id);
    if (inst && inst.status === INSTALLATION_STATUS.PENDING) {
      queries.updateInstallation.run(
        INSTALLATION_STATUS.CANCELLED,
        new Date().toISOString(),
        null,
        'Cancelled by user',
        id
      );
    }
  }
  
  return true;
}

module.exports = {
  startInstallation,
  getInstallationStatus,
  cancelInstallation
};