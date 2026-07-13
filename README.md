# Arzzaq

Arzzaq adalah aplikasi manajemen zakat musiman untuk membantu DKM Masjid Al-Jihad mengelola pengumpulan, verifikasi, pencatatan, distribusi, dan pelaporan zakat secara tertib, aman, serta transparan.

Sistem dirancang aktif sekitar Ramadan dan Idulfitri, lalu infrastrukturnya dinonaktifkan setelah proses tahunan selesai. Riwayat zakat tetap dipertahankan secara aman untuk periode berikutnya.

## Status Pengembangan

Fase 0 dan Fase 1 telah selesai. Repository saat ini berada pada Fase 2: infrastruktur Docker Compose yang menyerupai production, container hardening, isolasi jaringan, healthcheck, dan quality gate image. Migration domain, autentikasi, dan UI produk belum diimplementasikan pada fase ini.

## Peran Pengguna

### Muzakki

Muzakki dapat mendaftarkan keluarga, menghitung zakat fitrah atau maal, membuat transaksi, menunjukkan QR kepada Amil, melihat status transaksi, dan membuka E-Kwitansi setelah zakat disahkan.

### Amil

Amil dapat mencatat Muzakki secara langsung, memindai QR, mengesahkan penerimaan fisik zakat, dan melihat laporan operasional sesuai kewenangannya.

### Super Admin

Super Admin mengelola akun panitia, periode dan konfigurasi zakat, koreksi data final yang tercatat secara append-only, laporan agregat, serta distribusi zakat.

## Stack yang Dikunci

- Laravel 13.19.0 dan PHP 8.4;
- Vue 3.5.39 dan TypeScript 5.9.3 dalam strict mode;
- Vite 8.1.4 dan Tailwind CSS 4.3.2;
- Node.js 24.18.0 LTS dan npm 11;
- PostgreSQL 17 dan Redis 8.2 LTS;
- Caddy 2.11 sebagai reverse proxy;
- PHPUnit, Larastan, Laravel Pint, ESLint, Vitest, dan Playwright;
- OpenAPI 3.1.2 sebagai kontrak integrasi frontend-backend.

Versi PHP dan Node dikunci melalui manifest serta lockfile. Seluruh base image container resmi dipin menggunakan tag exact dan digest SHA-256.

## Persyaratan Pengembangan Native

- PHP 8.4 beserta ekstensi standar Laravel;
- Composer 2.10.2 atau patch lebih baru yang tidak terdampak advisory keamanan;
- Node.js 24.18.0;
- npm 11.

Horizon membutuhkan `pcntl` dan `posix` pada Linux. Kedua ekstensi tersebut tidak tersedia secara native pada PHP Windows. Saat bekerja langsung di Windows, instalasi lokal dapat dilakukan dengan:

```powershell
composer install --ignore-platform-req=ext-pcntl --ignore-platform-req=ext-posix
```

Pengecualian ini hanya untuk workstation Windows. CI dan runtime Linux tetap menjalankan pemeriksaan requirement tanpa pengecualian.

Mode native tetap berguna untuk quality gate cepat. Lingkungan terintegrasi menggunakan Docker Engine 29.6.x dan Docker Compose 5.1.x.

## Bootstrap Infrastruktur Lokal

Bootstrap menghasilkan secret acak pada `docker/secrets/*.txt`, membangun image, menyalakan seluruh layanan, dan menunggu semua healthcheck lulus. File secret tersebut diabaikan Git.

PowerShell:

```powershell
.\scripts\bootstrap-local.ps1
```

Linux atau WSL:

```bash
sh scripts/bootstrap-local.sh
```

Aplikasi tersedia melalui `https://localhost`. Caddy menggunakan CA internal khusus development, sehingga browser dapat menampilkan peringatan sampai root certificate lokal dipercaya. Jangan memakai sertifikat development ini pada production.

Layanan yang dijalankan:

- Caddy sebagai satu-satunya service yang membuka port host `80/443`;
- PHP-FPM Laravel tanpa port publik;
- Reverb internal yang hanya dicapai melalui proxy WSS Caddy;
- Horizon dan scheduler dalam container terpisah;
- PostgreSQL dan Redis pada network internal tanpa published port.

Periksa status seluruh layanan dengan:

```powershell
npm.cmd run infra:health
```

Reset lokal sengaja membutuhkan konfirmasi eksplisit karena menghapus volume PostgreSQL dan Redis:

```powershell
.\scripts\reset-local.ps1 -YaHapusData
```

```bash
sh scripts/reset-local.sh --ya-hapus-data
```

Secret lokal tidak ikut dihapus agar reset container tidak merotasi credential secara tidak sengaja. Prosedur production, rotasi secret, network boundary, dan troubleshooting berada di [`docs/INFRASTRUKTUR.md`](docs/INFRASTRUKTUR.md).

## Bootstrap Repository

PowerShell:

```powershell
Copy-Item .env.example .env
composer install --ignore-platform-req=ext-pcntl --ignore-platform-req=ext-posix
npm.cmd ci
php artisan key:generate
npm.cmd run build
```

Linux atau WSL:

```bash
cp .env.example .env
composer install
npm ci
php artisan key:generate
npm run build
```

