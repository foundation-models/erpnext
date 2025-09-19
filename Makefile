# ERPNext Installation Makefile
# This Makefile installs ERPNext using Docker with fresh MariaDB and Redis

.PHONY: help install install-auto install-prod dev-mode dev-switch fix-static run-with-static setup-dev-domain build-assets check-static install-deps setup-docker stop stop-old clean-old clean reset-db reset-all logs shell backup backup-db backup-site restore-db auto-restore list-backups clean-backups restore status restart update version check-ports stop-local-services init-site force-init-site

# Default target
help:
	@echo "ERPNext Docker Installation"
	@echo "=========================="
	@echo "Available targets:"
	@echo "  install-deps        - Install system dependencies"
	@echo "  setup-docker        - Set up Docker environment"
	@echo "  check-ports         - Check if required ports are available"
	@echo "  stop-local-services - Stop local MariaDB and Redis services"
	@echo "  install             - Install ERPNext with fresh MariaDB and Redis"
	@echo "  install-auto        - Install ERPNext (stops local services automatically)"
	@echo "  install-prod        - Install ERPNext with static assets built for production"
	@echo "  dev-mode            - Run ERPNext in development mode (with static file serving)"
	@echo "  dev-switch          - Switch existing installation to development mode"
	@echo "  fix-static          - Fix static files issue (builds assets and configures serving)"
	@echo "  run-with-static     - Run ERPNext with static files support (development mode)"
	@echo "  setup-dev-domain    - Setup domain mapping for development server"
	@echo "  build-assets        - Build static assets (CSS, JS, images) for production"
	@echo "  check-static        - Check if static files are being served correctly"
	@echo "  init-site           - Initialize ERPNext site (run after install if needed)"
	@echo "  force-init-site     - Force recreate ERPNext site (removes existing site)"
	@echo "  stop                - Stop all ERPNext services"
	@echo "  clean               - Remove all containers, volumes, and networks"
	@echo "  reset-db            - Reset MariaDB database (removes all data)"
	@echo "  reset-all           - Complete reset (removes all data and containers)"
	@echo "  logs                - Show logs from all services"
	@echo "  shell               - Open shell in ERPNext container"
	@echo "  backup              - Create comprehensive backup (site + database)"
	@echo "  backup-db           - Create database backup only (single transaction)"
	@echo "  backup-site         - Create ERPNext site backup only"
	@echo "  restore-db          - Restore database from backup"
	@echo "  auto-restore        - Auto-restore latest backup if database is empty"
	@echo "  list-backups        - List all available backups"
	@echo "  clean-backups       - Clean old backups (keep last 10)"
	@echo "  restore             - Show available backups and restore instructions (legacy)"
	@echo "  status              - Show status of all services"
	@echo "  restart             - Quick restart of all services"
	@echo "  update              - Update ERPNext to latest version"
	@echo "  version             - Show ERPNext version"

# Install system dependencies
install-deps:
	@echo "Installing system dependencies..."
	sudo apt-get update -y
	sudo apt-get install -y \
		curl \
		git \
		make \
		docker.io \
		python3 \
		python3-pip \
		nodejs \
		npm \
		redis-server \
		mariadb-server \
		mariadb-client \
		libmariadb-dev-compat \
		libmariadb-dev \
		libssl-dev \
		libffi-dev \
		libcairo2-dev \
		libpango1.0-dev \
		libgdk-pixbuf2.0-dev \
		libffi-dev \
		shared-mime-info
	@echo "System dependencies installed successfully!"

# Set up Docker environment
setup-docker:
	@echo "Setting up Docker environment..."
	sudo systemctl enable docker
	sudo systemctl start docker
	sudo usermod -aG docker $$USER
	@echo "Docker environment set up successfully!"
	@echo "Please log out and log back in for Docker group changes to take effect."

# Check if required ports are available
check-ports:
	@echo "Checking port availability..."
	@if netstat -tlnp 2>/dev/null | grep -q ":3306 "; then \
		echo "WARNING: Port 3306 (MariaDB) is already in use"; \
		echo "Run 'make stop-local-services' to stop local MariaDB"; \
		exit 1; \
	fi
	@if netstat -tlnp 2>/dev/null | grep -q ":6379 "; then \
		echo "WARNING: Port 6379 (Redis) is already in use"; \
		echo "Run 'make stop-local-services' to stop local Redis"; \
		exit 1; \
	fi
	@if netstat -tlnp 2>/dev/null | grep -q ":8000 "; then \
		echo "WARNING: Port 8000 (ERPNext) is already in use"; \
		exit 1; \
	fi
	@echo "All required ports are available!"

