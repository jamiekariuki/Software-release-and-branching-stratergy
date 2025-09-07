#!/bin/sh
set -e

cat <<EOF > /usr/share/nginx/html/env-config.js
window._env_ = {
  VERSION: "${VERSION:-v0.0.0}"
}
EOF

exec "$@"
