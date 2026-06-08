#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND="$(cd "$ROOT/.." && pwd)"
DOMAIN="cardenceapi.app"
TUNNEL_NAME="cardence-api"
CF_CONFIG_DIR="${HOME}/.cloudflared"
CF_CONFIG="${CF_CONFIG_DIR}/config-cardence.yml"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "cloudflared bulunamadı. Kurulum: brew install cloudflared"
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker bulunamadı."
  exit 1
fi

echo "==> 1/4 API container başlatılıyor (port 8080)..."
cd "$ROOT"
docker compose up -d --build

echo "==> API health bekleniyor..."
for i in $(seq 1 30); do
  if curl -sf http://localhost:8080/health/ready >/dev/null 2>&1; then
    echo "    API hazır: http://localhost:8080"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "API health check başarısız. Log: docker compose -f $ROOT/docker-compose.yml logs api"
    exit 1
  fi
  sleep 2
done

if [ ! -f "${CF_CONFIG_DIR}/cert.pem" ]; then
  echo ""
  echo "==> 2/4 Cloudflare hesabına giriş (tarayıcı açılacak)..."
  echo "    Domain Cloudflare'da görünmeli: ${DOMAIN}"
  cloudflared tunnel login
fi

echo "==> 3/4 Tunnel oluşturuluyor: ${TUNNEL_NAME}"
if ! cloudflared tunnel list 2>/dev/null | grep -q "${TUNNEL_NAME}"; then
  cloudflared tunnel create "${TUNNEL_NAME}"
fi

TUNNEL_ID="$(cloudflared tunnel list 2>/dev/null | awk -v name="$TUNNEL_NAME" '$0 ~ name {print $1; exit}')"
if [ -z "${TUNNEL_ID}" ]; then
  echo "Tunnel ID alınamadı."
  exit 1
fi

CREDS="${CF_CONFIG_DIR}/${TUNNEL_ID}.json"
if [ ! -f "${CREDS}" ]; then
  echo "Credentials dosyası bulunamadı: ${CREDS}"
  exit 1
fi

echo "==> DNS kayıtları: ${DOMAIN}"
cloudflared tunnel route dns --overwrite-dns "${TUNNEL_NAME}" "${DOMAIN}" 2>/dev/null || true
cloudflared tunnel route dns --overwrite-dns "${TUNNEL_NAME}" "www.${DOMAIN}" 2>/dev/null || true

sed "s|CREDENTIALS_PATH_PLACEHOLDER|${CREDS}|g" \
  "${ROOT}/cloudflare/config.yml" > "${CF_CONFIG}"

echo ""
echo "==> 4/4 Tunnel başlatılıyor..."
echo "    https://${DOMAIN} → http://localhost:8080"
echo "    Durdurmak için: Ctrl+C"
echo ""

exec cloudflared tunnel --config "${CF_CONFIG}" run "${TUNNEL_NAME}"