# Stop local MariaDB and Redis services
stop-local-services:
	@echo "Stopping local MariaDB and Redis services..."
	@sudo systemctl stop mariadb 2>/dev/null || echo "MariaDB service not running or not found"
	@sudo systemctl stop redis-server 2>/dev/null || echo "Redis service not running or not found"
	@sudo systemctl disable mariadb 2>/dev/null || echo "MariaDB service not found"
	@sudo systemctl disable redis-server 2>/dev/null || echo "Redis service not found"
	@echo "Local services stopped successfully!"

# Stop any existing ERPNext services
stop-old:
	@echo "Stopping any existing ERPNext services..."
	@docker compose down 2>/dev/null || true
	@docker stop erpnext-mariadb erpnext-redis erpnext-app 2>/dev/null || true
	@docker rm erpnext-mariadb erpnext-redis erpnext-app 2>/dev/null || true

# Clean up old volumes and networks
clean-old:
	@echo "Cleaning up old volumes and networks..."
	@docker volume rm erpnext_mariadb_data erpnext_redis_data erpnext_sites 2>/dev/null || true
	@docker network rm erpnext_network 2>/dev/null || true

# Install ERPNext with fresh setup
install: check-ports stop-old clean-old
	@echo "Installing ERPNext with fresh MariaDB and Redis..."
	@echo "This will create a completely new installation."
	@echo "Starting MariaDB and Redis services..."
	docker compose up -d mariadb redis
	@echo "Waiting for MariaDB to be ready..."
	@timeout=60; \
	while [ $$timeout -gt 0 ]; do \
		if docker compose exec mariadb mysqladmin ping -h localhost --silent 2>/dev/null; then \
			echo "MariaDB is ready!"; \
			break; \
		fi; \
		echo "Waiting for MariaDB... ($$timeout seconds remaining)"; \
		sleep 5; \
		timeout=$$((timeout-5)); \
	done; \
	if [ $$timeout -le 0 ]; then \
		echo "ERROR: MariaDB failed to start within 60 seconds"; \
		docker compose logs mariadb; \
		exit 1; \
	fi
	@echo "Starting ERPNext application..."
	docker compose up -d erpnext
	@echo "Waiting for ERPNext container to be ready..."
	@sleep 30
	@echo "Checking for existing database and auto-restoring if needed..."
	@$(MAKE) auto-restore
	@echo "Initializing ERPNext site..."
	@timeout=30; \
	while [ $$timeout -gt 0 ]; do \
		if docker compose exec mariadb mysqladmin ping -h localhost --silent 2>/dev/null; then \
			echo "MariaDB is ready for site initialization"; \
			break; \
		fi; \
		echo "Waiting for MariaDB... ($$timeout seconds remaining)"; \
		sleep 5; \
		timeout=$$((timeout-5)); \
	done; \
	if [ $$timeout -le 0 ]; then \
		echo "ERROR: MariaDB not ready for site initialization"; \
		exit 1; \
	fi
	@echo "Creating ERPNext site..."
	docker compose exec erpnext bench new-site erpnext.localhost --admin-password admin --db-root-password erpnext_root_password --db-root-username root --mariadb-root-password erpnext_root_password --db-host mariadb --db-name erpnext --db-user erpnext --db-password erpnext_password --force || echo "Site may already exist, continuing..."
	@echo "Installing ERPNext app..."
	docker compose exec erpnext bench --site erpnext.localhost install-app erpnext || echo "ERPNext app may already be installed, continuing..."
	@echo "Waiting for ERPNext to be fully ready..."
	@timeout=60; \
	while [ $$timeout -gt 0 ]; do \
		if curl -s http://erpnext.localhost:8000 >/dev/null 2>&1; then \
			echo "ERPNext is ready!"; \
			break; \
		fi; \
		echo "Waiting for ERPNext... ($$timeout seconds remaining)"; \
		sleep 10; \
		timeout=$$((timeout-10)); \
	done; \
	if [ $$timeout -le 0 ]; then \
		echo "WARNING: ERPNext may not be fully ready yet"; \
		echo "Check logs with: make logs"; \
	fi
	@echo ""
	@echo "ERPNext installation completed!"
	@echo "Access ERPNext at: http://erpnext.localhost:8000"
	@echo "Default credentials:"
	@echo "  Username: Administrator"
	@echo "  Password: admin"
	@echo ""
	@echo "Useful commands:"
	@echo "  make logs    - View service logs"
	@echo "  make status  - Check service status"
	@echo "  make shell   - Open shell in ERPNext container"

