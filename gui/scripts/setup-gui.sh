#!/bin/bash

# Kubuntu Setup GUI Installation Script
# This script sets up and starts the web-based GUI installer

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$GUI_DIR/backend"
FRONTEND_DIR="$GUI_DIR/frontend"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Node.js is installed
check_node() {
    if ! command -v node >/dev/null 2>&1; then
        log_error "Node.js is not installed. Please run the Node.js setup script first."
        exit 1
    fi
    log_success "Node.js is installed ($(node --version))"
}

# Check if npm is installed
check_npm() {
    if ! command -v npm >/dev/null 2>&1; then
        log_error "npm is not installed. Please run the Node.js setup script first."
        exit 1
    fi
    log_success "npm is installed ($(npm --version))"
}

# Install dependencies
install_dependencies() {
    log_info "Installing GUI dependencies..."
    
    cd "$GUI_DIR"
    
    # Install root dependencies
    if [[ -f package.json ]]; then
        log_info "Installing root dependencies..."
        npm install
    fi
    
    # Install backend dependencies
    if [[ -d "$BACKEND_DIR" && -f "$BACKEND_DIR/package.json" ]]; then
        log_info "Installing backend dependencies..."
        cd "$BACKEND_DIR"
        npm install
    else
        log_error "Backend directory not found!"
        exit 1
    fi
    
    # Check if frontend exists
    if [[ ! -d "$FRONTEND_DIR" || ! -f "$FRONTEND_DIR/package.json" ]]; then
        log_warning "Frontend not yet created. Run this script again after frontend setup."
    else
        log_info "Installing frontend dependencies..."
        cd "$FRONTEND_DIR"
        npm install
    fi
    
    log_success "Dependencies installed successfully!"
}

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."
    
    mkdir -p "$GUI_DIR/data"
    mkdir -p "$GUI_DIR/logs"
    
    log_success "Directories created!"
}

# Start the GUI server
start_server() {
    cd "$BACKEND_DIR"
    
    log_info "Starting Kubuntu Setup GUI server..."
    log_info "Server will be available at: http://localhost:7842"
    log_info "Press Ctrl+C to stop the server"
    
    # Start the server
    npm start
}

# Start development mode
start_dev() {
    cd "$GUI_DIR"
    
    log_info "Starting Kubuntu Setup GUI in development mode..."
    log_info "Backend will run on: http://localhost:7842"
    log_info "Frontend will run on: http://localhost:5173"
    log_info "Press Ctrl+C to stop the servers"
    
    # Start both backend and frontend in dev mode
    npm run dev
}

# Build frontend for production
build_frontend() {
    if [[ ! -d "$FRONTEND_DIR" || ! -f "$FRONTEND_DIR/package.json" ]]; then
        log_error "Frontend not yet created. Please set up the frontend first."
        exit 1
    fi
    
    cd "$GUI_DIR"
    log_info "Building frontend for production..."
    npm run build
    log_success "Frontend built successfully!"
}

# Show usage
show_usage() {
    echo "Kubuntu Setup GUI - Setup Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install    - Install dependencies"
    echo "  start      - Start the GUI server (production mode)"
    echo "  dev        - Start in development mode"
    echo "  build      - Build frontend for production"
    echo "  setup      - Full setup (install + start)"
    echo "  help       - Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 setup    # Run full setup and start server"
}

# Main script
main() {
    local command="${1:-help}"
    
    case "$command" in
        install)
            check_node
            check_npm
            create_directories
            install_dependencies
            ;;
        start)
            check_node
            start_server
            ;;
        dev)
            check_node
            start_dev
            ;;
        build)
            check_node
            build_frontend
            ;;
        setup)
            check_node
            check_npm
            create_directories
            install_dependencies
            start_server
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"