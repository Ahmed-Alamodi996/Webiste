# ============================================================
# Revenue Assurance Platform - Multi-stage Production Dockerfile
# ============================================================

# --- Stage 1: Builder ---
FROM python:3.12-slim as builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libaio1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# --- Stage 2: Production ---
FROM python:3.12-slim as production

LABEL maintainer="RA Platform Team"
LABEL version="1.0.0"
LABEL description="Revenue Assurance Data Automation Platform"

# Oracle Instant Client prerequisite
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    libaio1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Non-root user for security
RUN groupadd -r raplatform && useradd -r -g raplatform -d /app -s /sbin/nologin raplatform

WORKDIR /app

COPY --from=builder /install /usr/local

COPY src/ ./src/
COPY migrations/ ./migrations/
COPY alembic.ini .

RUN mkdir -p /data/ra-exports /data/ra-backups /data/ra-ctl /app/logs \
    && chown -R raplatform:raplatform /app /data

USER raplatform

ENV PYTHONPATH=/app \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health || exit 1

EXPOSE 8000

# Default: run API server. Override in docker-compose for workers.
CMD ["gunicorn", "src.main:app", \
     "--worker-class", "uvicorn.workers.UvicornWorker", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "4", \
     "--timeout", "120", \
     "--access-logfile", "-", \
     "--error-logfile", "-"]
