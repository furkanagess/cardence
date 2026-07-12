#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_ROOT="$(cd "$ROOT/.." && pwd)"
API_URL="${API_URL:-https://cardenceapi.app}"
SWAGGER_URL="${API_URL%/}/swagger/v1/swagger.json"
HEALTH_URL="${API_URL%/}/health/ready"
WAIT_SECONDS="${WAIT_SECONDS:-90}"

usage() {
  cat <<'EOF'
Cardence API deploy

Kullanım:
  ./deploy.sh railway [--detach]   Production'a Railway CLI ile deploy (önerilen)
  ./deploy.sh local                Local Docker API (localhost:8080)
  ./deploy.sh verify               Deploy sonrası health + swagger kontrolü

Railway (ilk kurulum):
  npm i -g @railway/cli   # veya: brew install railway
  cd backend && railway login
  railway link            # cardence API servisini seç

Örnek:
  cd backend/deploy
  ./scripts/deploy.sh railway
  ./scripts/deploy.sh verify

Notlar:
  - Railway Dashboard → Root Directory: backend
  - Builder: Dockerfile, Config: /backend/railway.toml
  - Detay: backend/docs/deployment-cardenceapi.app.md
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Hata: '$1' bulunamadı." >&2
    exit 1
  fi
}

verify_deploy() {
  echo "==> Health: $HEALTH_URL"
  local health_code
  health_code="$(curl -s -o /tmp/cardence_health.json -w '%{http_code}' "$HEALTH_URL" || true)"
  if [[ "$health_code" != "200" ]]; then
    echo "Health check başarısız (HTTP $health_code)" >&2
    cat /tmp/cardence_health.json 2>/dev/null || true
    exit 1
  fi
  echo "OK (HTTP 200)"

  echo "==> Swagger: $SWAGGER_URL"
  local swagger_code
  swagger_code="$(curl -s -o /tmp/cardence_swagger.json -w '%{http_code}' "$SWAGGER_URL" || true)"
  if [[ "$swagger_code" != "200" ]]; then
    echo "Swagger check başarısız (HTTP $swagger_code)" >&2
    head -c 500 /tmp/cardence_swagger.json 2>/dev/null || true
    echo "" >&2
    exit 1
  fi
  echo "OK (HTTP 200)"
  echo ""
  echo "Deploy doğrulandı."
  echo "Swagger UI: ${API_URL%/}/swagger"
}

deploy_railway() {
  require_cmd railway

  local detach_flag=()
  if [[ "${1:-}" == "--detach" ]]; then
    detach_flag=(--detach)
  fi

  echo "==> Railway deploy başlıyor (kök: $BACKEND_ROOT)"
  cd "$BACKEND_ROOT"

  if [[ ! -f "$BACKEND_ROOT/railway.toml" ]]; then
    echo "Hata: backend/railway.toml bulunamadı." >&2
    exit 1
  fi

  railway up "${detach_flag[@]}"

  echo ""
  echo "==> Deploy tetiklendi. Sağlık kontrolü bekleniyor (${WAIT_SECONDS}s)..."
  local elapsed=0
  while (( elapsed < WAIT_SECONDS )); do
    if curl -sf "$HEALTH_URL" >/dev/null 2>&1; then
      break
    fi
    sleep 5
    elapsed=$((elapsed + 5))
    echo "   ... ${elapsed}s"
  done

  verify_deploy
}

deploy_local() {
  echo "==> Local Docker deploy"
  "$ROOT/scripts/start-api.sh"
  API_URL="http://localhost:8080" \
  SWAGGER_URL="http://localhost:8080/swagger/v1/swagger.json" \
  HEALTH_URL="http://localhost:8080/health/ready" \
  verify_deploy
}

main() {
  local target="${1:-railway}"

  case "$target" in
    -h|--help|help)
      usage
      ;;
    railway)
      shift || true
      deploy_railway "${1:-}"
      ;;
    local)
      deploy_local
      ;;
    verify|check)
      verify_deploy
      ;;
    *)
      echo "Bilinmeyen komut: $target" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