# Initialize ERPNext site
init-site:
	@echo "Initializing ERPNext site..."
	@timeout=30; \
	while [ $$timeout -gt 0 ]; do \
		if docker compose exec mariadb mysqladmin ping -h localhost --silent 2>/dev/null; then \
			echo "MariaDB is ready for site initialization"; \
			break; \
		fi; \
		echo "Waiting for MariaDB... ($$timeout seconds remaining)"; \
		sleep 5; \
		timeout=$$((timeout-5)); \
	done; \
	if [ $$timeout -le 0 ]; then \
		echo "ERROR: MariaDB not ready for site initialization"; \
		exit 1; \
	fi
	@echo "Creating ERPNext site..."
	docker compose exec erpnext bench new-site erpnext.localhost --admin-password admin --db-root-password erpnext_root_password --db-root-username root --mariadb-root-password erpnext_root_password --db-host mariadb --db-name erpnext --db-user erpnext --db-password erpnext_password --force || echo "Site may already exist, continuing..."
	@echo "Installing ERPNext app..."
	docker compose exec erpnext bench --site erpnext.localhost install-app erpnext || echo "ERPNext app may already be installed, continuing..."
	@echo "Site initialization completed!"

# Force recreate ERPNext site (removes existing site and creates new one)
force-init-site:
	@echo "Force recreating ERPNext site..."
	@timeout=30; \
	while [ $$timeout -gt 0 ]; do \
		if docker compose exec mariadb mysqladmin ping -h localhost --silent 2>/dev/null; then \
			echo "MariaDB is ready for site initialization"; \
			break; \
		fi; \
		echo "Waiting for MariaDB... ($$timeout seconds remaining)"; \
		sleep 5; \
		timeout=$$((timeout-5)); \
	done; \
	if [ $$timeout -le 0 ]; then \
		echo "ERROR: MariaDB not ready for site initialization"; \
		exit 1; \
	fi
	@echo "Removing existing site..."
	docker compose exec erpnext bench drop-site erpnext.localhost --force || echo "Site may not exist, continuing..."
	@echo "Creating new ERPNext site..."
	docker compose exec erpnext bench new-site erpnext.localhost --admin-password admin --db-root-password erpnext_root_password --db-root-username root --mariadb-root-password erpnext_root_password
	@echo "Installing ERPNext app..."
	docker compose exec erpnext bench --site erpnext.localhost install-app erpnext
	@echo "Site force initialization completed!"

# Install with automatic local service stopping
install-auto: stop-local-services install

# Stop all services
stop:
	@echo "Stopping ERPNext services..."
	docker compose down

# Clean everything (containers, volumes, networks)
clean: stop
	@echo "Removing all containers, volumes, and networks..."
	docker compose down -v --remove-orphans
	docker system prune -f

# Reset database (removes all data)
reset-db: stop
	@echo "Resetting MariaDB database..."
	docker volume rm erpnext_mariadb_data 2>/dev/null || true
	docker volume rm erpnext_sites 2>/dev/null || true
	@echo "Database reset completed. Run 'make install' to start fresh."

# Complete reset (removes all data and containers)
reset-all: stop
	@echo "Performing complete reset..."
	docker compose down -v --remove-orphans
	docker volume rm erpnext_mariadb_data erpnext_redis_data erpnext_sites erpnext_logs 2>/dev/null || true
	docker network rm erpnext_erpnext_network 2>/dev/null || true
	docker system prune -f
	@echo "Complete reset finished. Run 'make install' to start fresh."

# Build static files for production
build-assets:
	@echo "Building static assets..."
	docker compose exec erpnext bench build --app erpnext
	@echo "Configuring static file serving..."
	docker compose exec erpnext bench --site erpnext.localhost set-config serve_static_files true
	@echo "Restarting ERPNext service to serve static files..."
	docker compose restart erpnext
	@echo "Static assets built and service restarted successfully!"

# Run in development mode (with auto-reload and static file serving)
dev-mode: install
	@echo "Setting up development mode..."
	@echo "Building static assets..."
	docker compose exec erpnext bench build --app erpnext
	@echo "Stopping production server..."
	docker compose stop erpnext
	@echo "Starting development server..."
	docker compose exec erpnext bench --site erpnext.localhost serve --port 8000
	@echo "Development mode started!"
	@echo "Access ERPNext at: http://erpnext.localhost:8000"
	@echo "Static files will be served automatically in development mode."

