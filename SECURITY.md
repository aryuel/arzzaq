# Kebijakan Keamanan

## Melaporkan Kerentanan

Jangan membuka detail kerentanan melalui issue publik. Laporkan secara pribadi kepada pemilik proyek dengan menyertakan:

- komponen dan versi yang terdampak;
- langkah reproduksi minimum menggunakan data dummy;
- dampak yang dapat terjadi;
- saran mitigasi jika tersedia.

Jangan mengakses, mengubah, mengunduh, atau menyebarkan data jemaah. Pengujian hanya boleh dilakukan pada lingkungan dan akun yang secara eksplisit diizinkan.

## Informasi yang Dilarang Masuk Repository

Credential, token, `.env`, data jemaah, dump database, backup, private key, recovery code, OTP, PIN, raw QR token, dan dokumen dalam folder `context/` tidak boleh dimasukkan ke commit, issue, artefak CI, maupun log.

## Dukungan Versi

Selama tahap pengembangan, perbaikan keamanan diterapkan pada branch aktif dan `main`. Kebijakan versi production akan ditetapkan sebelum go-live.
