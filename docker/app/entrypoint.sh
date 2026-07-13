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

# Docker membuat pipe stdout/stderr sebelum entrypoint turun dari root. PHP-FPM
# membuka ulang stderr saat validasi konfigurasi, sehingga inode pipe perlu
# dimiliki workload non-root terlebih dahulu.
if [ "$(id -u)" -eq 0 ]; then
    chown arzzaq:arzzaq /proc/self/fd/1 /proc/self/fd/2
fi

for nama_secret in APP_KEY DB_PASSWORD REDIS_PASSWORD REVERB_APP_SECRET; do
    muat_secret "$nama_secret"
done

exec su-exec arzzaq:arzzaq "$@"
