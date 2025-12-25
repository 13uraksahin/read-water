# AGENTS.md - AI Agent Guidelines for Read Water Platform

> This document provides essential context and guidelines for AI agents working on the Read Water codebase.

---

## 1. Project Overview

**Read Water** is a high-performance, multi-tenant **Utility Management Platform** for remote water consumption monitoring. It manages:

- **Tenants** (Water utilities/agencies)
- **Customers** (End users - individuals or organizations)
- **Subscriptions** (Service agreements linking customers to meters)
- **Meters** (Physical water meter assets)
- **Devices** (IoT communication modules attached to meters)

### Performance Targets
- 1M+ concurrent requests
- 10K+ users actively checking live data via WebSocket

---

## 2. Tech Stack

### Infrastructure
| Component | Technology |
|-----------|------------|
| Containerization | Docker, Docker Compose |
| Database | PostgreSQL with TimescaleDB + ltree extension |
| Cache/Queue | Redis (BullMQ + Streams) |

### Backend (`/api`)
| Component | Technology |
|-----------|------------|
| Framework | NestJS (Modular Monolith) |
| ORM | Prisma 6 |
| Query Builder | Kysely (for complex queries) |
| Realtime | Socket.IO with Redis Streams Adapter |
| Validation | Class-Validator & Class-Transformer |
| Auth | PassportJS |

### Frontend (`/app`)
| Component | Technology |
|-----------|------------|
| Framework | Nuxt 4 (Vue 3) |
| State | Pinia |
| UI Components | Shadcn/Vue + Tailwind CSS |
| Charts | Shadcn Charts (Unovis) |
| Maps | Leaflet |
| Realtime | Socket.IO Client |
| i18n | English, Turkish, French |

---

## 3. Core Architecture: The Subscription Model

### ⚠️ CRITICAL BUSINESS LOGIC

The system does **NOT** link Meters directly to Customers. The hierarchy is:

```
Tenant → Customer → Subscription → Meter → Device
```

### Key Concepts

1. **Subscription** is the central entity linking a Customer to a Meter
2. A Customer creates a Subscription for a specific location (e.g., a house)
3. A Meter is linked to that Subscription
4. If the customer moves, the Subscription ends, and the Meter becomes available for a new Subscription
5. **Address belongs to Subscription**, not to Customer, Meter, or Device

### Entity Relationships

```
┌─────────┐     ┌──────────┐     ┌──────────────┐     ┌───────┐     ┌────────┐
│ Tenant  │────▶│ Customer │────▶│ Subscription │────▶│ Meter │────▶│ Device │
└─────────┘     └──────────┘     └──────────────┘     └───────┘     └────────┘
     │               │                  │                 │             │
     │               │                  │                 │             │
     ▼               ▼                  ▼                 ▼             ▼
  ltree path    Individual/Org      Has Address      Has Profile   Has Profile
  hierarchy     details (JSONB)     (JSONB)          + Status      + Dynamic Fields
```

---

## 4. Database Schema (Prisma)

### Core Models

| Model | Key Fields | Notes |
|-------|------------|-------|
| `Tenant` | `id`, `name`, `path` (ltree), `type` | Hierarchical via ltree |
| `User` | `id`, `tenantId`, `role`, `permissions` | RBAC enforced |
| `Customer` | `id`, `tenantId`, `type`, `details` (JSONB) | Individual or Organizational |
| `Subscription` | `id`, `tenantId`, `customerId`, `type`, `group`, `address` (JSONB) | **Core linking entity** |
| `Meter` | `id`, `serialNumber`, `profileId`, `tenantId`, `status`, `subscriptionId?`, `activeDeviceId?` | Asset |
| `Device` | `id`, `serialNumber`, `profileId`, `tenantId`, `status`, `dynamicFields` (JSONB) | IoT inventory |
| `MeterProfile` | Mechanical specs (Qn, dimensions, brand, type) | Configuration template |
| `DeviceProfile` | IoT specs, decoder functions, field definitions | Configuration template |

### Important Enums

```typescript
// Subscription Types
enum SubscriptionType { INDIVIDUAL, ORGANIZATIONAL }

// Subscription Groups
enum SubscriptionGroup { NORMAL_CONSUMPTION, HIGH_CONSUMPTION }

// Meter/Device Statuses
enum Status { ACTIVE, PASSIVE, WAREHOUSE, MAINTENANCE, PLANNED, DEPLOYED, USED }

// Communication Technologies
enum CommTech { SIGFOX, LORAWAN, NBIOT, WMBUS, MIOTY, WIFI, BLUETOOTH, NFC, OMS }

// Communication Modules
enum CommModule { INTEGRATED, RETROFIT, NONE }
```

---

## 5. Module Structure

### Backend Modules (`/api/src/modules/`)

| Module | Purpose |
|--------|---------|
| `iam/` | Tenants, Users, Authentication, RBAC |
| `customers/` | Customer CRUD |
| `device/` | Meters, Devices, Profiles (Assets & Inventory) |
| `dashboard/` | Aggregated stats, map data |
| `readings/` | Historical consumption data |
| `realtime/` | Socket.IO gateway for live updates |
| `ingestion/` | IoT message ingestion pipeline |
| `alarms/` | Alert management |
| `worker/` | Background job processing (BullMQ) |
| `health/` | Health checks |
| `settings/` | System configuration |

### Frontend Pages (`/app/pages/`)

| Route | Purpose |
|-------|---------|
| `/` | Dashboard with map, stats, alerts |
| `/readings/` | Live readings table |
| `/subscriptions/` | Subscription management (core linking entity) |
| `/customers/` | Customer management |
| `/meters/` | Meter (Asset) management |
| `/devices/` | Device (IoT) management |
| `/profiles/` | Meter & Device profile configuration |
| `/iam/tenants/` | Tenant hierarchy management |
| `/iam/users/` | User management |
| `/alarms/` | Alarm monitoring |
| `/settings/` | System settings |

