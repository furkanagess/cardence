#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

TUNNEL_NAME="cardence-api"
CF_CONFIG="${HOME}/.cloudflared/config-cardence.yml"
LOG_DIR="${HOME}/.cloudflared/logs"
PID_FILE="${HOME}/.cloudflared/cardence-tunnel.pid"

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "cloudflared bulunamadı: brew install cloudflared"
  exit 1
fi

if [ ! -f "${CF_CONFIG}" ]; then
  echo "Tunnel config yok. Önce: ./scripts/connect-domain.sh"
  exit 1
fi

if [ -f "${PID_FILE}" ]; then
  OLD_PID="$(cat "${PID_FILE}")"
  if kill -0 "${OLD_PID}" 2>/dev/null; then
    echo "Tunnel zaten çalışıyor (pid ${OLD_PID})"
    exit 0
  fi
  rm -f "${PID_FILE}"
fi

mkdir -p "${LOG_DIR}"
nohup cloudflared tunnel --config "${CF_CONFIG}" run "${TUNNEL_NAME}" \
  >> "${LOG_DIR}/cardence-api.log" 2>&1 &
echo $! > "${PID_FILE}"

echo "Tunnel arka planda başlatıldı (pid $(cat "${PID_FILE}"))"
echo "Log: ${LOG_DIR}/cardence-api.log"
echo "Durdurmak için: ./scripts/stop-tunnel.sh"