# Switch to development mode (for existing installations)
dev-switch:
	@echo "Switching to development mode..."
	@echo "Building static assets..."
	docker compose exec erpnext bench build --app erpnext
	@echo "Stopping production server..."
	docker compose stop erpnext
	@echo "Starting container for development mode..."
	docker compose start erpnext
	@echo "Waiting for container to be ready..."
	@sleep 5
	@echo "Starting development server in background..."
	docker compose exec -d erpnext bench --site erpnext.localhost serve --port 8000
	@echo "Development mode started!"
	@echo "Access ERPNext at: http://erpnext.localhost:8000"
	@echo "Static files will be served automatically in development mode."
	@echo "To stop development mode, run: make stop"

# Fix static files issue (simple solution)
fix-static:
	@echo "Fixing static files issue..."
	@echo "Building static assets..."
	docker compose exec erpnext bench build --app erpnext
	@echo "Configuring static file serving..."
	docker compose exec erpnext bench --site erpnext.localhost set-config serve_static_files true
	@echo "Restarting ERPNext service..."
	docker compose restart erpnext
	@echo "Static files should now be working!"
	@echo "Access ERPNext at: http://erpnext.localhost:8000"
	@echo "If static files still don't work, run: make dev-switch"

# Run with static files (development mode - recommended for static files)
run-with-static:
	@echo "Running ERPNext with static files support..."
	@echo "Starting all services..."
	docker compose up -d mariadb redis
	@echo "Waiting for database to be ready..."
	@sleep 10
	@echo "Starting ERPNext container..."
	docker compose up -d erpnext
	@echo "Waiting for ERPNext container to be ready..."
	@sleep 15
	@echo "Building static assets..."
	docker compose exec erpnext bench build --app erpnext
	@echo "Stopping production server..."
	docker compose stop erpnext
	@echo "Starting container for development mode..."
	docker compose start erpnext
	@echo "Waiting for container to be ready..."
	@sleep 5
	@echo "Starting development server (this will run in foreground)..."
	@echo "Press Ctrl+C to stop the server"
	@echo "Access ERPNext at: http://erpnext.localhost:8001"
	@echo "Static files will be served automatically!"
	@echo "Login with: Administrator / admin"
	docker compose exec erpnext bench --site erpnext.localhost serve --port 8001

# Setup domain mapping for development server
setup-dev-domain:
	@echo "Setting up domain mapping for development server..."
	@echo "Adding erpnext.localhost to /etc/hosts..."
	@if ! grep -q "erpnext.localhost" /etc/hosts; then \
		echo "127.0.0.1 erpnext.localhost" | sudo tee -a /etc/hosts; \
		echo "Added erpnext.localhost to /etc/hosts"; \
	else \
		echo "erpnext.localhost already exists in /etc/hosts"; \
	fi
	@echo "Domain mapping setup complete!"
	@echo "You can now access ERPNext at: http://erpnext.localhost:8001"
	@echo "Make sure to run 'make run-with-static' to start the development server"

# Install and build assets for production
install-prod: install build-assets
	@echo "Production installation completed with static assets!"
	@echo "Access ERPNext at: http://erpnext.localhost:8000"

# Check if static files are being served
check-static:
	@echo "Checking static file serving..."
	@echo "Testing main page..."
	@curl -s -o /dev/null -w "Main page: %{http_code}\n" http://erpnext.localhost:8000
	@echo "Testing static assets..."
	@curl -s -o /dev/null -w "CSS files: %{http_code}\n" http://erpnext.localhost:8000/assets/erpnext/dist/css/erpnext.bundle.7OBAPSRQ.css
	@curl -s -o /dev/null -w "JS files: %{http_code}\n" http://erpnext.localhost:8000/assets/erpnext/dist/js/erpnext.bundle.Z6C6MIAE.js
	@echo "Static file check completed!"

# Show logs
logs:
	docker compose logs -f

# Open shell in ERPNext container
shell:
	docker compose exec erpnext bash

# Create MariaDB database backup (single transaction for consistency)
backup-db:
	@echo "Creating MariaDB database backup..."
	@mkdir -p backups
	@TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	docker compose exec mariadb mysqldump --single-transaction --routines --triggers \
		-u erpnext -perpnext_password erpnext > backups/erpnext_db_$$TIMESTAMP.sql; \
	echo "Database backup created: backups/erpnext_db_$$TIMESTAMP.sql"

