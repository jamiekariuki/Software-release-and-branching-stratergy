#!/bin/sh

cat <<EOF > /usr/share/nginx/html/env-config.js
window._env_ = {
  VERSION: "${VERSION}"
}
EOF

exec "$@"
