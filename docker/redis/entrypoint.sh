#!/bin/sh
set -eu

if [ ! -r "${REDIS_PASSWORD_FILE:-}" ]; then
    echo "Secret Redis tidak dapat dibaca." >&2
    exit 1
fi

redis_password="$(cat "$REDIS_PASSWORD_FILE")"
if [ -z "$redis_password" ]; then
    echo "Secret Redis tidak boleh kosong." >&2
    exit 1
fi

exec su-exec redis:redis redis-server - <<EOF
appendonly yes
appendfsync everysec
maxmemory 512mb
maxmemory-policy noeviction
requirepass $redis_password
EOF
