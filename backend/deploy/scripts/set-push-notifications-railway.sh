#!/usr/bin/env bash
# Railway production: Firebase service account JSON'u PushNotifications__ServiceAccountJson olarak set eder.
#
# Kullanım:
#   ./set-push-notifications-railway.sh
#   ./set-push-notifications-railway.sh /path/to/service-account.json
#
# Önkoşul: railway CLI giriş yapılmış ve doğru projede olun.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_JSON="${SCRIPT_DIR}/../../secrets/firebase-service-account.json"
JSON_FILE="${1:-$DEFAULT_JSON}"

if [[ ! -f "$JSON_FILE" ]]; then
  echo "Service account dosyası bulunamadı: $JSON_FILE" >&2
  exit 1
fi

if ! command -v railway >/dev/null 2>&1; then
  echo "railway CLI bulunamadı. Manuel set için minified JSON:" >&2
  python3 -c "import json,sys; print(json.dumps(json.load(open(sys.argv[1]))))" "$JSON_FILE"
  exit 1
fi

MINIFIED_JSON="$(python3 -c "import json,sys; print(json.dumps(json.load(open(sys.argv[1]))))" "$JSON_FILE")"

railway variables set "PushNotifications__ServiceAccountJson=${MINIFIED_JSON}"

echo "PushNotifications__ServiceAccountJson Railway'e kaydedildi."
