#!/usr/bin/env bash
# Generate strong random credentials as Docker secret files under ./secrets.
# Existing files are left untouched. Files are written without a trailing newline.
#
# Usage: ./scripts/generate-secrets.sh [length]   (default length 32)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_DIR="$ROOT/secrets"
LENGTH="${1:-32}"

mkdir -p "$SECRETS_DIR"

gen_password() {
  # Cryptographically random, URL-safe alphabet, exactly $LENGTH chars.
  LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$LENGTH"
}

for name in mysql_root_password.txt mysql_password.txt; do
  path="$SECRETS_DIR/$name"
  if [[ -f "$path" ]]; then
    echo "skip   $name (already exists)"
    continue
  fi
  printf '%s' "$(gen_password)" > "$path"
  chmod 600 "$path" 2>/dev/null || true
  echo "wrote  $name"
done

echo
echo "Secret files are in $SECRETS_DIR (git-ignored)."
echo "Next: docker compose up -d"
