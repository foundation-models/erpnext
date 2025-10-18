# ERPNext Docker Installation

This repository contains a complete Docker-based ERPNext installation with fresh MariaDB and Redis setup.

## Features

- **Fresh Installation**: Completely new MariaDB database and Redis cache
- **Docker-based**: Easy deployment and management
- **Optimized Configuration**: MariaDB tuned for ERPNext performance
- **Backup/Restore**: Built-in database backup and restore functionality
- **Development Mode**: Pre-configured for development with auto-reload

## Quick Start

### Option 1: Restore from Existing Backup (Recommended)

If you have existing ERPNext data, restore from a backup first:

1. **List available backups**:
   ```bash
   make list-backups
   ```

2. **Restore database from backup**:
   ```bash
   make restore-db BACKUP_FILE=backups/erpnext_db_YYYYMMDD_HHMMSS.sql
   ```

3. **Start ERPNext with static assets**:
   ```bash
   make run-with-static
   ```

4. **Login to ERPNext**:
   - **Email**: `hosseinakhlaghpour@gmail.com`
   - **Password**: [your usual password]

5. **Access ERPNext modules**:
   - Suppliers: http://172.18.0.4:8001/app/supplier
   - Customers: http://172.18.0.4:8001/app/customer
   - Purchase Invoices: http://172.18.0.4:8001/app/purchase-invoice
   - Main Dashboard: http://172.18.0.4:8001/app

> **Note**: If you encounter login issues after restoring, reset your password:
> ```bash
> docker exec -it erpnext-app bench --site erpnext.localhost set-password hosseinakhlaghpour@gmail.com your_new_password
> ```

### Option 2: Fresh Installation

For a brand new ERPNext instance:

1. **Install ERPNext**:
   ```bash
   make install
   ```

2. **Access ERPNext**:
   - URL: http://localhost:8000
   - Username: Administrator
   - Password: admin

## Available Commands

| Command | Description |
|---------|-------------|
| `make install` | Install ERPNext with fresh MariaDB and Redis |
| `make run-with-static` | Run ERPNext with static files support (development mode) |
| `make list-backups` | List all available database backups |
| `make restore-db` | Restore database from backup (requires BACKUP_FILE parameter) |
| `make backup` | Create comprehensive backup (site + database) |
| `make backup-db` | Create database backup only |
| `make stop` | Stop all ERPNext services |
| `make clean` | Remove all containers, volumes, and networks |
| `make reset-db` | Reset MariaDB database (removes all data) |
| `make logs` | Show logs from all services |
| `make shell` | Open shell in ERPNext container |
| `make status` | Show status of all services |
| `make restart` | Quick restart of all services |
| `make update` | Update ERPNext to latest version |

## Configuration

### Environment Variables

Copy `config.env` to `.env` and modify as needed:

```bash
cp config.env .env
```

Key configuration options:
- `MYSQL_ROOT_PASSWORD`: MariaDB root password
- `MYSQL_PASSWORD`: ERPNext database password
- `ADMIN_PASSWORD`: ERPNext admin password
- `SITE_NAME`: ERPNext site name

### MariaDB Configuration

The MariaDB configuration is optimized for ERPNext in `config/mariadb.cnf`:
- InnoDB buffer pool: 1GB
- UTF8MB4 character set
- Optimized for ERPNext workloads

## Services

- **ERPNext**: Main application (port 8000)
- **MariaDB**: Database server (port 3306)
- **Redis**: Cache and queue server (port 6379)

## Troubleshooting

### Reset Everything
If you encounter issues, reset everything:
```bash
make clean
make install
```

### Database Issues
Reset only the database:
```bash
make reset-db
make install
```

### View Logs
Check service logs:
```bash
make logs
```

### Access Container
Open shell in ERPNext container:
```bash
make shell
```

## Backup and Restore

### Create Backup

**Comprehensive backup (recommended)**:
```bash
make backup
```

**Database only**:
```bash
make backup-db
```

### List Available Backups
```bash
make list-backups
```

### Restore from Backup

1. **List available backups**:
   ```bash
   make list-backups
   ```

2. **Restore specific backup**:
   ```bash
   make restore-db BACKUP_FILE=backups/erpnext_db_20250920_175433.sql
   ```

3. **Reset passwords after restore** (if needed):
   ```bash
   # Reset Administrator password
   docker exec -it erpnext-app bench --site erpnext.localhost set-admin-password newpassword123
   
   # Reset specific user password
   docker exec -it erpnext-app bench --site erpnext.localhost set-password user@example.com newpassword123
   ```

> **Important**: Restoring a database will overwrite all current data and reset all user passwords to what they were at the time of the backup.

## Development

The installation is configured for development with:
- Developer mode enabled
- Auto-update disabled
- Debug logging enabled

## Production Considerations

For production deployment:
1. Change default passwords in `.env`
2. Use proper SSL certificates
3. Configure proper backup schedules
4. Set up monitoring
5. Use external database and Redis if needed

## Support

For ERPNext documentation, visit: https://docs.erpnext.com/