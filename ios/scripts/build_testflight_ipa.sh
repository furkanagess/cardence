#!/bin/sh
# TestFlight IPA: önce dağıtım sertifikası kontrolü, sonra flutter build ipa.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
EXPORT_PLIST="${ROOT_DIR}/ios/ExportOptions.plist"

echo "==> Dağıtım sertifikası kontrol ediliyor..."
DIST_IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null \
  | sed -n 's/.*"\(Apple Distribution:.*\)".*/\1/p' | head -1 || true)"

if [ -z "${DIST_IDENTITY}" ]; then
  echo ""
  echo "HATA: Keychain'de Apple Distribution sertifikası bulunamadı."
  echo "TestFlight yüklemesi için bu sertifika zorunludur."
  echo ""
  echo "Çözüm:"
  echo "  1. Xcode > Settings > Accounts > Apple ID > Manage Certificates"
  echo "  2. Sol alttaki '+' > Apple Distribution"
  echo "  3. Veya developer.apple.com > Certificates > Apple Distribution oluşturup .cer dosyasını çift tıklayın"
  echo "  4. Xcode > Settings > Accounts > Download Manual Profiles"
  echo ""
  exit 1
fi

echo "    Bulundu: ${DIST_IDENTITY}"
echo ""
echo "==> Temiz release build başlatılıyor..."
cd "${ROOT_DIR}"
flutter clean
flutter pub get
(cd ios && pod install)

flutter build ipa --release --export-options-plist="${EXPORT_PLIST}"

IPA_PATH="$(find "${ROOT_DIR}/build/ios/ipa" -maxdepth 1 -name '*.ipa' -print -quit)"
if [ -z "${IPA_PATH}" ]; then
  echo "HATA: IPA oluşturulamadı."
  exit 1
fi

echo ""
echo "==> IPA imzası doğrulanıyor: ${IPA_PATH}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT
unzip -q "${IPA_PATH}" -d "${TMP_DIR}"
APP="${TMP_DIR}/Payload/Runner.app"

for target in \
  "${APP}/Frameworks/App.framework/App" \
  "${APP}/Frameworks/Flutter.framework/Flutter" \
  "${APP}/Frameworks/objective_c.framework/objective_c" \
  "${APP}/Runner"; do
  name="$(basename "${target}")"
  auth="$(codesign -dvv "${target}" 2>&1 | sed -n 's/^Authority=//p' | head -1)"
  if ! echo "${auth}" | grep -q "Apple Distribution"; then
    echo "HATA: ${name} Apple Distribution ile imzalanmamış (${auth})."
    exit 1
  fi
  echo "    OK ${name}: ${auth}"
done

echo ""
echo "Başarılı. Transporter ile yükleyin:"
echo "  ${IPA_PATH}"
