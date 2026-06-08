#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-dev}"
POSTGRES_DB="${POSTGRES_DB:-cardence}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

if command -v docker >/dev/null 2>&1; then
  echo "Starting PostgreSQL via Docker Compose..."
  docker compose up -d
  echo "Waiting for database..."
  docker compose exec -T postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"
  echo "PostgreSQL is ready on localhost:${POSTGRES_PORT}"
  exit 0
fi

if command -v brew >/dev/null 2>&1 && brew list postgresql@16 >/dev/null 2>&1; then
  export PATH="/opt/homebrew/opt/postgresql@16/bin:/usr/local/opt/postgresql@16/bin:$PATH"
  echo "Starting PostgreSQL via Homebrew..."
  brew services start postgresql@16
  sleep 2

  if ! psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d postgres -c '\q' 2>/dev/null; then
    createuser -s "$POSTGRES_USER" 2>/dev/null || true
    psql -h localhost -p "$POSTGRES_PORT" -d postgres -v ON_ERROR_STOP=1 <<-SQL
      ALTER USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';
      SELECT 'CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER}'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${POSTGRES_DB}')\gexec
    SQL
  fi

  echo "PostgreSQL is ready on localhost:${POSTGRES_PORT}"
  exit 0
fi

cat <<'MSG'
PostgreSQL could not be started.

Option A — Docker (recommended):
  1. Install Docker Desktop
  2. cd backend/database && cp .env.example .env
  3. ./scripts/start.sh

Option B — Homebrew:
  brew install postgresql@16
  ./scripts/start.sh
MSG
exit 1
