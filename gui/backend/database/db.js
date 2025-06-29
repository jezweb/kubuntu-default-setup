const Database = require('better-sqlite3');
const path = require('path');
const fs = require('fs');

// Database file location
const DB_PATH = path.join(__dirname, '../../data/kubuntu-setup.db');
const SCHEMA_PATH = path.join(__dirname, 'schema.sql');

// Ensure data directory exists
const dataDir = path.dirname(DB_PATH);
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
}

// Create database connection
const db = new Database(DB_PATH, {
  verbose: process.env.NODE_ENV === 'development' ? console.log : null
});

// Enable foreign keys
db.pragma('foreign_keys = ON');

// Initialize database with schema
async function initDatabase() {
  try {
    const schema = fs.readFileSync(SCHEMA_PATH, 'utf8');
    db.exec(schema);
    console.log('Database schema initialized');
    
    // Load tools from existing scripts
    await loadToolsFromScripts();
    
    return true;
  } catch (error) {
    console.error('Database initialization error:', error);
    throw error;
  }
}

// Load tool definitions from existing scripts
async function loadToolsFromScripts() {
  const scriptsDir = path.join(__dirname, '../../../scripts');
  const categories = [
    { dir: 'system', name: 'System & Build Tools' },
    { dir: 'nodejs', name: 'Node.js & JavaScript' },
    { dir: 'python', name: 'Python Tools' },
    { dir: 'dev-tools', name: 'Development Tools' },
    { dir: 'databases', name: 'Databases' },
    { dir: 'cloud-services', name: 'Cloud Services' },
    { dir: 'ai-tools', name: 'AI/ML Tools' }
  ];
  
  const insertTool = db.prepare(`
    INSERT OR IGNORE INTO tools 
    (name, display_name, category, description, script_path, icon)
    VALUES (?, ?, ?, ?, ?, ?)
  `);
  
  // Tool definitions based on existing scripts
  const tools = [
    // System tools
    { name: 'apt-packages', display: 'Essential APT Packages', category: 'System & Build Tools', 
      desc: 'Core system packages and build tools', script: 'system/01-apt-packages.sh', icon: 'mdi-package' },
    { name: 'homebrew', display: 'Homebrew', category: 'System & Build Tools',
      desc: 'Package manager for Linux', script: 'system/02-homebrew.sh', icon: 'mdi-beer' },
    
    // Node.js
    { name: 'nvm', display: 'NVM & Node.js', category: 'Node.js & JavaScript',
      desc: 'Node Version Manager and Node.js', script: 'nodejs/01-nvm-node.sh', icon: 'mdi-nodejs' },
    { name: 'yarn', display: 'Yarn', category: 'Node.js & JavaScript',
      desc: 'Fast, reliable JavaScript package manager', script: 'nodejs/02-package-managers.sh', icon: 'mdi-package-variant' },
    { name: 'pnpm', display: 'pnpm', category: 'Node.js & JavaScript',
      desc: 'Fast, disk space efficient package manager', script: 'nodejs/02-package-managers.sh', icon: 'mdi-package-variant-closed' },
    { name: 'claude-code', display: 'Claude Code', category: 'AI/ML Tools',
      desc: "Anthropic's official CLI for Claude", script: 'nodejs/03-global-tools.sh', icon: 'mdi-robot' },
    { name: 'vite', display: 'Vite', category: 'Node.js & JavaScript',
      desc: 'Next generation frontend tooling', script: 'nodejs/03-global-tools.sh', icon: 'mdi-lightning-bolt' },
    { name: 'tailwindcss', display: 'Tailwind CSS', category: 'Node.js & JavaScript',
      desc: 'Utility-first CSS framework', script: 'nodejs/04-frontend-frameworks.sh', icon: 'mdi-tailwind' },
    { name: 'vuetify', display: 'Vuetify', category: 'Node.js & JavaScript',
      desc: 'Material Design component framework for Vue.js', script: 'nodejs/04-frontend-frameworks.sh', icon: 'mdi-vuetify' },
    { name: 'mui', display: 'Material-UI', category: 'Node.js & JavaScript',
      desc: 'React components for Material Design', script: 'nodejs/04-frontend-frameworks.sh', icon: 'mdi-material-ui' },
    
    // Python
    { name: 'python', display: 'Python & pip', category: 'Python Tools',
      desc: 'Python runtime and package manager', script: 'python/01-python-pip.sh', icon: 'mdi-language-python' },
    { name: 'pipx', display: 'pipx', category: 'Python Tools',
      desc: 'Install Python apps in isolated environments', script: 'python/02-pipx-tools.sh', icon: 'mdi-package-variant-closed' },
    { name: 'jupyter', display: 'Jupyter', category: 'Python Tools',
      desc: 'Interactive computing notebooks', script: 'python/03-data-science.sh', icon: 'mdi-notebook' },
    
    // Dev tools
    { name: 'vscode', display: 'VS Code', category: 'Development Tools',
      desc: 'Visual Studio Code editor', script: 'dev-tools/01-vscode.sh', icon: 'mdi-microsoft-visual-studio-code' },
    { name: 'git', display: 'Git', category: 'Development Tools',
      desc: 'Version control system', script: 'dev-tools/02-git.sh', icon: 'mdi-git' },
    { name: 'github-cli', display: 'GitHub CLI', category: 'Development Tools',
      desc: 'GitHub command line tool', script: 'dev-tools/03-github-cli.sh', icon: 'mdi-github' },
    
    // Databases
    { name: 'docker', display: 'Docker', category: 'Cloud Services',
      desc: 'Container platform', script: 'cloud-services/01-docker.sh', icon: 'mdi-docker' },
    { name: 'postgresql', display: 'PostgreSQL', category: 'Databases',
      desc: 'PostgreSQL database in Docker', script: 'databases/01-postgresql.sh', icon: 'mdi-database' },
    { name: 'mysql', display: 'MySQL', category: 'Databases',
      desc: 'MySQL database in Docker', script: 'databases/02-mysql.sh', icon: 'mdi-database' },
    { name: 'mongodb', display: 'MongoDB', category: 'Databases',
      desc: 'MongoDB NoSQL database in Docker', script: 'databases/03-mongodb.sh', icon: 'mdi-leaf' },
    { name: 'redis', display: 'Redis', category: 'Databases',
      desc: 'Redis in-memory data store', script: 'databases/04-redis.sh', icon: 'mdi-database-outline' },
    
    // Cloud services
    { name: 'aws-cli', display: 'AWS CLI', category: 'Cloud Services',
      desc: 'Amazon Web Services CLI', script: 'cloud-services/02-aws-cli.sh', icon: 'mdi-aws' },
    { name: 'gcloud', display: 'Google Cloud SDK', category: 'Cloud Services',
      desc: 'Google Cloud Platform tools', script: 'cloud-services/03-gcloud.sh', icon: 'mdi-google-cloud' },
    { name: 'azure-cli', display: 'Azure CLI', category: 'Cloud Services',
      desc: 'Microsoft Azure command line', script: 'cloud-services/04-azure-cli.sh', icon: 'mdi-microsoft-azure' },
    
    // AI tools
    { name: 'ollama', display: 'Ollama', category: 'AI/ML Tools',
      desc: 'Run large language models locally', script: 'ai-tools/01-ollama.sh', icon: 'mdi-robot' },
    { name: 'mcp-servers', display: 'MCP Servers', category: 'AI/ML Tools',
      desc: 'Model Context Protocol servers', script: 'ai-tools/02-mcp-servers.sh', icon: 'mdi-server' }
  ];
  
  const insertMany = db.transaction((tools) => {
    for (const tool of tools) {
      insertTool.run(
        tool.name,
        tool.display,
        tool.category,
        tool.desc,
        tool.script,
        tool.icon
      );
    }
  });
  
  insertMany(tools);
  console.log(`Loaded ${tools.length} tool definitions`);
}

