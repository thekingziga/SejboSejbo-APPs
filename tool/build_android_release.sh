#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [[ ! -f android/key.properties ]]; then
  echo "Missing android/key.properties; refusing to build a Play-ineligible debug-signed bundle." >&2
  exit 1
fi

for property in storeFile keyAlias storePassword keyPassword; do
  if ! grep -Eq "^${property}=.+" android/key.properties; then
    echo "android/key.properties is missing ${property}; refusing to build." >&2
    exit 1
  fi
done

keystore_path="$(sed -n 's/^storeFile=//p' android/key.properties | head -1)"
if [[ "$keystore_path" != /* ]]; then
  keystore_path="$repo_root/android/app/$keystore_path"
fi
if [[ ! -r "$keystore_path" ]]; then
  echo "Release keystore is missing or unreadable; refusing to build." >&2
  exit 1
fi

api_base_url="${API_BASE_URL:-https://sejbosejbo.fyi}"

flutter build appbundle \
  --release \
  --dart-define="API_BASE_URL=$api_base_url"

echo "Built build/app/outputs/bundle/release/app-release.aab"
