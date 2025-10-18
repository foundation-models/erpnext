# ERPNext Nginx Configuration

## Overview

This Nginx configuration provides a reverse proxy for ERPNext with proper static file handling.

## Architecture

```
Browser → Nginx (port 8000) → ERPNext Development Server (internal port 8000)
                            → Socket.IO (internal port 9000)
```

## Key Features

1. **Static File Serving**: Proxies `/assets` and `/files` requests to ERPNext development server
2. **WebSocket Support**: Handles Socket.IO connections for real-time features
3. **Caching Headers**: Sets appropriate cache headers for static assets
4. **Development Mode**: ERPNext runs with `bench serve` to support static file serving

## Why Development Server?

The ERPNext production server (gunicorn) doesn't serve static files directly. In production environments, static files are typically served by a web server like Nginx. However, since ERPNext's static assets use symlinks to app directories, and those directories aren't accessible to the Nginx container, we run ERPNext in development mode which serves static files directly.

## Files

- `nginx/nginx.conf` - Nginx configuration
- `docker-compose.yml` - Updated to include nginx service and run ERPNext in dev mode

## Usage

Start all services including Nginx:
```bash
make start-with-nginx
```

Or manually:
```bash
docker compose up -d
```

## Accessing ERPNext

- **Web UI**: http://erpnext.localhost:8000
- **Login**: Administrator / admin

## Configuration Details

### Upstream Servers
- `erpnext`: ERPNext development server on port 8000
- `socketio`: Socket.IO server on port 9000

### Location Blocks
- `/assets` - Static assets (CSS, JS, images)
- `/files` - User uploaded files
- `/socket.io` - WebSocket connections
- `/` - All other requests

### Cache Headers
- Assets: 30 days with immutable flag
- Files: 7 days

## Troubleshooting

### Static files not loading
1. Check if assets are built:
   ```bash
   docker compose exec erpnext ls -la /home/frappe/frappe-bench/sites/assets/
   ```

2. Rebuild assets:
   ```bash
   docker compose exec erpnext bench build --app erpnext
   ```

3. Check nginx logs:
   ```bash
   docker logs erpnext-nginx
   ```

4. Check ERPNext logs:
   ```bash
   docker logs erpnext-app
   ```

### Connection issues
- Verify all containers are running: `docker compose ps`
- Check network connectivity: `docker network inspect erpnext_erpnext_network`
- Verify `/etc/hosts` has `127.0.0.1 erpnext.localhost`

## Notes

- The development server is suitable for development and testing
- For production, consider using a proper WSGI server with Nginx serving static files from a mounted volume
- The `--noreload` flag prevents auto-reload to improve stability in containerized environment

