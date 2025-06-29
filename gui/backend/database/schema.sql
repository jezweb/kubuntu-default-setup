-- Tools table
CREATE TABLE IF NOT EXISTS tools (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT,
    version TEXT,
    installed BOOLEAN DEFAULT 0,
    install_date DATETIME,
    last_update DATETIME,
    config JSON,
    dependencies JSON,
    script_path TEXT,
    icon TEXT
);

-- Installation history
CREATE TABLE IF NOT EXISTS installations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tool_id INTEGER,
    status TEXT CHECK(status IN ('pending', 'running', 'completed', 'failed', 'cancelled')),
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    log TEXT,
    error_message TEXT,
    FOREIGN KEY (tool_id) REFERENCES tools(id)
);

-- Port monitoring
CREATE TABLE IF NOT EXISTS port_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    port INTEGER NOT NULL,
    service TEXT,
    process_name TEXT,
    pid INTEGER,
    first_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT 1
);

-- Services
CREATE TABLE IF NOT EXISTS services (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    type TEXT CHECK(type IN ('docker', 'systemd', 'process', 'mcp')),
    status TEXT CHECK(status IN ('running', 'stopped', 'unknown')),
    auto_start BOOLEAN DEFAULT 0,
    config JSON,
    last_check DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tool sets
CREATE TABLE IF NOT EXISTS tool_sets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    tools JSON NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- User settings
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value JSON,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Activity log
CREATE TABLE IF NOT EXISTS activity_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    details JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_installations_tool_id ON installations(tool_id);
CREATE INDEX IF NOT EXISTS idx_installations_status ON installations(status);
CREATE INDEX IF NOT EXISTS idx_port_history_port ON port_history(port);
CREATE INDEX IF NOT EXISTS idx_port_history_active ON port_history(active);
CREATE INDEX IF NOT EXISTS idx_services_status ON services(status);
CREATE INDEX IF NOT EXISTS idx_activity_log_created_at ON activity_log(created_at);

-- Insert default tool sets
INSERT OR IGNORE INTO tool_sets (name, display_name, description, icon, tools) VALUES
('fullstack_react', 'React Full Stack', 'Everything for modern React development', 'mdi-react', 
 '["nvm", "node", "npm", "yarn", "pnpm", "vite", "tailwindcss", "docker", "postgresql", "redis"]'),
 
('python_data_science', 'Python Data Science', 'Complete Python data science environment', 'mdi-language-python',
 '["python", "pip", "pipx", "jupyter", "pandas", "numpy", "matplotlib", "docker"]'),
 
('ai_engineer', 'AI/ML Engineer', 'AI development with local LLMs', 'mdi-robot',
 '["python", "pip", "ollama", "claude-code", "mcp-servers", "docker", "cuda-toolkit"]'),
 
('devops_pro', 'DevOps Professional', 'Infrastructure and deployment tools', 'mdi-infinity',
 '["docker", "docker-compose", "kubernetes", "terraform", "aws-cli", "gcloud", "github-cli"]'),
 
('frontend_developer', 'Frontend Developer', 'Modern frontend development tools', 'mdi-palette',
 '["nvm", "node", "npm", "yarn", "vite", "webpack", "tailwindcss", "vuetify", "mui"]'),
 
('backend_developer', 'Backend Developer', 'Server-side development essentials', 'mdi-server',
 '["nvm", "node", "python", "go", "docker", "postgresql", "redis", "mongodb", "nginx"]');

-- Insert default settings
INSERT OR IGNORE INTO settings (key, value) VALUES
('theme', '{"mode": "light", "primary": "#1976D2"}'),
('auto_update', 'true'),
('install_parallel', 'false'),
('max_parallel_installs', '3'),
('log_retention_days', '30'),
('port_scan_interval', '300'),
('notification_preferences', '{"install": true, "errors": true, "updates": false}');