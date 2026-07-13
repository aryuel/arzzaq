# Infrastruktur Arzzaq

Dokumen ini menjelaskan baseline operasional Fase 2. Infrastruktur dirancang untuk satu VPS musiman berukuran sekitar 4 vCPU dan 8 GB RAM. Konfigurasi bukan pengganti hardening host, firewall, backup, atau pengelolaan akses SSH.

## Topologi dan Trust Boundary

```text
Internet
   │ 80/443 TCP, 443 UDP
   ▼
Caddy ─────► PHP-FPM Laravel
   │              │
   └──────► Reverb│
                  ▼
        network data internal
           PostgreSQL + Redis
                  ▲
          Horizon + Scheduler
```

Hanya Caddy memiliki published port. PostgreSQL, Redis, Reverb, PHP-FPM, Horizon, dan scheduler tidak boleh diberi published port pada override deployment mana pun. Network `data` menggunakan `internal: true`. Horizon memperoleh network `egress` secara terpisah karena kelak mengirim notifikasi vendor; PostgreSQL dan Redis tidak memperoleh jalur tersebut.

## Baseline Hardening

Semua service memakai root filesystem read-only, `no-new-privileges`, `cap_drop: ALL`, PID limit, memory limit, CPU limit, log rotation, healthcheck, dan graceful stop period. Directory runtime yang harus ditulis disediakan melalui named volume atau `tmpfs`. Docker socket tidak pernah dipasang ke container.

Entrypoint aplikasi, PostgreSQL, dan Redis dimulai sebagai UID 0 dengan seluruh Linux capability dilepas, lalu hanya `DAC_READ_SEARCH`, `SETGID`, dan `SETUID` ditambahkan untuk membaca bind-mounted secret mode `0600` milik UID host dan menurunkan privilege. Entrypoint aplikasi juga memperoleh `CHOWN` sementara untuk menyerahkan pipe stdout/stderr Docker kepada UID workload agar PHP-FPM non-root tetap dapat mengirim log ke Docker. Entrypoint segera mengganti proses melalui `su-exec` ke UID workload non-root; seluruh capability bootstrap ikut hilang sebelum PHP-FPM, PostgreSQL, Redis, Reverb, Horizon, atau scheduler dijalankan. Validator Compose menolak capability tambahan lain. Pola ini menjaga secret host tidak world-readable dan tidak menaruh nilainya pada image, Compose environment, maupun command line workload.

Image resmi dipin dengan tag exact dan digest:

- PHP 8.4.23 FPM Alpine;
- Node.js 24.18.0 Alpine hanya pada build stage;
- Composer 2.10.2 hanya pada build stage;
- Caddy 2.11.4 Alpine;
- PostgreSQL 17.10 Alpine;
- Redis 8.2.7 LTS Alpine.

Binary Caddy 2.11.4 dibangun ulang dari modul upstream menggunakan Go 1.26.5 karena image resmi 2.11.4 masih membawa standard library Go yang memiliki advisori dengan perbaikan tersedia. Package Alpine pada final image diperbarui saat build dan hasil akhirnya tetap wajib lulus scan image CI.

Image PostgreSQL diturunkan dari image resmi 17.10 Alpine dan dijalankan langsung sebagai UID 70. Binary privilege-drop `gosu` dihapus karena tidak lagi diperlukan dan versi binary pada image upstream membawa standard library Go dengan advisori yang sudah memiliki perbaikan.

PHP-FPM berjalan sebagai UID/GID `10001`. Redis dan PostgreSQL memakai user non-root milik image resmi. Caddy mendengarkan port non-privileged `8080/8443` di dalam container, lalu Docker memetakan port host `80/443`.

## Secret

Secret runtime berada pada file berikut dan tidak boleh dimasukkan ke Git, image, log, atau command line:

```text
docker/secrets/app_key.txt
docker/secrets/db_password.txt
docker/secrets/redis_password.txt
docker/secrets/reverb_app_secret.txt
```

