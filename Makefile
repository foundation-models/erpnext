# ERPNext Installation Makefile
# This Makefile installs ERPNext using Docker with fresh MariaDB and Redis

.PHONY: help install stop clean reset-db logs shell backup restore

# Default target
help:
	@echo "ERPNext Docker Installation"
	@echo "=========================="
	@echo "Available targets:"
	@echo "  install     - Install ERPNext with fresh MariaDB and Redis"
	@echo "  stop        - Stop all ERPNext services"
	@echo "  clean       - Remove all containers, volumes, and networks"
	@echo "  reset-db    - Reset MariaDB database (removes all data)"
	@echo "  logs        - Show logs from all services"
	@echo "  shell       - Open shell in ERPNext container"
	@echo "  backup      - Backup ERPNext database"
	@echo "  restore     - Restore ERPNext database from backup"
	@echo "  status      - Show status of all services"

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
install: stop-old clean-old
	@echo "Installing ERPNext with fresh MariaDB and Redis..."
	@echo "This will create a completely new installation."
	@echo "Starting services..."
	docker compose up -d mariadb redis
	@echo "Waiting for MariaDB to be ready..."
	@sleep 30
	@echo "Starting ERPNext application..."
	docker compose up -d erpnext
	@echo "Waiting for ERPNext to initialize..."
	@sleep 60
	@echo "ERPNext installation completed!"
	@echo "Access ERPNext at: http://localhost:8000"
	@echo "Default credentials:"
	@echo "  Username: Administrator"
	@echo "  Password: admin"

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

# Show logs
logs:
	docker compose logs -f

# Open shell in ERPNext container
shell:
	docker compose exec erpnext bash

# Backup database
backup:
	@echo "Creating database backup..."
	@mkdir -p backups
	docker compose exec mariadb mysqldump -u root -p$$MYSQL_ROOT_PASSWORD --all-databases > backups/erpnext_backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Backup created in backups/ directory"

# Restore database from backup
restore:
	@echo "Available backups:"
	@ls -la backups/*.sql 2>/dev/null || echo "No backups found"
	@echo "To restore, run: docker compose exec -T mariadb mysql -u root -p$$MYSQL_ROOT_PASSWORD < backups/your_backup_file.sql"

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
