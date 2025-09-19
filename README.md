# ERPNext Docker Installation

This repository contains a complete Docker-based ERPNext installation with fresh MariaDB and Redis setup.

## Features

- **Fresh Installation**: Completely new MariaDB database and Redis cache
- **Docker-based**: Easy deployment and management
- **Optimized Configuration**: MariaDB tuned for ERPNext performance
- **Backup/Restore**: Built-in database backup and restore functionality
- **Development Mode**: Pre-configured for development with auto-reload

## Quick Start

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
| `make stop` | Stop all ERPNext services |
| `make clean` | Remove all containers, volumes, and networks |
| `make reset-db` | Reset MariaDB database (removes all data) |
| `make logs` | Show logs from all services |
| `make shell` | Open shell in ERPNext container |
| `make backup` | Backup ERPNext database |
| `make restore` | Restore ERPNext database from backup |
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
```bash
make backup
```

### Restore from Backup
```bash
make restore
# Then manually restore: docker-compose exec -T mariadb mysql -u root -p$MYSQL_ROOT_PASSWORD < backups/your_backup_file.sql
```

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