// Helper functions for common queries
const queries = {
  // Tools
  getAllTools: () => db.prepare('SELECT * FROM tools ORDER BY category, display_name').all(),
  getToolById: (id) => db.prepare('SELECT * FROM tools WHERE id = ?').get(id),
  getToolByName: (name) => db.prepare('SELECT * FROM tools WHERE name = ?').get(name),
  getInstalledTools: () => db.prepare('SELECT * FROM tools WHERE installed = 1').all(),
  updateToolStatus: db.prepare('UPDATE tools SET installed = ?, install_date = ? WHERE id = ?'),
  
  // Installations
  createInstallation: db.prepare('INSERT INTO installations (tool_id, status) VALUES (?, ?)'),
  updateInstallation: db.prepare('UPDATE installations SET status = ?, completed_at = ?, log = ?, error_message = ? WHERE id = ?'),
  getInstallation: (id) => db.prepare('SELECT * FROM installations WHERE id = ?').get(id),
  getActiveInstallations: () => db.prepare('SELECT * FROM installations WHERE status IN ("pending", "running")').all(),
  
  // Port history
  recordPort: db.prepare('INSERT OR REPLACE INTO port_history (port, service, process_name, pid, last_seen, active) VALUES (?, ?, ?, ?, datetime("now"), 1)'),
  getActivePorts: () => db.prepare('SELECT * FROM port_history WHERE active = 1').all(),
  deactivateOldPorts: db.prepare('UPDATE port_history SET active = 0 WHERE last_seen < datetime("now", "-5 minutes")'),
  
  // Services
  upsertService: db.prepare('INSERT OR REPLACE INTO services (name, display_name, type, status, last_check) VALUES (?, ?, ?, ?, datetime("now"))'),
  getServices: () => db.prepare('SELECT * FROM services ORDER BY display_name').all(),
  getRunningServices: () => db.prepare('SELECT * FROM services WHERE status = "running"').all(),
  
  // Settings
  getSetting: (key) => db.prepare('SELECT value FROM settings WHERE key = ?').get(key),
  setSetting: db.prepare('INSERT OR REPLACE INTO settings (key, value, updated_at) VALUES (?, ?, datetime("now"))'),
  
  // Activity log
  logActivity: db.prepare('INSERT INTO activity_log (type, message, details) VALUES (?, ?, ?)'),
  getRecentActivity: (limit = 50) => db.prepare('SELECT * FROM activity_log ORDER BY created_at DESC LIMIT ?').all(limit),
  
  // Tool sets
  getToolSets: () => db.prepare('SELECT * FROM tool_sets ORDER BY display_name').all(),
  getToolSet: (name) => db.prepare('SELECT * FROM tool_sets WHERE name = ?').get(name)
};

// Activity logging helper
function logActivity(type, message, details = null) {
  queries.logActivity.run(type, message, JSON.stringify(details));
}

module.exports = {
  db,
  initDatabase,
  queries,
  logActivity
};