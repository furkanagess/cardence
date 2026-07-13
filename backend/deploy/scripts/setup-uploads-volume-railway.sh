#!/usr/bin/env bash
# Railway production: kalıcı medya depolama (Volume + ObjectStorage env).
#
# Profil ve etkinlik fotoğrafları /app/uploads volume'unda kalır; deploy sonrası silinmez.
#
# Kullanım:
#   ./setup-uploads-volume-railway.sh
#
# Önkoşul: railway CLI giriş yapılmış ve cardence API servisine linkli olun.

set -euo pipefail

MOUNT_PATH="/app/uploads"
VOLUME_NAME="cardence-volume"

if ! command -v railway >/dev/null 2>&1; then
  echo "railway CLI bulunamadı. Manuel adımlar:" >&2
  echo "  1. Railway Dashboard → cardence servisi → Volumes → Add Volume" >&2
  echo "  2. Mount path: ${MOUNT_PATH}" >&2
  echo "  3. Variables:" >&2
  echo "     ObjectStorage__Provider=local" >&2
  echo "     ObjectStorage__LocalRootPath=${MOUNT_PATH}" >&2
  echo "     RAILWAY_RUN_UID=0" >&2
  exit 1
fi

echo "Railway volume kontrol ediliyor..."
if railway volume list 2>/dev/null | grep -q "Mount path: ${MOUNT_PATH}"; then
  echo "Volume zaten ${MOUNT_PATH} yoluna mount edilmiş."
else
  echo "Volume oluşturuluyor: ${VOLUME_NAME} → ${MOUNT_PATH}"
  railway volume add --mount-path "${MOUNT_PATH}"
fi

echo "ObjectStorage değişkenleri ayarlanıyor..."
railway variables set \
  "ObjectStorage__Provider=local" \
  "ObjectStorage__LocalRootPath=${MOUNT_PATH}" \
  "RAILWAY_RUN_UID=0"

echo ""
echo "Tamamlandı. Son adım: API servisini redeploy edin."
echo "  railway redeploy"
echo ""
echo "Doğrulama (fotoğraf yüklendikten sonra):"
echo "  curl -I https://cardenceapi.app/uploads/users/{userId}/profile-512.jpg"
