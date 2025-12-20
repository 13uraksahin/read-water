# Read Water - Dokploy Deployment Guide

This guide covers deploying Read Water on Dokploy.

## Prerequisites

- Dokploy instance running
- Domain configured (e.g., `your-domain.com`)
- SSL certificates (usually handled by Dokploy/Traefik)

## Quick Start

### 1. Create a New Project in Dokploy

1. Go to your Dokploy dashboard
2. Click "New Project"
3. Select "Docker Compose" as the deployment type
4. Connect your Git repository or upload the code

### 2. Configure Environment Variables

In Dokploy's environment configuration, set the following variables:

```env
# PostgreSQL
POSTGRES_USER=readwater
POSTGRES_PASSWORD=<generate-strong-password>
POSTGRES_DB=readwater

# Redis (optional, leave empty for no password)
REDIS_PASSWORD=<generate-strong-password>

# JWT Secrets (CRITICAL - generate unique values!)
# Generate with: openssl rand -base64 64
JWT_SECRET=<generate-64-char-secret>
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=<generate-64-char-secret>
JWT_REFRESH_EXPIRES_IN=30d

# Ports
API_PORT=4000
APP_PORT=3000

# CORS (your frontend domain)
CORS_ORIGINS=https://app.your-domain.com

# Frontend environment
NUXT_PUBLIC_API_BASE=https://api.your-domain.com
NUXT_PUBLIC_SOCKET_URL=https://api.your-domain.com

# Queue (optional)
QUEUE_READINGS_CONCURRENCY=10
```

### 3. Select the Docker Compose File

Use `docker-compose.prod.yml` as the compose file.

### 4. Configure Domains

In Dokploy, configure the following domains:

| Service | Domain | Port |
|---------|--------|------|
| `app` | `app.your-domain.com` | 3000 |
| `api` | `api.your-domain.com` | 4000 |

### 5. Deploy

Click "Deploy" in Dokploy. The deployment will:

1. Start TimescaleDB and Redis
2. Wait for health checks
3. Run database migrations
4. Start the API and App services

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

## Updating

1. Push your code changes to the repository
2. In Dokploy, click "Redeploy"
3. Migrations run automatically

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

