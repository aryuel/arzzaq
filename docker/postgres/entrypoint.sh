#!/bin/sh
set -eu

if [ ! -r "${POSTGRES_PASSWORD_FILE:-}" ]; then
    echo "Secret PostgreSQL tidak dapat dibaca." >&2
    exit 1
fi

POSTGRES_PASSWORD="$(cat "$POSTGRES_PASSWORD_FILE")"
if [ -z "$POSTGRES_PASSWORD" ]; then
    echo "Secret PostgreSQL tidak boleh kosong." >&2
    exit 1
fi

export POSTGRES_PASSWORD
unset POSTGRES_PASSWORD_FILE

exec su-exec postgres:postgres /usr/local/bin/docker-entrypoint.sh "$@"
