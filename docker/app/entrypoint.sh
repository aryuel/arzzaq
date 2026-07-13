#!/bin/sh
set -eu

muat_secret() {
    nama="$1"
    variabel_file="${nama}_FILE"
    eval "lokasi=\${$variabel_file:-}"

    if [ -z "$lokasi" ]; then
        return
    fi

    if [ ! -r "$lokasi" ]; then
        echo "Secret untuk $nama tidak dapat dibaca." >&2
        exit 1
    fi

    nilai="$(cat "$lokasi")"
    if [ -z "$nilai" ]; then
        echo "Secret untuk $nama tidak boleh kosong." >&2
        exit 1
    fi

    export "$nama=$nilai"
    unset "$variabel_file"
}

umask 027

for nama_secret in APP_KEY DB_PASSWORD REDIS_PASSWORD REVERB_APP_SECRET; do
    muat_secret "$nama_secret"
done

mkdir -p \
    bootstrap/cache \
    storage/app/private \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs

exec "$@"
