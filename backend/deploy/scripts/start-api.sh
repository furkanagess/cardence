#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
docker compose up -d --build
echo "API: http://localhost:8080"
echo "Health: http://localhost:8080/health/ready"
