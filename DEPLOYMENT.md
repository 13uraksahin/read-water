# Read Water - Dokploy Deployment Guide

This guide covers deploying Read Water on Dokploy with GitHub Actions CI/CD.

## Prerequisites

- Dokploy instance running
- Domain configured (e.g., `your-domain.com`)
- SSL certificates (usually handled by Dokploy/Traefik)
- GitHub repository with Actions enabled

## CI/CD Pipeline

This project uses GitHub Actions to build Docker images and deploy to Dokploy automatically.

### How It Works

```
Push to main → GitHub Actions → Build & Push to GHCR → Trigger Dokploy → Pull & Deploy
```

1. **CI** (`.github/workflows/ci.yml`): On PRs, verifies Docker builds succeed
2. **CD** (`.github/workflows/deploy-prod.yml`): On push to `main`, builds images, pushes to GHCR, and triggers Dokploy

### GitHub Setup

#### 1. Add Repository Secret

Go to **Settings → Secrets and variables → Actions → Secrets** and add:

| Secret | Description |
|--------|-------------|
| `DOKPLOY_DEPLOY_HOOK_URL` | The Deploy Hook URL from Dokploy (see step 2.1 below) |

#### 2. Add Repository Variables (Optional)

Go to **Settings → Secrets and variables → Actions → Variables** and add:

| Variable | Default | Description |
|----------|---------|-------------|
| `NUXT_PUBLIC_API_BASE` | `https://api.rwa.portall.tr` | API URL baked into frontend build |
| `NUXT_PUBLIC_SOCKET_URL` | `https://api.rwa.portall.tr` | WebSocket URL baked into frontend build |

### Docker Images

Images are published to GitHub Container Registry (GHCR):

- **API**: `ghcr.io/<owner>/readwater-api:latest`
- **App**: `ghcr.io/<owner>/readwater-app:latest`

Each push also creates a SHA-tagged version (e.g., `sha-abc1234`) for rollback purposes.

## Quick Start

### 1. Create a New Project in Dokploy

1. Go to your Dokploy dashboard
2. Click "New Project"
3. Select "Docker Compose" as the deployment type
4. Connect your Git repository
5. **Important**: Copy the **Deploy Hook URL** from the project settings (needed for GitHub Actions)

### 2. Configure Docker Registry (for GHCR)

If your GitHub repository/packages are **private**, add GHCR credentials in Dokploy:

1. Go to **Settings → Docker Registry** in Dokploy
2. Add a new registry:
   - **Registry URL**: `ghcr.io`
   - **Username**: Your GitHub username or organization
   - **Password**: A GitHub Personal Access Token with `read:packages` scope

> **Note**: If your packages are public, skip this step.

### 3. Configure Environment Variables

In Dokploy's environment configuration, set the following variables:

```env
# =============================================================================
# Docker Images (GHCR)
# =============================================================================
# Replace <owner> with your GitHub username or organization (lowercase)
API_IMAGE=ghcr.io/<owner>/readwater-api:latest
APP_IMAGE=ghcr.io/<owner>/readwater-app:latest

# =============================================================================
# PostgreSQL
# =============================================================================
POSTGRES_USER=readwater
POSTGRES_PASSWORD=<generate-strong-password>
POSTGRES_DB=readwater

# =============================================================================
# Redis (optional, leave empty for no password)
# =============================================================================
REDIS_PASSWORD=<generate-strong-password>

# =============================================================================
# JWT Secrets (CRITICAL - generate unique values!)
# Generate with: openssl rand -base64 64
# =============================================================================
JWT_SECRET=<generate-64-char-secret>
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=<generate-64-char-secret>
JWT_REFRESH_EXPIRES_IN=30d

# =============================================================================
# Ports
# =============================================================================
API_PORT=4000
APP_PORT=3000

# =============================================================================
# CORS (your frontend domain)
# =============================================================================
CORS_ORIGINS=https://app.your-domain.com

# =============================================================================
# Frontend environment
# =============================================================================
NUXT_PUBLIC_API_BASE=https://api.your-domain.com
NUXT_PUBLIC_SOCKET_URL=https://api.your-domain.com

# =============================================================================
# Queue (optional)
# =============================================================================
QUEUE_READINGS_CONCURRENCY=10
```

