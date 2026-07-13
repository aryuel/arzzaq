#!/bin/sh
set -eu

if [ "${1:-}" != "--ya-hapus-data" ]; then
    echo "Reset dibatalkan. Jalankan dengan --ya-hapus-data untuk menghapus container dan volume proyek Arzzaq." >&2
    exit 1
fi

docker compose down --volumes --remove-orphans
echo "Container dan volume lokal proyek Arzzaq telah dihapus. Secret lokal tidak dihapus."
