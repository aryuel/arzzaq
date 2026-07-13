$ErrorActionPreference = 'Stop'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker tidak ditemukan.'
}

docker compose version | Out-Null

if (-not (Test-Path -LiteralPath '.env')) {
    Copy-Item -LiteralPath '.env.example' -Destination '.env'
}

$secretDirectory = Join-Path $PSScriptRoot '..\docker\secrets'
New-Item -ItemType Directory -Force -Path $secretDirectory | Out-Null

function New-RandomSecret([int] $Bytes = 48) {
    $buffer = New-Object byte[] $Bytes
    $generator = [Security.Cryptography.RandomNumberGenerator]::Create()

    try {
        $generator.GetBytes($buffer)
    }
    finally {
        $generator.Dispose()
    }

    return [Convert]::ToBase64String($buffer)
}

function Set-SecretIfMissing([string] $Name, [string] $Value) {
    $path = Join-Path $secretDirectory "$Name.txt"
    if (-not (Test-Path -LiteralPath $path) -or (Get-Item -LiteralPath $path).Length -eq 0) {
        Set-Content -LiteralPath $path -Value $Value -NoNewline -Encoding ascii
    }
}

Set-SecretIfMissing 'app_key' "base64:$(New-RandomSecret 32)"
Set-SecretIfMissing 'db_password' (New-RandomSecret)
Set-SecretIfMissing 'redis_password' (New-RandomSecret)
Set-SecretIfMissing 'reverb_app_secret' (New-RandomSecret)

docker compose config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Konfigurasi Docker Compose tidak valid.' }

docker compose build --pull
if ($LASTEXITCODE -ne 0) { throw 'Build image gagal.' }

docker compose up --detach --wait
if ($LASTEXITCODE -ne 0) { throw 'Layanan gagal dinyalakan.' }

node scripts/healthcheck.mjs
if ($LASTEXITCODE -ne 0) { throw 'Health check gagal.' }

Write-Output 'Arzzaq tersedia di https://localhost (sertifikat development dikelola Caddy).'
