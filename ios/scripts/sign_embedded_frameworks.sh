#!/bin/sh
# Eski build phase kaldırıldı. Export aşamasında Xcode tüm framework'leri
# Apple Distribution ile yeniden imzalar. Bu dosya referans amaçlı tutuluyor.
echo "sign_embedded_frameworks.sh: build phase devre dışı; export imzası kullanılıyor."
exit 0
