-- =============================================================================
-- Read Water - PostgreSQL Extensions Initialization
-- =============================================================================
-- This script runs automatically when the container starts for the first time.
-- It enables required extensions for the Read Water platform.
-- =============================================================================

-- Enable TimescaleDB extension for time-series data (Readings)
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- Enable ltree extension for hierarchical multi-tenancy (Tenants)
CREATE EXTENSION IF NOT EXISTS ltree;

-- Enable uuid-ossp for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgcrypto for password hashing and encryption
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Log successful initialization
DO $$
BEGIN
    RAISE NOTICE '=============================================================================';
    RAISE NOTICE 'Read Water - PostgreSQL Extensions Initialized Successfully';
    RAISE NOTICE '=============================================================================';
    RAISE NOTICE 'Enabled Extensions:';
    RAISE NOTICE '  - timescaledb: Time-series data for meter readings';
    RAISE NOTICE '  - ltree: Hierarchical multi-tenancy tree structure';
    RAISE NOTICE '  - uuid-ossp: UUID generation';
    RAISE NOTICE '  - pgcrypto: Encryption and hashing';
    RAISE NOTICE '=============================================================================';
END $$;

