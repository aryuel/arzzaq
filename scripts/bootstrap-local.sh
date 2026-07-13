#!/bin/sh
set -eu

command -v docker >/dev/null 2>&1 || {
    echo "Docker tidak ditemukan." >&2
    exit 1
}

docker compose version >/dev/null
command -v openssl >/dev/null 2>&1 || {
    echo "OpenSSL diperlukan untuk menghasilkan secret." >&2
    exit 1
}

if [ ! -f .env ]; then
    cp .env.example .env
fi

mkdir -p docker/secrets
umask 077

buat_secret() {
    tujuan="$1"
    if [ ! -s "$tujuan" ]; then
        openssl rand -base64 48 | tr -d '\n' > "$tujuan"
    fi
}

if [ ! -s docker/secrets/app_key.txt ]; then
    printf 'base64:' > docker/secrets/app_key.txt
    openssl rand -base64 32 | tr -d '\n' >> docker/secrets/app_key.txt
fi

buat_secret docker/secrets/db_password.txt
buat_secret docker/secrets/redis_password.txt
buat_secret docker/secrets/reverb_app_secret.txt

docker compose config --quiet
docker compose build --pull
docker compose up --detach --wait
node scripts/healthcheck.mjs

echo "Arzzaq tersedia di https://localhost (sertifikat development dikelola Caddy)."
