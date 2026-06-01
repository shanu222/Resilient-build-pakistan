#!/usr/bin/env bash
# Vercel build — Flutter Web (production app in mobile/)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_DIR="${FLUTTER_ROOT:-${HOME}/flutter}"
ICON_B64="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="

echo "==> ResilientBuild Pakistan — Flutter Web production build"
echo "    Root: ${ROOT}"

if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
  echo "==> Installing Flutter SDK (stable, shallow clone)..."
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
export CI=true
export PUB_CACHE="${PUB_CACHE:-${ROOT}/.pub-cache}"

flutter --version
flutter config --no-analytics --no-cli-animations
flutter precache --web

ensure_icon() {
  local target="$1"
  if [ ! -f "${target}" ]; then
    mkdir -p "$(dirname "${target}")"
    if command -v python3 >/dev/null 2>&1; then
      python3 -c "import base64, pathlib; p=pathlib.Path('${target}'); p.parent.mkdir(parents=True, exist_ok=True); p.write_bytes(base64.b64decode('${ICON_B64}'))"
    else
      echo "${ICON_B64}" | base64 -d > "${target}"
    fi
  fi
}

ensure_icon "${ROOT}/mobile/web/favicon.png"
ensure_icon "${ROOT}/mobile/web/icons/Icon-192.png"
ensure_icon "${ROOT}/mobile/web/icons/Icon-512.png"
ensure_icon "${ROOT}/mobile/web/icons/Icon-maskable-192.png"
ensure_icon "${ROOT}/mobile/web/icons/Icon-maskable-512.png"

cd "${ROOT}/mobile"
flutter pub get
flutter build web \
  --release \
  --base-href / \
  --pwa-strategy=none

echo "==> Build output: ${ROOT}/mobile/build/web"
du -sh build/web 2>/dev/null || true
ls -la build/web | head -20
