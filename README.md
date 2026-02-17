# Revenue Assurance Data Automation Platform

Enterprise-grade data automation platform for telecom revenue assurance operations.

## Architecture

```
                    ┌─────────────┐
                    │   Ingress   │
                    │  (NGINX/K8s)│
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  FastAPI    │
                    │  API Server │
                    └──┬───┬───┬──┘
                       │   │   │
          ┌────────────┘   │   └────────────┐
          ▼                ▼                ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │PostgreSQL│    │  Redis   │    │  Oracle  │
    │(Metadata)│    │ (Queue)  │    │  (DWH)   │
    └──────────┘    └────┬─────┘    └──────────┘
                         │
                    ┌────▼─────┐
                    │ Workers  │
                    │(Export/  │
                    │ Load/    │
                    │ Refresh) │
                    └──────────┘
```

## Services

| Service | Description |
|---------|-------------|
| API Gateway | FastAPI REST API with JWT auth and RBAC |
| Job Orchestrator | Job lifecycle, retry, timeout management |
| Oracle Export | Chunked Oracle table export to CSV |
| ETL Loader | CSV/Excel/PostgreSQL to Oracle via SQL*Loader |
| Dependency Engine | Oracle view/MV dependency graph analysis |
| MV Refresh | Parallel materialized view refresh by topo level |
| Metadata Service | Table configs, connection profiles, DQ rules |
| Audit Service | Immutable audit trail and error tracking |
| Scheduler | Cron-based job scheduling via APScheduler |
| Health/Metrics | Health checks, Prometheus metrics |

## Quick Start

```bash
# 1. Configure environment
cp .env.example .env.dev

# 2. Start all services
docker-compose --env-file .env.dev up -d

# 3. API docs (dev only)
open http://localhost:8000/api/docs
```

## Tech Stack

- **API**: FastAPI + Uvicorn + Gunicorn
- **Metadata DB**: PostgreSQL 16 + SQLAlchemy 2.0 (async)
- **Data Warehouse**: Oracle (oracledb + SQL*Loader)
- **Job Queue**: Redis 7
- **Auth**: JWT + bcrypt + RBAC (Admin/Operator/Viewer)
- **Logging**: structlog (JSON)
- **Metrics**: Prometheus
- **Container**: Docker + Kubernetes-ready
- **CI/CD**: GitHub Actions

## Project Structure

```
├── src/
│   ├── main.py              # FastAPI app factory
│   ├── config/              # Pydantic settings, logging
│   ├── core/                # Security, exceptions, retry, middleware
│   ├── db/                  # PostgreSQL, Oracle, Redis pools
│   ├── models/
│   │   ├── domain/          # SQLAlchemy ORM models
│   │   └── schemas/         # Pydantic API schemas
│   ├── repositories/        # Data access layer
│   ├── services/            # Business logic
│   ├── api/v1/endpoints/    # REST API endpoints
│   └── workers/             # Background job processors
├── migrations/              # PostgreSQL DDL
├── k8s/                     # Kubernetes manifests
├── ci/                      # CI/CD pipeline
├── tests/                   # Test suite
└── legacy/                  # Original scripts (reference)
```
