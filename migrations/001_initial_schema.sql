-- ============================================================
-- Revenue Assurance Data Automation Platform
-- PostgreSQL Metadata Schema - Initial Migration
-- ============================================================
-- Target: PostgreSQL 16+
-- Schema: ra_meta (isolated namespace)
-- ============================================================

BEGIN;

-- Create dedicated schema
CREATE SCHEMA IF NOT EXISTS ra_meta;

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- 1. USERS (Authentication & RBAC)
-- ============================================================
CREATE TABLE ra_meta.users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username        VARCHAR(100) NOT NULL UNIQUE,
    email           VARCHAR(255) NOT NULL UNIQUE,
    hashed_password TEXT NOT NULL,
    full_name       VARCHAR(255) NOT NULL,
    role            VARCHAR(50) NOT NULL DEFAULT 'viewer'
                    CHECK (role IN ('admin', 'operator', 'viewer')),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login      TIMESTAMPTZ
);

CREATE INDEX idx_users_username ON ra_meta.users (username);
CREATE INDEX idx_users_role ON ra_meta.users (role);

-- ============================================================
-- 2. CONNECTION PROFILES (No Hardcoded Credentials)
-- ============================================================
CREATE TABLE ra_meta.connection_profiles (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    db_type         VARCHAR(30) NOT NULL CHECK (db_type IN ('oracle', 'postgresql')),
    host            VARCHAR(255) NOT NULL,
    port            INTEGER NOT NULL,
    database_name   VARCHAR(255) NOT NULL,
    username        VARCHAR(255) NOT NULL,
    password_env_var VARCHAR(255) NOT NULL,  -- References env var, NOT plaintext
    extra_params    JSONB DEFAULT '{}'::jsonb,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 3. TABLE CONFIGURATION (Replaces data_mapping.xlsx)
-- ============================================================
CREATE TABLE ra_meta.table_config (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                    VARCHAR(255) NOT NULL,
    source_type             VARCHAR(30) NOT NULL
                            CHECK (source_type IN ('postgres', 'csv', 'excel', 'oracle')),
    source_connection_id    UUID REFERENCES ra_meta.connection_profiles(id),
    source_table_name       VARCHAR(500) NOT NULL,
    source_columns          TEXT NOT NULL,
    where_condition         TEXT,
    destination_connection_id UUID REFERENCES ra_meta.connection_profiles(id),
    destination_table_name  VARCHAR(500) NOT NULL,
    destination_columns     TEXT NOT NULL,
    date_format             VARCHAR(50),
    date_column             VARCHAR(255),
    schedule_day            INTEGER CHECK (schedule_day BETWEEN 1 AND 31),
    skip_rows               INTEGER NOT NULL DEFAULT 0,
    file_name_pattern       VARCHAR(500),
    file_extension_filter   VARCHAR(50),
    backup_folder           VARCHAR(500),
    is_enabled              BOOLEAN NOT NULL DEFAULT TRUE,
    config_json             JSONB DEFAULT '{}'::jsonb,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_table_config_name ON ra_meta.table_config (name);
CREATE INDEX idx_table_config_source_type ON ra_meta.table_config (source_type);
CREATE INDEX idx_table_config_enabled ON ra_meta.table_config (is_enabled);

-- ============================================================
-- 4. JOBS (Job Definitions)
-- ============================================================
CREATE TABLE ra_meta.jobs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(255) NOT NULL UNIQUE,
    job_type        VARCHAR(50) NOT NULL
                    CHECK (job_type IN ('export', 'load', 'refresh', 'dependency_scan')),
    description     TEXT,
    schedule_cron   VARCHAR(100),
    config          JSONB DEFAULT '{}'::jsonb,
    is_enabled      BOOLEAN NOT NULL DEFAULT TRUE,
    max_retries     INTEGER NOT NULL DEFAULT 3,
    timeout_seconds INTEGER NOT NULL DEFAULT 3600,
    created_by      UUID REFERENCES ra_meta.users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_jobs_type ON ra_meta.jobs (job_type);
CREATE INDEX idx_jobs_enabled ON ra_meta.jobs (is_enabled);

-- ============================================================
-- 5. JOB RUNS (Execution Instances)
-- ============================================================
CREATE TABLE ra_meta.job_runs (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id              UUID NOT NULL REFERENCES ra_meta.jobs(id),
    status              VARCHAR(30) NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'running', 'success', 'failed', 'timeout', 'cancelled')),
    triggered_by        VARCHAR(50) DEFAULT 'scheduler',
    started_at          TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    duration_seconds    NUMERIC(12, 3),
    records_processed   BIGINT DEFAULT 0,
    records_failed      BIGINT DEFAULT 0,
    error_message       TEXT,
    retry_count         INTEGER DEFAULT 0,
    metadata_json       JSONB DEFAULT '{}'::jsonb,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_job_runs_job_id ON ra_meta.job_runs (job_id);
CREATE INDEX idx_job_runs_status ON ra_meta.job_runs (status);
CREATE INDEX idx_job_runs_started_at ON ra_meta.job_runs (started_at DESC);

-- Partial index for active runs (performance optimization for large tables)
CREATE INDEX idx_job_runs_active ON ra_meta.job_runs (job_id, status)
    WHERE status IN ('pending', 'running');

-- ============================================================
-- 6. JOB STEPS (Granular Step Tracking)
-- ============================================================
CREATE TABLE ra_meta.job_steps (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_run_id          UUID NOT NULL REFERENCES ra_meta.job_runs(id) ON DELETE CASCADE,
    step_name           VARCHAR(255) NOT NULL,
    step_order          INTEGER NOT NULL,
    status              VARCHAR(30) DEFAULT 'pending'
                        CHECK (status IN ('pending', 'running', 'success', 'failed', 'skipped')),
    started_at          TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    duration_seconds    NUMERIC(12, 3),
    records_in          BIGINT DEFAULT 0,
    records_out         BIGINT DEFAULT 0,
    error_message       TEXT,
    metadata_json       JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_job_steps_run_id ON ra_meta.job_steps (job_run_id);

-- ============================================================
-- 7. DEPENDENCY GRAPH (View/MV Dependencies)
-- ============================================================
CREATE TABLE ra_meta.dependency_graph (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    object_name     VARCHAR(255) NOT NULL,
    object_type     VARCHAR(50) NOT NULL
                    CHECK (object_type IN ('VIEW', 'MATERIALIZED VIEW', 'TABLE')),
    depends_on      VARCHAR(255) NOT NULL,
    depends_on_type VARCHAR(50) NOT NULL,
    topo_level      INTEGER,
    scan_run_id     UUID,
    scanned_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dep_graph_object ON ra_meta.dependency_graph (object_name);
CREATE INDEX idx_dep_graph_depends ON ra_meta.dependency_graph (depends_on);
CREATE INDEX idx_dep_graph_scan ON ra_meta.dependency_graph (scan_run_id);

-- Unique constraint: one edge per scan
CREATE UNIQUE INDEX idx_dep_graph_unique_edge
    ON ra_meta.dependency_graph (object_name, depends_on, scan_run_id);

-- ============================================================
-- 8. MV REFRESH STATUS
-- ============================================================
CREATE TABLE ra_meta.mv_refresh_status (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mv_name             VARCHAR(255) NOT NULL,
    refresh_type        VARCHAR(20) DEFAULT 'COMPLETE'
                        CHECK (refresh_type IN ('COMPLETE', 'FAST', 'FORCE')),
    status              VARCHAR(30) NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'running', 'success', 'failed', 'timeout', 'skipped')),
    topo_level          INTEGER,
    job_run_id          UUID,
    started_at          TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    duration_seconds    NUMERIC(12, 3),
    error_message       TEXT,
    retry_count         INTEGER DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_mv_refresh_name ON ra_meta.mv_refresh_status (mv_name);
CREATE INDEX idx_mv_refresh_status ON ra_meta.mv_refresh_status (status);
CREATE INDEX idx_mv_refresh_job_run ON ra_meta.mv_refresh_status (job_run_id);

-- ============================================================
-- 9. AUDIT LOGS (Immutable Audit Trail)
-- ============================================================
CREATE TABLE ra_meta.audit_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timestamp       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id         UUID,
    username        VARCHAR(100),
    action          VARCHAR(100) NOT NULL,
    resource_type   VARCHAR(100),
    resource_id     VARCHAR(255),
    details         JSONB DEFAULT '{}'::jsonb,
    ip_address      VARCHAR(45),
    user_agent      VARCHAR(500)
);

CREATE INDEX idx_audit_timestamp ON ra_meta.audit_logs (timestamp DESC);
CREATE INDEX idx_audit_action ON ra_meta.audit_logs (action);
CREATE INDEX idx_audit_user ON ra_meta.audit_logs (user_id);
CREATE INDEX idx_audit_resource ON ra_meta.audit_logs (resource_type, resource_id);

-- Partition by month for large-scale audit retention
-- (In production, convert to partitioned table for 100M+ rows)

-- ============================================================
-- 10. ERROR LOGS (Structured Error Tracking)
-- ============================================================
CREATE TABLE ra_meta.error_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timestamp       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    error_code      VARCHAR(100) NOT NULL,
    severity        VARCHAR(20) NOT NULL DEFAULT 'error'
                    CHECK (severity IN ('warning', 'error', 'critical')),
    source_service  VARCHAR(100) NOT NULL,
    job_run_id      UUID,
    message         TEXT NOT NULL,
    stack_trace     TEXT,
    context         JSONB DEFAULT '{}'::jsonb,
    resolved        BOOLEAN DEFAULT FALSE,
    resolved_by     VARCHAR(100),
    resolved_at     TIMESTAMPTZ
);

