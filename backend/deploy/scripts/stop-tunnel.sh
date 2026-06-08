#!/usr/bin/env bash
set -euo pipefail

PID_FILE="${HOME}/.cloudflared/cardence-tunnel.pid"

if [ -f "${PID_FILE}" ]; then
  PID="$(cat "${PID_FILE}")"
  if kill -0 "${PID}" 2>/dev/null; then
    kill "${PID}"
    echo "Tunnel durduruldu (pid ${PID})"
  else
    echo "PID dosyası var ama süreç çalışmıyor."
  fi
  rm -f "${PID_FILE}"
else
  pkill -f "cloudflared tunnel.*config-cardence.yml run cardence-api" 2>/dev/null \
    && echo "Tunnel süreci sonlandırıldı." \
    || echo "Çalışan tunnel bulunamadı."
fi
