#!/bin/bash

# Databases Setup Script
# This script installs various database clients and tools

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting databases setup..."

# PostgreSQL client
install_postgresql_client() {
    if command_exists psql; then
        log_success "PostgreSQL client is already installed"
    else
        if confirm "Would you like to install PostgreSQL client?" "y"; then
            log_info "Installing PostgreSQL client..."
            sudo apt update
            sudo apt install -y postgresql-client
            log_success "PostgreSQL client installed"
        fi
    fi
}

# MySQL client
install_mysql_client() {
    if command_exists mysql; then
        log_success "MySQL client is already installed"
    else
        if confirm "Would you like to install MySQL client?" "y"; then
            log_info "Installing MySQL client..."
            sudo apt update
            sudo apt install -y mysql-client
            log_success "MySQL client installed"
        fi
    fi
}

# MongoDB tools
install_mongodb_tools() {
    if command_exists mongosh; then
        log_success "MongoDB Shell is already installed"
    else
        if confirm "Would you like to install MongoDB Shell (mongosh)?" "y"; then
            log_info "Installing MongoDB Shell..."
            
            # Import MongoDB public GPG key
            curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
                sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
            
            # Create list file
            echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
                sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
            
            # Update and install
            sudo apt update
            sudo apt install -y mongodb-mongosh
            
            if command_exists mongosh; then
                log_success "MongoDB Shell installed"
            fi
        fi
    fi
}

# Redis client
install_redis_client() {
    if command_exists redis-cli; then
        log_success "Redis client is already installed"
    else
        if confirm "Would you like to install Redis client?" "y"; then
            log_info "Installing Redis client..."
            sudo apt update
            sudo apt install -y redis-tools
            log_success "Redis client installed"
        fi
    fi
}

# SQLite
install_sqlite() {
    if command_exists sqlite3; then
        log_success "SQLite is already installed"
    else
        if confirm "Would you like to install SQLite?" "y"; then
            log_info "Installing SQLite..."
            sudo apt update
            sudo apt install -y sqlite3
            log_success "SQLite installed"
        fi
    fi
}

# Database GUI tools
install_db_gui_tools() {
    # DBeaver
    if command_exists dbeaver; then
        log_success "DBeaver is already installed"
    else
        if confirm "Would you like to install DBeaver (universal database tool)?" "y"; then
            log_info "Installing DBeaver..."
            
            # Add repository
            wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
            echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
            
            # Install
            sudo apt update
            sudo apt install -y dbeaver-ce
            
            if command_exists dbeaver; then
                log_success "DBeaver installed"
            fi
        fi
    fi
    
    # Beekeeper Studio
    if ! command_exists beekeeper-studio; then
        if confirm "Would you like to install Beekeeper Studio (modern SQL editor)?" "n"; then
            log_info "Installing Beekeeper Studio..."
            
            # Download and install
            wget --quiet -O - https://beekeeper-studio.io/beekeeper-studio-gpg.key | sudo apt-key add -
            echo "deb https://deb.beekeeperstudio.io stable main" | sudo tee /etc/apt/sources.list.d/beekeeper-studio-app.list
            sudo apt update
            sudo apt install -y beekeeper-studio
            
            log_success "Beekeeper Studio installed"
        fi
    fi
}

# Database migration tools
install_migration_tools() {
    # migrate CLI
    if ! command_exists migrate; then
        if confirm "Would you like to install migrate (database migration tool)?" "y"; then
            log_info "Installing migrate..."
            
            # Install via curl
            curl -L https://github.com/golang-migrate/migrate/releases/latest/download/migrate.linux-amd64.tar.gz | tar xvz
            sudo mv migrate /usr/local/bin/
            
            if command_exists migrate; then
                log_success "migrate installed"
            fi
        fi
    fi
}

# Docker-based databases setup script
create_docker_db_scripts() {
    if command_exists docker && confirm "Would you like to create Docker database setup scripts?" "y"; then
        DB_SCRIPTS_DIR="$HOME/docker-databases"
        ensure_dir "$DB_SCRIPTS_DIR"
        
        # PostgreSQL script
        cat > "$DB_SCRIPTS_DIR/postgres.sh" << 'EOF'
#!/bin/bash
# Start PostgreSQL with Docker

CONTAINER_NAME="postgres-dev"
PASSWORD="${POSTGRES_PASSWORD:-postgres}"
PORT="${POSTGRES_PORT:-5432}"

docker run -d \
    --name $CONTAINER_NAME \
    -e POSTGRES_PASSWORD=$PASSWORD \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_DB=postgres \
    -p $PORT:5432 \
    -v postgres_data:/var/lib/postgresql/data \
    postgres:latest

echo "PostgreSQL started on port $PORT"
echo "Connection string: postgresql://postgres:$PASSWORD@localhost:$PORT/postgres"
EOF
        
        # MySQL script
        cat > "$DB_SCRIPTS_DIR/mysql.sh" << 'EOF'
#!/bin/bash
# Start MySQL with Docker

CONTAINER_NAME="mysql-dev"
PASSWORD="${MYSQL_PASSWORD:-mysql}"
PORT="${MYSQL_PORT:-3306}"

docker run -d \
    --name $CONTAINER_NAME \
    -e MYSQL_ROOT_PASSWORD=$PASSWORD \
    -e MYSQL_DATABASE=mydb \
    -p $PORT:3306 \
    -v mysql_data:/var/lib/mysql \
    mysql:latest

echo "MySQL started on port $PORT"
echo "Connection string: mysql://root:$PASSWORD@localhost:$PORT/mydb"
EOF
        
        # MongoDB script
        cat > "$DB_SCRIPTS_DIR/mongodb.sh" << 'EOF'
#!/bin/bash
# Start MongoDB with Docker

CONTAINER_NAME="mongodb-dev"
PORT="${MONGO_PORT:-27017}"

docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:27017 \
    -v mongodb_data:/data/db \
    mongo:latest

echo "MongoDB started on port $PORT"
echo "Connection string: mongodb://localhost:$PORT"
EOF
        
        # Redis script
        cat > "$DB_SCRIPTS_DIR/redis.sh" << 'EOF'
#!/bin/bash
# Start Redis with Docker

CONTAINER_NAME="redis-dev"
PORT="${REDIS_PORT:-6379}"

docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:6379 \
    -v redis_data:/data \
    redis:latest redis-server --appendonly yes

echo "Redis started on port $PORT"
echo "Connection string: redis://localhost:$PORT"
EOF
        
        # Make scripts executable
        chmod +x "$DB_SCRIPTS_DIR"/*.sh
        
        log_success "Docker database scripts created in $DB_SCRIPTS_DIR"
        log_info "Use these scripts to quickly start database containers"
    fi
}

# Main installation
install_postgresql_client
install_mysql_client
install_mongodb_tools
install_redis_client
install_sqlite
install_db_gui_tools
install_migration_tools
create_docker_db_scripts

log_success "Databases setup completed!"