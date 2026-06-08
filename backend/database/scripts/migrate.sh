#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export PATH="/usr/local/share/dotnet:$HOME/.dotnet:$PATH"

cd "$BACKEND_DIR"

if ! dotnet ef --version >/dev/null 2>&1; then
  echo "Installing dotnet-ef..."
  dotnet tool install --global dotnet-ef
  export PATH="$HOME/.dotnet/tools:$PATH"
fi

echo "Applying EF Core migrations..."
dotnet ef database update \
  --project Cardence.Infrastructure \
  --startup-project Cardence.Api

echo "Migrations applied."
