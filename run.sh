#!/bin/bash
# Loads local secrets from .env and runs the app with the right
# --dart-define flags. Never commit .env itself.
#
# Usage: ./run.sh

set -euo pipefail

if [ ! -f .env ]; then
  echo "Missing .env — copy .env.example to .env and fill in real values first."
  exit 1
fi

set -a
source .env
set +a

flutter run \
  --dart-define=APP_SHARED_SECRET="$APP_SHARED_SECRET" \
  --dart-define=PROXY_URL="$PROXY_URL"
