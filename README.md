# Arzzaq

Arzzaq adalah aplikasi manajemen zakat musiman untuk membantu DKM Masjid Al-Jihad mengelola proses pengumpulan, verifikasi, pencatatan, dan pelaporan zakat secara tertib, aman, serta transparan.

## Tentang Proyek

Arzzaq dirancang untuk melayani jemaah, panitia zakat, dan pengurus DKM dalam satu sistem dengan pembagian kewenangan yang jelas. Sistem beroperasi pada periode sekitar Ramadan dan Idulfitri, kemudian infrastrukturnya dinonaktifkan setelah seluruh proses tahunan selesai. Riwayat zakat tetap dipertahankan secara aman untuk periode berikutnya.

Fokus utama proyek ini meliputi:

- kemudahan penggunaan melalui antarmuka yang responsif dan ramah perangkat seluler;
- perlindungan data pribadi jemaah melalui prinsip minimalisasi data;
- integritas pencatatan penerimaan dan penyaluran zakat;
- pemisahan kewenangan antara Muzakki, Amil, dan Super Admin;
- verifikasi penyerahan zakat melalui QR internal;
- transparansi berbasis data agregat tanpa membuka informasi finansial individual;
- kesiapan operasional untuk proses penyediaan dan penonaktifan sistem setiap tahun.

## Peran Pengguna

### Muzakki

Muzakki dapat mendaftarkan keluarga, menghitung zakat fitrah atau zakat maal, membuat transaksi, menunjukkan QR kepada Amil, melihat status transaksi, dan membuka E-Kwitansi setelah zakat disahkan.

### Amil

Amil dapat mencatat Muzakki secara langsung, memindai dan memverifikasi QR, mengesahkan penerimaan fisik zakat, serta melihat laporan operasional sesuai kewenangannya.

### Super Admin

Super Admin mengelola akun panitia, konfigurasi zakat tahunan, laporan agregat, dan pencatatan penyaluran zakat.

## Teknologi Utama

- Vue 3 dan Vite untuk aplikasi web;
- Tailwind CSS untuk sistem tampilan;
- Laravel sebagai backend API;
- PostgreSQL sebagai basis data utama;
- Redis, Laravel Horizon, dan Laravel Reverb untuk antrean pekerjaan serta pembaruan waktu nyata;
- Docker Compose untuk lingkungan pengembangan dan produksi;
- PWA agar aplikasi nyaman digunakan melalui perangkat seluler.

## Prinsip Pengembangan

Pengembangan Arzzaq mengikuti prinsip berikut:

- keamanan dan integritas data tidak boleh dikorbankan demi kecepatan implementasi;
- aturan bisnis dan otorisasi selalu divalidasi oleh backend;
- data pribadi yang tidak dibutuhkan tidak dikumpulkan;
- perubahan data finansial harus memiliki jejak audit;
- operasi kritis harus aman terhadap permintaan ganda dan kondisi balapan;
- kode, pengujian, migrasi basis data, dan dokumentasi harus tetap sinkron;
- fitur dibangun berdasarkan kebutuhan nyata dan tidak diperluas tanpa keputusan yang jelas.

## Status Pengembangan

Proyek sedang berada pada tahap persiapan implementasi. Kebutuhan produk, desain teknis, alur pengguna, keamanan, basis data, serta prosedur operasional telah disusun sebagai acuan pengembangan internal.

## Dokumentasi Internal

Dokumen kebutuhan produk, desain teknis, kebijakan privasi, dan instruksi kerja pengembang dikelola secara lokal di luar riwayat Git publik. Dokumen tersebut sengaja tidak disertakan dalam repository ini karena memuat konteks operasional dan keamanan internal.

## Keamanan

Jangan memasukkan credential, token, berkas `.env`, data jemaah, salinan basis data, backup, atau dokumen operasional internal ke repository.

Temuan keamanan sebaiknya dilaporkan secara pribadi kepada pengelola proyek dan tidak dibuka melalui laporan publik sebelum tersedia mitigasi.

## Lisensi

Status lisensi proyek belum ditetapkan. Seluruh hak atas kode dan materi proyek tetap berada pada pemilik proyek sampai dokumen lisensi resmi ditambahkan.