### 4. Select the Docker Compose File

Use `docker-compose.prod.yml` as the compose file.

### 5. Configure Domains

In Dokploy, configure the following domains:

| Service | Domain | Port |
|---------|--------|------|
| `app` | `app.your-domain.com` | 3000 |
| `api` | `api.your-domain.com` | 4000 |

### 6. Deploy

Click "Deploy" in Dokploy. The deployment will:

1. Pull images from GHCR
2. Start TimescaleDB and Redis
3. Wait for health checks
4. Run database migrations
5. Start the API and App services

> **After initial setup**: Deployments happen automatically when you push to `main`. GitHub Actions builds the images, pushes to GHCR, and triggers the Dokploy deploy hook.

## Service Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Dokploy                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                    Traefik Proxy                        ││
│  │   app.your-domain.com → :3000                           ││
│  │   api.your-domain.com → :4000                           ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    App      │  │    API      │  │   Migrations       │  │
│  │  (Nuxt 4)   │──│  (NestJS)   │  │   (One-time)       │  │
│  │   :3000     │  │   :4000     │  └─────────────────────┘  │
│  └─────────────┘  └──────┬──────┘                           │
│                          │                                   │
│  ┌───────────────────────┼───────────────────────────────┐  │
│  │                       │                               │  │
│  │  ┌───────────────┐    │    ┌───────────────────────┐  │  │
│  │  │  TimescaleDB  │◄───┴───►│        Redis          │  │  │
│  │  │   (Postgres)  │         │   (Cache/Queue/WS)    │  │  │
│  │  └───────────────┘         └───────────────────────┘  │  │
│  │                                                       │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Health Checks

Both services expose health check endpoints:

- **API**: `GET /api/v1/health`
- **App**: `GET /api/_health`

These are used by Docker for container health monitoring.

## Database Migrations

Migrations run automatically via the `migrations` service on deployment. To run migrations manually:

```bash
docker compose -f docker-compose.prod.yml run --rm migrations npx prisma migrate deploy
```

## Seeding (First Deployment Only)

After the first deployment, you may want to seed the database:

```bash
docker compose -f docker-compose.prod.yml exec api npx prisma db seed
```

This creates:
- Root tenant
- Default users (Super Admin, Tenant Admins)
- Meter/Device brands
- Sample profiles

## Updating (Automatic via CI/CD)

1. Push your code changes to the `main` branch
2. GitHub Actions automatically:
   - Builds new Docker images
   - Pushes them to GHCR
   - Triggers Dokploy deploy hook
3. Dokploy pulls new images and restarts services
4. Migrations run automatically

### Manual Redeploy

If needed, you can also trigger a manual redeploy in Dokploy by clicking "Redeploy".

## Troubleshooting

### Check Service Logs

```bash
# Via Dokploy UI or SSH:
docker compose -f docker-compose.prod.yml logs api
docker compose -f docker-compose.prod.yml logs app
docker compose -f docker-compose.prod.yml logs timescaledb
```

### Database Connection Issues

Ensure `DATABASE_URL` is correctly formatted:
```
postgresql://USER:PASSWORD@timescaledb:5432/DATABASE?schema=public
```

### Redis Connection Issues

If using a password, ensure `REDIS_PASSWORD` is set in both the Redis service and API environment.

### CORS Errors

Verify `CORS_ORIGINS` includes your frontend domain with the correct protocol (https://).

## SSL/TLS

Dokploy handles SSL certificates automatically via Traefik and Let's Encrypt. Ensure your domains are correctly pointed to your Dokploy server.

## Scaling

For higher load, consider:

1. **Horizontal Scaling**: Increase API replicas in docker-compose
2. **Database**: Use managed TimescaleDB service
3. **Redis**: Use managed Redis service (AWS ElastiCache, etc.)
4. **CDN**: Put Cloudflare or similar in front of the app

## Backup

### Database Backup

```bash
docker compose -f docker-compose.prod.yml exec timescaledb pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup.sql
```

### Redis Backup

Redis data is persisted to the `redis_data` volume with AOF enabled.