Script bootstrap menghasilkan nilai acak menggunakan CSPRNG. File `*.example` hanya penanda struktur dan tidak mengandung nilai yang dapat digunakan.

Untuk merotasi secret pada environment baru:

1. hentikan akses publik;
2. buat backup PostgreSQL yang terenkripsi dan terverifikasi;
3. ganti file secret menggunakan kanal administratif aman;
4. untuk password PostgreSQL, ubah credential database secara atomik sebelum mengganti file;
5. nyalakan ulang service yang menggunakan secret;
6. jalankan healthcheck dan smoke test;
7. cabut serta hapus nilai lama dari penyimpanan administratif.

Rotasi `APP_KEY` tidak boleh dilakukan sembarangan karena dapat membuat data terenkripsi Laravel lama tidak dapat dibaca. Rotasi membutuhkan prosedur migrasi terenkripsi tersendiri pada fase operasional.

## TLS dan Reverse Proxy

`docker/caddy/Caddyfile.local` memakai CA internal Caddy untuk development. Production wajib memakai `compose.production.yaml` dan `Caddyfile.production`, domain publik yang valid, DNS yang sudah mengarah ke VPS, serta email ACME.

Contoh validasi production:

```bash
APP_DOMAIN=zakat.contoh.id ACME_EMAIL=admin@contoh.id \
docker compose -f compose.yaml -f compose.production.yaml config --quiet
```

Contoh menjalankan production:

```bash
docker compose -f compose.yaml -f compose.production.yaml up -d --wait
```

Production mengaktifkan automatic HTTPS dan HSTS. Caddy menerapkan CSP, anti-framing, MIME sniffing protection, referrer policy, permissions policy, batas body 10 MB, serta proxy WebSocket. Seluruh query string disunting dari access log untuk melindungi signed URL; path callback Fonnte dikecualikan sepenuhnya agar token path tidak terekam. Horizon diblokir pada edge dan kelak hanya boleh tersedia melalui jalur administratif yang terautorisasi.

Alamat Caddy pada network `edge` dikunci ke `172.28.0.2`; Laravel hanya mempercayai alamat tersebut dan loopback sebagai trusted proxy. Perubahan subnet wajib disinkronkan dengan `bootstrap/app.php` dan diuji agar IP client tidak dapat dipalsukan.

## Redis dan Queue

Redis memakai autentikasi, AOF `everysec`, batas memori 512 MB, serta kebijakan `noeviction`. Kebijakan ini sengaja mencegah job queue hilang diam-diam; ketika memori penuh, write gagal secara eksplisit dan harus memicu respons operasional.

Horizon dipisahkan dari aplikasi web dengan limit CPU/memori tersendiri. Restart Redis atau Horizon harus diikuti `docker compose up -d --wait` dan `npm run infra:health`. Job domain baru pada fase berikutnya tetap wajib idempotent.

## Validasi dan Diagnosis

Validasi deklaratif:

```bash
npm run infra:validate
docker compose config --quiet
```

Status dan log:

```bash
npm run infra:health
docker compose ps
docker compose logs --tail 200 app caddy reverb horizon postgres redis scheduler
```

Simulasi restart minimum:

```bash
docker compose restart postgres redis horizon
docker compose up -d --wait
npm run infra:health
```

CI menjalankan bootstrap dari kondisi bersih, memeriksa security header, melakukan simulasi restart, dan memindai seluruh image terhadap vulnerability HIGH/CRITICAL. Deployment tidak boleh dilanjutkan jika salah satu pemeriksaan gagal tanpa risk acceptance tertulis.

## Batas Fase 2

Migration dan role database least-privilege dibuat pada Fase 3. Autentikasi, otorisasi Horizon, rate limiting endpoint, dan session security lengkap dibuat pada Fase 4. Backup terenkripsi serta restore drill production diselesaikan pada fase operasional. Keterbatasan ini bukan izin untuk membuka service internal ke publik.
