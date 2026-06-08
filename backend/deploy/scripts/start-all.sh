#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

./scripts/start-api.sh
./scripts/start-tunnel.sh

echo ""
echo "Doğrula: curl https://cardenceapi.app/health/ready"
