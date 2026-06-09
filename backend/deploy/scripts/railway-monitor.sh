#!/usr/bin/env bash
set -euo pipefail

API_URL="${API_URL:-https://cardenceapi.app}"
MONITORING_KEY="${MONITORING_KEY:-}"

echo "==> Cardence Railway izleme"
echo "    API: ${API_URL}"
echo

echo "==> /health/ready (Railway healthcheck — API + PostgreSQL)"
curl -fsS "${API_URL}/health/ready" | python3 -m json.tool
echo

echo "==> /health/status (genel durum)"
if [[ -n "${MONITORING_KEY}" ]]; then
  curl -fsS "${API_URL}/health/status" \
    -H "X-Monitoring-Key: ${MONITORING_KEY}" | python3 -m json.tool
else
  echo "    (Tablo sayıları için: MONITORING_KEY=... ./railway-monitor.sh)"
  curl -fsS "${API_URL}/health/status" | python3 -m json.tool
fi
