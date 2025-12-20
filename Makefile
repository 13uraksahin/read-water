# =============================================================================
# Read Water - Makefile
# =============================================================================
# Quick commands for development and deployment
# =============================================================================

.PHONY: help dev dev-down prod prod-down dokploy dokploy-down logs migrate seed clean

# Default target
help:
	@echo "Read Water - Available Commands"
	@echo ""
	@echo "Development:"
	@echo "  make dev          - Start development environment (DB + Redis)"
	@echo "  make dev-down     - Stop development environment"
	@echo ""
	@echo "Production (Local):"
	@echo "  make prod         - Build and start production containers"
	@echo "  make prod-down    - Stop production containers"
	@echo ""
	@echo "Dokploy Deployment:"
	@echo "  make dokploy      - Build and start with Traefik labels"
	@echo "  make dokploy-down - Stop Dokploy containers"
	@echo ""
	@echo "Database:"
	@echo "  make migrate      - Run database migrations"
	@echo "  make seed         - Seed the database"
	@echo ""
	@echo "Utilities:"
	@echo "  make logs         - View all container logs"
	@echo "  make logs-api     - View API logs"
	@echo "  make logs-app     - View App logs"
	@echo "  make clean        - Remove all containers and volumes"
	@echo ""

# =============================================================================
# Development
# =============================================================================

dev:
	docker compose up -d
	@echo "Development services started (TimescaleDB + Redis)"
	@echo "Run 'cd api && npm run start:dev' for API"
	@echo "Run 'cd app && npm run dev' for App"

dev-down:
	docker compose down

# =============================================================================
# Production (Local Testing)
# =============================================================================

prod:
	docker compose -f docker-compose.prod.yml up -d --build
	@echo "Production containers started"
	@echo "API: http://localhost:4000"
	@echo "App: http://localhost:3000"

prod-down:
	docker compose -f docker-compose.prod.yml down

# =============================================================================
# Dokploy Deployment
# =============================================================================

dokploy:
	docker compose -f docker-compose.prod.yml -f docker-compose.dokploy.yml up -d --build
	@echo "Dokploy containers started with Traefik labels"

dokploy-down:
	docker compose -f docker-compose.prod.yml -f docker-compose.dokploy.yml down

# =============================================================================
# Database
# =============================================================================

migrate:
	docker compose -f docker-compose.prod.yml run --rm migrations

seed:
	docker compose -f docker-compose.prod.yml exec api npx prisma db seed

# =============================================================================
# Logs
# =============================================================================

logs:
	docker compose -f docker-compose.prod.yml logs -f

logs-api:
	docker compose -f docker-compose.prod.yml logs -f api

logs-app:
	docker compose -f docker-compose.prod.yml logs -f app

logs-db:
	docker compose -f docker-compose.prod.yml logs -f timescaledb

# =============================================================================
# Cleanup
# =============================================================================

clean:
	docker compose -f docker-compose.prod.yml down -v --remove-orphans
	docker compose down -v --remove-orphans
	@echo "All containers and volumes removed"

# =============================================================================
# Build Only
# =============================================================================

build-api:
	docker compose -f docker-compose.prod.yml build api

build-app:
	docker compose -f docker-compose.prod.yml build app

build-all:
	docker compose -f docker-compose.prod.yml build