---

## 6. Business Rules

### Tenant Isolation
1. Child tenants **cannot** see parent or sibling tenant data
2. Parent tenants **can** manage child tenants
3. All data queries must respect `tenantPath` (ltree) hierarchy
4. "Una IoT" is the one and only root tenant

### User Access
1. Users are assigned to tenants with specific permissions
2. A user can belong to multiple tenants
3. RBAC controls module access
4. Default super admin: `iot@una.net.tr`

### Subscription Rules
1. A Subscription belongs to exactly 1 Customer
2. A Subscription can have only 1 **active** Meter at a time
3. A Subscription maintains history of past Meters
4. Address is stored on Subscription, not on other entities

### Meter/Device Rules
1. A Meter belongs to exactly 1 Tenant
2. A Meter may or may not be linked to a Subscription
3. A Meter may or may not have an attached Device
4. Device-Meter compatibility is enforced via Profiles

---

## 7. API Conventions

### Endpoint Patterns
```
GET    /api/{module}              # List with pagination
GET    /api/{module}/:id          # Get single
POST   /api/{module}              # Create
PATCH  /api/{module}/:id          # Update
DELETE /api/{module}/:id          # Delete
```

### Common Query Parameters
- `page`, `limit` - Pagination
- `tenantId` - Tenant filtering (auto-applied from auth)
- `status` - Status filtering
- `search` - Full-text search

### Response Format
```typescript
// List response
{ data: T[], meta: { total, page, limit } }

// Single response
{ data: T }

// Error response
{ statusCode: number, message: string, error: string }
```

---

## 8. Frontend Conventions

### Component Organization
```
/components/
  /{module}/           # Module-specific components
    CreateForm.vue     # Create/Edit form
    ...
  /ui/                 # Shadcn/Vue base components
  /layout/             # Layout components (Header, Sidebar)
```

### State Management (Pinia)
```
/stores/
  app.ts              # Global app state
  auth.ts             # Authentication state
  dashboard.ts        # Dashboard data
  devices.ts          # Device/Meter state
  readings.ts         # Readings state
```

### Composables
```
/composables/
  useApi.ts           # HTTP client wrapper
  useApiUrl.ts        # API URL helper
  useAuthInit.ts      # Auth initialization
  useToast.ts         # Toast notifications
```

---

## 9. Development Guidelines

### When Adding a New Module

1. **Backend:**
   - Create module in `/api/src/modules/{name}/`
   - Include: `*.module.ts`, `*.controller.ts`, `*.service.ts`, DTOs
   - Register in `app.module.ts`
   - Add Prisma models if needed

2. **Frontend:**
   - Create page in `/app/pages/{name}/`
   - Create components in `/app/components/{name}/`
   - Add store in `/app/stores/` if needed
   - Update navigation in Sidebar

### Code Style

- Use TypeScript strict mode
- Follow NestJS/Nuxt conventions
- Prefer Kysely for complex queries with ltree
- Use Prisma for simple CRUD
- All dates in ISO 8601 format
- Display dates as `DD.MM.YYYY HH:mm:ss` (24h)

### Testing

- Backend: Jest (unit + e2e in `/api/test/`)
- Frontend: Playwright (in `/app/tests/`)

---

## 10. Seed Data Reference

### Tenants
1. **Una IoT** (Root)
   - ASKİ (Ankara Su İdaresi)
   - HATSU (Hatay Su İdaresi)

### Users
| Email | Tenant | Role |
|-------|--------|------|
| iot@una.net.tr | Una IoT | Super Admin |
| aski.yetkili@example.com | ASKİ | Tenant Admin |
| hatsu.yetkili@example.com | HATSU | Tenant Admin |

Password for all: `Asdf1234.`

### Data Distribution
| Tenant | Customers | Subscriptions | Meters | Devices |
|--------|-----------|---------------|--------|---------|
| ASKİ | 100 | 128 | 100 | 100 |
| HATSU | 64 | 50 | 50 | 50 |

### Historical Data
- Duration: 45 days
- Frequency: 24 readings/day (hourly)
- Target: All linked devices

---

## 11. Quick Reference: File Locations

| Need to... | Location |
|------------|----------|
| Modify DB schema | `/api/prisma/schema.prisma` |
| Add backend module | `/api/src/modules/` |
| Add frontend page | `/app/pages/` |
| Add UI component | `/app/components/ui/` |
| Configure Docker | `/docker-compose.yml` |
| Check project rules | `/.cursorrules` |
| View API specs | `/api/README.md` |

---

## 12. Common Pitfalls to Avoid

1. ❌ **Do NOT** link Meters directly to Customers (use Subscriptions)
2. ❌ **Do NOT** store addresses on Customers, Meters, or Devices
3. ❌ **Do NOT** bypass tenant isolation in queries
4. ❌ **Do NOT** use Prisma for ltree queries (use Kysely)
5. ❌ **Do NOT** forget to check Profile compatibility for Device-Meter links
6. ❌ **Do NOT** create new abstractions for one-time operations

---

## 13. MCP Tools Available

This project has MCP servers configured for:

- **Database Context** (`read-water-api-context`): Prisma schema, architecture rules
- **Frontend Context** (`read-water-app-context`): Nuxt structure, file reading
- **Database Queries** (`readwater-db`): Direct SQL queries
- **Nuxt Documentation** (`nuxt`): Latest Nuxt 4 docs
- **Shadcn/Vue** (`shadcnVue`): Component library reference

Use these tools to understand the codebase before making changes.

---

*Last updated: December 2025*