CREATE INDEX idx_error_timestamp ON ra_meta.error_logs (timestamp DESC);
CREATE INDEX idx_error_code ON ra_meta.error_logs (error_code);
CREATE INDEX idx_error_severity ON ra_meta.error_logs (severity);
CREATE INDEX idx_error_job_run ON ra_meta.error_logs (job_run_id);
CREATE INDEX idx_error_unresolved ON ra_meta.error_logs (resolved) WHERE resolved = FALSE;

-- ============================================================
-- 11. SLA POLICIES
-- ============================================================
CREATE TABLE ra_meta.sla_policies (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                        VARCHAR(255) NOT NULL UNIQUE,
    job_type                    VARCHAR(50) NOT NULL,
    max_duration_minutes        INTEGER NOT NULL,
    max_failure_rate_percent    NUMERIC(5, 2),
    min_records_threshold       INTEGER,
    alert_on_breach             BOOLEAN DEFAULT TRUE,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sla_policies_type ON ra_meta.sla_policies (job_type);

-- ============================================================
-- 12. SLA TRACKING
-- ============================================================
CREATE TABLE ra_meta.sla_tracking (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sla_policy_id               UUID NOT NULL REFERENCES ra_meta.sla_policies(id),
    job_run_id                  UUID NOT NULL,
    expected_duration_minutes   INTEGER NOT NULL,
    actual_duration_minutes     NUMERIC(10, 2),
    is_breached                 BOOLEAN DEFAULT FALSE,
    breach_reason               TEXT,
    breach_details              JSONB DEFAULT '{}'::jsonb,
    evaluated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sla_tracking_job_run ON ra_meta.sla_tracking (job_run_id);
CREATE INDEX idx_sla_tracking_breached ON ra_meta.sla_tracking (is_breached) WHERE is_breached = TRUE;

-- ============================================================
-- 13. DATA QUALITY RULES
-- ============================================================
CREATE TABLE ra_meta.data_quality_rules (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_config_id UUID NOT NULL,
    rule_name       VARCHAR(255) NOT NULL,
    rule_type       VARCHAR(50) NOT NULL
                    CHECK (rule_type IN ('not_null', 'unique', 'range', 'regex', 'row_count', 'custom')),
    column_name     VARCHAR(255),
    rule_expression TEXT NOT NULL,
    severity        VARCHAR(20) DEFAULT 'warning'
                    CHECK (severity IN ('warning', 'error', 'critical')),
    is_enabled      BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dq_rules_table ON ra_meta.data_quality_rules (table_config_id);

-- ============================================================
-- TRIGGER: Auto-update updated_at timestamps
-- ============================================================
CREATE OR REPLACE FUNCTION ra_meta.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON ra_meta.users
    FOR EACH ROW EXECUTE FUNCTION ra_meta.update_updated_at();

CREATE TRIGGER trg_jobs_updated_at
    BEFORE UPDATE ON ra_meta.jobs
    FOR EACH ROW EXECUTE FUNCTION ra_meta.update_updated_at();

CREATE TRIGGER trg_table_config_updated_at
    BEFORE UPDATE ON ra_meta.table_config
    FOR EACH ROW EXECUTE FUNCTION ra_meta.update_updated_at();

-- ============================================================
-- SEED DATA: Default admin user (password: change_me_immediately)
-- bcrypt hash of 'change_me_immediately'
-- ============================================================
INSERT INTO ra_meta.users (username, email, hashed_password, full_name, role)
VALUES (
    'admin',
    'admin@ra-platform.local',
    '$2b$12$LJ3m4ys3Lz0YOV7eFZQaZuHFGmHH1cd7/YcK.q3Xz2aOhXWnXmVi6',
    'Platform Administrator',
    'admin'
) ON CONFLICT (username) DO NOTHING;

-- ============================================================
-- SEED DATA: Default SLA Policies
-- ============================================================
INSERT INTO ra_meta.sla_policies (name, job_type, max_duration_minutes, alert_on_breach)
VALUES
    ('Export SLA', 'export', 30, TRUE),
    ('Load SLA', 'load', 60, TRUE),
    ('Refresh SLA', 'refresh', 120, TRUE),
    ('Dependency Scan SLA', 'dependency_scan', 15, TRUE)
ON CONFLICT (name) DO NOTHING;

COMMIT;