`.env.example` tidak berisi credential. Isi secret hanya pada `.env` lokal atau mekanisme secret production; jangan pernah memasukkannya ke commit.

## Menjalankan Skeleton

Gunakan dua terminal:

```powershell
php artisan serve
```

```powershell
npm.cmd run dev
```

Skeleton frontend sengaja tidak memiliki UI produk. Elemen Vue tanpa konten hanya digunakan untuk membuktikan integrasi Laravel, Vite, TypeScript, dan browser smoke test.

## Quality Gate Lokal

Backend:

```powershell
composer quality
composer audit --locked --abandoned=fail
```

Frontend dan kontrak:

```powershell
npm.cmd run quality
npm.cmd audit --audit-level=high
```

Smoke test browser pertama kali membutuhkan Chromium Playwright:

```powershell
npx.cmd playwright install chromium
npm.cmd run test:e2e
```

Perintah penting lainnya:

- `npm run openapi:lint` memvalidasi kontrak;
- `npm run openapi:types` menghasilkan type TypeScript dari OpenAPI;
- `npm run typecheck` memeriksa strict TypeScript;
- `npm run lint` menjalankan ESLint tanpa toleransi warning;
- `npm run test` menjalankan unit test frontend;
- `npm run build` membuktikan build production dapat direproduksi.
- `npm run infra:validate` memvalidasi isolasi, resource limit, healthcheck, dan hardening Compose;
- `npm run infra:health` memastikan seluruh container berjalan serta sehat.

## Kontrak API

Kontrak awal berada di [`openapi/openapi.yaml`](openapi/openapi.yaml). Seluruh endpoint aplikasi memakai prefix `/api/v1`, kecuali endpoint CSRF Sanctum dan health check framework.

Ketentuan utama kontrak:

- autentikasi SPA menggunakan cookie session Sanctum dan CSRF;
- error menggunakan RFC 9457 `application/problem+json`;
- uang dan berat dikirim sebagai decimal string, bukan JSON float;
- timestamp memakai RFC 3339 UTC dan nomor HP memakai E.164;
- operasi finansial serta administratif sensitif memakai `Idempotency-Key`;
- setiap operasi menyatakan policy tambahan melalui `x-arzzaq-policy`;
- type boundary frontend dihasilkan ke `resources/js/api/schema.d.ts` dan tidak diedit manual.

## Pemeriksaan CI

GitHub Actions menjalankan:

- validasi Composer dan requirement runtime Linux;
- Laravel Pint, Larastan level 8, dan PHPUnit;
- ESLint, strict TypeScript, Vitest, build Vite, dan Playwright;
- lint serta sinkronisasi type OpenAPI;
- audit Composer dan npm;
- pemindaian vulnerability, secret, serta misconfiguration dengan Trivy;
- pemindaian image otomatis setelah Dockerfile tersedia pada Fase 2.
- bootstrap bersih dan simulasi restart PostgreSQL, Redis, serta Horizon;
- pemindaian image aplikasi, Caddy, PostgreSQL, dan Redis.

Seluruh action eksternal dipin ke commit SHA. Dependabot hanya mengusulkan pembaruan melalui pull request agar perubahan dependency tetap melewati review dan CI.

## Struktur Utama

```text
app/                 kode backend Laravel
bootstrap/           bootstrap framework dan middleware
config/              konfigurasi aplikasi
database/            migration dan seeder domain mulai Fase 3
openapi/             kontrak API normatif
resources/js/        skeleton Vue TypeScript dan type API hasil generate
resources/views/     shell HTML minimum
routes/              route web, API, dan console
tests/               pengujian PHP dan browser
.github/             CI dan kebijakan pembaruan dependency
docker/              konfigurasi PHP-FPM, Caddy, dan template secret
scripts/             bootstrap, health check, validasi, dan reset lokal
compose.yaml         topologi development yang di-hardening
compose.production.yaml override TLS dan environment production
```

## Prinsip Pengembangan

- keamanan dan integritas data tidak dikorbankan demi kecepatan;
- aturan bisnis dan otorisasi selalu divalidasi backend;
- data pribadi dikumpulkan seminimal mungkin;
- data finansial final tidak diubah atau dihapus tanpa jejak;
- operasi kritis aman terhadap request ganda dan race condition;
- dependency exact dikunci dan pembaruannya harus lolos audit serta CI;
- UI produk dikerjakan setelah infra, database, autentikasi, dan domain stabil.

## Dokumentasi Internal

Dokumen kebutuhan, desain teknis, threat model, RBAC, kebijakan privasi, dan instruksi AI Agent berada pada folder lokal `context/`. Folder tersebut sengaja diabaikan Git karena memuat konteks operasional serta keamanan internal.

## Keamanan

Jangan memasukkan credential, token, `.env`, data jemaah, dump database, backup, private key, OTP, recovery code, PIN, raw QR token, atau dokumen internal ke repository.

Prosedur pelaporan kerentanan tersedia pada [`SECURITY.md`](SECURITY.md).

## Lisensi

Status lisensi publik belum ditetapkan. Seluruh hak atas kode dan materi proyek tetap berada pada pemilik proyek sampai dokumen lisensi resmi ditambahkan.
