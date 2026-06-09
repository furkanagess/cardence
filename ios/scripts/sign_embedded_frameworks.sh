#!/bin/sh
# Archive / TestFlight öncesi App.framework ve Flutter.framework dahil
# gömülü framework'leri Runner ile aynı dağıtım sertifikasıyla imzalar.
set -e

if [ -z "${EXPANDED_CODE_SIGN_IDENTITY}" ] || [ "${EXPANDED_CODE_SIGN_IDENTITY}" = "-" ]; then
  exit 0
fi

if [ "${CODE_SIGNING_ALLOWED}" = "NO" ]; then
  exit 0
fi

if [ -n "${CODESIGNING_FOLDER_PATH}" ]; then
  APP_FRAMEWORKS_DIR="${CODESIGNING_FOLDER_PATH}/Frameworks"
else
  APP_FRAMEWORKS_DIR="${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Frameworks"
fi

if [ ! -d "${APP_FRAMEWORKS_DIR}" ]; then
  exit 0
fi

echo "Signing embedded frameworks in ${APP_FRAMEWORKS_DIR}"

sign_framework() {
  framework="$1"
  name=$(basename "${framework}" .framework)
  binary="${framework}/${name}"

  if [ -f "${binary}" ]; then
    /usr/bin/codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" \
      --preserve-metadata=identifier,entitlements,flags \
      --timestamp=none \
      "${binary}"
  fi

  /usr/bin/codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" \
    --preserve-metadata=identifier,entitlements,flags \
    --timestamp=none \
    "${framework}"
}

find "${APP_FRAMEWORKS_DIR}" -type d -name '*.framework' -print0 | while IFS= read -r -d '' framework; do
  sign_framework "${framework}"
done