# Create ERPNext site backup
backup-site:
	@echo "Creating ERPNext site backup..."
	docker compose exec erpnext bench --site erpnext.localhost backup
	@echo "ERPNext site backup completed! Check the sites/erpnext.localhost/private/backups/ directory"

# Create comprehensive backup (both ERPNext site and database)
backup:
	@echo "Creating comprehensive backup (ERPNext site + database)..."
	@mkdir -p backups
	@TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	echo "Creating ERPNext site backup..."; \
	docker compose exec erpnext bench --site erpnext.localhost backup; \
	echo "Creating database backup..."; \
	docker compose exec mariadb mysqldump --single-transaction --routines --triggers \
		-u erpnext -perpnext_password erpnext > backups/erpnext_db_$$TIMESTAMP.sql; \
	echo "Comprehensive backup completed!"
	@echo "Files created:"
	@echo "  - ERPNext site backup: sites/erpnext.localhost/private/backups/"
	@echo "  - Database backup: backups/erpnext_db_$$(date +%Y%m%d_%H%M%S).sql"

# Restore database from backup
restore-db:
	@echo "Available database backups:"
	@ls -la backups/erpnext_db_*.sql 2>/dev/null || echo "No database backups found"
	@echo ""
	@echo "Usage: make restore-db BACKUP_FILE=backups/erpnext_db_YYYYMMDD_HHMMSS.sql"
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "Error: Please specify BACKUP_FILE parameter"; \
		exit 1; \
	fi
	@if [ ! -f "$(BACKUP_FILE)" ]; then \
		echo "Error: Backup file $(BACKUP_FILE) not found"; \
		exit 1; \
	fi
	@echo "Restoring database from $(BACKUP_FILE)..."
	@echo "WARNING: This will overwrite the current database!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	docker compose exec -T mariadb mysql -u erpnext -perpnext_password erpnext < $(BACKUP_FILE)
	@echo "Database restored successfully!"

# Auto-restore latest database backup if database is empty
auto-restore:
	@echo "Checking if database is empty..."
	@DB_EXISTS=$$(docker compose exec mariadb mysql -u erpnext -perpnext_password -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='erpnext';" -s -N 2>/dev/null || echo "0"); \
	if [ "$$DB_EXISTS" = "0" ]; then \
		echo "Database is empty, looking for latest backup..."; \
		LATEST_BACKUP=$$(ls -t backups/erpnext_db_*.sql 2>/dev/null | head -1); \
		if [ -n "$$LATEST_BACKUP" ]; then \
			echo "Found latest backup: $$LATEST_BACKUP"; \
			echo "Auto-restoring database..."; \
			docker compose exec -T mariadb mysql -u erpnext -perpnext_password erpnext < $$LATEST_BACKUP; \
			echo "Database auto-restored from $$LATEST_BACKUP"; \
		else \
			echo "No database backups found, database will remain empty"; \
		fi; \
	else \
		echo "Database already contains data ($$DB_EXISTS tables), skipping auto-restore"; \
	fi

# List all backups
list-backups:
	@echo "=== ERPNext Site Backups ==="
	@docker compose exec erpnext find /home/frappe/frappe-bench/sites/erpnext.localhost/private/backups -name "*.tar.gz" -type f 2>/dev/null | head -10 || echo "No site backups found"
	@echo ""
	@echo "=== Database Backups ==="
	@ls -la backups/erpnext_db_*.sql 2>/dev/null || echo "No database backups found"

# Clean old backups (keep last 10)
clean-backups:
	@echo "Cleaning old backups (keeping last 10)..."
	@echo "Database backups:"
	@ls -t backups/erpnext_db_*.sql 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || echo "No old database backups to clean"
	@echo "Site backups:"
	@docker compose exec erpnext find /home/frappe/frappe-bench/sites/erpnext.localhost/private/backups -name "*.tar.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | head -n -10 | cut -d' ' -f2- | xargs rm -f 2>/dev/null || echo "No old site backups to clean"
	@echo "Backup cleanup completed!"

# Legacy restore command (for backward compatibility)
restore:
	@echo "Available backups:"
	@ls -la backups/*.sql 2>/dev/null || echo "No backups found"
	@echo "To restore, run: make restore-db BACKUP_FILE=backups/your_backup_file.sql"

# Show status
status:
	@echo "ERPNext Services Status:"
	@echo "======================="
	docker compose ps

# Quick restart
restart: stop install

# Update ERPNext
update:
	@echo "Updating ERPNext..."
	docker compose pull
	docker compose up -d
	@echo "Update completed!"

# Show ERPNext version
version:
	docker compose exec erpnext bench version
