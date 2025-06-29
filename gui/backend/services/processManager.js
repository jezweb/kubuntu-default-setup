const { exec, spawn } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);
const { queries, logActivity } = require('../database/db');
const { SERVICE_TYPES, SERVICE_STATUS } = require('../../shared/constants');

// Get running services
async function getRunningServices() {
  const services = [];
  
  try {
    // Check Docker containers
    const dockerServices = await getDockerServices();
    services.push(...dockerServices);
    
    // Check systemd services (common ones)
    const systemdServices = await getSystemdServices();
    services.push(...systemdServices);
    
    // Check common processes
    const processServices = await getProcessServices();
    services.push(...processServices);
    
    // Update database
    for (const service of services) {
      queries.upsertService.run(
        service.name,
        service.displayName,
        service.type,
        service.status
      );
    }
    
    return services;
  } catch (error) {
    console.error('Get running services error:', error);
    return services; // Return what we have
  }
}

// Get Docker services
async function getDockerServices() {
  const services = [];
  
  try {
    const { stdout } = await execAsync('docker ps --format "{{.ID}}|{{.Names}}|{{.Status}}|{{.Ports}}"');
    const lines = stdout.trim().split('\n').filter(line => line);
    
    for (const line of lines) {
      const [id, name, status, ports] = line.split('|');
      services.push({
        name: `docker-${name}`,
        displayName: `Docker: ${name}`,
        type: SERVICE_TYPES.DOCKER,
        status: status.includes('Up') ? SERVICE_STATUS.RUNNING : SERVICE_STATUS.STOPPED,
        containerId: id,
        ports: ports
      });
    }
  } catch (error) {
    // Docker might not be installed or running
    console.log('Docker not available');
  }
  
  return services;
}

// Get systemd services
async function getSystemdServices() {
  const services = [];
  const checkServices = [
    { name: 'nginx', display: 'Nginx Web Server' },
    { name: 'apache2', display: 'Apache Web Server' },
    { name: 'mysql', display: 'MySQL Database' },
    { name: 'postgresql', display: 'PostgreSQL Database' },
    { name: 'mongodb', display: 'MongoDB Database' },
    { name: 'redis', display: 'Redis Server' },
    { name: 'docker', display: 'Docker Engine' },
    { name: 'ssh', display: 'SSH Server' }
  ];
  
  for (const service of checkServices) {
    try {
      const { stdout } = await execAsync(`systemctl is-active ${service.name}`);
      const isActive = stdout.trim() === 'active';
      
      services.push({
        name: `systemd-${service.name}`,
        displayName: service.display,
        type: SERVICE_TYPES.SYSTEMD,
        status: isActive ? SERVICE_STATUS.RUNNING : SERVICE_STATUS.STOPPED,
        serviceName: service.name
      });
    } catch (error) {
      // Service might not exist
    }
  }
  
  return services;
}

// Get process-based services
async function getProcessServices() {
  const services = [];
  const checkProcesses = [
    { cmd: 'node', name: 'Node.js Apps', pattern: 'node' },
    { cmd: 'python', name: 'Python Apps', pattern: 'python' },
    { cmd: 'jupyter', name: 'Jupyter Notebook', pattern: 'jupyter' },
    { cmd: 'ollama', name: 'Ollama', pattern: 'ollama serve' },
    { cmd: 'code', name: 'VS Code Server', pattern: 'code.*server' }
  ];
  
  for (const process of checkProcesses) {
    try {
      const { stdout } = await execAsync(`pgrep -f "${process.pattern}" | head -1`);
      const pid = stdout.trim();
      
      if (pid) {
        services.push({
          name: `process-${process.cmd}`,
          displayName: process.name,
          type: SERVICE_TYPES.PROCESS,
          status: SERVICE_STATUS.RUNNING,
          pid: parseInt(pid)
        });
      }
    } catch (error) {
      // Process not found
    }
  }
  
  return services;
}

// Perform action on a service
async function performServiceAction(serviceName, action) {
  const service = queries.db.prepare('SELECT * FROM services WHERE name = ?').get(serviceName);
  
  if (!service) {
    throw new Error('Service not found');
  }
  
  logActivity('service', `Performing ${action} on ${service.display_name}`);
  
  switch (service.type) {
    case SERVICE_TYPES.DOCKER:
      return performDockerAction(service, action);
    case SERVICE_TYPES.SYSTEMD:
      return performSystemdAction(service, action);
    case SERVICE_TYPES.PROCESS:
      return performProcessAction(service, action);
    default:
      throw new Error(`Unknown service type: ${service.type}`);
  }
}

// Docker actions
async function performDockerAction(service, action) {
  const containerName = service.name.replace('docker-', '');
  let command;
  
  switch (action) {
    case 'start':
      command = `docker start ${containerName}`;
      break;
    case 'stop':
      command = `docker stop ${containerName}`;
      break;
    case 'restart':
      command = `docker restart ${containerName}`;
      break;
    case 'logs':
      command = `docker logs --tail 100 ${containerName}`;
      break;
    default:
      throw new Error(`Unknown action: ${action}`);
  }
  
  const { stdout, stderr } = await execAsync(command);
  
  return {
    success: true,
    output: stdout || stderr,
    status: action === 'stop' ? SERVICE_STATUS.STOPPED : SERVICE_STATUS.RUNNING
  };
}

// Systemd actions
async function performSystemdAction(service, action) {
  const serviceName = service.name.replace('systemd-', '');
  let command;
  
  switch (action) {
    case 'start':
      command = `sudo systemctl start ${serviceName}`;
      break;
    case 'stop':
      command = `sudo systemctl stop ${serviceName}`;
      break;
    case 'restart':
      command = `sudo systemctl restart ${serviceName}`;
      break;
    case 'status':
      command = `systemctl status ${serviceName}`;
      break;
    default:
      throw new Error(`Unknown action: ${action}`);
  }
  
  const { stdout, stderr } = await execAsync(command);
  
  return {
    success: true,
    output: stdout || stderr,
    status: action === 'stop' ? SERVICE_STATUS.STOPPED : SERVICE_STATUS.RUNNING
  };
}

// Process actions
async function performProcessAction(service, action) {
  switch (action) {
    case 'stop':
      if (service.pid) {
        await execAsync(`kill ${service.pid}`);
        return {
          success: true,
          output: `Process ${service.pid} terminated`,
          status: SERVICE_STATUS.STOPPED
        };
      }
      throw new Error('No PID available for process');
    default:
      throw new Error(`Cannot perform ${action} on process services`);
  }
}

// Check if a service is running
async function isServiceRunning(serviceName) {
  const services = await getRunningServices();
  const service = services.find(s => s.name === serviceName);
  return service && service.status === SERVICE_STATUS.RUNNING;
}

module.exports = {
  getRunningServices,
  performServiceAction,
  isServiceRunning
};