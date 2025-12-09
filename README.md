# Read Water 💧

> High-performance, multi-tenant remote water meter reading platform capable of handling 1M+ concurrent requests.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Read Water Platform                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐                    │
│  │   IoT/MQTT  │────▶│   API       │────▶│   BullMQ    │                    │
│  │   Devices   │     │   Gateway   │     │   (Redis)   │                    │
│  └─────────────┘     └─────────────┘     └──────┬──────┘                    │
│                                                  │                           │
│                                                  ▼                           │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐                    │
│  │   Nuxt      │◀────│  Socket.IO  │◀────│   Worker    │                    │
│  │   Frontend  │     │   (Redis)   │     │   Service   │                    │
│  └─────────────┘     └─────────────┘     └──────┬──────┘                    │
│                                                  │                           │
│                                                  ▼                           │
│                                          ┌─────────────┐                    │
│                                          │ TimescaleDB │                    │
│                                          │  (ltree)    │                    │
│                                          └─────────────┘                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
ReadWater/
├── api/                    # NestJS Backend API
│   ├── src/
│   │   ├── modules/        # Feature modules
│   │   ├── common/         # Shared utilities
│   │   └── config/         # Configuration
│   └── prisma/             # Database schema & migrations
├── app/                    # Nuxt Frontend Application
│   ├── components/         # Vue components
│   ├── pages/              # Route pages
│   ├── stores/             # Pinia stores
│   └── composables/        # Vue composables
├── docker/                 # Docker configurations
│   └── postgres/
│       └── init/           # PostgreSQL init scripts
├── docker-compose.yml      # Docker services
├── .env.example            # Environment template
└── README.md
```

## 🛠️ Tech Stack

### Infrastructure
- **Database:** TimescaleDB (PostgreSQL 16 + TimescaleDB + ltree)
- **Cache/Queue:** Redis
- **Containerization:** Docker & Docker Compose

### Backend (`/api`)
- **Framework:** NestJS
- **ORM:** Prisma 6
- **Query Builder:** Kysely (for TimescaleDB analytics)
- **Queue:** BullMQ
- **Real-time:** Socket.IO with Redis Streams Adapter
- **Validation:** class-validator & class-transformer

### Frontend (`/app`)
- **Framework:** Nuxt 3
- **State Management:** Pinia
- **UI:** Shadcn/UI + TailwindCSS
- **Charts:** ApexCharts
- **Maps:** Leaflet
- **Real-time:** Socket.IO Client

## 🚀 Getting Started

### Prerequisites
- Docker & Docker Compose
- Node.js 20+ (LTS)
- pnpm (recommended) or npm

### 1. Clone & Setup Environment

```bash
# Clone the repository
git clone <repository-url>
cd ReadWater

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
```

### 2. Start Infrastructure

```bash
# Start TimescaleDB and Redis
docker compose up -d

# With development tools (Redis Insight)
docker compose --profile dev up -d
```

### 3. Verify Services

```bash
# Check running containers
docker compose ps

# Check TimescaleDB extensions
docker exec -it readwater-timescaledb psql -U readwater -d readwater -c "SELECT * FROM pg_extension;"
```

### 4. Development

```bash
# Install API dependencies
cd api && pnpm install

# Run database migrations
pnpm prisma migrate dev

# Start API development server
pnpm dev

# In another terminal - Install App dependencies
cd app && pnpm install

# Start frontend development server
pnpm dev
```

## 🔧 Service Ports

| Service | Port | Description |
|---------|------|-------------|
| TimescaleDB | 5433 | PostgreSQL database (mapped from 5432) |
| Redis | 6380 | Cache & Queue (mapped from 6379) |
| Redis Insight | 5540 | Redis GUI (dev profile) |
| API | 4000 | NestJS Backend |
| App | 3000 | Nuxt Frontend |
| Socket.IO | 4000 | Real-time events (/realtime namespace) |

## 🎨 Frontend Features

### Pages & Modules
- **Dashboard:** Real-time stats, Leaflet map with meter locations, active alarms
- **Live Readings:** Socket.IO powered real-time readings table
- **Customers:** CRUD with dynamic fields (Individual vs Organizational)
- **Meters:** CRUD with **dynamic connectivity form** based on selected technology
- **Profiles:** Meter model management with decoder functions
- **IAM:** Hierarchical tenant tree view and user management
- **Decoder Functions:** Read-only view (edit via Profiles)
- **Settings:** Platform configuration and white labeling

### Dynamic Meter Connectivity Form
When creating a meter, the form dynamically renders fields based on the selected communication technology:

| Technology | Dynamic Fields |
|------------|----------------|
| LoRaWAN | DevEUI (16 hex), JoinEUI (16 hex), AppKey (32 hex) |
| Sigfox | ID (8 hex), PAC (16 hex) |
| NB-IoT | IMEI (15 digits), IMSI (15 digits) |
| wM-Bus | ManufacturerId (3 chars), DeviceId (8 hex) |

Each field includes regex validation as defined in Section 6.8 of the specifications.

## 🏢 Multi-Tenancy

The platform uses PostgreSQL's `ltree` extension for hierarchical multi-tenancy:

```
Root
├── Region_A
│   ├── City_1
│   └── City_2
└── Region_B
    └── City_3
