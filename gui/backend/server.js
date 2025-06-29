const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const path = require('path');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const { initDatabase } = require('./database/db');
const installationAPI = require('./api/installation');
const monitoringAPI = require('./api/monitoring');
const toolsAPI = require('./api/tools');
const portsAPI = require('./api/ports');
const { setupWebSocketHandlers } = require('./websocket/handlers');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.NODE_ENV === 'production' 
      ? false 
      : ['http://localhost:5173', 'http://localhost:3000'],
    credentials: true
  }
});

const PORT = process.env.PORT || 7842;
const HOST = process.env.HOST || '0.0.0.0';

// Security middleware
app.use(helmet({
  contentSecurityPolicy: false, // We'll configure this for the GUI
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api', limiter);

// General middleware
app.use(compression());
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? false 
    : ['http://localhost:5173', 'http://localhost:3000'],
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined'));

// Static files in production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../frontend/dist')));
}

// API Routes
app.use('/api/install', installationAPI);
app.use('/api/monitor', monitoringAPI);
app.use('/api/tools', toolsAPI);
app.use('/api/ports', portsAPI);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    port: PORT,
    environment: process.env.NODE_ENV || 'development'
  });
});

// WebSocket setup
setupWebSocketHandlers(io);

// Serve frontend in production
if (process.env.NODE_ENV === 'production') {
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/dist/index.html'));
  });
}

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Initialize database and start server
async function startServer() {
  try {
    await initDatabase();
    console.log('Database initialized successfully');
    
    server.listen(PORT, HOST, () => {
      console.log(`
========================================
  Kubuntu Setup GUI Server
  
  Running on: http://${HOST === '0.0.0.0' ? 'localhost' : HOST}:${PORT}
  Environment: ${process.env.NODE_ENV || 'development'}
  
  API Endpoints:
  - Health: http://localhost:${PORT}/api/health
  - Tools: http://localhost:${PORT}/api/tools
  - Install: http://localhost:${PORT}/api/install
  - Monitor: http://localhost:${PORT}/api/monitor
  - Ports: http://localhost:${PORT}/api/ports
========================================
      `);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

// Start the server
startServer();