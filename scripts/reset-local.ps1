param(
    [switch] $YaHapusData
)

$ErrorActionPreference = 'Stop'

if (-not $YaHapusData) {
    throw 'Reset dibatalkan. Gunakan -YaHapusData untuk menghapus container dan volume proyek Arzzaq.'
}

docker compose down --volumes --remove-orphans
if ($LASTEXITCODE -ne 0) { throw 'Reset Docker Compose gagal.' }

Write-Output 'Container dan volume lokal proyek Arzzaq telah dihapus. Secret lokal tidak dihapus.'