```

Tenant paths are stored as `ltree` types (e.g., `Root.Region_A.City_1`), enabling efficient hierarchical queries and data isolation.

## 📊 High-Concurrency Ingestion Flow

1. **Ingest:** IoT device sends reading → API Gateway
2. **Buffer:** API validates → Pushes to BullMQ (Redis)
3. **Process:** Worker picks up job
4. **Decode:** Execute decoder function (JS expression from Meter Profile)
5. **Persist:** Bulk insert to TimescaleDB
6. **Notify:** Publish event via Socket.IO → Connected clients

## 🌍 Internationalization (i18n)

The platform supports multiple languages using `@nuxtjs/i18n`:

### Supported Languages
| Code | Language | Flag |
|------|----------|------|
| `en` | English (default) | 🇺🇸 |
| `tr` | Turkish | 🇹🇷 |
| `fr` | French | 🇫🇷 |

### Switching Languages

**In the UI:**
1. Open the sidebar navigation
2. Click on the language button (shows current language name)
3. Select desired language from the dropdown

**Programmatically:**
```javascript
const { setLocale } = useI18n()
setLocale('tr') // Switch to Turkish
```

**Via URL (if using prefix strategy):**
- English: `http://localhost:3000/en/dashboard`
- Turkish: `http://localhost:3000/tr/dashboard`
- French: `http://localhost:3000/fr/dashboard`

### Adding New Translations
1. Create a new locale file: `app/locales/{code}.json`
2. Add the locale to `nuxt.config.ts`:
```typescript
i18n: {
  locales: [
    // ... existing locales
    { code: 'de', name: 'Deutsch', file: 'de.json' },
  ],
}
```

## 🧪 Load Testing & Traffic Simulation

The platform includes a built-in traffic simulator to test the high-concurrency ingestion pipeline.

### Running the Simulator

```bash
cd api

# Default: 100 meters, 50 RPS, 60 seconds
npm run simulate

# Light load: 10 meters, 5 RPS, 30 seconds
npm run simulate:light

# Heavy load: 500 meters, 100 RPS, 120 seconds
npm run simulate:heavy

# Custom configuration
npx ts-node scripts/simulate-traffic.ts --meters=200 --rps=75 --duration=90
```

### Simulator Options

| Option | Default | Description |
|--------|---------|-------------|
| `--meters` | 100 | Number of unique simulated meters |
| `--rps` | 50 | Requests per second target |
| `--duration` | 60 | Duration in seconds |
| `--url` | http://localhost:4000 | API base URL |

### What It Tests

The simulator sends mock readings to the ingestion endpoint, which tests the entire data pipeline:

```
Simulator → HTTP POST /api/v1/ingest → BullMQ Queue → Worker Processor → TimescaleDB → Socket.IO → Frontend
```

### Monitoring During Simulation

1. **Frontend Live Readings Page:** Watch readings appear in real-time
2. **Dashboard Charts:** See consumption data update
3. **Terminal Output:** Monitor RPS, latency, and success rate
4. **Redis Insight:** Watch queue activity (if using dev profile)

### Sample Output

```
╔════════════════════════════════════════════════════════════════╗
║          Read Water - Traffic Simulator 🌊                     ║
╠════════════════════════════════════════════════════════════════╣
║  Meters: 100        │ RPS Target: 50                           ║
║  Duration: 60s      │ API: http://localhost:4000               ║
╚════════════════════════════════════════════════════════════════╝

📊 Sent: 3000 | Success: 2985 | Failed: 15 | RPS: 49.8 | Avg Latency: 12ms

╔════════════════════════════════════════════════════════════════╗
║                    Simulation Complete! ✅                     ║
╠════════════════════════════════════════════════════════════════╣
║  Total Requests:   3000                                        ║
║  Successful:       2985       (99.5%)                          ║
║  Failed:           15                                          ║
║  Actual RPS:       49.8                                        ║
║  Avg Latency:      12ms                                        ║
║  Total Time:       60.2s                                       ║
╚════════════════════════════════════════════════════════════════╝
```

## 📝 License

[MIT](LICENSE)

