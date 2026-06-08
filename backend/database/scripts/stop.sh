#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if command -v docker >/dev/null 2>&1 && docker compose ps -q postgres 2>/dev/null | grep -q .; then
  docker compose down
  echo "PostgreSQL container stopped."
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  brew services stop postgresql@16 2>/dev/null || true
  echo "Homebrew PostgreSQL stopped (if it was running)."
fi
